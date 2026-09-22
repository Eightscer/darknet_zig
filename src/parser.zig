//! Building a network from a .cfg file, and reading/writing .weights.
//!
//! The weights format is binary and positional -- a header followed by each
//! layer's parameters in network order, with no names or sizes -- so it only
//! round-trips if the layer shapes and the per-layer field order match
//! upstream exactly. They do: files written here load in darknet and vice
//! versa. That compatibility is the reason several apparent oddities below
//! (the version-dependent `seen` width, the transpose flag) are preserved.

const std = @import("std");
const sys = @import("sys.zig");
const cfg_mod = @import("cfg.zig");
const lay = @import("layer.zig");
const net_mod = @import("network.zig");
const utils = @import("utils.zig");
const activations = @import("activations.zig");
const gpu = @import("gpu.zig");

const conv = @import("layers/convolutional.zig");
const connected = @import("layers/connected.zig");
const pooling = @import("layers/pooling.zig");
const batchnorm = @import("layers/batchnorm.zig");
const misc = @import("layers/misc.zig");

const Layer = lay.Layer;
const Network = net_mod.Network;
const Options = cfg_mod.Options;

const SizeParams = struct {
    batch: usize,
    inputs: usize,
    h: usize,
    w: usize,
    c: usize,
    index: usize,
};

// ---------------------------------------------------------------------------
// [net]
// ---------------------------------------------------------------------------

fn parseNetOptions(allocator: std.mem.Allocator, o: *Options, net: *Network) !void {
    const batch_raw: usize = @intCast(@max(1, o.int("batch", 1)));
    net.learning_rate = o.float("learning_rate", 0.001);
    net.momentum = o.float("momentum", 0.9);
    net.decay = o.float("decay", 0.0001);
    const subdivs: usize = @intCast(@max(1, o.int("subdivisions", 1)));

    // darknet stores the *per-step* batch, with the configured batch split
    // across subdivisions and gradients accumulated between updates.
    net.batch = @max(1, batch_raw / subdivs);
    net.subdivisions = subdivs;

    net.random = o.boolQuiet("random", false);
    if (net.random) {
        std.debug.print(
            "Note: random=1 (multi-scale training) is not implemented; training at a fixed input size.\n",
            .{},
        );
    }

    net.adam = o.boolQuiet("adam", false);
    if (net.adam) {
        net.b1 = o.float("B1", 0.9);
        net.b2 = o.float("B2", 0.999);
        net.eps = o.float("eps", 0.0000001);
    }

    net.h = @intCast(@max(0, o.intQuiet("height", 0)));
    net.w = @intCast(@max(0, o.intQuiet("width", 0)));
    net.c = @intCast(@max(0, o.intQuiet("channels", 0)));
    net.inputs = @intCast(@max(0, o.intQuiet("inputs", @intCast(net.h * net.w * net.c))));

    net.max_crop = @intCast(@max(0, o.intQuiet("max_crop", @intCast(net.w * 2))));
    net.min_crop = @intCast(@max(0, o.intQuiet("min_crop", @intCast(net.w))));
    net.max_ratio = o.floatQuiet("max_ratio", @as(f32, @floatFromInt(net.max_crop)) / @as(f32, @floatFromInt(@max(net.w, 1))));
    net.min_ratio = o.floatQuiet("min_ratio", @as(f32, @floatFromInt(net.min_crop)) / @as(f32, @floatFromInt(@max(net.w, 1))));
    net.center = o.boolQuiet("center", false);
    net.clip = o.floatQuiet("clip", 0);

    net.angle = o.floatQuiet("angle", 0);
    net.aspect = o.floatQuiet("aspect", 1);
    net.saturation = o.floatQuiet("saturation", 1);
    net.exposure = o.floatQuiet("exposure", 1);
    net.hue = o.floatQuiet("hue", 0);

    if (net.inputs == 0 and !(net.h != 0 and net.w != 0 and net.c != 0)) {
        std.debug.print("No input parameters supplied in [net]\n", .{});
        return error.BadConfig;
    }

    net.policy = net_mod.LearningRatePolicy.fromString(o.str("policy", "constant").?);
    net.burn_in = @intCast(@max(0, o.intQuiet("burn_in", 0)));
    net.power = o.floatQuiet("power", 4);

    switch (net.policy) {
        .step => {
            net.step = @intCast(@max(1, o.int("step", 1)));
            net.scale = o.float("scale", 1);
        },
        .steps => {
            const steps_s = o.find("steps") orelse {
                std.debug.print("STEPS policy must have steps and scales in the cfg file\n", .{});
                return error.BadConfig;
            };
            const scales_s = o.find("scales") orelse {
                std.debug.print("STEPS policy must have steps and scales in the cfg file\n", .{});
                return error.BadConfig;
            };
            net.steps = try utils.parseIntList(allocator, steps_s);
            net.scales = try utils.parseFloatList(allocator, scales_s);
        },
        .exp => net.gamma = o.float("gamma", 1),
        .sig => {
            net.gamma = o.float("gamma", 1);
            net.step = @intCast(@max(1, o.int("step", 1)));
        },
        else => {},
    }
    net.max_batches = @intCast(@max(0, o.int("max_batches", 0)));
}

