//! Small helpers ported from darknet's utils.c: random number generation,
//! array statistics and the string mangling the cfg/label code needs.

const std = @import("std");
const sys = @import("sys.zig");

/// darknet leans on libc `rand()` plus a hidden static in `rand_normal()`.
/// That is neither reproducible nor safe to call from the loader threads, so
/// the generator is an explicit value here: the main thread owns `default`,
/// and each data-loading task gets its own seeded instance.
pub const Rng = struct {
    prng: std.Random.DefaultPrng,

    pub fn init(seed: u64) Rng {
        return .{ .prng = std.Random.DefaultPrng.init(seed) };
    }

    inline fn r(self: *Rng) std.Random {
        return self.prng.random();
    }

    pub fn uniform(self: *Rng, min: f32, max: f32) f32 {
        const lo = @min(min, max);
        const hi = @max(min, max);
        return lo + self.r().float(f32) * (hi - lo);
    }

    pub fn normal(self: *Rng) f32 {
        return self.r().floatNorm(f32);
    }

    /// Inclusive on both ends, like darknet's `rand_int`.
    pub fn int(self: *Rng, min: i32, max: i32) i32 {
        const lo = @min(min, max);
        const hi = @max(min, max);
        return self.r().intRangeAtMost(i32, lo, hi);
    }

    pub fn index(self: *Rng, n: usize) usize {
        return self.r().uintLessThan(usize, n);
    }

    pub fn boolean(self: *Rng) bool {
        return self.r().boolean();
    }

    /// A scale factor in [1/s, s], picked so that shrinking and growing are
    /// equally likely. Used by the hue/saturation/exposure augmentation.
    pub fn scale(self: *Rng, s: f32) f32 {
        const v = self.uniform(1, s);
        return if (self.boolean()) v else 1.0 / v;
    }

    pub fn u64Value(self: *Rng) u64 {
        return self.r().int(u64);
    }
};

/// The generator used by everything that runs on the main thread: weight
/// initialisation, dropout masks, batch shuffling.
pub var default: Rng = Rng.init(0);

pub fn seedDefault(seed: u64) void {
    default = Rng.init(seed);
}

// ---------------------------------------------------------------------------
// array statistics
// ---------------------------------------------------------------------------

pub fn sumArray(a: []const f32) f32 {
    var sum: f32 = 0;
    for (a) |v| sum += v;
    return sum;
}

pub fn meanArray(a: []const f32) f32 {
    return sumArray(a) / @as(f32, @floatFromInt(a.len));
}

pub fn varianceArray(a: []const f32) f32 {
    const mean = meanArray(a);
    var sum: f32 = 0;
    for (a) |v| sum += (v - mean) * (v - mean);
    return sum / @as(f32, @floatFromInt(a.len));
}

pub fn magArray(a: []const f32) f32 {
    var sum: f32 = 0;
    for (a) |v| sum += v * v;
    return @sqrt(sum);
}

pub fn maxIndex(a: []const f32) usize {
    if (a.len == 0) return 0;
    var best: usize = 0;
    for (a, 0..) |v, i| {
        if (v > a[best]) best = i;
    }
    return best;
}

/// Fills `index` with the positions of the `index.len` largest entries of `a`,
/// most significant first. Direct translation of darknet's insertion-style
/// `top_k`, which is fine because k is 1 or 5 in practice.
pub fn topK(a: []const f32, index: []usize) void {
    // `maxInt` stands in for the -1 sentinel the C version used to mark an
    // unfilled slot; every entry shifts right by one as a new maximum is
    // inserted, so the list stays sorted descending.
    const empty = std.math.maxInt(usize);
    for (index) |*slot| slot.* = empty;
    for (0..a.len) |i| {
        var curr: usize = i;
        for (index) |*slot| {
            if (slot.* == empty or (curr != empty and a[curr] > a[slot.*])) {
                const swap = curr;
                curr = slot.*;
                slot.* = swap;
            }
        }
    }
    // Only reachable when k exceeds the number of elements.
    for (index) |*slot| {
        if (slot.* == empty) slot.* = 0;
    }
}

