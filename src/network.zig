//! The network: layer list, forward/backward/update, and the training and
//! prediction entry points.
//!
//! darknet dispatched layer operations through function pointers stored in the
//! layer struct. Here it is a `switch` on `l.kind`, which is both easier to
//! follow and lets the compiler inline the small layers.

const std = @import("std");
const sys = @import("sys.zig");
const lay = @import("layer.zig");
const blas = @import("blas.zig");
const utils = @import("utils.zig");
const matrix = @import("matrix.zig");
const data_mod = @import("data.zig");
const gpu = @import("gpu.zig");

const conv = @import("layers/convolutional.zig");
const connected = @import("layers/connected.zig");
const pooling = @import("layers/pooling.zig");
const batchnorm = @import("layers/batchnorm.zig");
const misc = @import("layers/misc.zig");

const Layer = lay.Layer;
const State = lay.State;
const Matrix = matrix.Matrix;

pub const LearningRatePolicy = enum {
    constant,
    step,
    exp,
    poly,
    steps,
    sig,
    random,

    pub fn fromString(s: []const u8) LearningRatePolicy {
        const table = .{
            .{ "random", LearningRatePolicy.random },
            .{ "poly", LearningRatePolicy.poly },
            .{ "constant", LearningRatePolicy.constant },
            .{ "step", LearningRatePolicy.step },
            .{ "exp", LearningRatePolicy.exp },
            .{ "sigmoid", LearningRatePolicy.sig },
            .{ "steps", LearningRatePolicy.steps },
        };
        inline for (table) |entry| {
            if (std.mem.eql(u8, s, entry[0])) return entry[1];
        }
        std.debug.print("Couldn't find policy {s}, going with constant\n", .{s});
        return .constant;
    }
};

pub const Network = struct {
    allocator: std.mem.Allocator,
    layers: []Layer = &.{},

    /// Images consumed so far. Persisted in the .weights header so a run can
    /// be resumed with the learning-rate schedule in the right place.
    seen: u64 = 0,
    /// Adam step counter.
    t: usize = 0,

    batch: usize = 1,
    subdivisions: usize = 1,

    policy: LearningRatePolicy = .constant,
    learning_rate: f32 = 0.001,
    momentum: f32 = 0.9,
    decay: f32 = 0.0001,
    gamma: f32 = 0,
    scale: f32 = 1,
    power: f32 = 4,
    step: usize = 1,
    max_batches: usize = 0,
    scales: []f32 = &.{},
    steps: []i32 = &.{},
    burn_in: usize = 0,

    adam: bool = false,
    b1: f32 = 0.9,
    b2: f32 = 0.999,
    eps: f32 = 1e-7,

    inputs: usize = 0,
    outputs: usize = 0,
    truths: usize = 0,
    h: usize = 0,
    w: usize = 0,
    c: usize = 0,

    // Data augmentation settings, read by the loader.
    max_crop: usize = 0,
    min_crop: usize = 0,
    max_ratio: f32 = 1,
    min_ratio: f32 = 1,
    center: bool = false,
    angle: f32 = 0,
    aspect: f32 = 1,
    exposure: f32 = 1,
    saturation: f32 = 1,
    /// Random horizontal mirroring in the loader; darknet defaults this on.
    flip: bool = true,
    hue: f32 = 0,
    random: bool = false,

    input: []f32 = &.{},
    truth: []f32 = &.{},
    workspace: []f32 = &.{},
    /// Points into the output layer's buffer; not owned.
    output: []f32 = &.{},

    train: bool = false,
    cost: f32 = 0,
    clip: f32 = 0,

    input_gpu: gpu.Buf = .{},
    truth_gpu: gpu.Buf = .{},
    workspace_gpu: gpu.Buf = .{},

    pub fn deinit(self: *Network) void {
        for (self.layers) |*l| l.deinit(self.allocator);
        self.allocator.free(self.layers);
        if (self.input.len != 0) self.allocator.free(self.input);
        if (self.truth.len != 0) self.allocator.free(self.truth);
        if (self.workspace.len != 0) self.allocator.free(self.workspace);
        if (self.scales.len != 0) self.allocator.free(self.scales);
        if (self.steps.len != 0) self.allocator.free(self.steps);
        if (gpu.enabled) {
            gpu.free(self.input_gpu);
            gpu.free(self.truth_gpu);
            gpu.free(self.workspace_gpu);
        }
        self.* = .{ .allocator = self.allocator };
    }

    pub fn currentBatch(self: *const Network) u64 {
        return self.seen / @as(u64, self.batch * self.subdivisions);
    }

    /// The last layer that isn't a bare cost layer -- the one whose output is
    /// the network's prediction.
    pub fn outputLayer(self: *Network) *Layer {
        var i = self.layers.len;
        while (i > 0) {
            i -= 1;
            if (self.layers[i].kind != .cost) return &self.layers[i];
        }
        return &self.layers[0];
    }

    /// Shrink (or grow, within what was allocated) the per-step batch. Used to
    /// run a network trained with batch=128 one image at a time. No buffers
    /// are reallocated, so the new batch must not exceed the configured one.
    pub fn setBatch(self: *Network, b: usize) void {
        std.debug.assert(b <= self.batch or self.layers.len == 0);
        self.batch = b;
        for (self.layers) |*l| l.batch = b;
    }
};