// ---------------------------------------------------------------------------
// individual layers
// ---------------------------------------------------------------------------

fn requireImage(p: SizeParams, what: []const u8) !void {
    if (p.h == 0 or p.w == 0 or p.c == 0) {
        std.debug.print("Layer before {s} layer must output an image\n", .{what});
        return error.BadConfig;
    }
}

fn parseConvolutional(allocator: std.mem.Allocator, o: *Options, p: SizeParams, net: *Network) !Layer {
    const n: usize = @intCast(@max(1, o.int("filters", 1)));
    const size: usize = @intCast(@max(1, o.int("size", 1)));
    const stride: usize = @intCast(@max(1, o.int("stride", 1)));
    const pad = o.intQuiet("pad", 0);
    var padding: usize = @intCast(@max(0, o.intQuiet("padding", 0)));
    const groups: usize = @intCast(@max(1, o.intQuiet("groups", 1)));
    // `pad=1` is shorthand for "same" padding; `padding=N` is explicit.
    if (pad != 0) padding = size / 2;

    const activation = activations.Activation.fromString(o.str("activation", "logistic").?);
    try requireImage(p, "convolutional");
    const batch_normalize = o.boolQuiet("batch_normalize", false);

    if (o.boolQuiet("binary", false) or o.boolQuiet("xnor", false)) {
        std.debug.print("Note: binary/xnor convolutions are not implemented; using full-precision weights.\n", .{});
    }

    var l = try conv.make(allocator, p.batch, p.h, p.w, p.c, n, groups, size, stride, padding, activation, batch_normalize, net.adam);
    l.flipped = o.boolQuiet("flipped", false);
    return l;
}

fn parseConnected(allocator: std.mem.Allocator, o: *Options, p: SizeParams, net: *Network) !Layer {
    const output: usize = @intCast(@max(1, o.int("output", 1)));
    const activation = activations.Activation.fromString(o.str("activation", "logistic").?);
    const batch_normalize = o.boolQuiet("batch_normalize", false);
    return connected.make(allocator, p.batch, p.inputs, output, activation, batch_normalize, net.adam);
}

fn parseMaxpool(allocator: std.mem.Allocator, o: *Options, p: SizeParams) !Layer {
    const stride: usize = @intCast(@max(1, o.int("stride", 1)));
    const size: usize = @intCast(@max(1, o.int("size", @intCast(stride))));
    const padding: usize = @intCast(@max(0, o.intQuiet("padding", @intCast(size - 1))));
    try requireImage(p, "maxpool");
    return pooling.makeMaxpool(allocator, p.batch, p.h, p.w, p.c, size, stride, padding);
}

fn parseAvgpool(allocator: std.mem.Allocator, p: SizeParams) !Layer {
    try requireImage(p, "avgpool");
    return pooling.makeAvgpool(allocator, p.batch, p.w, p.h, p.c);
}

fn parseDropout(allocator: std.mem.Allocator, o: *Options, p: SizeParams) !Layer {
    const probability = o.float("probability", 0.5);
    var l = try misc.makeDropout(allocator, p.batch, p.inputs, probability);
    l.out_w = p.w;
    l.out_h = p.h;
    l.out_c = p.c;
    return l;
}