pub fn constrainInt(a: i32, min: i32, max: i32) i32 {
    return @max(min, @min(max, a));
}

pub fn constrain(min: f32, max: f32, a: f32) f32 {
    return @max(min, @min(max, a));
}

// ---------------------------------------------------------------------------
// strings
// ---------------------------------------------------------------------------

/// "cfg/cifar.cfg" -> "cifar". Used to name checkpoint files.
pub fn baseCfg(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    var name = path;
    if (std.mem.lastIndexOfScalar(u8, name, '/')) |i| name = name[i + 1 ..];
    if (std.mem.lastIndexOfScalar(u8, name, '.')) |i| name = name[0..i];
    return allocator.dupe(u8, name);
}

/// Remove spaces, tabs and carriage returns in place, returning the shortened
/// slice. cfg files are full of `key = value` with arbitrary padding.
pub fn stripInPlace(s: []u8) []u8 {
    var w: usize = 0;
    for (s) |c| {
        if (c == ' ' or c == '\t' or c == '\n' or c == '\r') continue;
        s[w] = c;
        w += 1;
    }
    return s[0..w];
}

pub fn strip(s: []const u8) []const u8 {
    return std.mem.trim(u8, s, " \t\r\n");
}

pub fn parseInt(s: []const u8, def: i32) i32 {
    return std.fmt.parseInt(i32, strip(s), 10) catch blk: {
        // darknet used atoi, which stops at the first non-digit rather than
        // failing. Some cfg files in the wild rely on that (trailing comments,
        // stray characters), so fall back to a prefix parse.
        const t = strip(s);
        var end: usize = 0;
        if (end < t.len and (t[end] == '-' or t[end] == '+')) end += 1;
        while (end < t.len and std.ascii.isDigit(t[end])) end += 1;
        if (end == 0) break :blk def;
        break :blk std.fmt.parseInt(i32, t[0..end], 10) catch def;
    };
}

pub fn parseFloat(s: []const u8, def: f32) f32 {
    return std.fmt.parseFloat(f32, strip(s)) catch def;
}

/// Parse a comma-separated list of ints, as used by `steps=`, `layers=` and
/// `mask=`. Caller owns the result.
pub fn parseIntList(allocator: std.mem.Allocator, s: []const u8) ![]i32 {
    var list: std.ArrayList(i32) = .empty;
    errdefer list.deinit(allocator);
    var it = std.mem.tokenizeScalar(u8, s, ',');
    while (it.next()) |tok| try list.append(allocator, parseInt(tok, 0));
    return list.toOwnedSlice(allocator);
}

pub fn parseFloatList(allocator: std.mem.Allocator, s: []const u8) ![]f32 {
    var list: std.ArrayList(f32) = .empty;
    errdefer list.deinit(allocator);
    var it = std.mem.tokenizeScalar(u8, s, ',');
    while (it.next()) |tok| try list.append(allocator, parseFloat(tok, 0));
    return list.toOwnedSlice(allocator);
}

test "topK picks the largest entries in order" {
    const a = [_]f32{ 0.1, 0.9, 0.3, 0.7, 0.5 };
    var idx: [3]usize = undefined;
    topK(a[0..], idx[0..]);
    try std.testing.expectEqual(@as(usize, 1), idx[0]);
    try std.testing.expectEqual(@as(usize, 3), idx[1]);
    try std.testing.expectEqual(@as(usize, 4), idx[2]);
}

test "baseCfg strips directory and extension" {
    const b = try baseCfg(std.testing.allocator, "cfg/cifar.cfg");
    defer std.testing.allocator.free(b);
    try std.testing.expectEqualStrings("cifar", b);
}