// ---------------------------------------------------------------------------
// learning rate schedule
// ---------------------------------------------------------------------------

pub fn currentRate(net: *Network) f32 {
    const batch_num = net.currentBatch();

    // Linear-ish warmup: ramp from 0 to the base rate over `burn_in` batches.
    if (batch_num < net.burn_in) {
        const frac = @as(f32, @floatFromInt(batch_num)) / @as(f32, @floatFromInt(net.burn_in));
        return net.learning_rate * std.math.pow(f32, frac, net.power);
    }

    return switch (net.policy) {
        .constant => net.learning_rate,
        .step => net.learning_rate * std.math.pow(f32, net.scale, @floatFromInt(batch_num / net.step)),
        .steps => blk: {
            var rate = net.learning_rate;
            for (net.steps, net.scales) |s, sc| {
                if (@as(u64, @intCast(@max(s, 0))) > batch_num) break :blk rate;
                rate *= sc;
            }
            break :blk rate;
        },
        .exp => net.learning_rate * std.math.pow(f32, net.gamma, @floatFromInt(batch_num)),
        .poly => blk: {
            const frac = 1.0 - @as(f32, @floatFromInt(batch_num)) / @as(f32, @floatFromInt(net.max_batches));
            break :blk net.learning_rate * std.math.pow(f32, @max(frac, 0), net.power);
        },
        .random => net.learning_rate * std.math.pow(f32, utils.default.uniform(0, 1), net.power),
        .sig => net.learning_rate * (1.0 / (1.0 + @exp(net.gamma * @as(f32, @floatFromInt(batch_num)) - net.gamma * @as(f32, @floatFromInt(net.step))))),
    };
}

// ---------------------------------------------------------------------------
// forward / backward / update
// ---------------------------------------------------------------------------

fn forwardLayer(l: *Layer, state: *State) void {
    switch (l.kind) {
        .convolutional => conv.forward(l, state),
        .connected => connected.forward(l, state),
        .maxpool => pooling.forwardMaxpool(l, state),
        .avgpool => pooling.forwardAvgpool(l, state),
        .batchnorm => batchnorm.forward(l, state),
        .softmax => misc.forwardSoftmax(l, state),
        .dropout => misc.forwardDropout(l, state),
        .cost => misc.forwardCost(l, state),
        .shortcut => misc.forwardShortcut(l, state),
        .route => misc.forwardRoute(l, state),
    }
}

fn backwardLayer(l: *Layer, state: *State) void {
    switch (l.kind) {
        .convolutional => conv.backward(l, state),
        .connected => connected.backward(l, state),
        .maxpool => pooling.backwardMaxpool(l, state),
        .avgpool => pooling.backwardAvgpool(l, state),
        .batchnorm => batchnorm.backward(l, state),
        .softmax => misc.backwardSoftmax(l, state),
        .dropout => misc.backwardDropout(l, state),
        .cost => misc.backwardCost(l, state),
        .shortcut => misc.backwardShortcut(l, state),
        .route => misc.backwardRoute(l, state),
    }
}

fn forwardLayerGpu(l: *Layer, state: *State) void {
    switch (l.kind) {
        .convolutional => conv.forwardGpu(l, state),
        .connected => connected.forwardGpu(l, state),
        .maxpool => pooling.forwardMaxpoolGpu(l, state),
        .avgpool => pooling.forwardAvgpoolGpu(l, state),
        .batchnorm => batchnorm.forwardGpu(l, state),
        .softmax => misc.forwardSoftmaxGpu(l, state),
        .dropout => misc.forwardDropoutGpu(l, state),
        .cost => misc.forwardCostGpu(l, state),
        .shortcut => misc.forwardShortcutGpu(l, state),
        .route => misc.forwardRouteGpu(l, state),
    }
}

