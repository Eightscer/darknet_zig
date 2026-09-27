//! CPU general matrix multiply: C = alpha*op(A)*op(B) + beta*C, row-major.
//!
//! This is the whole cost centre of CPU training -- every convolution and
//! fully-connected layer bottoms out here -- so unlike the rest of the port it
//! departs from darknet's code in two ways. The `#pragma omp parallel for`
//! becomes a row split across `std.Io` worker tasks, and the inner loops are
//! written in the order that lets LLVM emit vector FMAs.
//!
//! Slices are expected to be pre-offset by the caller, matching how darknet
//! passed `a = l.weights + j*l.nweights/l.groups` into gemm.

const std = @import("std");
const sys = @import("sys.zig");

/// Below this many multiply-adds the task spawn overhead dominates, so the
/// work stays on the calling thread.
const parallel_threshold = 1 << 19;

var cpu_count: usize = 0;

fn threads() usize {
    if (cpu_count == 0) {
        cpu_count = std.Thread.getCpuCount() catch 1;
        if (cpu_count == 0) cpu_count = 1;
    }
    return cpu_count;
}

const Job = struct {
    ta: bool,
    tb: bool,
    row_begin: usize,
    row_end: usize,
    n: usize,
    k: usize,
    alpha: f32,
    a: []const f32,
    lda: usize,
    b: []const f32,
    ldb: usize,
    beta: f32,
    c: []f32,
    ldc: usize,
};

pub fn gemm(
    ta: bool,
    tb: bool,
    m: usize,
    n: usize,
    k: usize,
    alpha: f32,
    a: []const f32,
    lda: usize,
    b: []const f32,
    ldb: usize,
    beta: f32,
    c: []f32,
    ldc: usize,
) void {
    if (m == 0 or n == 0) return;

    const work = m * n * k;
    var nthreads: usize = 1;
    if (work >= parallel_threshold) {
        nthreads = @min(threads(), m);
    }

    const job: Job = .{
        .ta = ta,
        .tb = tb,
        .row_begin = 0,
        .row_end = m,
        .n = n,
        .k = k,
        .alpha = alpha,
        .a = a,
        .lda = lda,
        .b = b,
        .ldb = ldb,
        .beta = beta,
        .c = c,
        .ldc = ldc,
    };

    if (nthreads <= 1) {
        runJob(job);
        return;
    }

    // One future per helper; the calling thread takes the last chunk itself so
    // it isn't sitting idle while the pool works.
    const max_helpers = 63;
    var futures: [max_helpers]std.Io.Future(void) = undefined;
    const helpers = @min(nthreads - 1, max_helpers);
    const chunk = (m + helpers) / (helpers + 1);

    var spawned: usize = 0;
    var row: usize = 0;
    while (spawned < helpers and row + chunk < m) : (spawned += 1) {
        var sub = job;
        sub.row_begin = row;
        sub.row_end = row + chunk;
        futures[spawned] = sys.io.async(runJob, .{sub});
        row += chunk;
    }

    var tail = job;
    tail.row_begin = row;
    tail.row_end = m;
    runJob(tail);

    for (futures[0..spawned]) |*f| f.await(sys.io);
}

fn runJob(j: Job) void {
    @setFloatMode(.optimized);

    // beta*C first, exactly as gemm_cpu does, so that the accumulate loops
    // below can be pure `+=`.
    if (j.beta != 1) {
        var i = j.row_begin;
        while (i < j.row_end) : (i += 1) {
            const row = j.c[i * j.ldc ..][0..j.n];
            if (j.beta == 0) {
                @memset(row, 0);
            } else {
                for (row) |*v| v.* *= j.beta;
            }
        }
    }

    if (!j.ta and !j.tb) {
        gemmNN(j);
    } else if (j.ta and !j.tb) {
        gemmTN(j);
    } else if (!j.ta and j.tb) {
        gemmNT(j);
    } else {
        gemmTT(j);
    }
}

/// Columns handled per vector step. The build targets the host by default, so
/// this is 8 on any AVX2 machine and 16 with AVX-512. Writing the vectors out
/// explicitly rather than hoping for autovectorisation is deliberate: the
/// scalar loop this replaced compiled to 41 scalar FMAs and not one packed
/// instruction, because LLVM would not hoist the alias check between the
/// output row and the input row out of the enclosing `k` loop.
const vlen: usize = std.simd.suggestVectorLength(f32) orelse 4;
const Vec = @Vector(vlen, f32);

/// Rows of C accumulated at once. Every element of B that gets loaded feeds
/// `mr` multiply-adds instead of one, and -- the bigger win -- each element of
/// C is read and written once per panel rather than once per step of `k`.
/// The old inner statement `C[j] += s*B[j]` moved 12 bytes per 2 flops, an
/// arithmetic intensity of 0.17 flops/byte that no amount of vectorising
/// would have fixed.
const mr = 4;

