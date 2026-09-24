//! Converts MNIST, CIFAR-10 and COCO into the on-disk layout darknet's
//! classifier expects, so all three can go through exactly the same code path
//! as any other dataset:
//!
//!     <root>/images/<class>/<split>_<n>.png
//!     <root>/labels.list   "/images/<class>/" per line, in output-unit order
//!     <root>/names.list    the plain class names, for display
//!     <root>/train.list    absolute image paths
//!     <root>/valid.list
//!     <root>/<name>.data
//!
//! Labels are assigned by finding a label string in the image path, which is
//! darknet's convention. The labels are written path-delimited as
//! "/images/<class>/" so the search is exact: undelimited, COCO's "car" is a
//! substring of "carrot" and both bits would be set in a one-hot target.
//!
//! Usage:  prepare <mnist|cifar10|coco> <raw-dir> <out-dir>
//!
//! A note on COCO: this port implements classification only, so COCO is used
//! as a classification set -- every annotated object box in val2017 is cropped
//! out and labelled with its category. That is a real 80-class task on the
//! real data, but it is not detection, and numbers from it are not comparable
//! to published COCO mAP.

const std = @import("std");

extern fn stbi_load(filename: [*:0]const u8, x: *c_int, y: *c_int, channels_in_file: *c_int, desired_channels: c_int) ?[*]u8;
extern fn stbi_image_free(retval: ?*anyopaque) void;
extern fn stbi_write_png(filename: [*:0]const u8, w: c_int, h: c_int, comp: c_int, data: *const anyopaque, stride_in_bytes: c_int) c_int;

