//! The `benchmark` subcommand: measure training throughput, inference
//! throughput and accuracy for one network on one platform.
//!
//! This exists rather than having the benchmark script scrape `classifier
//! train` output for two reasons. Timings taken inside the process can
//! separate the parts that matter -- forward/backward versus image decoding,
//! which the loader overlaps anyway -- and the output is key=value lines that
//! a script can read without a parser that breaks the next time a log line
//! changes.
//!
//! Training length comes from `-train-batches` rather than the config's
//! `max_batches`, so the same stock cfg can be used for a 30-second smoke run
//! and a long one.

const std = @import("std");
const sys = @import("sys.zig");
const cfg_mod = @import("cfg.zig");
const data_mod = @import("data.zig");
const net_mod = @import("network.zig");
const parser = @import("parser.zig");
const matrix = @import("matrix.zig");
const utils = @import("utils.zig");
const gpu = @import("gpu.zig");

const Network = net_mod.Network;

pub const Options = struct {
    data_cfg: []const u8,
    net_cfg: []const u8,
    weights: ?[]const u8 = null,
    train_batches: usize = 100,
    /// 0 means "the whole validation list".
    infer_images: usize = 0,
    /// Batches to run before starting the clock, so one-off costs (first
    /// allocation, kernel JIT, cache warming) do not land in the average.
    warmup_batches: usize = 3,
    threads: usize = 8,
    /// Where to write the trained weights, if anywhere.
    save_to: ?[]const u8 = null,
};

fn emit(comptime key: []const u8, comptime fmt: []const u8, args: anytype) void {
    sys.print(key ++ "=" ++ fmt ++ "\n", args);
}

