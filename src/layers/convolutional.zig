//! Convolution, lowered to GEMM via im2col.
//!
//! Dropped relative to darknet: binary/XNOR weights and the deconvolution
//! path. Neither is used by any classification config, and both carried a lot
//! of machinery. Grouped convolution is kept, because ResNeXt configs need it.

const std = @import("std");
const lay = @import("../layer.zig");
const blas = @import("../blas.zig");
const gemm_mod = @import("../gemm.zig");
const im2col_mod = @import("../im2col.zig");
const activations = @import("../activations.zig");
const batchnorm = @import("batchnorm.zig");
const utils = @import("../utils.zig");
const gpu = @import("../gpu.zig");

const Layer = lay.Layer;
const State = lay.State;
const gemm = gemm_mod.gemm;

pub fn outHeight(l: Layer) usize {
    return (l.h + 2 * l.pad - l.size) / l.stride + 1;
}

pub fn outWidth(l: Layer) usize {
    return (l.w + 2 * l.pad - l.size) / l.stride + 1;
}

fn workspaceSize(l: Layer) usize {
    // The im2col buffer: one column per output position, one row per weight
    // within a filter.
    return l.out_h * l.out_w * l.size * l.size * l.c / l.groups;
}

pub fn make(
    allocator: std.mem.Allocator,
    batch: usize,
    h: usize,
    w: usize,
    c: usize,
    n: usize,
    groups: usize,
    size: usize,
    stride: usize,
    padding: usize,
    activation: activations.Activation,
    batch_normalize: bool,
    adam: bool,
) !Layer {
    var l: Layer = .{ .kind = .convolutional };
    l.groups = groups;
    l.h = h;
    l.w = w;
    l.c = c;
    l.n = n;
    l.batch = batch;
    l.stride = stride;
    l.size = size;
    l.pad = padding;
    l.batch_normalize = batch_normalize;
    l.activation = activation;
    l.adam = adam;
    l.learning_rate_scale = 1;

    l.nweights = c / groups * n * size * size;
    l.nbiases = n;

    l.weights = try lay.zeros(allocator, l.nweights);
    l.weight_updates = try lay.zeros(allocator, l.nweights);
    l.biases = try lay.zeros(allocator, n);
    l.bias_updates = try lay.zeros(allocator, n);

    // He initialisation, as in darknet: sqrt(2 / fan_in) with fan_in counted
    // over the receptive field of one filter.
    const fan_in: f32 = @floatFromInt(size * size * c / groups);
    const scale = @sqrt(2.0 / fan_in);
    for (l.weights) |*v| v.* = scale * utils.default.normal();

    l.out_h = outHeight(l);
    l.out_w = outWidth(l);
    l.out_c = n;
    l.outputs = l.out_h * l.out_w * l.out_c;
    l.inputs = l.w * l.h * l.c;

    l.output = try lay.zeros(allocator, batch * l.outputs);
    l.delta = try lay.zeros(allocator, batch * l.outputs);

    if (batch_normalize) {
        l.scales = try lay.zeros(allocator, n);
        l.scale_updates = try lay.zeros(allocator, n);
        @memset(l.scales, 1);

        l.mean = try lay.zeros(allocator, n);
        l.variance = try lay.zeros(allocator, n);
        l.mean_delta = try lay.zeros(allocator, n);
        l.variance_delta = try lay.zeros(allocator, n);
        l.rolling_mean = try lay.zeros(allocator, n);
        l.rolling_variance = try lay.zeros(allocator, n);
        l.x = try lay.zeros(allocator, batch * l.outputs);
        l.x_norm = try lay.zeros(allocator, batch * l.outputs);
    }

    if (adam) {
        l.m = try lay.zeros(allocator, l.nweights);
        l.v = try lay.zeros(allocator, l.nweights);
        l.bias_m = try lay.zeros(allocator, n);
        l.bias_v = try lay.zeros(allocator, n);
        l.scale_m = try lay.zeros(allocator, n);
        l.scale_v = try lay.zeros(allocator, n);
    }

    if (gpu.active()) {
        l.gpu.weights = gpu.make(l.weights);
        l.gpu.weight_updates = gpu.alloc(l.nweights);
        l.gpu.biases = gpu.make(l.biases);
        l.gpu.bias_updates = gpu.alloc(n);
        l.gpu.output = gpu.alloc(batch * l.outputs);
        l.gpu.delta = gpu.alloc(batch * l.outputs);
        if (batch_normalize) try batchnorm.allocDevice(&l, n, batch * l.outputs);
        if (adam) {
            l.gpu.m = gpu.alloc(l.nweights);
            l.gpu.v = gpu.alloc(l.nweights);
            l.gpu.bias_m = gpu.alloc(n);
            l.gpu.bias_v = gpu.alloc(n);
            l.gpu.scale_m = gpu.alloc(n);
            l.gpu.scale_v = gpu.alloc(n);
        }
    }

    l.workspace_size = workspaceSize(l);

    const bflops = (2.0 * @as(f64, @floatFromInt(l.n * l.size * l.size * l.c / l.groups * l.out_h * l.out_w))) / 1e9;
    std.debug.print("conv  {d:5} {d:2} x{d:2} /{d:2}  {d:4} x{d:4} x{d:4}   ->  {d:4} x{d:4} x{d:4}  {d:5.3} BFLOPs\n", .{
        n, size, size, stride, w, h, c, l.out_w, l.out_h, l.out_c, bflops,
    });
    return l;
}

