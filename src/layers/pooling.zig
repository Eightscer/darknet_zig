//! Max pooling and global average pooling.

const std = @import("std");
const lay = @import("../layer.zig");
const gpu = @import("../gpu.zig");

const Layer = lay.Layer;
const State = lay.State;

// ---------------------------------------------------------------------------
// maxpool
// ---------------------------------------------------------------------------

pub fn makeMaxpool(
    allocator: std.mem.Allocator,
    batch: usize,
    h: usize,
    w: usize,
    c: usize,
    size: usize,
    stride: usize,
    padding: usize,
) !Layer {
    var l: Layer = .{ .kind = .maxpool };
    l.batch = batch;
    l.h = h;
    l.w = w;
    l.c = c;
    l.pad = padding;
    // Note the single `padding`, not `2*pad`: darknet's maxpool padding is the
    // *total* extra extent, split half above and half below, which is why the
    // kernels use an offset of -pad/2.
    l.out_w = (w + padding - size) / stride + 1;
    l.out_h = (h + padding - size) / stride + 1;
    l.out_c = c;
    l.outputs = l.out_h * l.out_w * l.out_c;
    l.inputs = h * w * c;
    l.size = size;
    l.stride = stride;

    const output_size = l.outputs * batch;
    l.indexes = try allocator.alloc(i32, output_size);
    @memset(l.indexes, 0);
    l.output = try lay.zeros(allocator, output_size);
    l.delta = try lay.zeros(allocator, output_size);

    if (gpu.active()) {
        l.gpu.indexes = gpu.allocInts(output_size);
        l.gpu.output = gpu.alloc(output_size);
        l.gpu.delta = gpu.alloc(output_size);
    }

    std.debug.print("max          {d} x {d} / {d}  {d:4} x{d:4} x{d:4}   ->  {d:4} x{d:4} x{d:4}\n", .{
        size, size, stride, w, h, c, l.out_w, l.out_h, l.out_c,
    });
    return l;
}

pub fn forwardMaxpool(l: *Layer, state: *State) void {
    const w_offset: isize = -@as(isize, @intCast(l.pad / 2));
    const h_offset: isize = w_offset;
    const h = l.out_h;
    const w = l.out_w;
    const c = l.c;

    for (0..l.batch) |b| {
        for (0..c) |k| {
            for (0..h) |i| {
                for (0..w) |j| {
                    const out_index = j + w * (i + h * (k + c * b));
                    var max: f32 = -std.math.floatMax(f32);
                    var max_i: i32 = -1;
                    for (0..l.size) |n| {
                        for (0..l.size) |m| {
                            const cur_h = h_offset + @as(isize, @intCast(i * l.stride + n));
                            const cur_w = w_offset + @as(isize, @intCast(j * l.stride + m));
                            if (cur_h < 0 or cur_h >= @as(isize, @intCast(l.h))) continue;
                            if (cur_w < 0 or cur_w >= @as(isize, @intCast(l.w))) continue;
                            const index = @as(usize, @intCast(cur_w)) + l.w * (@as(usize, @intCast(cur_h)) + l.h * (k + b * l.c));
                            const val = state.input[index];
                            if (val > max) {
                                max = val;
                                max_i = @intCast(index);
                            }
                        }
                    }
                    l.output[out_index] = max;
                    l.indexes[out_index] = max_i;
                }
            }
        }
    }
}

pub fn backwardMaxpool(l: *Layer, state: *State) void {
    if (state.delta.len == 0) return;
    const n = l.out_h * l.out_w * l.c * l.batch;
    for (0..n) |i| {
        const index = l.indexes[i];
        if (index < 0) continue;
        state.delta[@intCast(index)] += l.delta[i];
    }
}

pub fn forwardMaxpoolGpu(l: *Layer, state: *State) void {
    const n = l.out_h * l.out_w * l.c * l.batch;
    gpu.forwardMaxpool(n, l.h, l.w, l.c, l.stride, l.size, l.pad, state.input_gpu, l.gpu.output, l.gpu.indexes);
}

pub fn backwardMaxpoolGpu(l: *Layer, state: *State) void {
    if (state.delta_gpu.isNull()) return;
    const n = l.h * l.w * l.c * l.batch;
    gpu.backwardMaxpool(n, l.h, l.w, l.c, l.stride, l.size, l.pad, l.gpu.delta, state.delta_gpu, l.gpu.indexes);
}

// ---------------------------------------------------------------------------
// avgpool
// ---------------------------------------------------------------------------

/// Global average pooling: collapses each channel to a single number, which is
/// how darknet's classifiers turn a feature map into class scores.
pub fn makeAvgpool(allocator: std.mem.Allocator, batch: usize, w: usize, h: usize, c: usize) !Layer {
    std.debug.print("avg                     {d:4} x{d:4} x{d:4}   ->  {d:4}\n", .{ w, h, c, c });
    var l: Layer = .{ .kind = .avgpool };
    l.batch = batch;
    l.h = h;
    l.w = w;
    l.c = c;
    l.out_w = 1;
    l.out_h = 1;
    l.out_c = c;
    l.outputs = c;
    l.inputs = h * w * c;

    const output_size = l.outputs * batch;
    l.output = try lay.zeros(allocator, output_size);
    l.delta = try lay.zeros(allocator, output_size);

    if (gpu.active()) {
        l.gpu.output = gpu.alloc(output_size);
        l.gpu.delta = gpu.alloc(output_size);
    }
    return l;
}

pub fn forwardAvgpool(l: *Layer, state: *State) void {
    const spatial = l.h * l.w;
    const denom: f32 = @floatFromInt(spatial);
    for (0..l.batch) |b| {
        for (0..l.c) |k| {
            const out_index = k + b * l.c;
            const base = spatial * (k + b * l.c);
            var sum: f32 = 0;
            for (state.input[base..][0..spatial]) |v| sum += v;
            l.output[out_index] = sum / denom;
        }
    }
}

pub fn backwardAvgpool(l: *Layer, state: *State) void {
    if (state.delta.len == 0) return;
    const spatial = l.h * l.w;
    const denom: f32 = @floatFromInt(spatial);
    for (0..l.batch) |b| {
        for (0..l.c) |k| {
            const out_index = k + b * l.c;
            const base = spatial * (k + b * l.c);
            const d = l.delta[out_index] / denom;
            for (state.delta[base..][0..spatial]) |*v| v.* += d;
        }
    }
}

pub fn forwardAvgpoolGpu(l: *Layer, state: *State) void {
    gpu.forwardAvgpool(l.c * l.batch, l.w, l.h, l.c, state.input_gpu, l.gpu.output);
}

pub fn backwardAvgpoolGpu(l: *Layer, state: *State) void {
    if (state.delta_gpu.isNull()) return;
    gpu.backwardAvgpool(l.c * l.batch, l.w, l.h, l.c, state.delta_gpu, l.gpu.delta);
}
