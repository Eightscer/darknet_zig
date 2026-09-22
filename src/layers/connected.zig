//! Fully connected layer. A convolution with a 1x1 spatial extent, but darknet
//! keeps it separate because the GEMM shapes and the weight layout differ, and
//! the .weights file format depends on that layout.

const std = @import("std");
const lay = @import("../layer.zig");
const blas = @import("../blas.zig");
const gemm_mod = @import("../gemm.zig");
const activations = @import("../activations.zig");
const batchnorm = @import("batchnorm.zig");
const utils = @import("../utils.zig");
const gpu = @import("../gpu.zig");

const Layer = lay.Layer;
const State = lay.State;
const gemm = gemm_mod.gemm;

pub fn make(
    allocator: std.mem.Allocator,
    batch: usize,
    inputs: usize,
    outputs: usize,
    activation: activations.Activation,
    batch_normalize: bool,
    adam: bool,
) !Layer {
    var l: Layer = .{ .kind = .connected };
    l.learning_rate_scale = 1;
    l.inputs = inputs;
    l.outputs = outputs;
    l.batch = batch;
    l.batch_normalize = batch_normalize;
    l.activation = activation;
    l.adam = adam;
    l.h = 1;
    l.w = 1;
    l.c = inputs;
    l.out_h = 1;
    l.out_w = 1;
    l.out_c = outputs;
    l.n = outputs;
    l.nweights = inputs * outputs;
    l.nbiases = outputs;

    l.output = try lay.zeros(allocator, batch * outputs);
    l.delta = try lay.zeros(allocator, batch * outputs);
    l.weights = try lay.zeros(allocator, inputs * outputs);
    l.weight_updates = try lay.zeros(allocator, inputs * outputs);
    l.biases = try lay.zeros(allocator, outputs);
    l.bias_updates = try lay.zeros(allocator, outputs);

    // Uniform rather than normal here, matching darknet; the two layer types
    // genuinely disagree about this upstream.
    const scale = @sqrt(2.0 / @as(f32, @floatFromInt(inputs)));
    for (l.weights) |*v| v.* = scale * utils.default.uniform(-1, 1);

    if (adam) {
        l.m = try lay.zeros(allocator, inputs * outputs);
        l.v = try lay.zeros(allocator, inputs * outputs);
        l.bias_m = try lay.zeros(allocator, outputs);
        l.bias_v = try lay.zeros(allocator, outputs);
        l.scale_m = try lay.zeros(allocator, outputs);
        l.scale_v = try lay.zeros(allocator, outputs);
    }

    if (batch_normalize) {
        l.scales = try lay.zeros(allocator, outputs);
        l.scale_updates = try lay.zeros(allocator, outputs);
        @memset(l.scales, 1);
        l.mean = try lay.zeros(allocator, outputs);
        l.mean_delta = try lay.zeros(allocator, outputs);
        l.variance = try lay.zeros(allocator, outputs);
        l.variance_delta = try lay.zeros(allocator, outputs);
        l.rolling_mean = try lay.zeros(allocator, outputs);
        l.rolling_variance = try lay.zeros(allocator, outputs);
        l.x = try lay.zeros(allocator, batch * outputs);
        l.x_norm = try lay.zeros(allocator, batch * outputs);
    }

    if (gpu.active()) {
        l.gpu.weights = gpu.make(l.weights);
        l.gpu.weight_updates = gpu.alloc(inputs * outputs);
        l.gpu.biases = gpu.make(l.biases);
        l.gpu.bias_updates = gpu.alloc(outputs);
        l.gpu.output = gpu.alloc(batch * outputs);
        l.gpu.delta = gpu.alloc(batch * outputs);
        if (batch_normalize) try batchnorm.allocDevice(&l, outputs, batch * outputs);
        if (adam) {
            l.gpu.m = gpu.alloc(inputs * outputs);
            l.gpu.v = gpu.alloc(inputs * outputs);
            l.gpu.bias_m = gpu.alloc(outputs);
            l.gpu.bias_v = gpu.alloc(outputs);
            l.gpu.scale_m = gpu.alloc(outputs);
            l.gpu.scale_v = gpu.alloc(outputs);
        }
    }

    std.debug.print("connected                            {d:4}  ->  {d:4}\n", .{ inputs, outputs });
    return l;
}

// ---------------------------------------------------------------------------
// CPU
// ---------------------------------------------------------------------------

pub fn forward(l: *Layer, state: *State) void {
    const total = l.outputs * l.batch;
    blas.fill(l.output[0..total], 0);

    // out[batch x outputs] = in[batch x inputs] * W[outputs x inputs]^T
    gemm(false, true, l.batch, l.outputs, l.inputs, 1, state.input, l.inputs, l.weights, l.inputs, 1, l.output, l.outputs);

    if (l.batch_normalize) {
        batchnorm.forward(l, state);
    } else {
        blas.addBias(l.output[0..total], l.biases, l.batch, l.outputs, 1);
    }
    activations.activateArray(l.output[0..total], l.activation);
}