fn parseSoftmax(allocator: std.mem.Allocator, o: *Options, p: SizeParams) !Layer {
    const groups: usize = @intCast(@max(1, o.intQuiet("groups", 1)));
    var l = try misc.makeSoftmax(allocator, p.batch, p.inputs, groups);
    l.temperature = o.floatQuiet("temperature", 1);
    l.w = p.w;
    l.h = p.h;
    l.c = p.c;
    l.spatial = o.floatQuiet("spatial", 0) != 0;
    l.noloss = o.boolQuiet("noloss", false);
    if (o.find("tree") != null) {
        std.debug.print("Note: hierarchical softmax (tree=) is not implemented; using a flat softmax.\n", .{});
    }
    return l;
}

fn parseCost(allocator: std.mem.Allocator, o: *Options, p: SizeParams) !Layer {
    const cost_type = lay.CostType.fromString(o.str("type", "sse").?);
    const scale = o.floatQuiet("scale", 1);
    return misc.makeCost(allocator, p.batch, p.inputs, cost_type, scale);
}

fn parseBatchnorm(allocator: std.mem.Allocator, p: SizeParams) !Layer {
    return batchnorm.make(allocator, p.batch, p.w, p.h, p.c);
}

fn parseShortcut(allocator: std.mem.Allocator, o: *Options, p: SizeParams, net: *Network) !Layer {
    const from_s = o.find("from") orelse {
        std.debug.print("Shortcut layer must specify 'from'\n", .{});
        return error.BadConfig;
    };
    var index = utils.parseInt(from_s, 0);
    // Negative indices are relative to the current layer, which is how every
    // ResNet config refers to the block input.
    if (index < 0) index += @intCast(p.index);
    if (index < 0 or index >= @as(i32, @intCast(p.index))) {
        std.debug.print("Shortcut 'from' index {d} is out of range at layer {d}\n", .{ index, p.index });
        return error.BadConfig;
    }
    const from = net.layers[@intCast(index)];

    var l = try misc.makeShortcut(allocator, p.batch, @intCast(index), p.w, p.h, p.c, from.out_w, from.out_h, from.out_c);
    l.activation = activations.Activation.fromString(o.str("activation", "linear").?);
    l.alpha = o.floatQuiet("alpha", 1);
    l.beta = o.floatQuiet("beta", 1);
    return l;
}

fn parseRoute(allocator: std.mem.Allocator, o: *Options, p: SizeParams, net: *Network) !Layer {
    const list_s = o.find("layers") orelse {
        std.debug.print("Route layer must specify input layers\n", .{});
        return error.BadConfig;
    };
    const raw = try utils.parseIntList(allocator, list_s);
    defer allocator.free(raw);

    const layers = try allocator.alloc(usize, raw.len);
    errdefer allocator.free(layers);
    const sizes = try allocator.alloc(usize, raw.len);
    errdefer allocator.free(sizes);

    for (raw, 0..) |v, i| {
        var index = v;
        if (index < 0) index += @intCast(p.index);
        if (index < 0 or index >= @as(i32, @intCast(p.index))) {
            std.debug.print("Route index {d} is out of range at layer {d}\n", .{ index, p.index });
            return error.BadConfig;
        }
        layers[i] = @intCast(index);
        sizes[i] = net.layers[@intCast(index)].outputs;
    }

    var l = try misc.makeRoute(allocator, p.batch, layers, sizes);

    // The concatenation only has a meaningful spatial shape if every input
    // agrees on width and height; otherwise downstream layers must treat it
    // as a flat vector.
    const first = net.layers[layers[0]];
    l.out_w = first.out_w;
    l.out_h = first.out_h;
    l.out_c = first.out_c;
    for (layers[1..]) |index| {
        const next = net.layers[index];
        if (next.out_w == first.out_w and next.out_h == first.out_h) {
            l.out_c += next.out_c;
        } else {
            l.out_w = 0;
            l.out_h = 0;
            l.out_c = 0;
        }
    }
    return l;
}

// ---------------------------------------------------------------------------
// network assembly
// ---------------------------------------------------------------------------