// ---------------------------------------------------------------------------
// CPU
// ---------------------------------------------------------------------------

pub fn forward(l: *Layer, state: *State) void {
    const total = l.outputs * l.batch;
    blas.fill(l.output[0..total], 0);

    const m = l.n / l.groups;
    const k = l.size * l.size * l.c / l.groups;
    const n = l.out_w * l.out_h;
    const in_group = l.c / l.groups * l.h * l.w;
    const wgroup = l.nweights / l.groups;

    for (0..l.batch) |i| {
        for (0..l.groups) |j| {
            const a = l.weights[j * wgroup ..];
            const c_out = l.output[(i * l.groups + j) * n * m ..];
            const im = state.input[(i * l.groups + j) * in_group ..];

            const b = if (l.size == 1) im else blk: {
                im2col_mod.im2col(im, l.c / l.groups, l.h, l.w, l.size, l.stride, l.pad, state.workspace);
                break :blk state.workspace;
            };
            gemm(false, false, m, n, k, 1, a, k, b, n, 1, c_out, n);
        }
    }

    if (l.batch_normalize) {
        batchnorm.forward(l, state);
    } else {
        blas.addBias(l.output[0..total], l.biases, l.batch, l.n, l.out_h * l.out_w);
    }

    activations.activateArray(l.output[0..total], l.activation);
}

pub fn backward(l: *Layer, state: *State) void {
    const total = l.outputs * l.batch;
    const m = l.n / l.groups;
    const n = l.size * l.size * l.c / l.groups;
    const k = l.out_w * l.out_h;
    const in_group = l.c / l.groups * l.h * l.w;
    const wgroup = l.nweights / l.groups;

    activations.gradientArray(l.output[0..total], l.activation, l.delta[0..total]);

    if (l.batch_normalize) {
        batchnorm.backward(l, state);
    } else {
        blas.backwardBias(l.bias_updates, l.delta[0..total], l.batch, l.n, k);
    }

    for (0..l.batch) |i| {
        for (0..l.groups) |j| {
            const delta_slice = l.delta[(i * l.groups + j) * m * k ..];
            const im = state.input[(i * l.groups + j) * in_group ..];

            // dL/dW = delta * col(input)^T
            const b = if (l.size == 1) im else blk: {
                im2col_mod.im2col(im, l.c / l.groups, l.h, l.w, l.size, l.stride, l.pad, state.workspace);
                break :blk state.workspace;
            };
            gemm(false, true, m, n, k, 1, delta_slice, k, b, k, 1, l.weight_updates[j * wgroup ..], n);

            // dL/dX = W^T * delta, scattered back through col2im.
            if (state.delta.len != 0) {
                const imd = state.delta[(i * l.groups + j) * in_group ..];
                const dst = if (l.size == 1) imd else state.workspace;
                gemm(true, false, n, k, m, 1, l.weights[j * wgroup ..], n, delta_slice, k, 0, dst, k);
                if (l.size != 1) {
                    im2col_mod.col2im(state.workspace, l.c / l.groups, l.h, l.w, l.size, l.stride, l.pad, imd);
                }
            }
        }
    }
}

