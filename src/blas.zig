//! Array-level primitives: the contents of darknet's blas.c, plus the bias and
//! batch-norm helpers that upstream happened to keep in convolutional_layer.c
//! and batchnorm_layer.c. They are all pure array maths, so they live together
//! here and each has a matching HIP kernel in src/kernels/darknet_kernels.hip.
//!
//! darknet's versions take (n, ptr, incx) triples in BLAS style, but every
//! call site in the classification path uses a stride of 1, so these take
//! slices instead. Where a stride genuinely varies -- softmax over a spatial
//! grid -- it stays an explicit parameter.

const std = @import("std");

pub fn fill(x: []f32, alpha: f32) void {
    @memset(x, alpha);
}

pub fn copy(src: []const f32, dst: []f32) void {
    @memcpy(dst[0..src.len], src);
}

pub fn axpy(alpha: f32, x: []const f32, y: []f32) void {
    @setFloatMode(.optimized);
    for (y[0..x.len], x) |*yv, xv| yv.* += alpha * xv;
}

pub fn scal(alpha: f32, x: []f32) void {
    @setFloatMode(.optimized);
    for (x) |*v| v.* *= alpha;
}

pub fn mul(x: []const f32, y: []f32) void {
    for (y[0..x.len], x) |*yv, xv| yv.* *= xv;
}

pub fn dot(x: []const f32, y: []const f32) f32 {
    @setFloatMode(.optimized);
    var sum: f32 = 0;
    for (x, y[0..x.len]) |a, b| sum += a * b;
    return sum;
}

/// Clamp magnitudes to `alpha`. darknet applies this to the incoming delta of
/// a connected layer to keep exploding gradients from poisoning a run.
pub fn constrainArray(alpha: f32, x: []f32) void {
    for (x) |*v| v.* = std.math.clamp(v.*, -alpha, alpha);
}

// ---------------------------------------------------------------------------
// bias / scale
// ---------------------------------------------------------------------------
// Layout throughout is NCHW: output[((b*filters) + f)*spatial + s].

pub fn addBias(output: []f32, biases: []const f32, batch: usize, filters: usize, spatial: usize) void {
    for (0..batch) |b| {
        for (0..filters) |f| {
            const base = (b * filters + f) * spatial;
            const bias = biases[f];
            for (output[base..][0..spatial]) |*v| v.* += bias;
        }
    }
}

pub fn scaleBias(output: []f32, scales: []const f32, batch: usize, filters: usize, spatial: usize) void {
    for (0..batch) |b| {
        for (0..filters) |f| {
            const base = (b * filters + f) * spatial;
            const s = scales[f];
            for (output[base..][0..spatial]) |*v| v.* *= s;
        }
    }
}

pub fn backwardBias(bias_updates: []f32, delta: []const f32, batch: usize, filters: usize, spatial: usize) void {
    for (0..batch) |b| {
        for (0..filters) |f| {
            const base = (b * filters + f) * spatial;
            var sum: f32 = 0;
            for (delta[base..][0..spatial]) |v| sum += v;
            bias_updates[f] += sum;
        }
    }
}

pub fn backwardScale(
    x_norm: []const f32,
    delta: []const f32,
    batch: usize,
    filters: usize,
    spatial: usize,
    scale_updates: []f32,
) void {
    for (0..filters) |f| {
        var sum: f32 = 0;
        for (0..batch) |b| {
            const base = (b * filters + f) * spatial;
            for (x_norm[base..][0..spatial], delta[base..][0..spatial]) |xv, dv| sum += dv * xv;
        }
        scale_updates[f] += sum;
    }
}

// ---------------------------------------------------------------------------
// batch normalisation
// ---------------------------------------------------------------------------

pub fn mean(x: []const f32, batch: usize, filters: usize, spatial: usize, out: []f32) void {
    const scale_f = 1.0 / @as(f32, @floatFromInt(batch * spatial));
    for (0..filters) |f| {
        var sum: f32 = 0;
        for (0..batch) |b| {
            const base = (b * filters + f) * spatial;
            for (x[base..][0..spatial]) |v| sum += v;
        }
        out[f] = sum * scale_f;
    }
}

