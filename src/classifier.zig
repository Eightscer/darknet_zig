//! The classifier commands: train, validate and predict. The port of
//! darknet's examples/classifier.c, minus the tag/regression/label variants.

const std = @import("std");
const sys = @import("sys.zig");
const cfg_mod = @import("cfg.zig");
const data_mod = @import("data.zig");
const net_mod = @import("network.zig");
const parser = @import("parser.zig");
const image = @import("image.zig");
const matrix = @import("matrix.zig");
const utils = @import("utils.zig");

const Network = net_mod.Network;

pub const Options = struct {
    data_cfg: []const u8,
    net_cfg: []const u8,
    weights: ?[]const u8 = null,
    input: ?[]const u8 = null,
    clear: bool = false,
    top: usize = 0,
    threads: usize = 8,
};

fn loaderArgs(net: *Network, paths: []const []const u8, labels: []const []const u8, opts: Options) data_mod.LoadArgs {
    const fw: f32 = @floatFromInt(net.w);
    return .{
        .paths = paths,
        .labels = labels,
        .n = net.batch * net.subdivisions,
        .size = net.w,
        .min = @intFromFloat(net.min_ratio * fw),
        .max = @intFromFloat(net.max_ratio * fw),
        .angle = net.angle,
        .aspect = net.aspect,
        .hue = net.hue,
        .saturation = net.saturation,
        .exposure = net.exposure,
        .center = net.center,
        .shuffle = true,
        .threads = opts.threads,
    };
}

pub fn train(allocator: std.mem.Allocator, opts: Options) !void {
    var dcfg = try cfg_mod.readDataCfg(allocator, opts.data_cfg);
    defer dcfg.deinit();
    var o = &dcfg.options;

    const backup_dir = o.str("backup", "backup").?;
    const label_list = o.str("labels", "data/labels.list").?;
    const train_list = o.str("train", "data/train.list").?;
    const classes: usize = @intCast(@max(1, o.int("classes", 2)));

    const base = try utils.baseCfg(allocator, opts.net_cfg);
    defer allocator.free(base);

    var net = try parser.loadNetwork(allocator, opts.net_cfg, opts.weights, opts.clear);
    defer net.deinit();

    var labels = try data_mod.StringList.read(allocator, label_list);
    defer labels.deinit(allocator);
    if (labels.items.len != classes) {
        std.debug.print(
            "Warning: {s} lists {d} labels but classes={d} in {s}\n",
            .{ label_list, labels.items.len, classes, opts.data_cfg },
        );
    }

    var paths = try data_mod.StringList.read(allocator, train_list);
    defer paths.deinit(allocator);
    if (paths.items.len == 0) {
        std.debug.print("No training images listed in {s}\n", .{train_list});
        return error.NoTrainingData;
    }

    const n_images = paths.items.len;
    sys.print("{s}\n{d} training images, {d} classes\n", .{ base, n_images, labels.items.len });
    sys.print("Learning Rate: {d}, Momentum: {d}, Decay: {d}\n", .{ net.learning_rate, net.momentum, net.decay });

    var loader = data_mod.Loader.init(allocator, loaderArgs(&net, paths.items, labels.items, opts));
    loader.start();
    defer loader.drain();

    var avg_loss: f32 = -1;
    var epoch: u64 = net.seen / n_images;

    while (net.max_batches == 0 or net.currentBatch() < net.max_batches) {
        var t0 = sys.now();
        var train_data = try loader.wait();
        // Start decoding the next batch before touching this one, so image
        // loading overlaps the forward/backward pass.
        loader.start();
        const load_time = sys.now() - t0;

        t0 = sys.now();
        const loss = net_mod.trainNetwork(&net, train_data);
        avg_loss = if (avg_loss < 0) loss else avg_loss * 0.9 + loss * 0.1;

        sys.print("{d}, {d:.3}: {d}, {d} avg, {d} rate, {d:.3} s train, {d:.3} s load, {d} images\n", .{
            net.currentBatch(),
            @as(f32, @floatFromInt(net.seen)) / @as(f32, @floatFromInt(n_images)),
            loss,
            avg_loss,
            net_mod.currentRate(&net),
            sys.now() - t0,
            load_time,
            net.seen,
        });
        train_data.deinit(allocator);

        if (net.seen / n_images > epoch) {
            epoch = net.seen / n_images;
            var buf: [1024]u8 = undefined;
            const p = try std.fmt.bufPrint(&buf, "{s}/{s}_{d}.weights", .{ backup_dir, base, epoch });
            try parser.saveWeights(&net, p);
        }
        if (net.currentBatch() % 1000 == 0) {
            var buf: [1024]u8 = undefined;
            const p = try std.fmt.bufPrint(&buf, "{s}/{s}.backup", .{ backup_dir, base });
            try parser.saveWeights(&net, p);
        }
    }

    var buf: [1024]u8 = undefined;
    const p = try std.fmt.bufPrint(&buf, "{s}/{s}.weights", .{ backup_dir, base });
    try parser.saveWeights(&net, p);
}

