//! The remaining layer types: softmax, dropout, cost, shortcut and route.
//! Each is short enough that splitting them into separate files would cost
//! more in boilerplate than it bought in navigation.

const std = @import("std");
const lay = @import("../layer.zig");
const blas = @import("../blas.zig");
const utils = @import("../utils.zig");
const activations = @import("../activations.zig");
const gpu = @import("../gpu.zig");

const Layer = lay.Layer;
const State = lay.State;

// ===========================================================================
// softmax
// ===========================================================================

pub fn makeSoftmax(allocator: std.mem.Allocator, batch: usize, inputs: usize, groups: usize) !Layer {
    std.debug.assert(inputs % groups == 0);
    std.debug.print("softmax                                        {d:4}\n", .{inputs});
    var l: Layer = .{ .kind = .softmax };
    l.batch = batch;
    l.softmax_groups = groups;
    l.inputs = inputs;
    l.outputs = inputs;
    l.has_cost = true;

    l.loss = try lay.zeros(allocator, inputs * batch);
    l.output = try lay.zeros(allocator, inputs * batch);
    l.delta = try lay.zeros(allocator, inputs * batch);

    if (gpu.active()) {
        l.gpu.output = gpu.alloc(inputs * batch);
        l.gpu.loss = gpu.alloc(inputs * batch);
        l.gpu.delta = gpu.alloc(inputs * batch);
    }
    return l;
}

pub fn forwardSoftmax(l: *Layer, state: *State) void {
    const per_group = l.inputs / l.softmax_groups;
    blas.softmax(state.input, per_group, l.batch, l.inputs, l.softmax_groups, per_group, 1, l.temperature, l.output);

    if (state.truth.len != 0 and !l.noloss) {
        const n = l.batch * l.inputs;
        blas.softmaxCrossEntropy(l.output[0..n], state.truth, l.delta, l.loss);
        l.cost = utils.sumArray(l.loss[0..n]);
    }
}

/// Because `delta` here is already dL/d(logits), backprop into the previous
/// layer is a plain accumulate.
pub fn backwardSoftmax(l: *Layer, state: *State) void {
    if (state.delta.len == 0) return;
    blas.axpy(1, l.delta[0 .. l.inputs * l.batch], state.delta);
}

pub fn forwardSoftmaxGpu(l: *Layer, state: *State) void {
    const per_group = l.inputs / l.softmax_groups;
    gpu.softmax(state.input_gpu, per_group, l.batch, l.inputs, l.softmax_groups, per_group, 1, l.temperature, l.gpu.output);

    if (!state.truth_gpu.isNull() and !l.noloss) {
        const n = l.batch * l.inputs;
        gpu.softmaxCrossEntropy(n, l.gpu.output, state.truth_gpu, l.gpu.delta, l.gpu.loss);
        // The per-element losses come back to the host to be summed, exactly
        // as darknet did; a device-side reduction would save one transfer of
        // batch*classes floats per step, which is noise next to the GEMMs.
        gpu.pull(l.gpu.loss, l.loss[0..n]);
        l.cost = utils.sumArray(l.loss[0..n]);
    }
}

pub fn backwardSoftmaxGpu(l: *Layer, state: *State) void {
    if (state.delta_gpu.isNull()) return;
    gpu.axpy(l.batch * l.inputs, 1, l.gpu.delta, state.delta_gpu);
}

// ===========================================================================
// dropout
// ===========================================================================

/// Dropout has no buffers of its own: it perturbs the previous layer's output
/// in place and aliases that layer's output/delta so the network loop can
/// treat it uniformly. `owns_output` is false to keep the aliased slices from
/// being freed twice.
pub fn makeDropout(allocator: std.mem.Allocator, batch: usize, inputs: usize, probability: f32) !Layer {
    var l: Layer = .{ .kind = .dropout };
    l.probability = probability;
    l.inputs = inputs;
    l.outputs = inputs;
    l.batch = batch;
    l.rand = try lay.zeros(allocator, inputs * batch);
    // Inverted dropout: surviving activations are scaled up so the expected
    // value is unchanged and inference needs no adjustment.
    l.scale = 1.0 / (1.0 - probability);
    l.owns_output = false;

    if (gpu.active()) l.gpu.rand = gpu.alloc(inputs * batch);

    std.debug.print("dropout       p = {d:.2}               {d:4}  ->  {d:4}\n", .{ probability, inputs, inputs });
    return l;
}

pub fn forwardDropout(l: *Layer, state: *State) void {
    if (!state.train) return;
    for (0..l.batch * l.inputs) |i| {
        const r = utils.default.uniform(0, 1);
        l.rand[i] = r;
        if (r < l.probability) {
            state.input[i] = 0;
        } else {
            state.input[i] *= l.scale;
        }
    }
}