pub const BuildOptions = struct {
    /// Override `[net] batch`. Every activation buffer is sized
    /// `batch * outputs`, so for inference this is the difference between
    /// allocating for the config's training batch and allocating for the one
    /// image actually being classified. tiny.cfg declares `batch=128`: left
    /// alone that is 6.6 GB of buffers, 127/128 of which are never touched.
    batch: ?usize = null,
};

pub fn parseNetworkCfg(allocator: std.mem.Allocator, path: []const u8) !Network {
    return parseNetworkCfgWith(allocator, path, .{});
}

pub fn parseNetworkCfgWith(allocator: std.mem.Allocator, path: []const u8, opts: BuildOptions) !Network {
    var cfg = try cfg_mod.readCfg(allocator, path);
    defer cfg.deinit();
    return buildNetwork(allocator, &cfg, opts);
}

/// Build a network from cfg source held in memory rather than a file. `source`
/// is copied, so string literals are fine.
pub fn parseNetworkSource(allocator: std.mem.Allocator, source: []const u8) !Network {
    var cfg = try cfg_mod.parseCfg(allocator, try allocator.dupe(u8, source), "<source>");
    defer cfg.deinit();
    return buildNetwork(allocator, &cfg, .{});
}

fn buildNetwork(allocator: std.mem.Allocator, cfg: *cfg_mod.Cfg, opts: BuildOptions) !Network {
    if (cfg.sections.items.len == 0) {
        std.debug.print("Config file has no sections\n", .{});
        return error.BadConfig;
    }

    var net: Network = .{ .allocator = allocator };
    errdefer net.deinit();

    const head = &cfg.sections.items[0];
    if (!std.mem.eql(u8, head.name, "net") and !std.mem.eql(u8, head.name, "network")) {
        std.debug.print("First section must be [net] or [network]\n", .{});
        return error.BadConfig;
    }
    try parseNetOptions(allocator, &head.options, &net);
    // Applied before any layer is constructed, so the buffers are sized for
    // the batch that will actually be used rather than resized afterwards.
    if (opts.batch) |b| {
        net.batch = @max(1, b);
        net.subdivisions = 1;
    }

    const layer_sections = cfg.sections.items[1..];
    net.layers = try allocator.alloc(Layer, layer_sections.len);
    // A partially built network must still be safe to free if a later layer
    // fails to parse, so every slot starts as an empty, owned-nothing layer.
    for (net.layers) |*l| l.* = .{ .kind = .cost, .owns_output = false };

    var params: SizeParams = .{
        .batch = net.batch,
        .inputs = net.inputs,
        .h = net.h,
        .w = net.w,
        .c = net.c,
        .index = 0,
    };

    var workspace_size: usize = 0;
    std.debug.print("layer     filters    size              input                output\n", .{});

    for (layer_sections, 0..) |*section, count| {
        params.index = count;
        std.debug.print("{d:5} ", .{count});

        const kind = lay.LayerType.fromSection(section.name) orelse {
            std.debug.print("Type not recognized: [{s}]\n", .{section.name});
            return error.UnsupportedLayer;
        };

        var o = &section.options;
        var l: Layer = switch (kind) {
            .convolutional => try parseConvolutional(allocator, o, params, &net),
            .connected => try parseConnected(allocator, o, params, &net),
            .maxpool => try parseMaxpool(allocator, o, params),
            .avgpool => try parseAvgpool(allocator, params),
            .dropout => blk: {
                var d = try parseDropout(allocator, o, params);
                // Dropout works in place on the previous layer's buffers.
                if (count == 0) {
                    std.debug.print("A [dropout] layer cannot be the first layer\n", .{});
                    return error.BadConfig;
                }
                d.output = net.layers[count - 1].output;
                d.delta = net.layers[count - 1].delta;
                d.gpu.output = net.layers[count - 1].gpu.output;
                d.gpu.delta = net.layers[count - 1].gpu.delta;
                break :blk d;
            },
            .softmax => try parseSoftmax(allocator, o, params),
            .cost => try parseCost(allocator, o, params),
            .batchnorm => try parseBatchnorm(allocator, params),
            .shortcut => try parseShortcut(allocator, o, params, &net),
            .route => try parseRoute(allocator, o, params, &net),
        };

        l.truth = o.boolQuiet("truth", false);
        l.stopbackward = o.boolQuiet("stopbackward", false);
        l.dontsave = o.boolQuiet("dontsave", false);
        l.dontload = o.boolQuiet("dontload", false);
        l.dontloadscales = o.boolQuiet("dontloadscales", false);
        l.learning_rate_scale = o.floatQuiet("learning_rate", 1);
        l.smooth = o.floatQuiet("smooth", 0);
        o.reportUnused();

        net.layers[count] = l;
        workspace_size = @max(workspace_size, l.workspace_size);

        params.h = l.out_h;
        params.w = l.out_w;
        params.c = l.out_c;
        params.inputs = l.outputs;
    }

    const out = net.outputLayer();
    net.outputs = out.outputs;
    // For classification the targets are one value per output unit. (darknet
    // lets detection layers override this with their own `truths` count; none
    // of the layer types here do.)
    net.truths = out.outputs;
    net.output = out.output;

    net.input = try lay.zeros(allocator, net.inputs * net.batch);
    net.truth = try lay.zeros(allocator, net.truths * net.batch);
    if (workspace_size != 0) net.workspace = try lay.zeros(allocator, workspace_size);

    if (gpu.active()) {
        net.input_gpu = gpu.alloc(net.inputs * net.batch);
        net.truth_gpu = gpu.alloc(net.truths * net.batch);
        if (workspace_size != 0) net.workspace_gpu = gpu.alloc(workspace_size);
    }

    return net;
}

