//! Dataset loading for classification.
//!
//! One image is decoded, augmented and stored as a row of `x`; its one-hot
//! label vector becomes the matching row of `y`. Decoding dominates training
//! time on the CPU and would otherwise leave the GPU idle, so loading happens
//! on `std.Io` worker tasks while the previous batch trains -- the same
//! double-buffering darknet did with pthreads, minus the shared mutable RNG.

const std = @import("std");
const sys = @import("sys.zig");
const utils = @import("utils.zig");
const image = @import("image.zig");
const matrix = @import("matrix.zig");

const Matrix = matrix.Matrix;
const Rng = utils.Rng;

/// A list of newline-separated strings that owns the file it was read from;
/// the entries are slices into that single buffer.
pub const StringList = struct {
    buffer: []u8,
    items: [][]const u8,

    pub fn read(allocator: std.mem.Allocator, path: []const u8) !StringList {
        const buffer = try sys.readTextFile(path);
        errdefer allocator.free(buffer);

        var items: std.ArrayList([]const u8) = .empty;
        errdefer items.deinit(allocator);

        var it = sys.LineIter.init(buffer);
        while (it.next()) |line| {
            const trimmed = utils.strip(line);
            if (trimmed.len == 0) continue;
            try items.append(allocator, trimmed);
        }
        return .{ .buffer = buffer, .items = try items.toOwnedSlice(allocator) };
    }

    pub fn deinit(self: *StringList, allocator: std.mem.Allocator) void {
        allocator.free(self.items);
        allocator.free(self.buffer);
        self.* = undefined;
    }
};

pub const Data = struct {
    w: usize = 0,
    h: usize = 0,
    x: Matrix = .{},
    y: Matrix = .{},

    pub fn deinit(self: *Data, allocator: std.mem.Allocator) void {
        self.x.deinit(allocator);
        self.y.deinit(allocator);
        self.* = .{};
    }
};

/// Set the one-hot target for `path` by looking for each class name as a
/// substring of the path. Crude, but it is the convention every darknet
/// classification dataset follows: the class name appears in the directory.
pub fn fillTruth(path: []const u8, labels: []const []const u8, truth: []f32) void {
    @memset(truth, 0);
    var count: usize = 0;
    for (labels, 0..) |label, i| {
        if (std.mem.indexOf(u8, path, label) != null) {
            truth[i] = 1;
            count += 1;
        }
    }
    if (count != 1 and !(labels.len == 1 and count == 0)) {
        std.debug.print("Too many or too few labels: {d}, {s}\n", .{ count, path });
    }
}

pub const LoadArgs = struct {
    /// Every path in the dataset.
    paths: []const []const u8 = &.{},
    /// Class names, in output-unit order.
    labels: []const []const u8 = &.{},
    /// How many images to produce.
    n: usize = 0,
    /// Output crop edge, in pixels.
    size: usize = 0,
    /// Shortest-side crop range for random scaling.
    min: i32 = 0,
    max: i32 = 0,
    angle: f32 = 0,
    aspect: f32 = 1,
    hue: f32 = 0,
    saturation: f32 = 1,
    exposure: f32 = 1,
    /// Random horizontal mirroring. Upstream darknet's `[net] flip`, which
    /// defaults on because it is the right call for natural images -- but it
    /// is actively wrong wherever left and right mean different things, and a
    /// mirrored digit is not that digit. Turn it off with `flip=0`.
    flip: bool = true,
    /// Deterministic centre crop instead of random augmentation.
    center: bool = false,
    /// Sample uniformly at random rather than walking `paths` in order.
    shuffle: bool = true,
    threads: usize = 8,
};

const Chunk = struct {
    allocator: std.mem.Allocator,
    args: LoadArgs,
    /// The paths this worker is responsible for.
    paths: []const []const u8,
    /// Destination rows, one per path.
    x_rows: [][]f32,
    y_rows: [][]f32,
    seed: u64,
    err: ?anyerror = null,
};

fn loadChunk(chunk: *Chunk) void {
    var rng = Rng.init(chunk.seed);
    const a = chunk.args;
    for (chunk.paths, 0..) |path, i| {
        loadOne(chunk.allocator, &rng, a, path, &chunk.x_rows[i], chunk.y_rows[i]) catch |err| {
            chunk.err = err;
            return;
        };
    }
}

fn loadOne(
    allocator: std.mem.Allocator,
    rng: *Rng,
    a: LoadArgs,
    path: []const u8,
    x_row: *[]f32,
    y_row: []f32,
) !void {
    var im = try image.loadColor(allocator, path, 0, 0);
    defer im.deinit(allocator);

    var cropped = if (a.center)
        try image.centerCrop(allocator, im, a.size, a.size)
    else
        try image.randomAugment(allocator, rng, im, a.angle, a.aspect, a.min, a.max, a.size, a.size);
    errdefer cropped.deinit(allocator);

    if (!a.center) {
        if (a.flip and rng.boolean()) image.flip(cropped);
        image.randomDistort(rng, cropped, a.hue, a.saturation, a.exposure);
    }

    // Ownership of the pixel buffer moves straight into the data matrix; at
    // 224x224x3 floats per image, copying here would be the single largest
    // memory traffic in the loader.
    x_row.* = cropped.toOwnedSlice();
    if (a.labels.len != 0) fillTruth(path, a.labels, y_row);
}

