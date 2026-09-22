//! CPU-vs-GPU consistency check.
//!
//! This project was written on a machine with no AMD card in it, so every HIP
//! kernel is unverified until it runs somewhere with a GPU. This command is
//! how you verify it: each op is run on both backends over the same random
//! input and the largest absolute difference is reported. Anything materially
//! above single-precision rounding error means the kernel and its host twin
//! have diverged.
//!
//! Run it first, before trusting a training run:
//!     darknet-zig gputest -gpu 0

const std = @import("std");
const sys = @import("sys.zig");
const blas = @import("blas.zig");
const gemm_mod = @import("gemm.zig");
const im2col_mod = @import("im2col.zig");
const activations = @import("activations.zig");
const utils = @import("utils.zig");
const gpu = @import("gpu.zig");

/// Loose enough to absorb a different summation order in the reductions,
/// tight enough that a real indexing bug shows up.
const tolerance: f32 = 1e-3;

var failures: usize = 0;
var checks: usize = 0;

fn report(name: []const u8, cpu: []const f32, host_of_gpu: []const f32) void {
    checks += 1;
    var max_diff: f32 = 0;
    var max_rel: f32 = 0;
    for (cpu, host_of_gpu) |a, b| {
        const d = @abs(a - b);
        max_diff = @max(max_diff, d);
        const scale = @max(@abs(a), @abs(b));
        if (scale > 1e-4) max_rel = @max(max_rel, d / scale);
    }
    const ok = max_diff <= tolerance or max_rel <= tolerance;
    if (!ok) failures += 1;
    sys.print("{s:<28} {s}  max abs diff {e:>12.4}  max rel {e:>12.4}\n", .{
        name,
        if (ok) "ok  " else "FAIL",
        max_diff,
        max_rel,
    });
}

fn randomFill(rng: *utils.Rng, x: []f32) void {
    for (x) |*v| v.* = rng.uniform(-1, 1);
}

pub fn run(allocator: std.mem.Allocator) !void {
    if (!gpu.active()) {
        std.debug.print("gputest needs a GPU: pass -gpu <index> (and build with -Dgpu=true)\n", .{});
        return error.GpuRequired;
    }

    // Synchronise after every launch for the duration of the test. A kernel
    // that walks off its buffer otherwise reports the fault at whatever
    // memcpy happens next, naming the wrong op; here the whole point is to
    // name the right one, and the stalls do not matter at this size.
    gpu.setSyncAfterLaunch(true);
    defer gpu.setSyncAfterLaunch(false);

    var rng = utils.Rng.init(20240921);
    sys.print("\nComparing CPU and HIP implementations (tolerance {e}):\n\n", .{tolerance});

    try elementwise(allocator, &rng);
    try biasAndNorm(allocator, &rng);
    try softmaxAndLoss(allocator, &rng);
    try convHelpers(allocator, &rng);
    try gemmAll(allocator, &rng);
    try pooling(allocator, &rng);
    try shortcutOp(allocator, &rng);

    sys.print("\n{d}/{d} checks passed.\n", .{ checks - failures, checks });
    if (failures != 0) return error.GpuMismatch;
}

fn elementwise(allocator: std.mem.Allocator, rng: *utils.Rng) !void {
    const n = 4099; // deliberately not a multiple of the block size
    const a = try allocator.alloc(f32, n);
    defer allocator.free(a);
    const b = try allocator.alloc(f32, n);
    defer allocator.free(b);
    const back = try allocator.alloc(f32, n);
    defer allocator.free(back);

    randomFill(rng, a);
    randomFill(rng, b);

    {
        const cpu = try allocator.dupe(f32, b);
        defer allocator.free(cpu);
        blas.axpy(2.5, a, cpu);

        const da = gpu.make(a);
        defer gpu.free(da);
        const db = gpu.make(b);
        defer gpu.free(db);
        gpu.axpy(n, 2.5, da, db);
        gpu.pull(db, back);
        report("axpy", cpu, back);
    }

    {
        const cpu = try allocator.dupe(f32, a);
        defer allocator.free(cpu);
        blas.scal(0.3, cpu);

        const da = gpu.make(a);
        defer gpu.free(da);
        gpu.scal(n, 0.3, da);
        gpu.pull(da, back);
        report("scal", cpu, back);
    }

    inline for (.{ .leaky, .relu, .logistic, .elu, .tanh }) |act| {
        const cpu = try allocator.dupe(f32, a);
        defer allocator.free(cpu);
        activations.activateArray(cpu, act);

        const da = gpu.make(a);
        defer gpu.free(da);
        gpu.activateArray(da, n, @intFromEnum(@as(activations.Activation, act)));
        gpu.pull(da, back);
        report("activate " ++ @tagName(act), cpu, back);
    }

    {
        // gradient() consumes activation outputs, so feed it a plausible one.
        const y = try allocator.dupe(f32, a);
        defer allocator.free(y);
        activations.activateArray(y, .leaky);

        const cpu = try allocator.dupe(f32, b);
        defer allocator.free(cpu);
        activations.gradientArray(y, .leaky, cpu);

        const dy = gpu.make(y);
        defer gpu.free(dy);
        const dd = gpu.make(b);
        defer gpu.free(dd);
        gpu.gradientArray(dy, n, @intFromEnum(activations.Activation.leaky), dd);
        gpu.pull(dd, back);
        report("gradient leaky", cpu, back);
    }
}