const Writer = struct {
    gpa: std.mem.Allocator,
    io: std.Io,
    root: []const u8,
    train: std.ArrayList(u8) = .empty,
    valid: std.ArrayList(u8) = .empty,
    counts: std.StringHashMapUnmanaged(usize) = .empty,

    fn deinit(self: *Writer) void {
        self.train.deinit(self.gpa);
        self.valid.deinit(self.gpa);
        self.counts.deinit(self.gpa);
    }

    fn ensureClassDir(self: *Writer, class: []const u8) !void {
        const dir = try std.fmt.allocPrint(self.gpa, "{s}/images/{s}", .{ self.root, class });
        defer self.gpa.free(dir);
        try std.Io.Dir.cwd().createDirPath(self.io, dir);
    }

    /// `rgb` is interleaved 8-bit RGB, `w*h*3` bytes.
    fn writeImage(self: *Writer, class: []const u8, split: []const u8, index: usize, w: usize, h: usize, rgb: []const u8) !void {
        const path = try std.fmt.allocPrintSentinel(
            self.gpa,
            "{s}/images/{s}/{s}_{d:0>6}.png",
            .{ self.root, class, split, index },
            0,
        );
        defer self.gpa.free(path);

        if (stbi_write_png(path.ptr, @intCast(w), @intCast(h), 3, rgb.ptr, @intCast(w * 3)) == 0) {
            return error.ImageWriteFailed;
        }

        const list = if (std.mem.eql(u8, split, "train")) &self.train else &self.valid;
        try list.appendSlice(self.gpa, path);
        try list.append(self.gpa, '\n');

        const gop = try self.counts.getOrPut(self.gpa, class);
        if (!gop.found_existing) gop.value_ptr.* = 0;
        gop.value_ptr.* += 1;
    }

    fn finish(self: *Writer, name: []const u8, classes: []const []const u8, top: usize) !void {
        // Two lists, because darknet uses them for different jobs. `labels`
        // is matched against each image path with a plain substring search to
        // decide the truth vector; `names` is only ever displayed.
        //
        // Writing the labels path-delimited as "/images/<class>/" makes that
        // search exact. Undelimited, COCO alone collides several ways -- "car"
        // inside "carrot", "bus" inside "bus stop" -- and each one silently sets
        // two bits in a one-hot target. The "images/" component is part of the
        // pattern because COCO also has a class called "bench", and this
        // repository keeps the suite in a directory of that name. Every image is at
        // <root>/images/<class>/<split>_<n>.png, so the pattern occurs there
        // exactly once.
        var labels: std.ArrayList(u8) = .empty;
        defer labels.deinit(self.gpa);
        var names: std.ArrayList(u8) = .empty;
        defer names.deinit(self.gpa);
        for (classes) |c| {
            try labels.appendSlice(self.gpa, "/images/");
            try labels.appendSlice(self.gpa, c);
            try labels.appendSlice(self.gpa, "/\n");
            try names.appendSlice(self.gpa, c);
            try names.append(self.gpa, '\n');
        }

        // The delimiting only helps if the root itself does not contain the
        // pattern -- a parent directory named after a class would match too.
        for (classes) |c| {
            const pat = try std.fmt.allocPrint(self.gpa, "/images/{s}/", .{c});
            defer self.gpa.free(pat);
            if (std.mem.indexOf(u8, self.root, pat) != null) {
                std.debug.print(
                    "the output path {s} contains \"{s}\", which would match every image; move it\n",
                    .{ self.root, pat },
                );
                return error.AmbiguousOutputPath;
            }
        }

        try self.write("labels.list", labels.items);
        try self.write("names.list", names.items);
        try self.write("train.list", self.train.items);
        try self.write("valid.list", self.valid.items);

        const data_cfg = try std.fmt.allocPrint(self.gpa,
            \\classes = {d}
            \\train   = {s}/train.list
            \\valid   = {s}/valid.list
            \\labels  = {s}/labels.list
            \\names   = {s}/names.list
            \\backup  = {s}/backup
            \\top     = {d}
            \\
        , .{ classes.len, self.root, self.root, self.root, self.root, self.root, top });
        defer self.gpa.free(data_cfg);

        const data_name = try std.fmt.allocPrint(self.gpa, "{s}.data", .{name});
        defer self.gpa.free(data_name);
        try self.write(data_name, data_cfg);

        const backup = try std.fmt.allocPrint(self.gpa, "{s}/backup", .{self.root});
        defer self.gpa.free(backup);
        try std.Io.Dir.cwd().createDirPath(self.io, backup);

        var n_train: usize = std.mem.count(u8, self.train.items, "\n");
        var n_valid: usize = std.mem.count(u8, self.valid.items, "\n");
        std.debug.print("{s}: {d} classes, {d} train, {d} valid -> {s}\n", .{ name, classes.len, n_train, n_valid, self.root });
        n_train = 0;
        n_valid = 0;
    }

    fn write(self: *Writer, name: []const u8, bytes: []const u8) !void {
        const p = try std.fmt.allocPrint(self.gpa, "{s}/{s}", .{ self.root, name });
        defer self.gpa.free(p);
        try std.Io.Dir.cwd().writeFile(self.io, .{ .sub_path = p, .data = bytes });
    }
};

fn readFile(gpa: std.mem.Allocator, io: std.Io, path: []const u8) ![]u8 {
    return std.Io.Dir.cwd().readFileAlloc(io, path, gpa, .limited(2 << 30));
}

// ---------------------------------------------------------------------------
// MNIST
// ---------------------------------------------------------------------------
// IDX format: big-endian magic, then dimensions, then raw bytes. Images are
// 28x28 greyscale, which we widen to RGB because the rest of the pipeline is
// three-channel throughout.

fn be32(b: []const u8) u32 {
    return std.mem.readInt(u32, b[0..4], .big);
}

fn mnistSplit(w: *Writer, images_raw: []const u8, labels_raw: []const u8, split: []const u8) !void {
    if (be32(images_raw[0..4]) != 2051) return error.BadIdxImages;
    if (be32(labels_raw[0..4]) != 2049) return error.BadIdxLabels;

    const count = be32(images_raw[4..8]);
    const rows = be32(images_raw[8..12]);
    const cols = be32(images_raw[12..16]);
    const pixels = rows * cols;

    const rgb = try w.gpa.alloc(u8, pixels * 3);
    defer w.gpa.free(rgb);

    for (0..count) |i| {
        const gray = images_raw[16 + i * pixels ..][0..pixels];
        for (gray, 0..) |v, p| {
            rgb[p * 3 + 0] = v;
            rgb[p * 3 + 1] = v;
            rgb[p * 3 + 2] = v;
        }
        const digit = labels_raw[8 + i];
        var class_buf: [8]u8 = undefined;
        const class = try std.fmt.bufPrint(&class_buf, "digit{d}", .{digit});
        try w.writeImage(class, split, i, cols, rows, rgb);
    }
}