/// Loads `args.n` images, fanning the decode work out across worker tasks.
/// Blocks until every image is ready; see `Loader` for the overlapped version.
pub fn loadClassification(allocator: std.mem.Allocator, args: LoadArgs) !Data {
    var d: Data = .{ .w = args.size, .h = args.size };
    errdefer d.deinit(allocator);

    // Choose the sample up front on one thread: workers then need no shared
    // RNG, and a run is reproducible from the top-level seed alone.
    const chosen = try allocator.alloc([]const u8, args.n);
    defer allocator.free(chosen);
    for (chosen, 0..) |*p, i| {
        p.* = if (args.shuffle)
            args.paths[utils.default.index(args.paths.len)]
        else
            args.paths[i % args.paths.len];
    }

    d.x = try Matrix.initRowsUnset(allocator, args.n);
    d.x.cols = args.size * args.size * 3;
    d.y = try Matrix.init(allocator, args.n, args.labels.len);

    const nthreads = @max(1, @min(args.threads, args.n));
    const chunks = try allocator.alloc(Chunk, nthreads);
    defer allocator.free(chunks);
    const futures = try allocator.alloc(std.Io.Future(void), nthreads);
    defer allocator.free(futures);

    const per = (args.n + nthreads - 1) / nthreads;
    var started: usize = 0;
    var offset: usize = 0;
    while (offset < args.n) : (started += 1) {
        const end = @min(offset + per, args.n);
        chunks[started] = .{
            .allocator = allocator,
            .args = args,
            .paths = chosen[offset..end],
            .x_rows = d.x.vals[offset..end],
            .y_rows = d.y.vals[offset..end],
            .seed = utils.default.u64Value(),
        };
        futures[started] = sys.io.async(loadChunk, .{&chunks[started]});
        offset = end;
    }

    var first_err: ?anyerror = null;
    for (futures[0..started], 0..) |*f, i| {
        f.await(sys.io);
        if (chunks[i].err) |e| first_err = first_err orelse e;
    }
    if (first_err) |e| return e;
    return d;
}

/// Double-buffered loader: `start` kicks off the next batch, `wait` collects
/// it. Call `start` again immediately after `wait` so decoding overlaps the
/// training step.
pub const Loader = struct {
    allocator: std.mem.Allocator,
    args: LoadArgs,
    future: ?std.Io.Future(anyerror!Data) = null,

    pub fn init(allocator: std.mem.Allocator, args: LoadArgs) Loader {
        return .{ .allocator = allocator, .args = args };
    }

    pub fn start(self: *Loader) void {
        std.debug.assert(self.future == null);
        self.future = sys.io.async(loadClassificationBoxed, .{ self.allocator, self.args });
    }

    pub fn wait(self: *Loader) !Data {
        const f = &(self.future orelse return error.LoaderNotStarted);
        const result = f.await(sys.io);
        self.future = null;
        return result;
    }

    /// Await and discard, so a half-finished load doesn't leak when training
    /// stops between `start` and `wait`.
    pub fn drain(self: *Loader) void {
        if (self.future == null) return;
        var d = self.wait() catch return;
        d.deinit(self.allocator);
    }
};

fn loadClassificationBoxed(allocator: std.mem.Allocator, args: LoadArgs) anyerror!Data {
    return loadClassification(allocator, args);
}

// ---------------------------------------------------------------------------
// batching
// ---------------------------------------------------------------------------

/// Copy rows [offset, offset+n) into the network's flat input/truth buffers.
pub fn nextBatch(d: Data, n: usize, offset: usize, x: []f32, y: []f32) void {
    for (0..n) |j| {
        const index = offset + j;
        @memcpy(x[j * d.x.cols ..][0..d.x.cols], d.x.vals[index]);
        if (y.len != 0 and d.y.cols != 0) {
            @memcpy(y[j * d.y.cols ..][0..d.y.cols], d.y.vals[index]);
        }
    }
}

pub fn randomBatch(d: Data, n: usize, x: []f32, y: []f32) void {
    for (0..n) |j| {
        const index = utils.default.index(d.x.rows);
        @memcpy(x[j * d.x.cols ..][0..d.x.cols], d.x.vals[index]);
        if (y.len != 0 and d.y.cols != 0) {
            @memcpy(y[j * d.y.cols ..][0..d.y.cols], d.y.vals[index]);
        }
    }
}

test "fillTruth marks the matching class" {
    const labels = [_][]const u8{ "cat", "dog", "bird" };
    var truth: [3]f32 = undefined;
    fillTruth("data/train/dog/img001.jpg", &labels, &truth);
    try std.testing.expectEqualSlices(f32, &[_]f32{ 0, 1, 0 }, &truth);
}
