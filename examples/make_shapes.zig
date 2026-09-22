//! Generates a small "circle vs square" image classification dataset, so the
//! trainer can be exercised end to end without downloading ImageNet.
//!
//! The task is deliberately not trivially memorisable: shape position, size,
//! background colour and foreground colour are all random, and the validation
//! split comes from a different seed, so validation accuracy only rises if the
//! network has actually learned *shape*. Colour is useless as a cue by
//! construction, and the training config's hue/saturation jitter scrambles it
//! further.
//!
//! Output is binary PPM (P6). stb_image sniffs the format from the file
//! contents rather than the extension, so no JPEG encoder is needed here.
//!
//!     zig run examples/make_shapes.zig -- /tmp/shapes
//!
//! Writes:
//!     <root>/images/{circle,square}/{train,valid}_*.ppm
//!     <root>/{labels,train,valid}.list
//!     <root>/shapes.data
//!     <root>/backup/

const std = @import("std");

const side = 96; // native image size; the trainer random-crops 64x64 out of it
const train_per_class = 200;
const valid_per_class = 50;

const Rgb = [3]u8;

fn drawShape(pixels: []u8, rnd: std.Random, is_circle: bool) void {
    const bg: Rgb = .{
        rnd.intRangeAtMost(u8, 30, 140),
        rnd.intRangeAtMost(u8, 30, 140),
        rnd.intRangeAtMost(u8, 30, 140),
    };
    // Keep the shape clearly brighter than the background so the task is about
    // geometry, not contrast polarity.
    var fg: Rgb = .{
        rnd.intRangeAtMost(u8, 150, 255),
        rnd.intRangeAtMost(u8, 150, 255),
        rnd.intRangeAtMost(u8, 150, 255),
    };
    for (&fg, bg) |*f, b| {
        if (@as(i32, f.*) - @as(i32, b) < 60) f.* = @intCast(@min(255, @as(i32, b) + 60));
    }

    const radius = rnd.intRangeAtMost(i32, 16, 34);
    const cx = rnd.intRangeAtMost(i32, radius + 2, side - radius - 2);
    const cy = rnd.intRangeAtMost(i32, radius + 2, side - radius - 2);

    for (0..side) |yi| {
        for (0..side) |xi| {
            const x: i32 = @intCast(xi);
            const y: i32 = @intCast(yi);
            const dx = x - cx;
            const dy = y - cy;
            const inside = if (is_circle)
                dx * dx + dy * dy <= radius * radius
            else
                @abs(dx) <= radius and @abs(dy) <= radius;

            const base = if (inside) fg else bg;
            const idx = (yi * side + xi) * 3;
            for (base, 0..) |v, ch| {
                const noise = rnd.intRangeAtMost(i32, -8, 8);
                pixels[idx + ch] = @intCast(std.math.clamp(@as(i32, v) + noise, 0, 255));
            }
        }
    }
}

fn writeSplit(
    gpa: std.mem.Allocator,
    io: std.Io,
    root: []const u8,
    class: []const u8,
    is_circle: bool,
    split: []const u8,
    count: usize,
    rnd: std.Random,
    list: *std.ArrayList(u8),
) !void {
    const pixels = try gpa.alloc(u8, side * side * 3);
    defer gpa.free(pixels);

    var header_buf: [32]u8 = undefined;
    const header = try std.fmt.bufPrint(&header_buf, "P6\n{d} {d}\n255\n", .{ side, side });

    const file_bytes = try gpa.alloc(u8, header.len + pixels.len);
    defer gpa.free(file_bytes);
    @memcpy(file_bytes[0..header.len], header);

    for (0..count) |n| {
        drawShape(pixels, rnd, is_circle);
        @memcpy(file_bytes[header.len..], pixels);

        const path = try std.fmt.allocPrint(gpa, "{s}/images/{s}/{s}_{d:0>4}.ppm", .{ root, class, split, n });
        defer gpa.free(path);
        try std.Io.Dir.cwd().writeFile(io, .{ .sub_path = path, .data = file_bytes });
        try list.appendSlice(gpa, path);
        try list.append(gpa, '\n');
    }
}

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const argv = try init.minimal.args.toSlice(init.arena.allocator());
    if (argv.len < 2) {
        std.debug.print("usage: make_shapes <output-directory>\n", .{});
        return error.MissingArgument;
    }
    const root = argv[1];

    const cwd = std.Io.Dir.cwd();
    for ([_][]const u8{ "images/circle", "images/square", "backup" }) |sub| {
        const p = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ root, sub });
        defer gpa.free(p);
        try cwd.createDirPath(io, p);
    }

    var train_list: std.ArrayList(u8) = .empty;
    defer train_list.deinit(gpa);
    var valid_list: std.ArrayList(u8) = .empty;
    defer valid_list.deinit(gpa);

    // Separate seeds so no validation image can coincide with a training one.
    var train_prng = std.Random.DefaultPrng.init(0xC14C1E);
    var valid_prng = std.Random.DefaultPrng.init(0x5A0A4E);

    const classes = [_]struct { name: []const u8, circle: bool }{
        .{ .name = "circle", .circle = true },
        .{ .name = "square", .circle = false },
    };
    for (classes) |c| {
        try writeSplit(gpa, io, root, c.name, c.circle, "train", train_per_class, train_prng.random(), &train_list);
        try writeSplit(gpa, io, root, c.name, c.circle, "valid", valid_per_class, valid_prng.random(), &valid_list);
    }

    const write = struct {
        fn f(g: std.mem.Allocator, i: std.Io, r: []const u8, name: []const u8, data: []const u8) !void {
            const p = try std.fmt.allocPrint(g, "{s}/{s}", .{ r, name });
            defer g.free(p);
            try std.Io.Dir.cwd().writeFile(i, .{ .sub_path = p, .data = data });
        }
    }.f;

    try write(gpa, io, root, "labels.list", "circle\nsquare\n");
    try write(gpa, io, root, "train.list", train_list.items);
    try write(gpa, io, root, "valid.list", valid_list.items);

    const data_cfg = try std.fmt.allocPrint(gpa,
        \\classes = 2
        \\train   = {s}/train.list
        \\valid   = {s}/valid.list
        \\labels  = {s}/labels.list
        \\names   = {s}/labels.list
        \\backup  = {s}/backup
        \\top     = 2
        \\
    , .{ root, root, root, root, root });
    defer gpa.free(data_cfg);
    try write(gpa, io, root, "shapes.data", data_cfg);

    std.debug.print(
        "Wrote {d} training and {d} validation images to {s}\n",
        .{ 2 * train_per_class, 2 * valid_per_class, root },
    );
}