fn prepareMnist(gpa: std.mem.Allocator, io: std.Io, raw: []const u8, out: []const u8) !void {
    var w = Writer{ .gpa = gpa, .io = io, .root = out };
    defer w.deinit();

    var classes: [10][]const u8 = undefined;
    var names: [10][8]u8 = undefined;
    for (0..10) |d| {
        classes[d] = try std.fmt.bufPrint(&names[d], "digit{d}", .{d});
        try w.ensureClassDir(classes[d]);
    }

    const pairs = [_]struct { img: []const u8, lbl: []const u8, split: []const u8 }{
        .{ .img = "train-images-idx3-ubyte", .lbl = "train-labels-idx1-ubyte", .split = "train" },
        .{ .img = "t10k-images-idx3-ubyte", .lbl = "t10k-labels-idx1-ubyte", .split = "valid" },
    };
    for (pairs) |p| {
        const ip = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ raw, p.img });
        defer gpa.free(ip);
        const lp = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ raw, p.lbl });
        defer gpa.free(lp);
        const images = try readFile(gpa, io, ip);
        defer gpa.free(images);
        const labels = try readFile(gpa, io, lp);
        defer gpa.free(labels);
        try mnistSplit(&w, images, labels, p.split);
    }

    try w.finish("mnist", &classes, 1);
}

// ---------------------------------------------------------------------------
// CIFAR-10
// ---------------------------------------------------------------------------
// Binary batches: 3073 bytes per record -- one label byte, then 1024 red,
// 1024 green, 1024 blue (planar), for a 32x32 image.

const cifar_classes = [_][]const u8{
    "airplane", "automobile", "bird",  "cat",  "deer",
    "dog",      "frog",       "horse", "ship", "truck",
};

fn cifarBatch(w: *Writer, bytes: []const u8, split: []const u8, start_index: usize) !usize {
    const record = 1 + 32 * 32 * 3;
    const n = bytes.len / record;
    const rgb = try w.gpa.alloc(u8, 32 * 32 * 3);
    defer w.gpa.free(rgb);

    for (0..n) |i| {
        const rec = bytes[i * record ..][0..record];
        const label = rec[0];
        if (label >= cifar_classes.len) return error.BadCifarLabel;
        const planes = rec[1..];
        for (0..32 * 32) |p| {
            rgb[p * 3 + 0] = planes[p];
            rgb[p * 3 + 1] = planes[1024 + p];
            rgb[p * 3 + 2] = planes[2048 + p];
        }
        try w.writeImage(cifar_classes[label], split, start_index + i, 32, 32, rgb);
    }
    return n;
}

fn prepareCifar(gpa: std.mem.Allocator, io: std.Io, raw: []const u8, out: []const u8) !void {
    var w = Writer{ .gpa = gpa, .io = io, .root = out };
    defer w.deinit();
    for (cifar_classes) |c| try w.ensureClassDir(c);

    var index: usize = 0;
    inline for (.{ "data_batch_1", "data_batch_2", "data_batch_3", "data_batch_4", "data_batch_5" }) |name| {
        const p = try std.fmt.allocPrint(gpa, "{s}/cifar-10-batches-bin/{s}.bin", .{ raw, name });
        defer gpa.free(p);
        const bytes = try readFile(gpa, io, p);
        defer gpa.free(bytes);
        index += try cifarBatch(&w, bytes, "train", index);
    }

    const tp = try std.fmt.allocPrint(gpa, "{s}/cifar-10-batches-bin/test_batch.bin", .{raw});
    defer gpa.free(tp);
    const test_bytes = try readFile(gpa, io, tp);
    defer gpa.free(test_bytes);
    _ = try cifarBatch(&w, test_bytes, "valid", 0);

    try w.finish("cifar10", &cifar_classes, 5);
}