fn backwardLayerGpu(l: *Layer, state: *State) void {
    switch (l.kind) {
        .convolutional => conv.backwardGpu(l, state),
        .connected => connected.backwardGpu(l, state),
        .maxpool => pooling.backwardMaxpoolGpu(l, state),
        .avgpool => pooling.backwardAvgpoolGpu(l, state),
        .batchnorm => batchnorm.backwardGpu(l, state),
        .softmax => misc.backwardSoftmaxGpu(l, state),
        .dropout => misc.backwardDropoutGpu(l, state),
        .cost => misc.backwardCostGpu(l, state),
        .shortcut => misc.backwardShortcutGpu(l, state),
        .route => misc.backwardRouteGpu(l, state),
    }
}

fn updateLayer(l: *Layer, a: lay.UpdateArgs) void {
    switch (l.kind) {
        .convolutional => conv.update(l, a),
        .connected => connected.update(l, a),
        else => {},
    }
}

fn updateLayerGpu(l: *Layer, a: lay.UpdateArgs) void {
    switch (l.kind) {
        .convolutional => conv.updateGpu(l, a),
        .connected => connected.updateGpu(l, a),
        else => {},
    }
}

pub fn forward(net: *Network) void {
    if (gpu.active()) return forwardGpu(net);

    var state: State = .{
        .workspace = net.workspace,
        .train = net.train,
        .layers = net.layers,
    };
    var input = net.input;
    var truth = net.truth;

    for (net.layers, 0..) |*l, i| {
        state.index = i;
        state.input = input;
        state.truth = truth;
        // Layer 0 has nowhere to send gradient, which `delta.len == 0`
        // signals; every other layer writes into its predecessor's delta.
        state.delta = if (i == 0) &.{} else net.layers[i - 1].delta;

        if (l.delta.len != 0) blas.fill(l.delta[0 .. l.outputs * l.batch], 0);
        forwardLayer(l, &state);

        input = l.output;
        // A `truth=1` layer supplies the target for the layers after it,
        // which is how darknet wires up autoencoder-style configs.
        if (l.truth) truth = l.output;
    }
    net.output = net.outputLayer().output;
    calcCost(net);
}

pub fn backward(net: *Network) void {
    if (gpu.active()) return backwardGpu(net);

    var state: State = .{
        .workspace = net.workspace,
        .train = net.train,
        .layers = net.layers,
        .truth = net.truth,
    };

    var i = net.layers.len;
    while (i > 0) {
        i -= 1;
        const l = &net.layers[i];
        if (l.stopbackward) break;
        state.index = i;
        if (i == 0) {
            state.input = net.input;
            state.delta = &.{};
        } else {
            state.input = net.layers[i - 1].output;
            state.delta = net.layers[i - 1].delta;
        }
        backwardLayer(l, &state);
    }
}

pub fn update(net: *Network) void {
    net.t += 1;
    const a: lay.UpdateArgs = .{
        .batch = net.batch * net.subdivisions,
        .learning_rate = currentRate(net),
        .momentum = net.momentum,
        .decay = net.decay,
        .adam = net.adam,
        .b1 = net.b1,
        .b2 = net.b2,
        .eps = net.eps,
        .t = net.t,
    };
    if (gpu.active()) {
        for (net.layers) |*l| updateLayerGpu(l, a);
    } else {
        for (net.layers) |*l| updateLayer(l, a);
    }
}

fn calcCost(net: *Network) void {
    var sum: f32 = 0;
    var count: usize = 0;
    for (net.layers) |l| {
        if (l.has_cost) {
            sum += l.cost;
            count += 1;
        }
    }
    net.cost = if (count > 0) sum / @as(f32, @floatFromInt(count)) else 0;
}

// ---------------------------------------------------------------------------
// GPU variants
// ---------------------------------------------------------------------------

fn forwardGpu(net: *Network) void {
    gpu.push(net.input_gpu, net.input[0 .. net.inputs * net.batch]);
    if (net.truth.len != 0) {
        gpu.push(net.truth_gpu, net.truth[0 .. net.truths * net.batch]);
    }

    var state: State = .{
        .workspace_gpu = net.workspace_gpu,
        .train = net.train,
        .layers = net.layers,
    };
    var input = net.input_gpu;
    var truth = if (net.truth.len != 0) net.truth_gpu else gpu.Buf{};

    for (net.layers, 0..) |*l, i| {
        state.index = i;
        state.input_gpu = input;
        state.truth_gpu = truth;
        state.delta_gpu = if (i == 0) .{} else net.layers[i - 1].gpu.delta;

        if (!l.gpu.delta.isNull()) gpu.fill(l.gpu.delta, l.outputs * l.batch, 0);
        forwardLayerGpu(l, &state);

        input = l.gpu.output;
        if (l.truth) truth = l.gpu.output;
    }

    // Mirror the prediction back to the host so callers see it in `output`.
    const out = net.outputLayer();
    gpu.pull(out.gpu.output, out.output[0 .. out.outputs * out.batch]);
    net.output = out.output;
    calcCost(net);
}