/// Note the `- 1`: darknet uses the unbiased (sample) variance here but the
/// biased form implicitly in `normalize`, and the weights format depends on
/// reproducing that exactly.
pub fn variance(x: []const f32, mean_in: []const f32, batch: usize, filters: usize, spatial: usize, out: []f32) void {
    const scale_f = 1.0 / @as(f32, @floatFromInt(batch * spatial - 1));
    for (0..filters) |f| {
        var sum: f32 = 0;
        const m = mean_in[f];
        for (0..batch) |b| {
            const base = (b * filters + f) * spatial;
            for (x[base..][0..spatial]) |v| {
                const d = v - m;
                sum += d * d;
            }
        }
        out[f] = sum * scale_f;
    }
}

pub fn normalize(x: []f32, mean_in: []const f32, variance_in: []const f32, batch: usize, filters: usize, spatial: usize) void {
    for (0..batch) |b| {
        for (0..filters) |f| {
            const base = (b * filters + f) * spatial;
            const m = mean_in[f];
            const inv = 1.0 / (@sqrt(variance_in[f]) + 0.000001);
            for (x[base..][0..spatial]) |*v| v.* = (v.* - m) * inv;
        }
    }
}

pub fn meanDelta(delta: []const f32, variance_in: []const f32, batch: usize, filters: usize, spatial: usize, out: []f32) void {
    for (0..filters) |f| {
        var sum: f32 = 0;
        for (0..batch) |b| {
            const base = (b * filters + f) * spatial;
            for (delta[base..][0..spatial]) |v| sum += v;
        }
        out[f] = sum * (-1.0 / @sqrt(variance_in[f] + 0.00001));
    }
}

pub fn varianceDelta(
    x: []const f32,
    delta: []const f32,
    mean_in: []const f32,
    variance_in: []const f32,
    batch: usize,
    filters: usize,
    spatial: usize,
    out: []f32,
) void {
    for (0..filters) |f| {
        var sum: f32 = 0;
        const m = mean_in[f];
        for (0..batch) |b| {
            const base = (b * filters + f) * spatial;
            for (x[base..][0..spatial], delta[base..][0..spatial]) |xv, dv| sum += dv * (xv - m);
        }
        out[f] = sum * -0.5 * std.math.pow(f32, variance_in[f] + 0.00001, -1.5);
    }
}

pub fn normalizeDelta(
    x: []const f32,
    mean_in: []const f32,
    variance_in: []const f32,
    mean_delta_in: []const f32,
    variance_delta_in: []const f32,
    batch: usize,
    filters: usize,
    spatial: usize,
    delta: []f32,
) void {
    const denom: f32 = @floatFromInt(spatial * batch);
    for (0..batch) |b| {
        for (0..filters) |f| {
            const base = (b * filters + f) * spatial;
            const inv = 1.0 / @sqrt(variance_in[f] + 0.00001);
            const vd = variance_delta_in[f];
            const md = mean_delta_in[f];
            const m = mean_in[f];
            for (delta[base..][0..spatial], x[base..][0..spatial]) |*dv, xv| {
                dv.* = dv.* * inv + vd * 2.0 * (xv - m) / denom + md / denom;
            }
        }
    }
}

// ---------------------------------------------------------------------------
// softmax and losses
// ---------------------------------------------------------------------------

/// One softmax group. `stride` lets a group be interleaved through the buffer,
/// which the spatial-softmax and tree-softmax modes need; it is 1 for plain
/// classification.
pub fn softmaxOne(input: []const f32, n: usize, temp: f32, stride: usize, output: []f32) void {
    var largest: f32 = -std.math.floatMax(f32);
    for (0..n) |i| largest = @max(largest, input[i * stride]);
    var sum: f32 = 0;
    for (0..n) |i| {
        const e = @exp(input[i * stride] / temp - largest / temp);
        sum += e;
        output[i * stride] = e;
    }
    for (0..n) |i| output[i * stride] /= sum;
}

