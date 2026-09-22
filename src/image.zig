//! Images and the augmentation pipeline.
//!
//! Layout is planar CHW with values in [0,1]: `data[c*h*w + y*w + x]`. That is
//! darknet's layout, and it is also what the network wants as input, so no
//! conversion happens between the loader and the first convolution.
//!
//! Decoding goes through stb_image, the same library darknet uses -- see
//! src/c/stb_impl.c for why that stayed in C.

const std = @import("std");
const sys = @import("sys.zig");
const utils = @import("utils.zig");

const Rng = utils.Rng;

extern fn stbi_load(filename: [*:0]const u8, x: *c_int, y: *c_int, channels_in_file: *c_int, desired_channels: c_int) ?[*]u8;
extern fn stbi_image_free(retval: ?*anyopaque) void;
extern fn stbi_failure_reason() [*:0]const u8;
extern fn stbi_write_png(filename: [*:0]const u8, w: c_int, h: c_int, comp: c_int, data: *const anyopaque, stride_in_bytes: c_int) c_int;
extern fn stbi_write_jpg(filename: [*:0]const u8, x: c_int, y: c_int, comp: c_int, data: *const anyopaque, quality: c_int) c_int;

const two_pi: f32 = 6.2831853071795864769252866;

pub const Image = struct {
    w: usize = 0,
    h: usize = 0,
    c: usize = 0,
    data: []f32 = &.{},

    pub fn deinit(self: *Image, allocator: std.mem.Allocator) void {
        if (self.data.len != 0) allocator.free(self.data);
        self.* = .{};
    }

    /// Hand the pixel buffer to the caller and leave the image empty. Used by
    /// the loader, which stores decoded pixels directly as a matrix row.
    pub fn toOwnedSlice(self: *Image) []f32 {
        const d = self.data;
        self.* = .{};
        return d;
    }

    pub inline fn get(self: Image, x: usize, y: usize, ch: usize) f32 {
        return self.data[ch * self.h * self.w + y * self.w + x];
    }

    pub inline fn set(self: Image, x: usize, y: usize, ch: usize, v: f32) void {
        if (x >= self.w or y >= self.h or ch >= self.c) return;
        self.data[ch * self.h * self.w + y * self.w + x] = v;
    }

    inline fn add(self: Image, x: usize, y: usize, ch: usize, v: f32) void {
        self.data[ch * self.h * self.w + y * self.w + x] += v;
    }

    /// Out-of-bounds reads give 0, matching darknet's `get_pixel_extend`.
    fn getExtend(self: Image, x: isize, y: isize, ch: usize) f32 {
        if (x < 0 or y < 0 or ch >= self.c) return 0;
        const ux: usize = @intCast(x);
        const uy: usize = @intCast(y);
        if (ux >= self.w or uy >= self.h) return 0;
        return self.get(ux, uy, ch);
    }

    fn bilinear(self: Image, x: f32, y: f32, ch: usize) f32 {
        const ix: isize = @intFromFloat(@floor(x));
        const iy: isize = @intFromFloat(@floor(y));
        const dx = x - @as(f32, @floatFromInt(ix));
        const dy = y - @as(f32, @floatFromInt(iy));
        return (1 - dy) * (1 - dx) * self.getExtend(ix, iy, ch) +
            dy * (1 - dx) * self.getExtend(ix, iy + 1, ch) +
            (1 - dy) * dx * self.getExtend(ix + 1, iy, ch) +
            dy * dx * self.getExtend(ix + 1, iy + 1, ch);
    }
};

pub fn make(allocator: std.mem.Allocator, w: usize, h: usize, c: usize) !Image {
    const data = try allocator.alloc(f32, w * h * c);
    @memset(data, 0);
    return .{ .w = w, .h = h, .c = c, .data = data };
}

// ---------------------------------------------------------------------------
// loading and saving
// ---------------------------------------------------------------------------

/// Decode `path` into planar float form. `channels` of 3 forces RGB.
pub fn loadStb(allocator: std.mem.Allocator, path: []const u8, channels: usize) !Image {
    const path_z = try allocator.dupeZ(u8, path);
    defer allocator.free(path_z);

    var w: c_int = 0;
    var h: c_int = 0;
    var c: c_int = 0;
    const raw = stbi_load(path_z.ptr, &w, &h, &c, @intCast(channels)) orelse {
        std.debug.print("Cannot load image \"{s}\"\nSTB reason: {s}\n", .{ path, stbi_failure_reason() });
        return error.ImageLoadFailed;
    };
    defer stbi_image_free(raw);

    const actual_c: usize = if (channels != 0) channels else @intCast(c);
    const uw: usize = @intCast(w);
    const uh: usize = @intCast(h);

    var im = try make(allocator, uw, uh, actual_c);
    // stb gives interleaved bytes; transpose to planar floats in [0,1].
    for (0..actual_c) |k| {
        for (0..uh) |j| {
            for (0..uw) |i| {
                const dst = i + uw * j + uw * uh * k;
                const src = k + actual_c * i + actual_c * uw * j;
                im.data[dst] = @as(f32, @floatFromInt(raw[src])) / 255.0;
            }
        }
    }
    return im;
}