/// One panel of `mr` rows of C, accumulated in registers across the whole of
/// `k`. `ta` selects how A is indexed: false for A row-major (M x K), true for
/// A transposed (K x M), which is the shape the backward-data pass hands over.
fn gemmPanel(comptime ta: bool, j: Job, base: usize) void {
    @setFloatMode(.optimized);
    const alpha: Vec = @splat(j.alpha);

    var q: usize = 0;
    while (q + vlen <= j.n) : (q += vlen) {
        var acc: [mr]Vec = .{@as(Vec, @splat(0))} ** mr;
        var p: usize = 0;
        while (p < j.k) : (p += 1) {
            const bv: Vec = j.b[p * j.ldb + q ..][0..vlen].*;
            inline for (0..mr) |r| {
                const scalar = if (ta) j.a[p * j.lda + base + r] else j.a[(base + r) * j.lda + p];
                acc[r] += @as(Vec, @splat(scalar)) * bv;
            }
        }
        inline for (0..mr) |r| {
            const dst = j.c[(base + r) * j.ldc + q ..][0..vlen];
            const cur: Vec = dst.*;
            dst.* = cur + alpha * acc[r];
        }
    }

    // Columns past the last whole vector.
    while (q < j.n) : (q += 1) {
        var acc: [mr]f32 = .{0} ** mr;
        var p: usize = 0;
        while (p < j.k) : (p += 1) {
            const bv = j.b[p * j.ldb + q];
            inline for (0..mr) |r| {
                const scalar = if (ta) j.a[p * j.lda + base + r] else j.a[(base + r) * j.lda + p];
                acc[r] += scalar * bv;
            }
        }
        inline for (0..mr) |r| j.c[(base + r) * j.ldc + q] += j.alpha * acc[r];
    }
}

/// The leftover rows when the row count is not a multiple of `mr`. This is
/// darknet's original loop shape, kept because at one row there is nothing to
/// block against.
fn gemmRow(comptime ta: bool, j: Job, i: usize) void {
    @setFloatMode(.optimized);
    const crow = j.c[i * j.ldc ..][0..j.n];
    var p: usize = 0;
    while (p < j.k) : (p += 1) {
        const scale = j.alpha * (if (ta) j.a[p * j.lda + i] else j.a[i * j.lda + p]);
        if (scale == 0) continue;
        const brow = j.b[p * j.ldb ..][0..j.n];
        for (crow, brow) |*cv, bv| cv.* += scale * bv;
    }
}

fn gemmBlocked(comptime ta: bool, j: Job) void {
    var i = j.row_begin;
    while (i + mr <= j.row_end) : (i += mr) gemmPanel(ta, j, i);
    while (i < j.row_end) : (i += 1) gemmRow(ta, j, i);
}

/// A is MxK row-major, B is KxN row-major.
fn gemmNN(j: Job) void {
    gemmBlocked(false, j);
}

/// A is KxM row-major (i.e. transposed): A(i,p) lives at a[p*lda + i].
fn gemmTN(j: Job) void {
    gemmBlocked(true, j);
}

/// B is NxK row-major: B(p,q) lives at b[q*ldb + p]. Both operands are walked
/// contiguously here, so this becomes a dot product per output element.
fn gemmNT(j: Job) void {
    @setFloatMode(.optimized);
    var i = j.row_begin;
    while (i < j.row_end) : (i += 1) {
        const arow = j.a[i * j.lda ..][0..j.k];
        var q: usize = 0;
        while (q < j.n) : (q += 1) {
            const brow = j.b[q * j.ldb ..][0..j.k];
            var sum: f32 = 0;
            for (arow, brow) |av, bv| sum += av * bv;
            j.c[i * j.ldc + q] += j.alpha * sum;
        }
    }
}

fn gemmTT(j: Job) void {
    @setFloatMode(.optimized);
    var i = j.row_begin;
    while (i < j.row_end) : (i += 1) {
        var q: usize = 0;
        while (q < j.n) : (q += 1) {
            var sum: f32 = 0;
            var p: usize = 0;
            while (p < j.k) : (p += 1) {
                sum += j.a[i + p * j.lda] * j.b[p + q * j.ldb];
            }
            j.c[i * j.ldc + q] += j.alpha * sum;
        }
    }
}

test "gemm variants agree with a naive reference" {
    var threaded = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threaded.deinit();
    sys.init(threaded.io(), std.testing.allocator);

    const m = 5;
    const n = 4;
    const k = 3;
    var a: [m * k]f32 = undefined;
    var b: [k * n]f32 = undefined;
    var at: [k * m]f32 = undefined;
    var bt: [n * k]f32 = undefined;
    for (&a, 0..) |*v, i| v.* = @floatFromInt(i % 7);
    for (&b, 0..) |*v, i| v.* = @floatFromInt(i % 5);
    for (0..m) |i| for (0..k) |p| {
        at[p * m + i] = a[i * k + p];
    };
    for (0..k) |p| for (0..n) |q| {
        bt[q * k + p] = b[p * n + q];
    };

    var want: [m * n]f32 = @splat(0);
    for (0..m) |i| for (0..n) |q| {
        var s: f32 = 0;
        for (0..k) |p| s += a[i * k + p] * b[p * n + q];
        want[i * n + q] = 2 * s;
    };

    var got: [m * n]f32 = undefined;
    inline for (.{ .{ false, false }, .{ true, false }, .{ false, true }, .{ true, true } }) |flags| {
        @memset(&got, 0);
        const ta = flags[0];
        const tb = flags[1];
        gemm(
            ta,
            tb,
            m,
            n,
            k,
            2,
            if (ta) &at else &a,
            if (ta) m else k,
            if (tb) &bt else &b,
            if (tb) k else n,
            1,
            &got,
            n,
        );
        for (want, got) |w, g| try std.testing.expectApproxEqAbs(w, g, 1e-4);
    }
}