pub fn softmax(
    input: []const f32,
    n: usize,
    batch: usize,
    batch_offset: usize,
    groups: usize,
    group_offset: usize,
    stride: usize,
    temp: f32,
    output: []f32,
) void {
    for (0..batch) |b| {
        for (0..groups) |g| {
            const off = b * batch_offset + g * group_offset;
            softmaxOne(input[off..], n, temp, stride, output[off..]);
        }
    }
}

/// Cross entropy against a softmax output. `delta` is truth - pred, which is
/// already the gradient with respect to the pre-softmax logits, which is why
/// the softmax layer's backward pass is a plain axpy.
pub fn softmaxCrossEntropy(pred: []const f32, truth: []const f32, delta: []f32, err: []f32) void {
    for (pred, truth[0..pred.len], delta[0..pred.len], err[0..pred.len]) |p, t, *d, *e| {
        e.* = if (t != 0) -@log(p) else 0;
        d.* = t - p;
    }
}

pub fn l2(pred: []const f32, truth: []const f32, delta: []f32, err: []f32) void {
    for (pred, truth[0..pred.len], delta[0..pred.len], err[0..pred.len]) |p, t, *d, *e| {
        const diff = t - p;
        e.* = diff * diff;
        d.* = diff;
    }
}

pub fn l1(pred: []const f32, truth: []const f32, delta: []f32, err: []f32) void {
    for (pred, truth[0..pred.len], delta[0..pred.len], err[0..pred.len]) |p, t, *d, *e| {
        const diff = t - p;
        e.* = @abs(diff);
        d.* = if (diff > 0) 1 else -1;
    }
}

pub fn smoothL1(pred: []const f32, truth: []const f32, delta: []f32, err: []f32) void {
    for (pred, truth[0..pred.len], delta[0..pred.len], err[0..pred.len]) |p, t, *d, *e| {
        const diff = t - p;
        const a = @abs(diff);
        if (a < 1) {
            e.* = diff * diff;
            d.* = diff;
        } else {
            e.* = 2 * a - 1;
            d.* = if (diff < 0) 1 else -1;
        }
    }
}

// ---------------------------------------------------------------------------
// shortcut (residual add)
// ---------------------------------------------------------------------------

/// out = s1*out + s2*add, where `add` may be at a different resolution than
/// `out`; whichever is larger gets strided down to meet the other.
pub fn shortcut(
    batch: usize,
    w1: usize,
    h1: usize,
    c1: usize,
    add: []const f32,
    w2: usize,
    h2: usize,
    c2: usize,
    s1: f32,
    s2: f32,
    out: []f32,
) void {
    var stride = w1 / w2;
    var sample = w2 / w1;
    if (stride < 1) stride = 1;
    if (sample < 1) sample = 1;
    const minw = @min(w1, w2);
    const minh = @min(h1, h2);
    const minc = @min(c1, c2);

    for (0..batch) |b| {
        for (0..minc) |k| {
            for (0..minh) |j| {
                for (0..minw) |i| {
                    const out_index = i * sample + w2 * (j * sample + h2 * (k + c2 * b));
                    const add_index = i * stride + w1 * (j * stride + h1 * (k + c1 * b));
                    out[out_index] = s1 * out[out_index] + s2 * add[add_index];
                }
            }
        }
    }
}

test "softmax sums to one and cross entropy matches" {
    var input = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    var output: [4]f32 = undefined;
    softmax(input[0..], 4, 1, 4, 1, 4, 1, 1.0, output[0..]);
    var total: f32 = 0;
    for (output) |v| total += v;
    try std.testing.expectApproxEqAbs(@as(f32, 1.0), total, 1e-6);
    try std.testing.expect(output[3] > output[0]);
}

test "normalize then denormalize round trips" {
    var x = [_]f32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    var m: [2]f32 = undefined;
    var v: [2]f32 = undefined;
    mean(x[0..], 1, 2, 4, m[0..]);
    try std.testing.expectApproxEqAbs(@as(f32, 2.5), m[0], 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, 6.5), m[1], 1e-6);
    variance(x[0..], m[0..], 1, 2, 4, v[0..]);
    normalize(x[0..], m[0..], v[0..], 1, 2, 4);
    var sum: f32 = 0;
    for (x[0..4]) |e| sum += e;
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), sum, 1e-5);
}