/// Load and optionally resize. `w`/`h` of 0 mean "keep the native size".
pub fn load(allocator: std.mem.Allocator, path: []const u8, w: usize, h: usize, c: usize) !Image {
    var im = try loadStb(allocator, path, c);
    if (w != 0 and h != 0 and (im.w != w or im.h != h)) {
        var r = try resize(allocator, im, w, h);
        im.deinit(allocator);
        im = r;
        r = .{};
    }
    return im;
}

pub fn loadColor(allocator: std.mem.Allocator, path: []const u8, w: usize, h: usize) !Image {
    return load(allocator, path, w, h, 3);
}

pub fn savePng(allocator: std.mem.Allocator, im: Image, path: []const u8) !void {
    const path_z = try allocator.dupeZ(u8, path);
    defer allocator.free(path_z);
    const bytes = try allocator.alloc(u8, im.w * im.h * im.c);
    defer allocator.free(bytes);
    for (0..im.c) |k| {
        for (0..im.w * im.h) |i| {
            const v = im.data[i + k * im.w * im.h];
            bytes[i * im.c + k] = @intFromFloat(std.math.clamp(v * 255.0, 0, 255));
        }
    }
    if (stbi_write_png(path_z.ptr, @intCast(im.w), @intCast(im.h), @intCast(im.c), bytes.ptr, @intCast(im.w * im.c)) == 0) {
        return error.ImageWriteFailed;
    }
}

// ---------------------------------------------------------------------------
// geometry
// ---------------------------------------------------------------------------

/// Separable bilinear resize: horizontal pass into a scratch image, then
/// vertical. Reproduces darknet's `resize_image` including its endpoint
/// handling, so crops match upstream pixel for pixel.
pub fn resize(allocator: std.mem.Allocator, im: Image, w: usize, h: usize) !Image {
    var resized = try make(allocator, w, h, im.c);
    errdefer resized.deinit(allocator);
    var part = try make(allocator, w, im.h, im.c);
    defer part.deinit(allocator);

    const w_scale: f32 = if (w > 1) @as(f32, @floatFromInt(im.w - 1)) / @as(f32, @floatFromInt(w - 1)) else 0;
    const h_scale: f32 = if (h > 1) @as(f32, @floatFromInt(im.h - 1)) / @as(f32, @floatFromInt(h - 1)) else 0;

    for (0..im.c) |k| {
        for (0..im.h) |r| {
            for (0..w) |c| {
                var val: f32 = 0;
                if (c == w - 1 or im.w == 1) {
                    val = im.get(im.w - 1, r, k);
                } else {
                    const sx = @as(f32, @floatFromInt(c)) * w_scale;
                    const ix: usize = @intFromFloat(sx);
                    const dx = sx - @as(f32, @floatFromInt(ix));
                    val = (1 - dx) * im.get(ix, r, k) + dx * im.get(ix + 1, r, k);
                }
                part.set(c, r, k, val);
            }
        }
    }
    for (0..im.c) |k| {
        for (0..h) |r| {
            const sy = @as(f32, @floatFromInt(r)) * h_scale;
            const iy: usize = @intFromFloat(sy);
            const dy = sy - @as(f32, @floatFromInt(iy));
            for (0..w) |c| {
                resized.set(c, r, k, (1 - dy) * part.get(c, iy, k));
            }
            if (r == h - 1 or im.h == 1) continue;
            for (0..w) |c| {
                resized.add(c, r, k, dy * part.get(c, iy + 1, k));
            }
        }
    }
    return resized;
}

/// Crop with edge clamping: out-of-bounds reads take the nearest edge pixel.
pub fn crop(allocator: std.mem.Allocator, im: Image, dx: isize, dy: isize, w: usize, h: usize) !Image {
    var cropped = try make(allocator, w, h, im.c);
    for (0..im.c) |k| {
        for (0..h) |j| {
            for (0..w) |i| {
                const r = utils.constrainInt(@intCast(dy + @as(isize, @intCast(j))), 0, @intCast(im.h - 1));
                const c = utils.constrainInt(@intCast(dx + @as(isize, @intCast(i))), 0, @intCast(im.w - 1));
                cropped.set(i, j, k, im.get(@intCast(c), @intCast(r), k));
            }
        }
    }
    return cropped;
}

