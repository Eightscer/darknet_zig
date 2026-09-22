//! Batch normalisation, both as a standalone `[batchnorm]` layer and as the
//! `batch_normalize=1` option on convolutional and connected layers. In the
//! latter case the functions here are called with the host layer, and operate
//! on the output buffer it has already filled -- which is why they key off
//! `l.kind` to decide whether to copy the input in first.

const std = @import("std");
const lay = @import("../layer.zig");
const blas = @import("../blas.zig");
const gpu = @import("../gpu.zig");

const Layer = lay.Layer;
const State = lay.State;

/// Exponential moving average rate for the inference-time statistics.
const rolling_momentum: f32 = 0.99;

pub fn make(allocator: std.mem.Allocator, batch: usize, w: usize, h: usize, c: usize) !Layer {
    std.debug.print("Batch Normalization Layer: {d} x {d} x {d} image\n", .{ w, h, c });
    var l: Layer = .{ .kind = .batchnorm };
    l.batch = batch;
    l.h = h;
    l.out_h = h;
    l.w = w;
    l.out_w = w;
    l.c = c;
    l.out_c = c;
    l.inputs = w * h * c;
    l.outputs = l.inputs;
    l.n = c;
    l.nbiases = c;

    l.output = try lay.zeros(allocator, l.outputs * batch);
    l.delta = try lay.zeros(allocator, l.outputs * batch);

    l.scales = try lay.zeros(allocator, c);
    l.scale_updates = try lay.zeros(allocator, c);
    l.biases = try lay.zeros(allocator, c);
    l.bias_updates = try lay.zeros(allocator, c);
    @memset(l.scales, 1);

    l.mean = try lay.zeros(allocator, c);
    l.variance = try lay.zeros(allocator, c);
    l.mean_delta = try lay.zeros(allocator, c);
    l.variance_delta = try lay.zeros(allocator, c);
    l.rolling_mean = try lay.zeros(allocator, c);
    l.rolling_variance = try lay.zeros(allocator, c);
    l.x = try lay.zeros(allocator, l.outputs * batch);
    l.x_norm = try lay.zeros(allocator, l.outputs * batch);

    if (gpu.active()) try allocDevice(&l, c, l.outputs * batch);
    return l;
}

/// Shared by make() here and by the conv/connected layers, which opt into
/// batch norm rather than being a batchnorm layer.
pub fn allocDevice(l: *Layer, filters: usize, elems: usize) !void {
    l.gpu.mean = gpu.alloc(filters);
    l.gpu.variance = gpu.alloc(filters);
    l.gpu.rolling_mean = gpu.alloc(filters);
    l.gpu.rolling_variance = gpu.alloc(filters);
    l.gpu.mean_delta = gpu.alloc(filters);
    l.gpu.variance_delta = gpu.alloc(filters);
    l.gpu.scales = gpu.make(l.scales);
    l.gpu.scale_updates = gpu.alloc(filters);
    l.gpu.x = gpu.alloc(elems);
    l.gpu.x_norm = gpu.alloc(elems);
}

// ---------------------------------------------------------------------------
// CPU
// ---------------------------------------------------------------------------

pub fn forward(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    const spatial = l.out_h * l.out_w;

    if (l.kind == .batchnorm) blas.copy(state.input[0..n], l.output);
    blas.copy(l.output[0..n], l.x);

    if (state.train) {
        blas.mean(l.output[0..n], l.batch, l.out_c, spatial, l.mean);
        blas.variance(l.output[0..n], l.mean, l.batch, l.out_c, spatial, l.variance);

        // Track the statistics used at inference time.
        blas.scal(rolling_momentum, l.rolling_mean);
        blas.axpy(1 - rolling_momentum, l.mean, l.rolling_mean);
        blas.scal(rolling_momentum, l.rolling_variance);
        blas.axpy(1 - rolling_momentum, l.variance, l.rolling_variance);

        blas.normalize(l.output[0..n], l.mean, l.variance, l.batch, l.out_c, spatial);
        blas.copy(l.output[0..n], l.x_norm);
    } else {
        blas.normalize(l.output[0..n], l.rolling_mean, l.rolling_variance, l.batch, l.out_c, spatial);
    }

    blas.scaleBias(l.output[0..n], l.scales, l.batch, l.out_c, spatial);
    blas.addBias(l.output[0..n], l.biases, l.batch, l.out_c, spatial);
}

