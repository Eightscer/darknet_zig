//! Process-wide handles that darknet's C original got for free from libc.
//!
//! Zig 0.16 threads an explicit `std.Io` through every filesystem call, and an
//! allocator through every allocation. Rather than add two parameters to the
//! several hundred functions ported from darknet -- where the C code just
//! called `fopen` and `calloc` -- both live here as globals initialised once
//! by `main`. The rest of the codebase reads them like ambient state, which is
//! the same shape the original had, without pretending they aren't globals.

const std = @import("std");

pub var io: std.Io = undefined;
pub var gpa: std.mem.Allocator = undefined;

/// Set once, at the top of main, before anything else runs.
pub fn init(the_io: std.Io, allocator: std.mem.Allocator) void {
    io = the_io;
    gpa = allocator;
}

/// Monotonic seconds since an arbitrary epoch. The analogue of darknet's
/// `what_time_is_it_now()`, used for the per-batch timing printouts.
pub fn now() f64 {
    const ns = std.Io.Timestamp.now(io, .awake).nanoseconds;
    return @as(f64, @floatFromInt(ns)) / 1e9;
}

pub fn readFile(path: []const u8, limit_bytes: usize) ![]u8 {
    return std.Io.Dir.cwd().readFileAlloc(io, path, gpa, .limited(limit_bytes)) catch |err| {
        std.debug.print("Couldn't open file: {s} ({t})\n", .{ path, err });
        return error.FileError;
    };
}

/// Text files (cfg, label lists, image path lists) are read whole; none of
/// them are big enough to be worth streaming.
pub const text_file_limit = 64 << 20;

pub fn readTextFile(path: []const u8) ![]u8 {
    return readFile(path, text_file_limit);
}

/// Iterate the lines of a buffer with trailing '\r' stripped, skipping the
/// empty last element that a trailing newline produces. Replaces darknet's
/// `fgetl` loop.
pub const LineIter = struct {
    rest: []const u8,

    pub fn init(buf: []const u8) LineIter {
        return .{ .rest = buf };
    }

    pub fn next(self: *LineIter) ?[]const u8 {
        if (self.rest.len == 0) return null;
        const end = std.mem.indexOfScalar(u8, self.rest, '\n') orelse {
            const line = self.rest;
            self.rest = self.rest[self.rest.len..];
            return std.mem.trimEnd(u8, line, "\r");
        };
        const line = self.rest[0..end];
        self.rest = self.rest[end + 1 ..];
        return std.mem.trimEnd(u8, line, "\r");
    }
};

/// Buffered sequential reader over a file, for the binary .weights format.
pub const BinReader = struct {
    file: std.Io.File,
    buf: []u8,
    reader: std.Io.File.Reader,

    pub fn open(path: []const u8) !BinReader {
        const file = std.Io.Dir.cwd().openFile(io, path, .{}) catch |err| {
            std.debug.print("Couldn't open file: {s} ({t})\n", .{ path, err });
            return error.FileError;
        };
        const buf = try gpa.alloc(u8, 1 << 16);
        var self: BinReader = .{ .file = file, .buf = buf, .reader = undefined };
        self.reader = file.reader(io, buf);
        return self;
    }

    pub fn close(self: *BinReader) void {
        self.file.close(io);
        gpa.free(self.buf);
    }

    pub fn readInto(self: *BinReader, comptime T: type, dest: []T) !void {
        try self.reader.interface.readSliceAll(std.mem.sliceAsBytes(dest));
    }

    pub fn readOne(self: *BinReader, comptime T: type) !T {
        var v: [1]T = undefined;
        try self.readInto(T, v[0..]);
        return v[0];
    }

    /// Skip `n` bytes; used when a layer is marked `dontload` but its weights
    /// still occupy space in the file.
    pub fn skip(self: *BinReader, n: usize) !void {
        try self.reader.interface.discardAll(n);
    }
};

/// Buffered sequential writer, the mirror of `BinReader`.
pub const BinWriter = struct {
    file: std.Io.File,
    buf: []u8,
    writer: std.Io.File.Writer,

    pub fn create(path: []const u8) !BinWriter {
        const file = std.Io.Dir.cwd().createFile(io, path, .{}) catch |err| {
            std.debug.print("Couldn't create file: {s} ({t})\n", .{ path, err });
            return error.FileError;
        };
        const buf = try gpa.alloc(u8, 1 << 16);
        var self: BinWriter = .{ .file = file, .buf = buf, .writer = undefined };
        self.writer = file.writer(io, buf);
        return self;
    }

    pub fn write(self: *BinWriter, comptime T: type, src: []const T) !void {
        try self.writer.interface.writeAll(std.mem.sliceAsBytes(src));
    }

    pub fn writeOne(self: *BinWriter, comptime T: type, v: T) !void {
        const a = [1]T{v};
        try self.write(T, a[0..]);
    }

    /// Flush and close. Must be called for the file to be complete; on the
    /// error path use `abort` instead.
    pub fn finish(self: *BinWriter) !void {
        errdefer self.abort();
        try self.writer.interface.flush();
        self.file.close(io);
        gpa.free(self.buf);
    }

    /// Release the handle and buffer, abandoning anything still buffered.
    pub fn abort(self: *BinWriter) void {
        self.file.close(io);
        gpa.free(self.buf);
    }
};

/// stdout, line-buffered. The training loop prints one line per batch, so
/// going through an unbuffered write syscall per formatted chunk would be
/// wasteful.
var stdout_buf: [4096]u8 = undefined;
var stdout_writer: ?std.Io.File.Writer = null;

pub fn print(comptime fmt: []const u8, args: anytype) void {
    if (stdout_writer == null) {
        stdout_writer = std.Io.File.stdout().writer(io, &stdout_buf);
    }
    const w = &stdout_writer.?.interface;
    w.print(fmt, args) catch return;
    w.flush() catch return;
}
