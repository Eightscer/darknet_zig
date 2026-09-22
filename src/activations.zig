//! Element-wise activation functions and their gradients.
//!
//! Note the convention inherited from darknet: `gradient` takes the *output*
//! of the activation, not its input. That is why `logistic_gradient(y)` is
//! `(1-y)*y` rather than anything involving x -- the forward pass overwrites
//! the pre-activation values in place, so only y survives to the backward
//! pass.

const std = @import("std");

pub const Activation = enum(c_int) {
    // The numeric values matter: they are passed to the HIP kernels, which
    // switch on the same enum, and they must stay in the order darknet used.
    logistic = 0,
    relu = 1,
    relie = 2,
    linear = 3,
    ramp = 4,
    tanh = 5,
    plse = 6,
    leaky = 7,
    elu = 8,
    loggy = 9,
    stair = 10,
    hardtan = 11,
    lhtan = 12,
    selu = 13,

    pub fn fromString(s: []const u8) Activation {
        const table = .{
            .{ "logistic", Activation.logistic },
            .{ "loggy", Activation.loggy },
            .{ "relu", Activation.relu },
            .{ "elu", Activation.elu },
            .{ "selu", Activation.selu },
            .{ "relie", Activation.relie },
            .{ "plse", Activation.plse },
            .{ "hardtan", Activation.hardtan },
            .{ "lhtan", Activation.lhtan },
            .{ "linear", Activation.linear },
            .{ "ramp", Activation.ramp },
            .{ "leaky", Activation.leaky },
            .{ "tanh", Activation.tanh },
            .{ "stair", Activation.stair },
        };
        inline for (table) |entry| {
            if (std.mem.eql(u8, s, entry[0])) return entry[1];
        }
        std.debug.print("Couldn't find activation function {s}, going with ReLU\n", .{s});
        return .relu;
    }

    pub fn toString(a: Activation) []const u8 {
        return @tagName(a);
    }
};

pub fn activate(x: f32, a: Activation) f32 {
    return switch (a) {
        .linear => x,
        .logistic => 1.0 / (1.0 + @exp(-x)),
        .loggy => 2.0 / (1.0 + @exp(-x)) - 1.0,
        .relu => if (x > 0) x else 0,
        .elu => if (x >= 0) x else @exp(x) - 1,
        .selu => if (x >= 0) 1.0507 * x else 1.0507 * 1.6732 * (@exp(x) - 1),
        .relie => if (x > 0) x else 0.01 * x,
        .ramp => (if (x > 0) x else 0) + 0.1 * x,
        .leaky => if (x > 0) x else 0.1 * x,
        .tanh => blk: {
            const e = @exp(2 * x);
            break :blk (e - 1) / (e + 1);
        },
        .plse => if (x < -4) 0.01 * (x + 4) else if (x > 4) 0.01 * (x - 4) + 1 else 0.125 * x + 0.5,
        .stair => blk: {
            const n = @floor(x);
            const ni: i64 = @intFromFloat(n);
            break :blk if (@rem(ni, 2) == 0) @floor(x / 2) else (x - n) + @floor(x / 2);
        },
        .hardtan => std.math.clamp(x, -1, 1),
        .lhtan => if (x < 0) 0.001 * x else if (x > 1) 0.001 * (x - 1) + 1 else x,
    };
}

/// `y` is the activation's output, see the note at the top of the file.
pub fn gradient(y: f32, a: Activation) f32 {
    return switch (a) {
        .linear => 1,
        .logistic => (1 - y) * y,
        .loggy => blk: {
            const t = (y + 1) / 2;
            break :blk 2 * (1 - t) * t;
        },
        .relu => if (y > 0) 1 else 0,
        .elu => if (y >= 0) 1 else y + 1,
        .selu => if (y >= 0) 1.0507 else y + 1.0507 * 1.6732,
        .relie => if (y > 0) 1 else 0.01,
        .ramp => (if (y > 0) @as(f32, 1) else @as(f32, 0)) + 0.1,
        .leaky => if (y > 0) 1 else 0.1,
        .tanh => 1 - y * y,
        .plse => if (y < 0 or y > 1) 0.01 else 0.125,
        .stair => if (@floor(y) == y) 0 else 1,
        .hardtan => if (y > -1 and y < 1) 1 else 0,
        .lhtan => if (y > 0 and y < 1) 1 else 0.001,
    };
}

pub fn activateArray(x: []f32, a: Activation) void {
    // Hoisting the switch out of the loop lets LLVM vectorise the common
    // cases (leaky, relu, linear) instead of branching per element.
    switch (a) {
        .linear => {},
        .leaky => for (x) |*v| {
            v.* = if (v.* > 0) v.* else 0.1 * v.*;
        },
        .relu => for (x) |*v| {
            v.* = if (v.* > 0) v.* else 0;
        },
        .logistic => for (x) |*v| {
            v.* = 1.0 / (1.0 + @exp(-v.*));
        },
        else => for (x) |*v| {
            v.* = activate(v.*, a);
        },
    }
}

pub fn gradientArray(y: []const f32, a: Activation, delta: []f32) void {
    switch (a) {
        .linear => {},
        .leaky => for (y, delta) |v, *d| {
            d.* *= if (v > 0) 1 else 0.1;
        },
        .relu => for (y, delta) |v, *d| {
            d.* *= if (v > 0) 1 else 0;
        },
        .logistic => for (y, delta) |v, *d| {
            d.* *= (1 - v) * v;
        },
        else => for (y, delta) |v, *d| {
            d.* *= gradient(v, a);
        },
    }
}

test "leaky activation and its gradient agree with darknet" {
    try std.testing.expectApproxEqAbs(@as(f32, 2.0), activate(2.0, .leaky), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -0.2), activate(-2.0, .leaky), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 1.0), gradient(2.0, .leaky), 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 0.1), gradient(-0.2, .leaky), 1e-6);
}