pub fn backward(l: *Layer, state: *State) void {
    const total = l.outputs * l.batch;
    activations.gradientArray(l.output[0..total], l.activation, l.delta[0..total]);

    if (l.batch_normalize) {
        batchnorm.backward(l, state);
    } else {
        blas.backwardBias(l.bias_updates, l.delta[0..total], l.batch, l.outputs, 1);
    }

    // dW[outputs x inputs] = delta^T * in
    gemm(true, false, l.outputs, l.inputs, l.batch, 1, l.delta, l.outputs, state.input, l.inputs, 1, l.weight_updates, l.inputs);

    // dX[batch x inputs] = delta * W
    if (state.delta.len != 0) {
        gemm(false, false, l.batch, l.inputs, l.outputs, 1, l.delta, l.outputs, l.weights, l.inputs, 1, state.delta, l.inputs);
    }
}

pub fn update(l: *Layer, a: lay.UpdateArgs) void {
    const learning_rate = a.learning_rate * l.learning_rate_scale;
    const batch: f32 = @floatFromInt(a.batch);

    blas.axpy(learning_rate / batch, l.bias_updates, l.biases);
    blas.scal(a.momentum, l.bias_updates);

    if (l.batch_normalize) {
        blas.axpy(learning_rate / batch, l.scale_updates, l.scales);
        blas.scal(a.momentum, l.scale_updates);
    }

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
    gpu.gemm(false, true, l.batch, l.outputs, l.inputs, 1, state.input_gpu, l.inputs, l.gpu.weights, l.inputs, 1, l.gpu.output, l.outputs);

    if (l.batch_normalize) {
        batchnorm.forwardGpu(l, state);
    } else {
        gpu.addBias(l.gpu.output, l.gpu.biases, l.batch, l.outputs, 1);
    }
    gpu.activateArray(l.gpu.output, total, @intFromEnum(l.activation));
}

pub fn backwardGpu(l: *Layer, state: *State) void {
    const total = l.outputs * l.batch;
    // darknet clamps the incoming delta of connected layers only; keeping the
    // asymmetry so GPU and upstream agree.
    gpu.constrainArray(total, 1, l.gpu.delta);
    gpu.gradientArray(l.gpu.output, total, @intFromEnum(l.activation), l.gpu.delta);

    if (l.batch_normalize) {
        batchnorm.backwardGpu(l, state);
    } else {
        gpu.backwardBias(l.gpu.bias_updates, l.gpu.delta, l.batch, l.outputs, 1);
    }

    gpu.gemm(true, false, l.outputs, l.inputs, l.batch, 1, l.gpu.delta, l.outputs, state.input_gpu, l.inputs, 1, l.gpu.weight_updates, l.inputs);

    if (!state.delta_gpu.isNull()) {
        gpu.gemm(false, false, l.batch, l.inputs, l.outputs, 1, l.gpu.delta, l.outputs, l.gpu.weights, l.inputs, 1, state.delta_gpu, l.inputs);
    }
}

pub fn updateGpu(l: *Layer, a: lay.UpdateArgs) void {
    const learning_rate = a.learning_rate * l.learning_rate_scale;
    const batch: f32 = @floatFromInt(a.batch);

    if (a.adam) {
        gpu.adamUpdate(l.gpu.weights, l.gpu.weight_updates, l.gpu.m, l.gpu.v, a.b1, a.b2, a.eps, a.decay, learning_rate, l.inputs * l.outputs, a.batch, a.t);
        gpu.adamUpdate(l.gpu.biases, l.gpu.bias_updates, l.gpu.bias_m, l.gpu.bias_v, a.b1, a.b2, a.eps, a.decay, learning_rate, l.outputs, a.batch, a.t);
        if (!l.gpu.scales.isNull()) {
            gpu.adamUpdate(l.gpu.scales, l.gpu.scale_updates, l.gpu.scale_m, l.gpu.scale_v, a.b1, a.b2, a.eps, a.decay, learning_rate, l.outputs, a.batch, a.t);
        }
        return;
    }

    gpu.axpy(l.outputs, learning_rate / batch, l.gpu.bias_updates, l.gpu.biases);
    gpu.scal(l.outputs, a.momentum, l.gpu.bias_updates);

    if (l.batch_normalize) {
        gpu.axpy(l.outputs, learning_rate / batch, l.gpu.scale_updates, l.gpu.scales);
        gpu.scal(l.outputs, a.momentum, l.gpu.scale_updates);
    }

    gpu.axpy(l.inputs * l.outputs, -a.decay * batch, l.gpu.weights, l.gpu.weight_updates);
    gpu.axpy(l.inputs * l.outputs, learning_rate / batch, l.gpu.weight_updates, l.gpu.weights);
    gpu.scal(l.inputs * l.outputs, a.momentum, l.gpu.weight_updates);
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
