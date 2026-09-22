//! The layer record and the slice of network state a layer is allowed to see.
//!
//! darknet used one enormous struct for every layer type and passed the whole
//! `network` by value into each forward/backward function. This keeps the flat
//! struct -- it makes the parser and the weights format a direct translation,
//! and the unused fields cost nothing at runtime -- but replaces the
//! pass-the-network trick with an explicit `State`, which both documents what
//! a layer actually touches and avoids an import cycle between the layer
//! modules and network.zig.

const std = @import("std");
const gpu = @import("gpu.zig");
const activations = @import("activations.zig");

pub const Activation = activations.Activation;

pub const LayerType = enum {
    convolutional,
    connected,
    maxpool,
    avgpool,
    softmax,
    dropout,
    batchnorm,
    cost,
    shortcut,
    route,

    pub fn fromSection(name: []const u8) ?LayerType {
        const table = .{
            .{ "convolutional", LayerType.convolutional },
            .{ "conv", LayerType.convolutional },
            .{ "connected", LayerType.connected },
            .{ "conn", LayerType.connected },
            .{ "maxpool", LayerType.maxpool },
            .{ "max", LayerType.maxpool },
            .{ "avgpool", LayerType.avgpool },
            .{ "avg", LayerType.avgpool },
            .{ "softmax", LayerType.softmax },
            .{ "soft", LayerType.softmax },
            .{ "dropout", LayerType.dropout },
            .{ "batchnorm", LayerType.batchnorm },
            .{ "cost", LayerType.cost },
            .{ "shortcut", LayerType.shortcut },
            .{ "route", LayerType.route },
        };
        inline for (table) |entry| {
            if (std.mem.eql(u8, name, entry[0])) return entry[1];
        }
        return null;
    }
};

pub const CostType = enum {
    sse,
    masked,
    l1,
    seg,
    smooth,
    wgan,

    pub fn fromString(s: []const u8) CostType {
        const table = .{
            .{ "seg", CostType.seg },
            .{ "sse", CostType.sse },
            .{ "masked", CostType.masked },
            .{ "smooth", CostType.smooth },
            .{ "L1", CostType.l1 },
            .{ "wgan", CostType.wgan },
        };
        inline for (table) |entry| {
            if (std.mem.eql(u8, s, entry[0])) return entry[1];
        }
        std.debug.print("Couldn't find cost type {s}, going with SSE\n", .{s});
        return .sse;
    }
};

/// Hyperparameters for one weight update, assembled once per step by the
/// network and handed to every layer. darknet's `update_args`.
pub const UpdateArgs = struct {
    batch: usize,
    learning_rate: f32,
    momentum: f32,
    decay: f32,
    adam: bool = false,
    b1: f32 = 0.9,
    b2: f32 = 0.999,
    eps: f32 = 1e-7,
    t: usize = 0,
};

/// What a layer sees of the network around it. `input`/`delta` point at the
/// previous layer's output and delta buffers; `delta` is empty for the first
/// layer, which is how darknet signalled "don't bother propagating further".
pub const State = struct {
    input: []f32 = &.{},
    delta: []f32 = &.{},
    truth: []f32 = &.{},
    workspace: []f32 = &.{},
    train: bool = false,
    index: usize = 0,
    layers: []Layer = &.{},

    input_gpu: gpu.Buf = .{},
    delta_gpu: gpu.Buf = .{},
    truth_gpu: gpu.Buf = .{},
    workspace_gpu: gpu.Buf = .{},
};

/// Device-side mirrors of the host buffers. Every field is null in a CPU-only
/// build; the HIP backend fills them in at layer construction time.
pub const GpuBuffers = struct {
    weights: gpu.Buf = .{},
    weight_updates: gpu.Buf = .{},
    biases: gpu.Buf = .{},
    bias_updates: gpu.Buf = .{},
    scales: gpu.Buf = .{},
    scale_updates: gpu.Buf = .{},

    output: gpu.Buf = .{},
    delta: gpu.Buf = .{},
    loss: gpu.Buf = .{},

    mean: gpu.Buf = .{},
    variance: gpu.Buf = .{},
    mean_delta: gpu.Buf = .{},
    variance_delta: gpu.Buf = .{},
    rolling_mean: gpu.Buf = .{},
    rolling_variance: gpu.Buf = .{},
    x: gpu.Buf = .{},
    x_norm: gpu.Buf = .{},

    rand: gpu.Buf = .{},
    indexes: gpu.Buf = .{},

    m: gpu.Buf = .{},
    v: gpu.Buf = .{},
    bias_m: gpu.Buf = .{},
    bias_v: gpu.Buf = .{},
    scale_m: gpu.Buf = .{},
    scale_v: gpu.Buf = .{},
};