fn backwardGpu(net: *Network) void {
    var state: State = .{
        .workspace_gpu = net.workspace_gpu,
        .train = net.train,
        .layers = net.layers,
        .truth_gpu = net.truth_gpu,
    };

    var i = net.layers.len;
    while (i > 0) {
        i -= 1;
        const l = &net.layers[i];
        if (l.stopbackward) break;
        state.index = i;
        if (i == 0) {
            state.input_gpu = net.input_gpu;
            state.delta_gpu = .{};
        } else {
            state.input_gpu = net.layers[i - 1].gpu.output;
            state.delta_gpu = net.layers[i - 1].gpu.delta;
        }
        backwardLayerGpu(l, &state);
    }
}

// ---------------------------------------------------------------------------
// training
// ---------------------------------------------------------------------------

pub fn trainDatum(net: *Network) f32 {
    net.seen += net.batch;
    net.train = true;
    forward(net);
    backward(net);
    const err = net.cost;
    // Gradients accumulate across subdivisions; only step once per full batch.
    if ((net.seen / net.batch) % net.subdivisions == 0) update(net);
    return err;
}

/// One pass over `d`, in batch-sized chunks. Returns mean loss per image.
pub fn trainNetwork(net: *Network, d: data_mod.Data) f32 {
    std.debug.assert(d.x.rows % net.batch == 0);
    const n = d.x.rows / net.batch;
    var sum: f32 = 0;
    for (0..n) |i| {
        data_mod.nextBatch(d, net.batch, i * net.batch, net.input, net.truth);
        sum += trainDatum(net);
    }
    return sum / @as(f32, @floatFromInt(n * net.batch));
}

// ---------------------------------------------------------------------------
// inference
// ---------------------------------------------------------------------------

/// Run the network over `input` (batch-many images, laid out contiguously) and
/// return the output layer's buffer. The result aliases network-owned memory
/// and is valid until the next call.
pub fn predict(net: *Network, input: []const f32) []f32 {
    const n = @min(input.len, net.inputs * net.batch);
    @memcpy(net.input[0..n], input[0..n]);

    const saved_truth = net.truth;
    net.truth = &.{};
    net.train = false;
    forward(net);
    net.truth = saved_truth;
    return net.output;
}

/// Predictions for every row of `test`, one row of class scores each.
pub fn predictData(net: *Network, test_data: data_mod.Data) !Matrix {
    const k = net.outputs;
    var pred = try Matrix.init(net.allocator, test_data.x.rows, k);
    errdefer pred.deinit(net.allocator);

    const x = try net.allocator.alloc(f32, net.batch * test_data.x.cols);
    defer net.allocator.free(x);

    var i: usize = 0;
    while (i < test_data.x.rows) : (i += net.batch) {
        @memset(x, 0);
        for (0..net.batch) |b| {
            if (i + b >= test_data.x.rows) break;
            @memcpy(x[b * test_data.x.cols ..][0..test_data.x.cols], test_data.x.vals[i + b]);
        }
        const out = predict(net, x);
        for (0..net.batch) |b| {
            if (i + b >= test_data.x.rows) break;
            @memcpy(pred.vals[i + b][0..k], out[b * k ..][0..k]);
        }
    }
    return pred;
}

/// Top-1 and top-n accuracy over a labelled dataset.
pub fn accuracies(net: *Network, d: data_mod.Data, n: usize) ![2]f32 {
    var guess = try predictData(net, d);
    defer guess.deinit(net.allocator);
    return .{
        try matrix.topkAccuracy(net.allocator, d.y, guess, 1),
        try matrix.topkAccuracy(net.allocator, d.y, guess, n),
    };
}

// ---------------------------------------------------------------------------
// weight transfer, used around save/load when running on the GPU
// ---------------------------------------------------------------------------

pub fn pullWeights(net: *Network) void {
    if (!gpu.active()) return;
    for (net.layers) |*l| {
        switch (l.kind) {
            .convolutional => conv.pull(l),
            .connected => connected.pull(l),
            .batchnorm => batchnorm.pull(l),
            else => {},
        }
    }
}

pub fn pushWeights(net: *Network) void {
    if (!gpu.active()) return;
    for (net.layers) |*l| {
        switch (l.kind) {
            .convolutional => conv.push(l),
            .connected => connected.push(l),
            .batchnorm => batchnorm.push(l),
            else => {},
        }
    }
}