/// Top-1 and top-k accuracy over the validation list, one centre crop per
/// image. darknet calls this `validate_classifier_single`.
pub fn validate(allocator: std.mem.Allocator, opts: Options) !void {
    var dcfg = try cfg_mod.readDataCfg(allocator, opts.data_cfg);
    defer dcfg.deinit();
    var o = &dcfg.options;

    const label_list = o.str("labels", "data/labels.list").?;
    const valid_list = o.str("valid", "data/train.list").?;
    const classes: usize = @intCast(@max(1, o.int("classes", 2)));
    const topk: usize = if (opts.top != 0) opts.top else @intCast(@max(1, o.int("top", 1)));

    // Build at batch=1 rather than the config's training batch: activation
    // buffers are sized batch*outputs, and for tiny.cfg (batch=128) the
    // difference is 6.6 GB of allocations that inference never touches.
    var net = try parser.loadNetworkWith(allocator, opts.net_cfg, opts.weights, false, .{ .batch = 1 });
    defer net.deinit();

    var labels = try data_mod.StringList.read(allocator, label_list);
    defer labels.deinit(allocator);
    var paths = try data_mod.StringList.read(allocator, valid_list);
    defer paths.deinit(allocator);

    const indexes = try allocator.alloc(usize, topk);
    defer allocator.free(indexes);

    var top1: f32 = 0;
    var topn: f32 = 0;

    for (paths.items, 0..) |path, i| {
        // The class is whichever label appears in the path, matching how the
        // training targets were assigned.
        var class: ?usize = null;
        for (labels.items, 0..) |label, j| {
            if (std.mem.indexOf(u8, path, label) != null) {
                class = j;
                break;
            }
        }

        var im = try image.loadColor(allocator, path, 0, 0);
        defer im.deinit(allocator);
        var cropped = try image.centerCrop(allocator, im, net.w, net.h);
        defer cropped.deinit(allocator);

        const pred = net_mod.predict(&net, cropped.data);
        utils.topK(pred[0..@min(classes, net.outputs)], indexes);

        if (class) |c| {
            if (indexes[0] == c) top1 += 1;
            for (indexes) |idx| {
                if (idx == c) {
                    topn += 1;
                    break;
                }
            }
        }

        const seen: f32 = @floatFromInt(i + 1);
        sys.print("{d}: top 1: {d:.4}, top {d}: {d:.4}\n", .{ i, top1 / seen, topk, topn / seen });
    }
}

pub fn predict(allocator: std.mem.Allocator, opts: Options) !void {
    var dcfg = try cfg_mod.readDataCfg(allocator, opts.data_cfg);
    defer dcfg.deinit();
    var o = &dcfg.options;

    const name_list = o.str("names", null) orelse o.str("labels", "data/labels.list").?;
    const top: usize = if (opts.top != 0) opts.top else @intCast(@max(1, o.int("top", 1)));

    // Build at batch=1 rather than the config's training batch: activation
    // buffers are sized batch*outputs, and for tiny.cfg (batch=128) the
    // difference is 6.6 GB of allocations that inference never touches.
    var net = try parser.loadNetworkWith(allocator, opts.net_cfg, opts.weights, false, .{ .batch = 1 });
    defer net.deinit();

    var names = try data_mod.StringList.read(allocator, name_list);
    defer names.deinit(allocator);

    const input_path = opts.input orelse {
        std.debug.print("classifier predict needs an image path\n", .{});
        return error.MissingArgument;
    };

    var im = try image.loadColor(allocator, input_path, 0, 0);
    defer im.deinit(allocator);
    var boxed = try image.letterbox(allocator, im, net.w, net.h);
    defer boxed.deinit(allocator);

    const t0 = sys.now();
    const predictions = net_mod.predict(&net, boxed.data);
    const elapsed = sys.now() - t0;

    const k = @min(top, net.outputs);
    const indexes = try allocator.alloc(usize, k);
    defer allocator.free(indexes);
    utils.topK(predictions[0..net.outputs], indexes);

    std.debug.print("{s}: Predicted in {d:.6} seconds.\n", .{ input_path, elapsed });
    for (indexes) |index| {
        const name = if (index < names.items.len) names.items[index] else "<unnamed>";
        sys.print("{d:5.2}%: {s}\n", .{ predictions[index] * 100, name });
    }
}
