//! Parsing for darknet's two INI-ish file formats: network configs
//! (`[section]` headers with key=value bodies) and data configs (bare
//! key=value pairs). Both are read whole and the parsed entries borrow slices
//! of that one buffer, so the owning struct must outlive every lookup.

const std = @import("std");
const sys = @import("sys.zig");
const utils = @import("utils.zig");

pub const Entry = struct {
    key: []const u8,
    value: []const u8,
    /// Tracks whether anything read this key, so the parser can warn about
    /// options it silently ignored -- typically a typo or a feature this port
    /// doesn't implement.
    used: bool = false,
};

pub const Options = struct {
    entries: std.ArrayList(Entry) = .empty,

    pub fn deinit(self: *Options, allocator: std.mem.Allocator) void {
        self.entries.deinit(allocator);
    }

    pub fn insert(self: *Options, allocator: std.mem.Allocator, key: []const u8, value: []const u8) !void {
        try self.entries.append(allocator, .{ .key = key, .value = value });
    }

    pub fn find(self: *Options, key: []const u8) ?[]const u8 {
        for (self.entries.items) |*e| {
            if (std.mem.eql(u8, e.key, key)) {
                e.used = true;
                return e.value;
            }
        }
        return null;
    }

    pub fn str(self: *Options, key: []const u8, def: ?[]const u8) ?[]const u8 {
        return self.find(key) orelse def;
    }

    pub fn int(self: *Options, key: []const u8, def: i32) i32 {
        const v = self.find(key) orelse {
            std.debug.print("{s}: Using default '{d}'\n", .{ key, def });
            return def;
        };
        return utils.parseInt(v, def);
    }

    pub fn intQuiet(self: *Options, key: []const u8, def: i32) i32 {
        const v = self.find(key) orelse return def;
        return utils.parseInt(v, def);
    }

    pub fn float(self: *Options, key: []const u8, def: f32) f32 {
        const v = self.find(key) orelse {
            std.debug.print("{s}: Using default '{d}'\n", .{ key, def });
            return def;
        };
        return utils.parseFloat(v, def);
    }

    pub fn floatQuiet(self: *Options, key: []const u8, def: f32) f32 {
        const v = self.find(key) orelse return def;
        return utils.parseFloat(v, def);
    }

    pub fn boolQuiet(self: *Options, key: []const u8, def: bool) bool {
        return self.intQuiet(key, if (def) 1 else 0) != 0;
    }

    pub fn reportUnused(self: *Options) void {
        for (self.entries.items) |e| {
            if (!e.used) std.debug.print("Unused field: '{s} = {s}'\n", .{ e.key, e.value });
        }
    }
};

pub const Section = struct {
    /// The header with its brackets removed, e.g. "convolutional".
    name: []const u8,
    options: Options = .{},
};

/// A parsed network config. Owns the file contents every slice points into.
pub const Cfg = struct {
    allocator: std.mem.Allocator,
    buffer: []u8,
    sections: std.ArrayList(Section),

    pub fn deinit(self: *Cfg) void {
        for (self.sections.items) |*s| s.options.deinit(self.allocator);
        self.sections.deinit(self.allocator);
        self.allocator.free(self.buffer);
        self.* = undefined;
    }
};

fn splitOption(line: []const u8) ?struct { key: []const u8, value: []const u8 } {
    const eq = std.mem.indexOfScalar(u8, line, '=') orelse return null;
    if (eq + 1 >= line.len) return null;
    return .{ .key = line[0..eq], .value = line[eq + 1 ..] };
}

pub fn readCfg(allocator: std.mem.Allocator, path: []const u8) !Cfg {
    return parseCfg(allocator, try sys.readTextFile(path), path);
}

/// Complaining about every malformed line is only useful when there are a
/// handful. Handing a binary file to the parser by mistake otherwise buries
/// the real message under thousands of them.
const max_reported_errors = 8;

