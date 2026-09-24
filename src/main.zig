//! darknet-zig: a Zig rewrite of pjreddie's darknet, scoped to training and
//! running image classifiers, with AMD (HIP) and NVIDIA (CUDA) GPU backends.
//!
//! Usage:
//!   darknet-zig classifier train   <data.cfg> <net.cfg> [weights] [-clear]
//!   darknet-zig classifier valid   <data.cfg> <net.cfg> <weights>
//!   darknet-zig classifier predict <data.cfg> <net.cfg> <weights> <image>
//!   darknet-zig gputest
//!
//! Common flags: -gpu <index>, -seed <n>, -threads <n>, -top <k>

const std = @import("std");
const build_options = @import("build_options");
const sys = @import("sys.zig");
const utils = @import("utils.zig");
const gpu = @import("gpu.zig");
const classifier = @import("classifier.zig");
const gputest = @import("gputest.zig");
const benchmark = @import("benchmark.zig");

const usage =
    \\darknet-zig -- neural networks in Zig, with AMD (HIP) and NVIDIA (CUDA) backends
    \\
    \\Usage:
    \\  darknet-zig classifier train   <data.cfg> <net.cfg> [weights] [options]
    \\  darknet-zig classifier valid   <data.cfg> <net.cfg> <weights>  [options]
    \\  darknet-zig classifier predict <data.cfg> <net.cfg> <weights> <image> [options]
    \\  darknet-zig benchmark      <data.cfg> <net.cfg> [options]
    \\  darknet-zig gputest [options]
    \\
    \\Options:
    \\  -gpu <index>     Run on GPU device <index> (default: CPU)
    \\  -seed <n>        Seed the random number generator (default: time based)
    \\  -threads <n>     Image loader worker tasks (default: 8)
    \\  -top <k>         Report the k highest-scoring classes (default: from data.cfg)
    \\  -clear           Reset the seen-images counter when resuming from weights
    \\
    \\benchmark options:
    \\  -train-batches N Batches to time (default 100; 0 skips training)
    \\  -infer-images N  Validation images to time (default: all)
    \\  -warmup N        Untimed batches before the clock starts (default 3)
    \\  -save-weights W  Keep the trained weights at this path
    \\
;

/// A flag and its optional value stripped out of argv, leaving the
/// positionals behind in order -- the same shape darknet's `find_int_arg`
/// gave, without mutating a global argv.
const Args = struct {
    positional: [][]const u8,
    gpu_index: i32 = -1,
    seed: ?u64 = null,
    threads: usize = 8,
    top: usize = 0,
    clear: bool = false,
    train_batches: usize = 100,
    infer_images: usize = 0,
    warmup: usize = 3,
    save_weights: ?[]const u8 = null,

    fn parse(allocator: std.mem.Allocator, argv: []const []const u8) !Args {
        var positional: std.ArrayList([]const u8) = .empty;
        errdefer positional.deinit(allocator);

        var self: Args = .{ .positional = &.{} };
        var i: usize = 0;
        while (i < argv.len) : (i += 1) {
            const a = argv[i];
            if (std.mem.eql(u8, a, "-clear")) {
                self.clear = true;
            } else if (std.mem.eql(u8, a, "-gpu") or std.mem.eql(u8, a, "-gpus")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.gpu_index = utils.parseInt(argv[i], 0);
            } else if (std.mem.eql(u8, a, "-seed")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.seed = @intCast(@max(0, utils.parseInt(argv[i], 0)));
            } else if (std.mem.eql(u8, a, "-threads")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.threads = @intCast(@max(1, utils.parseInt(argv[i], 8)));
            } else if (std.mem.eql(u8, a, "-train-batches")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.train_batches = @intCast(@max(0, utils.parseInt(argv[i], 100)));
            } else if (std.mem.eql(u8, a, "-infer-images")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.infer_images = @intCast(@max(0, utils.parseInt(argv[i], 0)));
            } else if (std.mem.eql(u8, a, "-warmup")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.warmup = @intCast(@max(0, utils.parseInt(argv[i], 3)));
            } else if (std.mem.eql(u8, a, "-save-weights")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.save_weights = argv[i];
            } else if (std.mem.eql(u8, a, "-top")) {
                i += 1;
                if (i >= argv.len) return error.MissingArgument;
                self.top = @intCast(@max(1, utils.parseInt(argv[i], 1)));
            } else {
                try positional.append(allocator, a);
            }
        }
        self.positional = try positional.toOwnedSlice(allocator);
        return self;
    }
};

pub fn main(init: std.process.Init) u8 {
    // Returning `u8` rather than `!void` keeps Zig from dumping an error
    // return trace on the way out. Every failure path below has already
    // printed something a user can act on; a stack trace through the config
    // parser adds nothing to "that file is not a .cfg".
    run(init) catch |err| {
        std.debug.print("error: {t}\n", .{err});
        return 1;
    };
    return 0;
}