fn biasAndNorm(allocator: std.mem.Allocator, rng: *utils.Rng) !void {
    const batch = 4;
    const filters = 17;
    const spatial = 53;
    const n = batch * filters * spatial;

    const x = try allocator.alloc(f32, n);
    defer allocator.free(x);
    const delta = try allocator.alloc(f32, n);
    defer allocator.free(delta);
    const biases = try allocator.alloc(f32, filters);
    defer allocator.free(biases);
    randomFill(rng, x);
    randomFill(rng, delta);
    randomFill(rng, biases);

    const back_n = try allocator.alloc(f32, n);
    defer allocator.free(back_n);
    const back_f = try allocator.alloc(f32, filters);
    defer allocator.free(back_f);

    {
        const cpu = try allocator.dupe(f32, x);
        defer allocator.free(cpu);
        blas.addBias(cpu, biases, batch, filters, spatial);

        const dx = gpu.make(x);
        defer gpu.free(dx);
        const dbias = gpu.make(biases);
        defer gpu.free(dbias);
        gpu.addBias(dx, dbias, batch, filters, spatial);
        gpu.pull(dx, back_n);
        report("add_bias", cpu, back_n);
    }

    {
        const cpu = try allocator.alloc(f32, filters);
        defer allocator.free(cpu);
        @memset(cpu, 0);
        blas.backwardBias(cpu, delta, batch, filters, spatial);

        const ddelta = gpu.make(delta);
        defer gpu.free(ddelta);
        const dupd = gpu.alloc(filters);
        defer gpu.free(dupd);
        gpu.backwardBias(dupd, ddelta, batch, filters, spatial);
        gpu.pull(dupd, back_f);
        report("backward_bias", cpu, back_f);
    }

    // The batch-norm statistics, then the normalisation that consumes them.
    const mean_cpu = try allocator.alloc(f32, filters);
    defer allocator.free(mean_cpu);
    const var_cpu = try allocator.alloc(f32, filters);
    defer allocator.free(var_cpu);
    blas.mean(x, batch, filters, spatial, mean_cpu);
    blas.variance(x, mean_cpu, batch, filters, spatial, var_cpu);

    const dx = gpu.make(x);
    defer gpu.free(dx);
    const dmean = gpu.alloc(filters);
    defer gpu.free(dmean);
    const dvar = gpu.alloc(filters);
    defer gpu.free(dvar);
    gpu.mean(dx, batch, filters, spatial, dmean);
    gpu.pull(dmean, back_f);
    report("mean", mean_cpu, back_f);

    gpu.variance(dx, dmean, batch, filters, spatial, dvar);
    gpu.pull(dvar, back_f);
    report("variance", var_cpu, back_f);

    {
        const cpu = try allocator.dupe(f32, x);
        defer allocator.free(cpu);
        blas.normalize(cpu, mean_cpu, var_cpu, batch, filters, spatial);
        gpu.normalize(dx, dmean, dvar, batch, filters, spatial);
        gpu.pull(dx, back_n);
        report("normalize", cpu, back_n);
    }

    {
        const cpu = try allocator.alloc(f32, filters);
        defer allocator.free(cpu);
        blas.meanDelta(delta, var_cpu, batch, filters, spatial, cpu);

        const ddelta = gpu.make(delta);
        defer gpu.free(ddelta);
        const dout = gpu.alloc(filters);
        defer gpu.free(dout);
        gpu.meanDelta(ddelta, dvar, batch, filters, spatial, dout);
        gpu.pull(dout, back_f);
        report("mean_delta", cpu, back_f);
    }
}