pub fn update(l: *Layer, a: lay.UpdateArgs) void {
    const learning_rate = a.learning_rate * l.learning_rate_scale;
    const batch: f32 = @floatFromInt(a.batch);

    blas.axpy(learning_rate / batch, l.bias_updates, l.biases);
    blas.scal(a.momentum, l.bias_updates);

    if (l.scales.len != 0) {
        blas.axpy(learning_rate / batch, l.scale_updates, l.scales);
        blas.scal(a.momentum, l.scale_updates);
    }

    // Weight decay folded into the update: gradient += -decay*batch*w.
    blas.axpy(-a.decay * batch, l.weights, l.weight_updates);
    blas.axpy(learning_rate / batch, l.weight_updates, l.weights);
    blas.scal(a.momentum, l.weight_updates);
}

// ---------------------------------------------------------------------------
// GPU
// ---------------------------------------------------------------------------

pub fn forwardGpu(l: *Layer, state: *State) void {
    const total = l.outputs * l.batch;
    gpu.fill(l.gpu.output, total, 0);

    const m = l.n / l.groups;
    const k = l.size * l.size * l.c / l.groups;
    const n = l.out_w * l.out_h;
    const in_group = l.c / l.groups * l.h * l.w;
    const wgroup = l.nweights / l.groups;

    for (0..l.batch) |i| {
        for (0..l.groups) |j| {
            const a = l.gpu.weights.offset(j * wgroup);
            const c_out = l.gpu.output.offset((i * l.groups + j) * n * m);
            const im = state.input_gpu.offset((i * l.groups + j) * in_group);

            const b = if (l.size == 1) im else blk: {
                gpu.im2col(im, l.c / l.groups, l.h, l.w, l.size, l.stride, l.pad, state.workspace_gpu);
                break :blk state.workspace_gpu;
            };
            gpu.gemm(false, false, m, n, k, 1, a, k, b, n, 1, c_out, n);
        }
    }

    if (l.batch_normalize) {
        batchnorm.forwardGpu(l, state);
    } else {
        gpu.addBias(l.gpu.output, l.gpu.biases, l.batch, l.n, l.out_h * l.out_w);
    }

    gpu.activateArray(l.gpu.output, total, @intFromEnum(l.activation));
}