/// Parse an already-loaded config. Takes ownership of `buffer`, which the
/// returned `Cfg` frees; entries are slices into it. `name` appears in
/// diagnostics only. Split out from `readCfg` so networks can be built from a
/// string, which is what the tests do.
pub fn parseCfg(allocator: std.mem.Allocator, buffer: []u8, name: []const u8) !Cfg {
    errdefer allocator.free(buffer);

    // A .weights file passed where a .cfg was expected is the overwhelmingly
    // common way to get here with nonsense, and it is worth catching before
    // the line loop rather than after: a NUL byte means this is not text.
    if (std.mem.indexOfScalar(u8, buffer[0..@min(buffer.len, 4096)], 0) != null) {
        std.debug.print(
            \\{s} is not a text file, so it cannot be a darknet .cfg.
            \\If you meant to pass a .weights file, note the argument order:
            \\  classifier predict <data.cfg> <net.cfg> <weights> <image>
            \\
        , .{name});
        return error.NotAConfigFile;
    }

    var sections: std.ArrayList(Section) = .empty;
    errdefer {
        for (sections.items) |*s| s.options.deinit(allocator);
        sections.deinit(allocator);
    }

    // Whitespace is stripped in place, so the trimmed text stays inside the
    // same allocation and every slice below borrows from it.
    var offset: usize = 0;
    var line_no: usize = 0;
    var errors: usize = 0;
    while (offset < buffer.len) {
        const end = std.mem.indexOfScalarPos(u8, buffer, offset, '\n') orelse buffer.len;
        const raw = buffer[offset..end];
        offset = end + 1;
        line_no += 1;

        const line = utils.stripInPlace(raw);
        if (line.len == 0) continue;
        switch (line[0]) {
            '#', ';' => continue,
            '[' => {
                const close = std.mem.indexOfScalar(u8, line, ']') orelse line.len;
                try sections.append(allocator, .{ .name = line[1..close] });
            },
            else => {
                const kv = splitOption(line) orelse {
                    errors += 1;
                    if (errors <= max_reported_errors) {
                        std.debug.print("{s}:{d}: could not parse: {s}\n", .{ name, line_no, line });
                    }
                    continue;
                };
                if (sections.items.len == 0) {
                    errors += 1;
                    if (errors <= max_reported_errors) {
                        std.debug.print("{s}:{d}: option outside any section\n", .{ name, line_no });
                    }
                    continue;
                }
                try sections.items[sections.items.len - 1].options.insert(allocator, kv.key, kv.value);
            },
        }
    }
    if (errors > max_reported_errors) {
        std.debug.print("{s}: ... and {d} more malformed lines\n", .{ name, errors - max_reported_errors });
    }

    if (sections.items.len == 0) {
        std.debug.print(
            \\{s} contains no [section] headers, so it is not a darknet .cfg.
            \\If you meant to pass a .weights file, note the argument order:
            \\  classifier predict <data.cfg> <net.cfg> <weights> <image>
            \\
        , .{name});
        return error.NotAConfigFile;
    }

    return .{ .allocator = allocator, .buffer = buffer, .sections = sections };
}

/// A `.data` file: flat key=value pairs, no sections.
pub const DataCfg = struct {
    allocator: std.mem.Allocator,
    buffer: []u8,
    options: Options = .{},

    pub fn deinit(self: *DataCfg) void {
        self.options.deinit(self.allocator);
        self.allocator.free(self.buffer);
        self.* = undefined;
    }
};

pub fn readDataCfg(allocator: std.mem.Allocator, path: []const u8) !DataCfg {
    const buffer = try sys.readTextFile(path);
    errdefer allocator.free(buffer);

    var cfg: DataCfg = .{ .allocator = allocator, .buffer = buffer };
    errdefer cfg.options.deinit(allocator);

    var offset: usize = 0;
    while (offset < buffer.len) {
        const end = std.mem.indexOfScalarPos(u8, buffer, offset, '\n') orelse buffer.len;
        const raw = buffer[offset..end];
        offset = end + 1;

        const line = utils.stripInPlace(raw);
        if (line.len == 0 or line[0] == '#' or line[0] == ';') continue;
        const kv = splitOption(line) orelse continue;
        try cfg.options.insert(allocator, kv.key, kv.value);
    }
    return cfg;
}

test "parseCfg reads sections, options and comments" {
    const a = std.testing.allocator;
    const src = "[net]\nbatch = 8\n# a comment\n; another\n\n[convolutional]\nfilters=16\n";
    var cfg = try parseCfg(a, try a.dupe(u8, src), "test.cfg");
    defer cfg.deinit();

    try std.testing.expectEqual(@as(usize, 2), cfg.sections.items.len);
    try std.testing.expectEqualStrings("net", cfg.sections.items[0].name);
    try std.testing.expectEqual(@as(i32, 8), cfg.sections.items[0].options.intQuiet("batch", 0));
    try std.testing.expectEqualStrings("convolutional", cfg.sections.items[1].name);
    try std.testing.expectEqual(@as(i32, 16), cfg.sections.items[1].options.intQuiet("filters", 0));
}

test "parseCfg rejects a .weights file passed as a config" {
    // Mixing up the positional arguments is the easiest CLI mistake to make,
    // and it used to produce thousands of lines of parse errors (upstream
    // darknet segfaults). Detect it from the NUL bytes and say so once.
    const a = std.testing.allocator;
    const binary = "\x00\x00\x00\x00\x02\x00\x00\x00" ++ "\xff\xfe\x01\x00 not text at all";
    try std.testing.expectError(
        error.NotAConfigFile,
        parseCfg(a, try a.dupe(u8, binary), "tiny.weights"),
    );
}

test "parseCfg rejects text with no section headers" {
    // e.g. handing it a .data file, which is the other half of the same slip.
    const a = std.testing.allocator;
    const src = "classes = 2\ntrain = foo.list\nlabels = bar.list\n";
    try std.testing.expectError(
        error.NotAConfigFile,
        parseCfg(a, try a.dupe(u8, src), "imagenet1k.data"),
    );
}