fn softmaxAndLoss(allocator: std.mem.Allocator, rng: *utils.Rng) !void {
    const batch = 8;
    const classes = 137;
    const n = batch * classes;

    const x = try allocator.alloc(f32, n);
    defer allocator.free(x);
    randomFill(rng, x);

    const truth = try allocator.alloc(f32, n);
    defer allocator.free(truth);
    @memset(truth, 0);
    for (0..batch) |b| truth[b * classes + rng.index(classes)] = 1;

    const cpu = try allocator.alloc(f32, n);
    defer allocator.free(cpu);
    const back = try allocator.alloc(f32, n);
    defer allocator.free(back);

    blas.softmax(x, classes, batch, classes, 1, classes, 1, 1.0, cpu);

    const dx = gpu.make(x);
    defer gpu.free(dx);
    const dout = gpu.alloc(n);
    defer gpu.free(dout);
    gpu.softmax(dx, classes, batch, classes, 1, classes, 1, 1.0, dout);
    gpu.pull(dout, back);
    report("softmax", cpu, back);

    {
        const delta_cpu = try allocator.alloc(f32, n);
        defer allocator.free(delta_cpu);
        const err_cpu = try allocator.alloc(f32, n);
        defer allocator.free(err_cpu);
        blas.softmaxCrossEntropy(cpu, truth, delta_cpu, err_cpu);

        const dtruth = gpu.make(truth);
        defer gpu.free(dtruth);
        const ddelta = gpu.alloc(n);
        defer gpu.free(ddelta);
        const derr = gpu.alloc(n);
        defer gpu.free(derr);
        gpu.softmaxCrossEntropy(n, dout, dtruth, ddelta, derr);
        gpu.pull(ddelta, back);
        report("softmax_x_ent delta", delta_cpu, back);
        gpu.pull(derr, back);
        report("softmax_x_ent loss", err_cpu, back);
    }
}

fn convHelpers(allocator: std.mem.Allocator, rng: *utils.Rng) !void {
    const c = 5;
    const h = 13;
    const w = 11;
    const ksize = 3;
    const stride = 2;
    const pad = 1;
    const hc = im2col_mod.outputSize(h, ksize, stride, pad);
    const wc = im2col_mod.outputSize(w, ksize, stride, pad);
    const col_n = c * ksize * ksize * hc * wc;

    const im = try allocator.alloc(f32, c * h * w);
    defer allocator.free(im);
    randomFill(rng, im);

    const cpu_col = try allocator.alloc(f32, col_n);
    defer allocator.free(cpu_col);
    const back_col = try allocator.alloc(f32, col_n);
    defer allocator.free(back_col);
    im2col_mod.im2col(im, c, h, w, ksize, stride, pad, cpu_col);

    const dim = gpu.make(im);
    defer gpu.free(dim);
    const dcol = gpu.alloc(col_n);
    defer gpu.free(dcol);
    gpu.im2col(dim, c, h, w, ksize, stride, pad, dcol);
    gpu.pull(dcol, back_col);
    report("im2col", cpu_col, back_col);

    {
        const cpu_im = try allocator.alloc(f32, c * h * w);
        defer allocator.free(cpu_im);
        @memset(cpu_im, 0);
        im2col_mod.col2im(cpu_col, c, h, w, ksize, stride, pad, cpu_im);

        const dim2 = gpu.alloc(c * h * w);
        defer gpu.free(dim2);
        gpu.col2im(dcol, c, h, w, ksize, stride, pad, dim2);
        const back_im = try allocator.alloc(f32, c * h * w);
        defer allocator.free(back_im);
        gpu.pull(dim2, back_im);
        report("col2im", cpu_im, back_im);
    }
}