pub const Layer = struct {
    kind: LayerType,
    activation: Activation = .linear,
    cost_type: CostType = .sse,

    batch_normalize: bool = false,
    batch: usize = 0,
    inputs: usize = 0,
    outputs: usize = 0,
    nweights: usize = 0,
    nbiases: usize = 0,

    h: usize = 0,
    w: usize = 0,
    c: usize = 0,
    out_h: usize = 0,
    out_w: usize = 0,
    out_c: usize = 0,

    /// Filter count for convolutional layers, input count for route.
    n: usize = 0,
    groups: usize = 1,
    size: usize = 0,
    stride: usize = 1,
    pad: usize = 0,

    /// Source layer for a shortcut.
    index: usize = 0,

    softmax_groups: usize = 1,
    temperature: f32 = 1,
    spatial: bool = false,
    noloss: bool = false,

    probability: f32 = 0,
    /// Dropout's 1/(1-p) rescale, and the cost layer's loss weight.
    scale: f32 = 1,
    alpha: f32 = 1,
    beta: f32 = 1,
    smooth: f32 = 0,
    learning_rate_scale: f32 = 1,

    truth: bool = false,
    stopbackward: bool = false,
    dontload: bool = false,
    dontsave: bool = false,
    dontloadscales: bool = false,
    flipped: bool = false,
    adam: bool = false,

    /// Accumulated loss for layers that produce one (softmax, cost).
    cost: f32 = 0,
    /// Set when this layer contributes to the network's reported cost.
    has_cost: bool = false,

    // Host buffers. An empty slice means "not used by this layer type".
    weights: []f32 = &.{},
    weight_updates: []f32 = &.{},
    biases: []f32 = &.{},
    bias_updates: []f32 = &.{},
    scales: []f32 = &.{},
    scale_updates: []f32 = &.{},

    output: []f32 = &.{},
    delta: []f32 = &.{},
    loss: []f32 = &.{},

    mean: []f32 = &.{},
    variance: []f32 = &.{},
    mean_delta: []f32 = &.{},
    variance_delta: []f32 = &.{},
    rolling_mean: []f32 = &.{},
    rolling_variance: []f32 = &.{},
    x: []f32 = &.{},
    x_norm: []f32 = &.{},

    /// Adam moment estimates.
    m: []f32 = &.{},
    v: []f32 = &.{},
    bias_m: []f32 = &.{},
    bias_v: []f32 = &.{},
    scale_m: []f32 = &.{},
    scale_v: []f32 = &.{},

    /// Maxpool argmax positions, one per output element.
    indexes: []i32 = &.{},
    /// Dropout keep/drop draws, retained for the backward pass.
    rand: []f32 = &.{},
    /// Route inputs.
    input_layers: []usize = &.{},
    input_sizes: []usize = &.{},

    /// Scratch space this layer needs from the shared network workspace.
    workspace_size: usize = 0,

    /// Dropout aliases the previous layer's output and delta rather than
    /// allocating its own, so it must not free them.
    owns_output: bool = true,

    gpu: GpuBuffers = .{},

    pub fn deinit(self: *Layer, allocator: std.mem.Allocator) void {
        const owned = [_][]f32{
            self.weights,       self.weight_updates, self.biases,        self.bias_updates,
            self.scales,        self.scale_updates,  self.loss,          self.mean,
            self.variance,      self.mean_delta,     self.variance_delta, self.rolling_mean,
            self.rolling_variance, self.x,           self.x_norm,        self.m,
            self.v,             self.bias_m,         self.bias_v,        self.scale_m,
            self.scale_v,       self.rand,
        };
        for (owned) |buf| {
            if (buf.len != 0) allocator.free(buf);
        }
        if (self.owns_output) {
            if (self.output.len != 0) allocator.free(self.output);
            if (self.delta.len != 0) allocator.free(self.delta);
        }
        if (self.indexes.len != 0) allocator.free(self.indexes);
        if (self.input_layers.len != 0) allocator.free(self.input_layers);
        if (self.input_sizes.len != 0) allocator.free(self.input_sizes);

        if (gpu.enabled) {
            inline for (@typeInfo(GpuBuffers).@"struct".fields) |f| {
                // `output` and `delta` follow the same borrowing rule as their
                // host counterparts: dropout aliases the previous layer's
                // device buffers and must not release them.
                const aliasable = comptime (std.mem.eql(u8, f.name, "output") or std.mem.eql(u8, f.name, "delta"));
                const borrowed = aliasable and !self.owns_output;
                if (!borrowed) gpu.free(@field(self.gpu, f.name));
            }
        }
        self.* = .{ .kind = self.kind };
    }
};

/// Allocate and zero a host buffer, the equivalent of darknet's ubiquitous
/// `calloc(n, sizeof(float))`.
pub fn zeros(allocator: std.mem.Allocator, n: usize) ![]f32 {
    const buf = try allocator.alloc(f32, n);
    @memset(buf, 0);
    return buf;
}