pub fn backwardGpu(l: *Layer, state: *State) void {
    const total = l.outputs * l.batch;
    const m = l.n / l.groups;
    const n = l.size * l.size * l.c / l.groups;
    const k = l.out_w * l.out_h;
    const in_group = l.c / l.groups * l.h * l.w;
    const wgroup = l.nweights / l.groups;

    gpu.gradientArray(l.gpu.output, total, @intFromEnum(l.activation), l.gpu.delta);

    if (l.batch_normalize) {
        batchnorm.backwardGpu(l, state);
    } else {
        gpu.backwardBias(l.gpu.bias_updates, l.gpu.delta, l.batch, l.n, k);
    }

    for (0..l.batch) |i| {
        for (0..l.groups) |j| {
            const delta_slice = l.gpu.delta.offset((i * l.groups + j) * m * k);
            const im = state.input_gpu.offset((i * l.groups + j) * in_group);

            const b = if (l.size == 1) im else blk: {
                gpu.im2col(im, l.c / l.groups, l.h, l.w, l.size, l.stride, l.pad, state.workspace_gpu);
                break :blk state.workspace_gpu;
            };
            gpu.gemm(false, true, m, n, k, 1, delta_slice, k, b, k, 1, l.gpu.weight_updates.offset(j * wgroup), n);

            if (!state.delta_gpu.isNull()) {
                const imd = state.delta_gpu.offset((i * l.groups + j) * in_group);
                const dst = if (l.size == 1) imd else state.workspace_gpu;
                gpu.gemm(true, false, n, k, m, 1, l.gpu.weights.offset(j * wgroup), n, delta_slice, k, 0, dst, k);
                if (l.size != 1) {
                    gpu.col2im(state.workspace_gpu, l.c / l.groups, l.h, l.w, l.size, l.stride, l.pad, imd);
                }
            }
        }
    }
}

pub fn updateGpu(l: *Layer, a: lay.UpdateArgs) void {
    const learning_rate = a.learning_rate * l.learning_rate_scale;
    const batch: f32 = @floatFromInt(a.batch);

    if (a.adam) {
        gpu.adamUpdate(l.gpu.weights, l.gpu.weight_updates, l.gpu.m, l.gpu.v, a.b1, a.b2, a.eps, a.decay, learning_rate, l.nweights, a.batch, a.t);
        gpu.adamUpdate(l.gpu.biases, l.gpu.bias_updates, l.gpu.bias_m, l.gpu.bias_v, a.b1, a.b2, a.eps, a.decay, learning_rate, l.n, a.batch, a.t);
        if (!l.gpu.scales.isNull()) {
            gpu.adamUpdate(l.gpu.scales, l.gpu.scale_updates, l.gpu.scale_m, l.gpu.scale_v, a.b1, a.b2, a.eps, a.decay, learning_rate, l.n, a.batch, a.t);
        }
        return;
    }

    gpu.axpy(l.n, learning_rate / batch, l.gpu.bias_updates, l.gpu.biases);
    gpu.scal(l.n, a.momentum, l.gpu.bias_updates);

    if (!l.gpu.scales.isNull()) {
        gpu.axpy(l.n, learning_rate / batch, l.gpu.scale_updates, l.gpu.scales);
        gpu.scal(l.n, a.momentum, l.gpu.scale_updates);
    }

    gpu.axpy(l.nweights, -a.decay * batch, l.gpu.weights, l.gpu.weight_updates);
    gpu.axpy(l.nweights, learning_rate / batch, l.gpu.weight_updates, l.gpu.weights);
    gpu.scal(l.nweights, a.momentum, l.gpu.weight_updates);
}

pub fn pull(l: *Layer) void {
    gpu.pull(l.gpu.weights, l.weights);
    gpu.pull(l.gpu.biases, l.biases);
    gpu.pull(l.gpu.weight_updates, l.weight_updates);
    gpu.pull(l.gpu.bias_updates, l.bias_updates);
    if (l.batch_normalize) {
        gpu.pull(l.gpu.scales, l.scales);
        gpu.pull(l.gpu.rolling_mean, l.rolling_mean);
        gpu.pull(l.gpu.rolling_variance, l.rolling_variance);
    }
}

pub fn push(l: *Layer) void {
    gpu.push(l.gpu.weights, l.weights);
    gpu.push(l.gpu.biases, l.biases);
    gpu.push(l.gpu.weight_updates, l.weight_updates);
    gpu.push(l.gpu.bias_updates, l.bias_updates);
    if (l.batch_normalize) {
        gpu.push(l.gpu.scales, l.scales);
        gpu.push(l.gpu.rolling_mean, l.rolling_mean);
        gpu.push(l.gpu.rolling_variance, l.rolling_variance);
    }
}