fn gemmAll(allocator: std.mem.Allocator, rng: *utils.Rng) !void {
    const m = 37;
    const n = 29;
    const k = 53;

    const a = try allocator.alloc(f32, m * k);
    defer allocator.free(a);
    const b = try allocator.alloc(f32, k * n);
    defer allocator.free(b);
    const c0 = try allocator.alloc(f32, m * n);
    defer allocator.free(c0);
    randomFill(rng, a);
    randomFill(rng, b);
    randomFill(rng, c0);

    const back = try allocator.alloc(f32, m * n);
    defer allocator.free(back);

    inline for (.{ .{ false, false }, .{ true, false }, .{ false, true }, .{ true, true } }) |flags| {
        const ta = flags[0];
        const tb = flags[1];
        const lda = if (ta) m else k;
        const ldb = if (tb) k else n;

        const cpu = try allocator.dupe(f32, c0);
        defer allocator.free(cpu);
        gemm_mod.gemm(ta, tb, m, n, k, 1.5, a, lda, b, ldb, 1, cpu, n);

        const da = gpu.make(a);
        defer gpu.free(da);
        const db = gpu.make(b);
        defer gpu.free(db);
        const dc = gpu.make(c0);
        defer gpu.free(dc);
        gpu.gemm(ta, tb, m, n, k, 1.5, da, lda, db, ldb, 1, dc, n);
        gpu.pull(dc, back);

        const name = "gemm " ++ (if (ta) "T" else "N") ++ (if (tb) "T" else "N");
        report(name, cpu, back);
    }
}

fn pooling(allocator: std.mem.Allocator, rng: *utils.Rng) !void {
    const lay = @import("layer.zig");
    const pool = @import("layers/pooling.zig");

    const batch = 3;
    const c = 6;
    const h = 14;
    const w = 14;
    const size = 2;
    const stride = 2;
    const pad = size - 1;

    var l = try pool.makeMaxpool(allocator, batch, h, w, c, size, stride, pad);
    defer l.deinit(allocator);

    const input = try allocator.alloc(f32, batch * c * h * w);
    defer allocator.free(input);
    randomFill(rng, input);

    var state: lay.State = .{ .input = input, .train = true };
    pool.forwardMaxpool(&l, &state);

    const cpu_out = try allocator.dupe(f32, l.output);
    defer allocator.free(cpu_out);

    const dinput = gpu.make(input);
    defer gpu.free(dinput);
    var gstate: lay.State = .{ .input_gpu = dinput, .train = true };
    pool.forwardMaxpoolGpu(&l, &gstate);
    const back = try allocator.alloc(f32, l.output.len);
    defer allocator.free(back);
    gpu.pull(l.gpu.output, back);
    report("maxpool forward", cpu_out, back);

    // Backward: seed the output delta, then compare what lands in the input.
    randomFill(rng, l.delta);
    const cpu_in_delta = try allocator.alloc(f32, input.len);
    defer allocator.free(cpu_in_delta);
    @memset(cpu_in_delta, 0);
    state.delta = cpu_in_delta;
    pool.backwardMaxpool(&l, &state);

    gpu.push(l.gpu.delta, l.delta);
    const dindelta = gpu.alloc(input.len);
    defer gpu.free(dindelta);
    gstate.delta_gpu = dindelta;
    pool.backwardMaxpoolGpu(&l, &gstate);
    const back_in = try allocator.alloc(f32, input.len);
    defer allocator.free(back_in);
    gpu.pull(dindelta, back_in);
    report("maxpool backward", cpu_in_delta, back_in);

    var al = try pool.makeAvgpool(allocator, batch, w, h, c);
    defer al.deinit(allocator);
    pool.forwardAvgpool(&al, &state);
    const cpu_avg = try allocator.dupe(f32, al.output);
    defer allocator.free(cpu_avg);
    pool.forwardAvgpoolGpu(&al, &gstate);
    const back_avg = try allocator.alloc(f32, al.output.len);
    defer allocator.free(back_avg);
    gpu.pull(al.gpu.output, back_avg);
    report("avgpool forward", cpu_avg, back_avg);
}

fn shortcutOp(allocator: std.mem.Allocator, rng: *utils.Rng) !void {
    const batch = 2;
    const w = 8;
    const h = 8;
    const c = 4;
    const n = batch * w * h * c;

    const add = try allocator.alloc(f32, n);
    defer allocator.free(add);
    const out = try allocator.alloc(f32, n);
    defer allocator.free(out);
    randomFill(rng, add);
    randomFill(rng, out);

    const cpu = try allocator.dupe(f32, out);
    defer allocator.free(cpu);
    blas.shortcut(batch, w, h, c, add, w, h, c, 1, 1, cpu);

    const dadd = gpu.make(add);
    defer gpu.free(dadd);
    const dout = gpu.make(out);
    defer gpu.free(dout);
    gpu.shortcut(batch, w, h, c, dadd, w, h, c, 1, 1, dout);
    const back = try allocator.alloc(f32, n);
    defer allocator.free(back);
    gpu.pull(dout, back);
    report("shortcut", cpu, back);
}