pub fn backwardDropout(l: *Layer, state: *State) void {
    if (state.delta.len == 0) return;
    for (0..l.batch * l.inputs) |i| {
        if (l.rand[i] < l.probability) {
            state.delta[i] = 0;
        } else {
            state.delta[i] *= l.scale;
        }
    }
}

pub fn forwardDropoutGpu(l: *Layer, state: *State) void {
    if (!state.train) return;
    const size = l.inputs * l.batch;
    // Fresh seed per call, so successive steps get independent masks.
    gpu.randUniform(size, l.gpu.rand, @truncate(utils.default.u64Value()));
    gpu.dropout(state.input_gpu, size, l.gpu.rand, l.probability, l.scale);
}

pub fn backwardDropoutGpu(l: *Layer, state: *State) void {
    if (state.delta_gpu.isNull()) return;
    const size = l.inputs * l.batch;
    gpu.dropout(state.delta_gpu, size, l.gpu.rand, l.probability, l.scale);
}

// ===========================================================================
// cost
// ===========================================================================

pub fn makeCost(allocator: std.mem.Allocator, batch: usize, inputs: usize, cost_type: lay.CostType, scale: f32) !Layer {
    std.debug.print("cost                                           {d:4}\n", .{inputs});
    var l: Layer = .{ .kind = .cost };
    l.scale = scale;
    l.batch = batch;
    l.inputs = inputs;
    l.outputs = inputs;
    l.cost_type = cost_type;
    l.has_cost = true;
    l.delta = try lay.zeros(allocator, inputs * batch);
    l.output = try lay.zeros(allocator, inputs * batch);

    if (gpu.active()) {
        l.gpu.delta = gpu.alloc(inputs * batch);
        l.gpu.output = gpu.alloc(inputs * batch);
    }
    return l;
}

pub fn forwardCost(l: *Layer, state: *State) void {
    if (state.truth.len == 0) return;
    const n = l.batch * l.inputs;
    switch (l.cost_type) {
        .smooth => blas.smoothL1(state.input[0..n], state.truth, l.delta, l.output),
        .l1 => blas.l1(state.input[0..n], state.truth, l.delta, l.output),
        else => blas.l2(state.input[0..n], state.truth, l.delta, l.output),
    }
    l.cost = utils.sumArray(l.output[0..n]);
}

pub fn backwardCost(l: *Layer, state: *State) void {
    if (state.delta.len == 0) return;
    blas.axpy(l.scale, l.delta[0 .. l.batch * l.inputs], state.delta);
}

pub fn forwardCostGpu(l: *Layer, state: *State) void {
    if (state.truth_gpu.isNull()) return;
    const n = l.batch * l.inputs;
    if (l.smooth != 0) {
        // Label smoothing, applied to the truth buffer in place.
        gpu.scal(n, 1 - l.smooth, state.truth_gpu);
        gpu.addScalar(n, l.smooth / @as(f32, @floatFromInt(l.inputs)), state.truth_gpu);
    }
    switch (l.cost_type) {
        .smooth => gpu.smoothL1(n, state.input_gpu, state.truth_gpu, l.gpu.delta, l.gpu.output),
        .l1 => gpu.l1(n, state.input_gpu, state.truth_gpu, l.gpu.delta, l.gpu.output),
        else => gpu.l2(n, state.input_gpu, state.truth_gpu, l.gpu.delta, l.gpu.output),
    }
    gpu.pull(l.gpu.output, l.output[0..n]);
    l.cost = utils.sumArray(l.output[0..n]);
}

pub fn backwardCostGpu(l: *Layer, state: *State) void {
    if (state.delta_gpu.isNull()) return;
    gpu.axpy(l.batch * l.inputs, l.scale, l.gpu.delta, state.delta_gpu);
}

// ===========================================================================
// shortcut (residual connection)
// ===========================================================================

pub fn makeShortcut(
    allocator: std.mem.Allocator,
    batch: usize,
    index: usize,
    w: usize,
    h: usize,
    c: usize,
    w2: usize,
    h2: usize,
    c2: usize,
) !Layer {
    std.debug.print("res  {d:3}                {d:4} x{d:4} x{d:4}   ->  {d:4} x{d:4} x{d:4}\n", .{ index, w2, h2, c2, w, h, c });
    var l: Layer = .{ .kind = .shortcut };
    l.batch = batch;
    // w/h/c describe the *source* layer, out_* the current stream. darknet
    // names them this way round and the kernels depend on it.
    l.w = w2;
    l.h = h2;
    l.c = c2;
    l.out_w = w;
    l.out_h = h;
    l.out_c = c;
    l.outputs = w * h * c;
    l.inputs = l.outputs;
    l.index = index;

    l.delta = try lay.zeros(allocator, l.outputs * batch);
    l.output = try lay.zeros(allocator, l.outputs * batch);

    if (gpu.active()) {
        l.gpu.delta = gpu.alloc(l.outputs * batch);
        l.gpu.output = gpu.alloc(l.outputs * batch);
    }
    return l;
}

