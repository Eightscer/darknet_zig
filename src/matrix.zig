//! A row-of-pointers matrix, matching darknet's `matrix`. Rows are separately
//! allocated because the image loader hands ownership of a decoded image's
//! pixel buffer straight over as a row, without copying it.

const std = @import("std");
const utils = @import("utils.zig");

pub const Matrix = struct {
    rows: usize = 0,
    cols: usize = 0,
    vals: [][]f32 = &.{},

    pub fn init(allocator: std.mem.Allocator, rows: usize, cols: usize) !Matrix {
        const vals = try allocator.alloc([]f32, rows);
        errdefer allocator.free(vals);
        var made: usize = 0;
        errdefer for (vals[0..made]) |r| allocator.free(r);
        while (made < rows) : (made += 1) {
            const row = try allocator.alloc(f32, cols);
            @memset(row, 0);
            vals[made] = row;
        }
        return .{ .rows = rows, .cols = cols, .vals = vals };
    }

    /// Allocates the row array but leaves the rows themselves unset, for the
    /// loader to fill in with buffers it already owns.
    pub fn initRowsUnset(allocator: std.mem.Allocator, rows: usize) !Matrix {
        const vals = try allocator.alloc([]f32, rows);
        @memset(vals, &.{});
        return .{ .rows = rows, .cols = 0, .vals = vals };
    }

    pub fn deinit(self: *Matrix, allocator: std.mem.Allocator) void {
        for (self.vals) |row| {
            if (row.len != 0) allocator.free(row);
        }
        allocator.free(self.vals);
        self.* = .{};
    }

    /// Release the row array but not the rows, for a "shallow" view whose rows
    /// are owned by another matrix.
    pub fn deinitShallow(self: *Matrix, allocator: std.mem.Allocator) void {
        allocator.free(self.vals);
        self.* = .{};
    }

    pub fn scale(self: Matrix, s: f32) void {
        for (self.vals) |row| {
            for (row) |*v| v.* *= s;
        }
    }
};

/// Fraction of rows where the true class is among the k highest-scoring
/// predictions.
pub fn topkAccuracy(allocator: std.mem.Allocator, truth: Matrix, guess: Matrix, k: usize) !f32 {
    const indexes = try allocator.alloc(usize, k);
    defer allocator.free(indexes);
    var correct: usize = 0;
    for (0..truth.rows) |i| {
        utils.topK(guess.vals[i][0..truth.cols], indexes);
        for (indexes) |class| {
            if (truth.vals[i][class] != 0) {
                correct += 1;
                break;
            }
        }
    }
    if (truth.rows == 0) return 0;
    return @as(f32, @floatFromInt(correct)) / @as(f32, @floatFromInt(truth.rows));
}