pub fn loadNetwork(allocator: std.mem.Allocator, cfg_path: []const u8, weights_path: ?[]const u8, clear: bool) !Network {
    return loadNetworkWith(allocator, cfg_path, weights_path, clear, .{});
}

pub fn loadNetworkWith(
    allocator: std.mem.Allocator,
    cfg_path: []const u8,
    weights_path: ?[]const u8,
    clear: bool,
    opts: BuildOptions,
) !Network {
    var net = try parseNetworkCfgWith(allocator, cfg_path, opts);
    errdefer net.deinit();
    if (weights_path) |wp| {
        if (wp.len != 0) try loadWeights(&net, wp);
    }
    if (clear) net.seen = 0;
    return net;
}

// ---------------------------------------------------------------------------
// weights: load
// ---------------------------------------------------------------------------

/// Reinterpret an inputs x outputs matrix as outputs x inputs, in place.
/// Only needed for pre-2015 files, flagged by a version field above 1000.
fn transposeMatrix(allocator: std.mem.Allocator, a: []f32, rows: usize, cols: usize) !void {
    const tmp = try allocator.alloc(f32, rows * cols);
    defer allocator.free(tmp);
    for (0..rows) |x| {
        for (0..cols) |y| tmp[y * rows + x] = a[x * cols + y];
    }
    @memcpy(a, tmp);
}

fn loadConvolutionalWeights(l: *Layer, r: *sys.BinReader) !void {
    try r.readInto(f32, l.biases[0..l.n]);
    if (l.batch_normalize and !l.dontloadscales) {
        try r.readInto(f32, l.scales[0..l.n]);
        try r.readInto(f32, l.rolling_mean[0..l.n]);
        try r.readInto(f32, l.rolling_variance[0..l.n]);
    }
    try r.readInto(f32, l.weights[0..l.nweights]);
    if (l.flipped) {
        try transposeMatrix(sys.gpa, l.weights, l.c * l.size * l.size, l.n);
    }
    if (gpu.active()) conv.push(l);
}

fn loadConnectedWeights(l: *Layer, r: *sys.BinReader, transpose: bool) !void {
    try r.readInto(f32, l.biases[0..l.outputs]);
    try r.readInto(f32, l.weights[0 .. l.outputs * l.inputs]);
    if (transpose) try transposeMatrix(sys.gpa, l.weights, l.inputs, l.outputs);
    if (l.batch_normalize and !l.dontloadscales) {
        try r.readInto(f32, l.scales[0..l.outputs]);
        try r.readInto(f32, l.rolling_mean[0..l.outputs]);
        try r.readInto(f32, l.rolling_variance[0..l.outputs]);
    }
    if (gpu.active()) connected.push(l);
}