/// Square centre crop scaled to w x h. The deterministic counterpart to
/// `randomAugment`, used for validation and single-image prediction.
pub fn centerCrop(allocator: std.mem.Allocator, im: Image, w: usize, h: usize) !Image {
    const m = @min(im.w, im.h);
    var c = try crop(allocator, im, @intCast((im.w - m) / 2), @intCast((im.h - m) / 2), m, m);
    defer c.deinit(allocator);
    return resize(allocator, c, w, h);
}

pub fn embed(source: Image, dest: Image, dx: usize, dy: usize) void {
    for (0..source.c) |k| {
        for (0..source.h) |y| {
            for (0..source.w) |x| {
                dest.set(dx + x, dy + y, k, source.get(x, y, k));
            }
        }
    }
}

pub fn fill(im: Image, s: f32) void {
    @memset(im.data, s);
}

/// Resize preserving aspect ratio and pad the remainder with 0.5 grey.
pub fn letterbox(allocator: std.mem.Allocator, im: Image, w: usize, h: usize) !Image {
    var new_w = im.w;
    var new_h = im.h;
    const fw: f32 = @floatFromInt(w);
    const fh: f32 = @floatFromInt(h);
    if (fw / @as(f32, @floatFromInt(im.w)) < fh / @as(f32, @floatFromInt(im.h))) {
        new_w = w;
        new_h = im.h * w / im.w;
    } else {
        new_h = h;
        new_w = im.w * h / im.h;
    }
    var resized = try resize(allocator, im, new_w, new_h);
    defer resized.deinit(allocator);
    const boxed = try make(allocator, w, h, im.c);
    fill(boxed, 0.5);
    embed(resized, boxed, (w - new_w) / 2, (h - new_h) / 2);
    return boxed;
}

pub fn flip(im: Image) void {
    for (0..im.c) |k| {
        for (0..im.h) |i| {
            for (0..im.w / 2) |j| {
                const index = j + im.w * (i + im.h * k);
                const mirrored = (im.w - j - 1) + im.w * (i + im.h * k);
                std.mem.swap(f32, &im.data[index], &im.data[mirrored]);
            }
        }
    }
}

pub fn constrainImage(im: Image) void {
    for (im.data) |*v| v.* = std.math.clamp(v.*, 0, 1);
}

/// Rotate, scale and translate in one resampling pass.
fn rotateCrop(allocator: std.mem.Allocator, im: Image, rad: f32, s: f32, w: usize, h: usize, dx: f32, dy: f32, aspect: f32) !Image {
    var rot = try make(allocator, w, h, im.c);
    const cx = @as(f32, @floatFromInt(im.w)) / 2.0;
    const cy = @as(f32, @floatFromInt(im.h)) / 2.0;
    const hw = @as(f32, @floatFromInt(w)) / 2.0;
    const hh = @as(f32, @floatFromInt(h)) / 2.0;
    const cos_r = @cos(rad);
    const sin_r = @sin(rad);

    for (0..im.c) |ch| {
        for (0..h) |y| {
            for (0..w) |x| {
                const fx = @as(f32, @floatFromInt(x)) - hw;
                const fy = @as(f32, @floatFromInt(y)) - hh;
                const u = fx / s * aspect + dx / s * aspect;
                const v = fy / s + dy / s;
                const rx = cos_r * u - sin_r * v + cx;
                const ry = sin_r * u + cos_r * v + cy;
                rot.set(x, y, ch, im.bilinear(rx, ry, ch));
            }
        }
    }
    return rot;
}

pub const AugmentArgs = struct {
    rad: f32,
    scale: f32,
    dx: f32,
    dy: f32,
    aspect: f32,
};

pub fn randomAugmentArgs(rng: *Rng, im: Image, angle: f32, aspect_in: f32, low: i32, high: i32, w: usize) AugmentArgs {
    const aspect = rng.scale(aspect_in);
    const r = rng.int(low, high);
    const fh: f32 = @floatFromInt(im.h);
    const fw: f32 = @floatFromInt(im.w);
    const min_dim = @min(fh, fw * aspect);
    const s = @as(f32, @floatFromInt(r)) / min_dim;
    const rad = rng.uniform(-angle, angle) * two_pi / 360.0;

    // Note the `w` in both expressions: darknet computes the vertical slack
    // against the output *width*. Harmless for the square crops every
    // classification config uses, and reproduced here so augmentation matches
    // upstream exactly.
    const fout: f32 = @floatFromInt(w);
    var dx = (fw * s / aspect - fout) / 2.0;
    var dy = (fh * s - fout) / 2.0;
    dx = rng.uniform(-dx, dx);
    dy = rng.uniform(-dy, dy);

    return .{ .rad = rad, .scale = s, .dx = dx, .dy = dy, .aspect = aspect };
}