pub fn run(allocator: std.mem.Allocator, opts: Options) !void {
    var dcfg = try cfg_mod.readDataCfg(allocator, opts.data_cfg);
    defer dcfg.deinit();
    var o = &dcfg.options;

    const label_list = o.str("labels", "data/labels.list").?;
    const train_list = o.str("train", "data/train.list").?;
    const valid_list = o.str("valid", "data/valid.list").?;

    var labels = try data_mod.StringList.read(allocator, label_list);
    defer labels.deinit(allocator);
    const classes = labels.items.len;

    const base = try utils.baseCfg(allocator, opts.net_cfg);
    defer allocator.free(base);

    emit("backend", "{s}", .{if (gpu.active()) gpu.backend_label else "CPU"});
    emit("net", "{s}", .{base});
    emit("classes", "{d}", .{classes});

    // ---------------------------------------------------------------
    // training
    // ---------------------------------------------------------------
    var trained_weights: ?[]const u8 = opts.weights;
    var owned_weights: ?[]u8 = null;
    defer if (owned_weights) |w| allocator.free(w);

    if (opts.train_batches > 0) {
        var paths = try data_mod.StringList.read(allocator, train_list);
        defer paths.deinit(allocator);
        if (paths.items.len == 0) return error.NoTrainingData;

        var net = try parser.loadNetwork(allocator, opts.net_cfg, opts.weights, true);
        defer net.deinit();

        emit("train_batch", "{d}", .{net.batch * net.subdivisions});
        emit("train_pool_images", "{d}", .{paths.items.len});

        const fw: f32 = @floatFromInt(net.w);
        var loader = data_mod.Loader.init(allocator, .{
            .paths = paths.items,
            .labels = labels.items,
            .n = net.batch * net.subdivisions,
            .size = net.w,
            .min = @intFromFloat(net.min_ratio * fw),
            .max = @intFromFloat(net.max_ratio * fw),
            .angle = net.angle,
            .aspect = net.aspect,
            .flip = net.flip,
            .hue = net.hue,
            .saturation = net.saturation,
            .exposure = net.exposure,
            .center = net.center,
            .shuffle = true,
            .threads = opts.threads,
        });
        loader.start();
        defer loader.drain();

        var elapsed: f64 = 0;
        var images: usize = 0;
        var last_loss: f32 = 0;
        var loss_sum: f32 = 0;
        var counted: usize = 0;

        const total = opts.warmup_batches + opts.train_batches;
        for (0..total) |i| {
            var batch = try loader.wait();
            loader.start();

            const t0 = sys.now();
            last_loss = net_mod.trainNetwork(&net, batch);
            // The GPU queue is asynchronous; without this the clock would
            // measure how fast work was *submitted*, not how fast it ran.
            if (gpu.active()) gpu.sync();
            const dt = sys.now() - t0;
            batch.deinit(allocator);

            if (i >= opts.warmup_batches) {
                elapsed += dt;
                images += net.batch * net.subdivisions;
                loss_sum += last_loss;
                counted += 1;
            }
        }

        emit("train_batches", "{d}", .{opts.train_batches});
        emit("train_images", "{d}", .{images});
        emit("train_seconds", "{d:.3}", .{elapsed});
        emit("train_images_per_sec", "{d:.1}", .{@as(f64, @floatFromInt(images)) / elapsed});
        emit("train_mean_loss", "{d:.4}", .{loss_sum / @as(f32, @floatFromInt(@max(counted, 1)))});
        emit("train_final_loss", "{d:.4}", .{last_loss});

        // Inference needs a separate network built at a different batch size,
        // so the trained parameters have to go through a file.
        const dest = opts.save_to orelse blk: {
            const p = try std.fmt.allocPrint(allocator, "{s}.bench.weights", .{base});
            owned_weights = p;
            break :blk p;
        };
        try parser.saveWeights(&net, dest);
        trained_weights = dest;
    }

    // ---------------------------------------------------------------
    // inference
    // ---------------------------------------------------------------
    var valid = try data_mod.StringList.read(allocator, valid_list);
    defer valid.deinit(allocator);
    if (valid.items.len == 0) return error.NoValidationData;

    const want = if (opts.infer_images == 0) valid.items.len else @min(opts.infer_images, valid.items.len);

    var net = try parser.loadNetwork(allocator, opts.net_cfg, trained_weights, false);
    defer net.deinit();
    const batch = net.batch;
    emit("infer_batch", "{d}", .{batch});
    emit("infer_images", "{d}", .{want});

    const topk = @min(@as(usize, 5), classes);
    const indexes = try allocator.alloc(usize, topk);
    defer allocator.free(indexes);

    var top1: usize = 0;
    var topn: usize = 0;
    var seen: usize = 0;
    var forward_seconds: f64 = 0;
    var load_seconds: f64 = 0;

    var offset: usize = 0;
    while (offset < want) : (offset += batch) {
        const n = @min(batch, want - offset);
        const chunk = valid.items[offset .. offset + n];

        // Centre crop, no augmentation -- the deterministic path, same as
        // `classifier valid`.
        const t_load = sys.now();
        var d = try data_mod.loadClassification(allocator, .{
            .paths = chunk,
            .labels = labels.items,
            .n = n,
            .size = net.w,
            .center = true,
            .shuffle = false,
            .threads = opts.threads,
        });
        defer d.deinit(allocator);
        load_seconds += sys.now() - t_load;

        // One flat buffer of n images, exactly what the network wants.
        const x = try allocator.alloc(f32, net.inputs * batch);
        defer allocator.free(x);
        @memset(x, 0);
        for (0..n) |i| @memcpy(x[i * d.x.cols ..][0..d.x.cols], d.x.vals[i]);

        const t0 = sys.now();
        const out = net_mod.predict(&net, x);
        if (gpu.active()) gpu.sync();
        forward_seconds += sys.now() - t0;

        for (0..n) |i| {
            const scores = out[i * net.outputs ..][0..@min(classes, net.outputs)];
            utils.topK(scores, indexes);
            const truth = d.y.vals[i];
            if (truth[indexes[0]] != 0) top1 += 1;
            for (indexes) |idx| {
                if (truth[idx] != 0) {
                    topn += 1;
                    break;
                }
            }
            seen += 1;
        }
    }

    const fseen: f64 = @floatFromInt(seen);
    emit("infer_forward_seconds", "{d:.3}", .{forward_seconds});
    emit("infer_forward_images_per_sec", "{d:.1}", .{fseen / forward_seconds});
    emit("infer_load_seconds", "{d:.3}", .{load_seconds});
    emit("infer_end_to_end_images_per_sec", "{d:.1}", .{fseen / (forward_seconds + load_seconds)});
    emit("top1", "{d:.4}", .{fseen_ratio(top1, seen)});
    if (topk > 1) {
        emit("top{d}", "{d:.4}", .{ topk, fseen_ratio(topn, seen) });
    }
}

fn fseen_ratio(hits: usize, total: usize) f64 {
    if (total == 0) return 0;
    return @as(f64, @floatFromInt(hits)) / @as(f64, @floatFromInt(total));
}