fn run(init: std.process.Init) !void {
    // This program links libc anyway (for stb_image) and allocates from
    // several loader tasks at once, so the C allocator is both available and
    // a good fit.
    const allocator = std.heap.c_allocator;

    // Own thread pool rather than `init.io`, purely to raise `async_limit`.
    // Two kinds of task compete for it: the image loader (one task that fans
    // out into per-chunk decode tasks) and the row split inside the CPU GEMM.
    // The default limit is cpu_count-1, and `Io.Threaded.async` runs a task
    // inline once the limit is hit -- correct, but it would collapse the
    // loader's fan-out back to a single thread exactly when training needs it
    // most. Threads are spawned lazily, so the headroom is free when unused.
    const cpus = std.Thread.getCpuCount() catch 4;
    var threaded: std.Io.Threaded = .init(allocator, .{
        .async_limit = .limited(@max(16, cpus * 2)),
    });
    defer threaded.deinit();
    sys.init(threaded.io(), allocator);

    const argv = try init.minimal.args.toSlice(init.arena.allocator());

    if (argv.len < 2) {
        sys.print("{s}", .{usage});
        return;
    }

    // argv comes back sentinel-terminated; the rest of the code wants plain
    // slices.
    const raw = try allocator.alloc([]const u8, argv.len - 1);
    defer allocator.free(raw);
    for (argv[1..], 0..) |a, i| raw[i] = a;

    var args = try Args.parse(allocator, raw);
    defer allocator.free(args.positional);

    // Seed from the clock unless asked otherwise, so successive training runs
    // see different augmentation and different weight initialisation.
    utils.seedDefault(args.seed orelse @truncate(@as(u96, @bitCast(std.Io.Timestamp.now(sys.io, .real).nanoseconds))));

    if (args.gpu_index >= 0) {
        try gpu.init(allocator, args.gpu_index);
    } else if (build_options.gpu) {
        std.debug.print("Running on the CPU; pass -gpu <index> to use the {s} backend.\n", .{gpu.backend_label});
    }
    defer gpu.deinit();

    if (args.positional.len == 0) {
        sys.print("{s}", .{usage});
        return;
    }

    const command = args.positional[0];
    const rest = args.positional[1..];

    if (std.mem.eql(u8, command, "benchmark")) {
        if (rest.len != 2) {
            std.debug.print("benchmark takes <data.cfg> <net.cfg>; got {d} argument(s)\n", .{rest.len});
            return error.WrongArgumentCount;
        }
        return benchmark.run(allocator, .{
            .data_cfg = rest[0],
            .net_cfg = rest[1],
            .train_batches = args.train_batches,
            .infer_images = args.infer_images,
            .warmup_batches = args.warmup,
            .threads = args.threads,
            .save_to = args.save_weights,
        });
    }

    if (std.mem.eql(u8, command, "gputest")) {
        return gputest.run(allocator);
    }

    if (std.mem.eql(u8, command, "classifier")) {
        if (rest.len == 0) {
            sys.print("{s}", .{usage});
            return error.MissingArgument;
        }
        const sub = rest[0];
        const positionals = rest[1..];

        // Check the count per subcommand before touching the filesystem.
        // Getting this wrong -- typically by omitting the net cfg, so the
        // weights file lands in its slot -- is the easiest mistake to make
        // here, and it is much better to say so than to start parsing a
        // 4 MB binary as text. (Upstream darknet segfaults on exactly this.)
        const spec: struct { min: usize, max: usize, form: []const u8 } = if (std.mem.eql(u8, sub, "train"))
            .{ .min = 2, .max = 3, .form = "<data.cfg> <net.cfg> [weights]" }
        else if (std.mem.eql(u8, sub, "valid") or std.mem.eql(u8, sub, "validate"))
            .{ .min = 3, .max = 3, .form = "<data.cfg> <net.cfg> <weights>" }
        else if (std.mem.eql(u8, sub, "predict") or std.mem.eql(u8, sub, "test"))
            .{ .min = 4, .max = 4, .form = "<data.cfg> <net.cfg> <weights> <image>" }
        else {
            std.debug.print("Unknown classifier subcommand: {s}\n\n", .{sub});
            sys.print("{s}", .{usage});
            return error.UnknownCommand;
        };

        if (positionals.len < spec.min or positionals.len > spec.max) {
            std.debug.print(
                "classifier {s} takes {s}\n  got {d} argument(s):",
                .{ sub, spec.form, positionals.len },
            );
            for (positionals) |p| std.debug.print(" {s}", .{p});
            std.debug.print("\n", .{});
            return error.WrongArgumentCount;
        }

        const opts: classifier.Options = .{
            .data_cfg = positionals[0],
            .net_cfg = positionals[1],
            .weights = if (positionals.len > 2) positionals[2] else null,
            .input = if (positionals.len > 3) positionals[3] else null,
            .clear = args.clear,
            .top = args.top,
            .threads = args.threads,
        };
        if (std.mem.eql(u8, sub, "train")) return classifier.train(allocator, opts);
        if (std.mem.eql(u8, sub, "valid") or std.mem.eql(u8, sub, "validate")) return classifier.validate(allocator, opts);
        return classifier.predict(allocator, opts);
    }

    std.debug.print("Unknown command: {s}\n\n", .{command});
    sys.print("{s}", .{usage});
    return error.UnknownCommand;
}

test {
    // Referencing each module pulls its `test` blocks into this build.
    _ = @import("utils.zig");
    _ = @import("activations.zig");
    _ = @import("blas.zig");
    _ = @import("gemm.zig");
    _ = @import("im2col.zig");
    _ = @import("image.zig");
    _ = @import("data.zig");
    _ = @import("cfg.zig");
    _ = @import("parser.zig");
    _ = @import("network.zig");
    _ = @import("smoke_test.zig");
}