// ---------------------------------------------------------------------------
// COCO (as classification)
// ---------------------------------------------------------------------------

const Ann = struct {
    image_id: i64,
    category_id: i64,
    x: f64,
    y: f64,
    w: f64,
    h: f64,
};

/// Boxes smaller than this in either dimension are dropped: a 6-pixel crop
/// upscaled to the network input is noise, and COCO has a great many of them.
const min_box_px: f64 = 32;

fn sanitise(gpa: std.mem.Allocator, name: []const u8) ![]u8 {
    // Class names go into paths and are matched as substrings, so spaces are
    // replaced and the result must stay unique.
    const buf = try gpa.alloc(u8, name.len);
    for (name, 0..) |c, i| buf[i] = if (c == ' ' or c == '/') '_' else c;
    return buf;
}

fn prepareCoco(gpa: std.mem.Allocator, io: std.Io, raw: []const u8, out: []const u8) !void {
    const ann_path = try std.fmt.allocPrint(gpa, "{s}/annotations/instances_val2017.json", .{raw});
    defer gpa.free(ann_path);
    const json_bytes = try readFile(gpa, io, ann_path);
    defer gpa.free(json_bytes);

    std.debug.print("coco: parsing {d} MB of annotations...\n", .{json_bytes.len >> 20});
    var parsed = try std.json.parseFromSlice(std.json.Value, gpa, json_bytes, .{});
    defer parsed.deinit();
    const root = parsed.value.object;

    // category id -> name
    var cat_name: std.AutoHashMapUnmanaged(i64, []const u8) = .empty;
    defer cat_name.deinit(gpa);
    var class_names: std.ArrayList([]const u8) = .empty;
    defer {
        for (class_names.items) |c| gpa.free(c);
        class_names.deinit(gpa);
    }
    for (root.get("categories").?.array.items) |c| {
        const obj = c.object;
        const id = obj.get("id").?.integer;
        const clean = try sanitise(gpa, obj.get("name").?.string);
        try cat_name.put(gpa, id, clean);
        try class_names.append(gpa, clean);
    }

    // Class names become a path component, so a slash in one would break the
    // "/<class>/" label pattern that `finish` relies on to keep "car" from
    // matching "carrot". None of COCO's 80 names contains one today; check
    // anyway, since the failure would be silent mislabelling.
    for (class_names.items) |c| {
        if (std.mem.indexOfAny(u8, c, "/\\") != null) {
            std.debug.print("coco: category \"{s}\" contains a path separator\n", .{c});
            return error.AmbiguousClassNames;
        }

    }
    // image id -> file name
    var image_file: std.AutoHashMapUnmanaged(i64, []const u8) = .empty;
    defer image_file.deinit(gpa);
    for (root.get("images").?.array.items) |im| {
        const obj = im.object;
        try image_file.put(gpa, obj.get("id").?.integer, obj.get("file_name").?.string);
    }

    // Group annotations by image so each JPEG is decoded exactly once.
    var by_image: std.AutoHashMapUnmanaged(i64, std.ArrayListUnmanaged(Ann)) = .empty;
    defer {
        var it = by_image.valueIterator();
        while (it.next()) |list| list.deinit(gpa);
        by_image.deinit(gpa);
    }

    var kept: usize = 0;
    for (root.get("annotations").?.array.items) |a| {
        const obj = a.object;
        if (obj.get("iscrowd")) |c| {
            if (c.integer != 0) continue;
        }
        const bbox = obj.get("bbox").?.array.items;
        const bw = jsonNum(bbox[2]);
        const bh = jsonNum(bbox[3]);
        if (bw < min_box_px or bh < min_box_px) continue;

        const id = obj.get("image_id").?.integer;
        const gop = try by_image.getOrPut(gpa, id);
        if (!gop.found_existing) gop.value_ptr.* = .empty;
        try gop.value_ptr.append(gpa, .{
            .image_id = id,
            .category_id = obj.get("category_id").?.integer,
            .x = jsonNum(bbox[0]),
            .y = jsonNum(bbox[1]),
            .w = bw,
            .h = bh,
        });
        kept += 1;
    }
    std.debug.print("coco: {d} object crops from {d} images\n", .{ kept, by_image.count() });

    var w = Writer{ .gpa = gpa, .io = io, .root = out };
    defer w.deinit();
    for (class_names.items) |c| try w.ensureClassDir(c);

    var index: usize = 0;
    var it = by_image.iterator();
    while (it.next()) |entry| {
        const file = image_file.get(entry.key_ptr.*) orelse continue;
        const jpg = try std.fmt.allocPrintSentinel(gpa, "{s}/val2017/{s}", .{ raw, file }, 0);
        defer gpa.free(jpg);

        var iw: c_int = 0;
        var ih: c_int = 0;
        var ic: c_int = 0;
        const pixels = stbi_load(jpg.ptr, &iw, &ih, &ic, 3) orelse continue;
        defer stbi_image_free(pixels);

        for (entry.value_ptr.items) |ann| {
            const class = cat_name.get(ann.category_id) orelse continue;
            const crop = cropRgb(gpa, pixels, @intCast(iw), @intCast(ih), ann) catch continue;
            defer gpa.free(crop.data);
            // Every fifth image is held out. Splitting on the source image
            // rather than the crop keeps objects from the same photo out of
            // both splits.
            const split: []const u8 = if (@rem(entry.key_ptr.*, 5) == 0) "valid" else "train";
            try w.writeImage(class, split, index, crop.w, crop.h, crop.data);
            index += 1;
        }
    }

    try w.finish("coco", class_names.items, 5);
}