pub fn backward(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    const spatial = l.out_h * l.out_w;

    // At inference time the batch statistics were never computed, so the
    // rolling ones stand in. darknet did this by reassigning the pointers on
    // its by-value copy of the layer.
    const mean_in = if (state.train) l.mean else l.rolling_mean;
    const variance_in = if (state.train) l.variance else l.rolling_variance;

    blas.backwardBias(l.bias_updates, l.delta[0..n], l.batch, l.out_c, spatial);
    blas.backwardScale(l.x_norm, l.delta[0..n], l.batch, l.out_c, spatial, l.scale_updates);

    blas.scaleBias(l.delta[0..n], l.scales, l.batch, l.out_c, spatial);

    blas.meanDelta(l.delta[0..n], variance_in, l.batch, l.out_c, spatial, l.mean_delta);
    blas.varianceDelta(l.x, l.delta[0..n], mean_in, variance_in, l.batch, l.out_c, spatial, l.variance_delta);
    blas.normalizeDelta(l.x, mean_in, variance_in, l.mean_delta, l.variance_delta, l.batch, l.out_c, spatial, l.delta[0..n]);

    if (l.kind == .batchnorm and state.delta.len != 0) {
        blas.copy(l.delta[0..n], state.delta);
    }
}

// ---------------------------------------------------------------------------
// GPU
// ---------------------------------------------------------------------------

pub fn forwardGpu(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    const spatial = l.out_h * l.out_w;

    if (l.kind == .batchnorm) gpu.copy(n, state.input_gpu, l.gpu.output);
    gpu.copy(n, l.gpu.output, l.gpu.x);

    if (state.train) {
        gpu.mean(l.gpu.output, l.batch, l.out_c, spatial, l.gpu.mean);
        gpu.variance(l.gpu.output, l.gpu.mean, l.batch, l.out_c, spatial, l.gpu.variance);

        gpu.scal(l.out_c, rolling_momentum, l.gpu.rolling_mean);
        gpu.axpy(l.out_c, 1 - rolling_momentum, l.gpu.mean, l.gpu.rolling_mean);
        gpu.scal(l.out_c, rolling_momentum, l.gpu.rolling_variance);
        gpu.axpy(l.out_c, 1 - rolling_momentum, l.gpu.variance, l.gpu.rolling_variance);

        gpu.normalize(l.gpu.output, l.gpu.mean, l.gpu.variance, l.batch, l.out_c, spatial);
        gpu.copy(n, l.gpu.output, l.gpu.x_norm);
    } else {
        gpu.normalize(l.gpu.output, l.gpu.rolling_mean, l.gpu.rolling_variance, l.batch, l.out_c, spatial);
    }

    gpu.scaleBias(l.gpu.output, l.gpu.scales, l.batch, l.out_c, spatial);
    gpu.addBias(l.gpu.output, l.gpu.biases, l.batch, l.out_c, spatial);
}

pub fn backwardGpu(l: *Layer, state: *State) void {
    const n = l.outputs * l.batch;
    const spatial = l.out_h * l.out_w;

    const mean_in = if (state.train) l.gpu.mean else l.gpu.rolling_mean;
    const variance_in = if (state.train) l.gpu.variance else l.gpu.rolling_variance;

    gpu.backwardBias(l.gpu.bias_updates, l.gpu.delta, l.batch, l.out_c, spatial);
    gpu.backwardScale(l.gpu.x_norm, l.gpu.delta, l.batch, l.out_c, spatial, l.gpu.scale_updates);

    gpu.scaleBias(l.gpu.delta, l.gpu.scales, l.batch, l.out_c, spatial);

    gpu.meanDelta(l.gpu.delta, variance_in, l.batch, l.out_c, spatial, l.gpu.mean_delta);
    gpu.varianceDelta(l.gpu.x, l.gpu.delta, mean_in, variance_in, l.batch, l.out_c, spatial, l.gpu.variance_delta);
    gpu.normalizeDelta(l.gpu.x, mean_in, variance_in, l.gpu.mean_delta, l.gpu.variance_delta, l.batch, l.out_c, spatial, l.gpu.delta);

    if (l.kind == .batchnorm and !state.delta_gpu.isNull()) {
        gpu.copy(n, l.gpu.delta, state.delta_gpu);
    }
}

pub fn pull(l: *Layer) void {
    gpu.pull(l.gpu.scales, l.scales);
    gpu.pull(l.gpu.rolling_mean, l.rolling_mean);
    gpu.pull(l.gpu.rolling_variance, l.rolling_variance);
}

pub fn push(l: *Layer) void {
    gpu.push(l.gpu.scales, l.scales);
    gpu.push(l.gpu.rolling_mean, l.rolling_mean);
    gpu.push(l.gpu.rolling_variance, l.rolling_variance);
}