pub fn forwardShortcut(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    blas.copy(state.input[0..n], l.output);
    blas.shortcut(l.batch, l.w, l.h, l.c, state.layers[l.index].output, l.out_w, l.out_h, l.out_c, l.alpha, l.beta, l.output);
    activations.activateArray(l.output[0..n], l.activation);
}

pub fn backwardShortcut(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    activations.gradientArray(l.output[0..n], l.activation, l.delta[0..n]);
    if (state.delta.len != 0) blas.axpy(l.alpha, l.delta[0..n], state.delta);
    blas.shortcut(l.batch, l.out_w, l.out_h, l.out_c, l.delta, l.w, l.h, l.c, 1, l.beta, state.layers[l.index].delta);
}

pub fn forwardShortcutGpu(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    gpu.copy(n, state.input_gpu, l.gpu.output);
    gpu.shortcut(l.batch, l.w, l.h, l.c, state.layers[l.index].gpu.output, l.out_w, l.out_h, l.out_c, l.alpha, l.beta, l.gpu.output);
    gpu.activateArray(l.gpu.output, n, @intFromEnum(l.activation));
}

pub fn backwardShortcutGpu(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    gpu.gradientArray(l.gpu.output, n, @intFromEnum(l.activation), l.gpu.delta);
    if (!state.delta_gpu.isNull()) gpu.axpy(n, l.alpha, l.gpu.delta, state.delta_gpu);
    gpu.shortcut(l.batch, l.out_w, l.out_h, l.out_c, l.gpu.delta, l.w, l.h, l.c, 1, l.beta, state.layers[l.index].gpu.delta);
}

// ===========================================================================
// route (concatenate earlier layers)
// ===========================================================================

pub fn makeRoute(allocator: std.mem.Allocator, batch: usize, input_layers: []usize, input_sizes: []usize) !Layer {
    std.debug.print("route ", .{});
    var l: Layer = .{ .kind = .route };
    l.batch = batch;
    l.n = input_layers.len;
    l.input_layers = input_layers;
    l.input_sizes = input_sizes;

    var outputs: usize = 0;
    for (input_layers, input_sizes) |idx, sz| {
        std.debug.print(" {d}", .{idx});
        outputs += sz;
    }
    std.debug.print("\n", .{});

    l.outputs = outputs;
    l.inputs = outputs;
    l.delta = try lay.zeros(allocator, outputs * batch);
    l.output = try lay.zeros(allocator, outputs * batch);

    if (gpu.active()) {
        l.gpu.delta = gpu.alloc(outputs * batch);
        l.gpu.output = gpu.alloc(outputs * batch);
    }
    return l;
}

pub fn forwardRoute(l: *Layer, state: *State) void {
    var offset: usize = 0;
    for (l.input_layers, l.input_sizes) |index, input_size| {
        const input = state.layers[index].output;
        for (0..l.batch) |b| {
            blas.copy(input[b * input_size ..][0..input_size], l.output[offset + b * l.outputs ..]);
        }
        offset += input_size;
    }
}

pub fn backwardRoute(l: *Layer, state: *State) void {
    var offset: usize = 0;
    for (l.input_layers, l.input_sizes) |index, input_size| {
        const delta = state.layers[index].delta;
        for (0..l.batch) |b| {
            blas.axpy(1, l.delta[offset + b * l.outputs ..][0..input_size], delta[b * input_size ..]);
        }
        offset += input_size;
    }
}

pub fn forwardRouteGpu(l: *Layer, state: *State) void {
    var offset: usize = 0;
    for (l.input_layers, l.input_sizes) |index, input_size| {
        const input = state.layers[index].gpu.output;
        for (0..l.batch) |b| {
            gpu.copy(input_size, input.offset(b * input_size), l.gpu.output.offset(offset + b * l.outputs));
        }
        offset += input_size;
    }
}

pub fn backwardRouteGpu(l: *Layer, state: *State) void {
    var offset: usize = 0;
    for (l.input_layers, l.input_sizes) |index, input_size| {
        const delta = state.layers[index].gpu.delta;
        for (0..l.batch) |b| {
            gpu.axpy(input_size, 1, l.gpu.delta.offset(offset + b * l.outputs), delta.offset(b * input_size));
        }
        offset += input_size;
    }
}