fn jsonNum(v: std.json.Value) f64 {
    return switch (v) {
        .integer => |i| @floatFromInt(i),
        .float => |f| f,
        else => 0,
    };
}

const Crop = struct { w: usize, h: usize, data: []u8 };

fn cropRgb(gpa: std.mem.Allocator, pixels: [*]u8, iw: usize, ih: usize, ann: Ann) !Crop {
    const x0: usize = @intFromFloat(@max(0, @floor(ann.x)));
    const y0: usize = @intFromFloat(@max(0, @floor(ann.y)));
    const x1: usize = @min(iw, @as(usize, @intFromFloat(@max(0, @ceil(ann.x + ann.w)))));
    const y1: usize = @min(ih, @as(usize, @intFromFloat(@max(0, @ceil(ann.y + ann.h)))));
    if (x1 <= x0 or y1 <= y0) return error.EmptyCrop;

    const cw = x1 - x0;
    const ch = y1 - y0;
    const buf = try gpa.alloc(u8, cw * ch * 3);
    for (0..ch) |row| {
        const src = ((y0 + row) * iw + x0) * 3;
        @memcpy(buf[row * cw * 3 ..][0 .. cw * 3], pixels[src .. src + cw * 3]);
    }
    return .{ .w = cw, .h = ch, .data = buf };
}

// ---------------------------------------------------------------------------

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;
    const argv = try init.minimal.args.toSlice(init.arena.allocator());
    if (argv.len < 4) {
        std.debug.print("usage: prepare <mnist|cifar10|coco> <raw-dir> <out-dir>\n", .{});
        return error.MissingArgument;
    }
    const which = argv[1];
    const raw = argv[2];
    const out = argv[3];

    try std.Io.Dir.cwd().createDirPath(io, out);

    if (std.mem.eql(u8, which, "mnist")) return prepareMnist(gpa, io, raw, out);
    if (std.mem.eql(u8, which, "cifar10")) return prepareCifar(gpa, io, raw, out);
    if (std.mem.eql(u8, which, "coco")) return prepareCoco(gpa, io, raw, out);

    std.debug.print("unknown dataset: {s}\n", .{which});
    return error.UnknownDataset;
}