pub fn randomAugment(
    allocator: std.mem.Allocator,
    rng: *Rng,
    im: Image,
    angle: f32,
    aspect: f32,
    low: i32,
    high: i32,
    w: usize,
    h: usize,
) !Image {
    const a = randomAugmentArgs(rng, im, angle, aspect, low, high, w);
    return rotateCrop(allocator, im, a.rad, a.scale, w, h, a.dx, a.dy, a.aspect);
}

// ---------------------------------------------------------------------------
// colour
// ---------------------------------------------------------------------------

pub fn rgbToHsv(im: Image) void {
    std.debug.assert(im.c == 3);
    for (0..im.h) |j| {
        for (0..im.w) |i| {
            const r = im.get(i, j, 0);
            const g = im.get(i, j, 1);
            const b = im.get(i, j, 2);
            const max = @max(r, @max(g, b));
            const min = @min(r, @min(g, b));
            const delta = max - min;
            const v = max;
            var s: f32 = 0;
            var hue: f32 = 0;
            if (max != 0) {
                s = delta / max;
                if (delta != 0) {
                    if (r == max) {
                        hue = (g - b) / delta;
                    } else if (g == max) {
                        hue = 2 + (b - r) / delta;
                    } else {
                        hue = 4 + (r - g) / delta;
                    }
                    if (hue < 0) hue += 6;
                    hue /= 6.0;
                }
            }
            im.set(i, j, 0, hue);
            im.set(i, j, 1, s);
            im.set(i, j, 2, v);
        }
    }
}

pub fn hsvToRgb(im: Image) void {
    std.debug.assert(im.c == 3);
    for (0..im.h) |j| {
        for (0..im.w) |i| {
            const hue = 6 * im.get(i, j, 0);
            const s = im.get(i, j, 1);
            const v = im.get(i, j, 2);
            var r: f32 = undefined;
            var g: f32 = undefined;
            var b: f32 = undefined;
            if (s == 0) {
                r = v;
                g = v;
                b = v;
            } else {
                const index: i32 = @intFromFloat(@floor(hue));
                const f = hue - @floor(hue);
                const p = v * (1 - s);
                const q = v * (1 - s * f);
                const t = v * (1 - s * (1 - f));
                switch (index) {
                    0 => { r = v; g = t; b = p; },
                    1 => { r = q; g = v; b = p; },
                    2 => { r = p; g = v; b = t; },
                    3 => { r = p; g = q; b = v; },
                    4 => { r = t; g = p; b = v; },
                    else => { r = v; g = p; b = q; },
                }
            }
            im.set(i, j, 0, r);
            im.set(i, j, 1, g);
            im.set(i, j, 2, b);
        }
    }
}

fn scaleChannel(im: Image, ch: usize, v: f32) void {
    const plane = im.data[ch * im.h * im.w ..][0 .. im.h * im.w];
    for (plane) |*p| p.* *= v;
}

/// Shift hue and scale saturation/value. Hue wraps rather than clamping.
pub fn distort(im: Image, hue: f32, sat: f32, val: f32) void {
    if (im.c != 3) return;
    rgbToHsv(im);
    scaleChannel(im, 1, sat);
    scaleChannel(im, 2, val);
    const hue_plane = im.data[0 .. im.w * im.h];
    for (hue_plane) |*p| {
        p.* += hue;
        if (p.* > 1) p.* -= 1;
        if (p.* < 0) p.* += 1;
    }
    hsvToRgb(im);
    constrainImage(im);
}

pub fn randomDistort(rng: *Rng, im: Image, hue: f32, saturation: f32, exposure: f32) void {
    distort(im, rng.uniform(-hue, hue), rng.scale(saturation), rng.scale(exposure));
}

test "resize to the same size is close to the identity" {
    const allocator = std.testing.allocator;
    var im = try make(allocator, 4, 4, 1);
    defer im.deinit(allocator);
    for (im.data, 0..) |*v, i| v.* = @floatFromInt(i);
    var r = try resize(allocator, im, 4, 4);
    defer r.deinit(allocator);
    for (im.data, r.data) |a, b| try std.testing.expectApproxEqAbs(a, b, 1e-4);
}

test "rgb/hsv round trip" {
    const allocator = std.testing.allocator;
    var im = try make(allocator, 2, 2, 3);
    defer im.deinit(allocator);
    const original = [_]f32{ 0.2, 0.9, 0.5, 0.1, 0.4, 0.7, 0.3, 0.8, 0.6, 0.25, 0.55, 0.85 };
    @memcpy(im.data, &original);
    rgbToHsv(im);
    hsvToRgb(im);
    for (original, im.data) |a, b| try std.testing.expectApproxEqAbs(a, b, 1e-4);
}