fn loadBatchnormWeights(l: *Layer, r: *sys.BinReader) !void {
    try r.readInto(f32, l.scales[0..l.c]);
    try r.readInto(f32, l.rolling_mean[0..l.c]);
    try r.readInto(f32, l.rolling_variance[0..l.c]);
    if (gpu.active()) batchnorm.push(l);
}

pub fn loadWeights(net: *Network, path: []const u8) !void {
    try loadWeightsUpto(net, path, 0, net.layers.len);
}

pub fn loadWeightsUpto(net: *Network, path: []const u8, start: usize, cutoff: usize) !void {
    std.debug.print("Loading weights from {s}...", .{path});

    var r = try sys.BinReader.open(path);
    defer r.close();

    const major = try r.readOne(i32);
    const minor = try r.readOne(i32);
    _ = try r.readOne(i32); // revision

    // Version 0.2 widened `seen` from int to size_t. Values above 1000 in the
    // version fields are the old "transposed connected weights" marker, not a
    // version at all, hence the bounds on the comparison.
    if ((major * 10 + minor) >= 2 and major < 1000 and minor < 1000) {
        net.seen = try r.readOne(u64);
    } else {
        net.seen = @intCast(@max(0, try r.readOne(i32)));
    }
    const transpose = (major > 1000) or (minor > 1000);

    var i = start;
    while (i < net.layers.len and i < cutoff) : (i += 1) {
        const l = &net.layers[i];
        if (l.dontload) continue;
        switch (l.kind) {
            .convolutional => try loadConvolutionalWeights(l, &r),
            .connected => try loadConnectedWeights(l, &r, transpose),
            .batchnorm => try loadBatchnormWeights(l, &r),
            else => {},
        }
    }
    std.debug.print("Done!\n", .{});
}

// ---------------------------------------------------------------------------
// weights: save
// ---------------------------------------------------------------------------

fn saveConvolutionalWeights(l: *Layer, w: *sys.BinWriter) !void {
    try w.write(f32, l.biases[0..l.n]);
    if (l.batch_normalize) {
        try w.write(f32, l.scales[0..l.n]);
        try w.write(f32, l.rolling_mean[0..l.n]);
        try w.write(f32, l.rolling_variance[0..l.n]);
    }
    try w.write(f32, l.weights[0..l.nweights]);
}

fn saveConnectedWeights(l: *Layer, w: *sys.BinWriter) !void {
    try w.write(f32, l.biases[0..l.outputs]);
    try w.write(f32, l.weights[0 .. l.outputs * l.inputs]);
    if (l.batch_normalize) {
        try w.write(f32, l.scales[0..l.outputs]);
        try w.write(f32, l.rolling_mean[0..l.outputs]);
        try w.write(f32, l.rolling_variance[0..l.outputs]);
    }
}

fn saveBatchnormWeights(l: *Layer, w: *sys.BinWriter) !void {
    try w.write(f32, l.scales[0..l.c]);
    try w.write(f32, l.rolling_mean[0..l.c]);
    try w.write(f32, l.rolling_variance[0..l.c]);
}

pub fn saveWeights(net: *Network, path: []const u8) !void {
    try saveWeightsUpto(net, path, net.layers.len);
}

pub fn saveWeightsUpto(net: *Network, path: []const u8, cutoff: usize) !void {
    std.debug.print("Saving weights to {s}\n", .{path});
    // Parameters live on the device while training on a GPU; bring them back
    // before writing.
    net_mod.pullWeights(net);

    var w = try sys.BinWriter.create(path);
    errdefer w.abort();

    try w.writeOne(i32, 0); // major
    try w.writeOne(i32, 2); // minor
    try w.writeOne(i32, 0); // revision
    try w.writeOne(u64, net.seen);

    var i: usize = 0;
    while (i < net.layers.len and i < cutoff) : (i += 1) {
        const l = &net.layers[i];
        if (l.dontsave) continue;
        switch (l.kind) {
            .convolutional => try saveConvolutionalWeights(l, &w),
            .connected => try saveConnectedWeights(l, &w),
            .batchnorm => try saveBatchnormWeights(l, &w),
            else => {},
        }
    }
    try w.finish();
}
