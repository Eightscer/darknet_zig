//! The HIP backend: device buffers, the kernel registry, and one wrapper per
//! device op.
//!
//! Everything here compiles in a CPU-only build too -- `enabled` is false, the
//! wrappers are unreachable, and no HIP symbol is ever referenced, so nothing
//! needs to link against libamdhip64. That is what lets the project build and
//! its CPU path be tested on a machine with no ROCm at all, which is exactly
//! the situation it was written in.
//!
//! Each wrapper corresponds to one kernel in src/kernels/darknet_kernels.hip
//! and to one function in blas.zig / im2col.zig / activations.zig. When you
//! change one of the three, change all three: `darknet-zig gputest` exists to
//! catch it when you don't.

const std = @import("std");
const build_options = @import("build_options");
const hip = @import("hip/hip.zig");
const sys = @import("sys.zig");

pub const enabled = build_options.gpu;

/// Threads per block for the 1-D kernels. Must match BLOCK in the .hip file.
pub const block_size: u32 = 256;
/// Tile edge for the GEMM kernel. Must match TILE in the .hip file.
pub const gemm_tile: u32 = 16;

/// A device-side float array. A null pointer means "this layer doesn't use
/// this buffer", the same convention the host-side empty slices follow.
pub const Buf = struct {
    ptr: ?*anyopaque = null,
    /// Length in floats, not bytes.
    len: usize = 0,

    pub fn isNull(self: Buf) bool {
        return self.ptr == null;
    }

    /// A view starting `n` floats in. Used the way darknet did pointer
    /// arithmetic on `float *`, e.g. picking out one image's slice of a batch.
    pub fn offset(self: Buf, n: usize) Buf {
        if (self.ptr == null) return .{};
        std.debug.assert(n <= self.len);
        const base: [*]u8 = @ptrCast(self.ptr.?);
        return .{ .ptr = @ptrCast(base + n * @sizeOf(f32)), .len = self.len - n };
    }
};

// ---------------------------------------------------------------------------
// state
// ---------------------------------------------------------------------------

/// -1 means "run on the CPU". Set by main from the -gpu flag.
pub var device_index: i32 = -1;

pub fn active() bool {
    return enabled and device_index >= 0;
}

var module: hip.Module = null;
var kernels: Kernels = undefined;

/// One field per `extern "C" __global__` function in the .hip file. The field
/// name is the symbol name, so registration is a comptime loop rather than 36
/// hand-written lookups.
const Kernels = struct {
    activate_array_kernel: hip.Function = null,
    gradient_array_kernel: hip.Function = null,

    fill_kernel: hip.Function = null,
    copy_kernel: hip.Function = null,
    axpy_kernel: hip.Function = null,
    scal_kernel: hip.Function = null,
    mul_kernel: hip.Function = null,
    add_scalar_kernel: hip.Function = null,
    constrain_kernel: hip.Function = null,
    rand_uniform_kernel: hip.Function = null,

    add_bias_kernel: hip.Function = null,
    scale_bias_kernel: hip.Function = null,
    backward_bias_kernel: hip.Function = null,
    backward_bias_conn_kernel: hip.Function = null,
    backward_scale_kernel: hip.Function = null,

    fast_mean_kernel: hip.Function = null,
    fast_variance_kernel: hip.Function = null,
    normalize_kernel: hip.Function = null,
    fast_mean_delta_kernel: hip.Function = null,
    fast_variance_delta_kernel: hip.Function = null,
    normalize_delta_kernel: hip.Function = null,

    softmax_kernel: hip.Function = null,
    softmax_x_ent_kernel: hip.Function = null,
    l2_kernel: hip.Function = null,
    l1_kernel: hip.Function = null,
    smooth_l1_kernel: hip.Function = null,

    im2col_kernel: hip.Function = null,
    col2im_kernel: hip.Function = null,

    forward_maxpool_kernel: hip.Function = null,
    backward_maxpool_kernel: hip.Function = null,
    forward_avgpool_kernel: hip.Function = null,
    backward_avgpool_kernel: hip.Function = null,

    dropout_kernel: hip.Function = null,
    shortcut_kernel: hip.Function = null,
    adam_kernel: hip.Function = null,
    gemm_kernel: hip.Function = null,
};

/// Locate darknet_kernels.hsaco. The build installs it next to the executable;
/// $DARKNET_HSACO overrides that, which is what you want when running out of a
/// build tree or shipping the code object separately from the binary.
fn findCodeObject(allocator: std.mem.Allocator) ![:0]u8 {
    if (std.c.getenv("DARKNET_HSACO")) |p| {
        return allocator.dupeZ(u8, std.mem.sliceTo(p, 0));
    }

    // Resolve the executable's own directory. ROCm is Linux-only in practice,
    // so /proc/self/exe is a fair assumption; if it isn't there, fall back to
    // the working directory and let the load error say what was tried.
    var buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const len = std.Io.Dir.readLinkAbsolute(sys.io, "/proc/self/exe", &buf) catch {
        return allocator.dupeZ(u8, "darknet_kernels.hsaco");
    };
    const exe_path = buf[0..len];
    const exe_dir = std.fs.path.dirname(exe_path) orelse ".";
    return std.fmt.allocPrintSentinel(allocator, "{s}/darknet_kernels.hsaco", .{exe_dir}, 0);
}

pub fn init(allocator: std.mem.Allocator, index: i32) !void {
    if (!enabled) {
        std.debug.print(
            \\This binary was built without GPU support.
            \\Rebuild with: zig build -Dgpu=true -Drocm-path=$ROCM_PATH -Doffload-arch=<your gfx>
            \\
        , .{});
        return error.GpuNotCompiledIn;
    }

    var count: c_int = 0;
    try hip.check(hip.hipGetDeviceCount(&count), "hipGetDeviceCount");
    if (index >= count) {
        std.debug.print("Requested GPU {d} but only {d} HIP device(s) present\n", .{ index, count });
        return error.NoSuchDevice;
    }
    try hip.check(hip.hipSetDevice(index), "hipSetDevice");

    var dev: hip.Device = 0;
    var name: [256]u8 = @splat(0);
    if (hip.hipDeviceGet(&dev, index) == hip.success) {
        _ = hip.hipDeviceGetName(&name, name.len - 1, dev);
    }

    const path = try findCodeObject(allocator);
    defer allocator.free(path);
    hip.check(hip.hipModuleLoad(&module, path.ptr), "hipModuleLoad") catch {
        std.debug.print(
            \\Failed to load device code from: {s}
            \\The .hsaco must have been compiled for this GPU's architecture.
            \\Check `rocminfo | grep gfx` and rebuild with -Doffload-arch=<that>.
            \\
        , .{path});
        return error.CodeObjectLoadFailed;
    };

    kernels = .{};
    inline for (@typeInfo(Kernels).@"struct".fields) |f| {
        var fun: hip.Function = null;
        try hip.check(hip.hipModuleGetFunction(&fun, module, f.name ++ ""), "hipModuleGetFunction " ++ f.name);
        @field(kernels, f.name) = fun;
    }

    device_index = index;

    var free_mem: usize = 0;
    var total_mem: usize = 0;
    _ = hip.hipMemGetInfo(&free_mem, &total_mem);
    std.debug.print("HIP device {d}: {s} ({d} MiB free / {d} MiB total)\n", .{
        index,
        std.mem.sliceTo(&name, 0),
        free_mem >> 20,
        total_mem >> 20,
    });
}

pub fn deinit() void {
    if (!enabled) return;
    if (module != null) {
        _ = hip.hipModuleUnload(module);
        module = null;
    }
    device_index = -1;
}

// ---------------------------------------------------------------------------
// memory
// ---------------------------------------------------------------------------

pub fn alloc(n: usize) Buf {
    if (!enabled) unreachable;
    if (n == 0) return .{};
    var ptr: ?*anyopaque = null;
    hip.must(hip.hipMalloc(&ptr, n * @sizeOf(f32)), "hipMalloc");
    hip.must(hip.hipMemset(ptr, 0, n * @sizeOf(f32)), "hipMemset");
    return .{ .ptr = ptr, .len = n };
}

/// Device buffer for `n` 32-bit ints (maxpool argmax indices). Sized in floats
/// because i32 and f32 are the same width, which keeps `Buf` single-purpose.
pub fn allocInts(n: usize) Buf {
    return alloc(n);
}

/// Allocate and upload in one go, the analogue of `cuda_make_array(x, n)`.
pub fn make(host: []const f32) Buf {
    const b = alloc(host.len);
    push(b, host);
    return b;
}

pub fn free(b: Buf) void {
    if (!enabled) return;
    if (b.ptr) |p| hip.must(hip.hipFree(p), "hipFree");
}

pub fn push(b: Buf, host: []const f32) void {
    if (!enabled) unreachable;
    if (host.len == 0 or b.ptr == null) return;
    hip.must(hip.hipMemcpy(b.ptr, host.ptr, host.len * @sizeOf(f32), hip.memcpy_host_to_device), "hipMemcpy H2D");
}

pub fn pull(b: Buf, host: []f32) void {
    if (!enabled) unreachable;
    if (host.len == 0 or b.ptr == null) return;
    hip.must(hip.hipMemcpy(host.ptr, b.ptr, host.len * @sizeOf(f32), hip.memcpy_device_to_host), "hipMemcpy D2H");
}

pub fn pullInts(b: Buf, host: []i32) void {
    if (!enabled) unreachable;
    if (host.len == 0 or b.ptr == null) return;
    hip.must(hip.hipMemcpy(host.ptr, b.ptr, host.len * @sizeOf(i32), hip.memcpy_device_to_host), "hipMemcpy D2H int");
}

pub fn sync() void {
    if (!enabled) return;
    hip.must(hip.hipDeviceSynchronize(), "hipDeviceSynchronize");
}

// ---------------------------------------------------------------------------
// launching
// ---------------------------------------------------------------------------

inline fn ci(x: usize) c_int {
    return @intCast(x);
}

fn grid(n: usize) u32 {
    return @intCast((n + block_size - 1) / block_size);
}

/// Build the array-of-pointers-to-arguments that hipModuleLaunchKernel wants.
/// `args` is a tuple; each element is copied into a local so it has an address
/// that outlives the call.
fn launchDims(
    func: hip.Function,
    gx: u32,
    gy: u32,
    bx: u32,
    by: u32,
    args: anytype,
) void {
    if (!enabled) unreachable;
    var local = args;
    const fields = @typeInfo(@TypeOf(args)).@"struct".fields;
    var params: [fields.len]?*anyopaque = undefined;
    inline for (fields, 0..) |f, i| {
        params[i] = @ptrCast(&@field(local, f.name));
    }
    hip.must(hip.hipModuleLaunchKernel(func, gx, gy, 1, bx, by, 1, 0, null, &params, null), "hipModuleLaunchKernel");
}

fn launch1d(func: hip.Function, n: usize, args: anytype) void {
    if (n == 0) return;
    launchDims(func, grid(n), 1, block_size, 1, args);
}

/// For the per-filter reduction kernels: one block per filter, BLOCK threads
/// cooperating inside it.
fn launchPerFilter(func: hip.Function, filters: usize, args: anytype) void {
    if (filters == 0) return;
    launchDims(func, @intCast(filters), 1, block_size, 1, args);
}

// ---------------------------------------------------------------------------
// elementwise ops
// ---------------------------------------------------------------------------

pub fn fill(x: Buf, n: usize, alpha: f32) void {
    launch1d(kernels.fill_kernel, n, .{ ci(n), alpha, x.ptr });
}

pub fn copy(n: usize, x: Buf, y: Buf) void {
    launch1d(kernels.copy_kernel, n, .{ ci(n), x.ptr, y.ptr });
}

pub fn axpy(n: usize, alpha: f32, x: Buf, y: Buf) void {
    launch1d(kernels.axpy_kernel, n, .{ ci(n), alpha, x.ptr, y.ptr });
}

pub fn scal(n: usize, alpha: f32, x: Buf) void {
    launch1d(kernels.scal_kernel, n, .{ ci(n), alpha, x.ptr });
}

pub fn mul(n: usize, x: Buf, y: Buf) void {
    launch1d(kernels.mul_kernel, n, .{ ci(n), x.ptr, y.ptr });
}

pub fn addScalar(n: usize, alpha: f32, x: Buf) void {
    launch1d(kernels.add_scalar_kernel, n, .{ ci(n), alpha, x.ptr });
}

pub fn constrainArray(n: usize, alpha: f32, x: Buf) void {
    launch1d(kernels.constrain_kernel, n, .{ ci(n), alpha, x.ptr });
}

pub fn randUniform(n: usize, x: Buf, seed: u32) void {
    launch1d(kernels.rand_uniform_kernel, n, .{ ci(n), x.ptr, @as(c_uint, seed) });
}

pub fn activateArray(x: Buf, n: usize, a: c_int) void {
    launch1d(kernels.activate_array_kernel, n, .{ x.ptr, ci(n), a });
}

pub fn gradientArray(x: Buf, n: usize, a: c_int, delta: Buf) void {
    launch1d(kernels.gradient_array_kernel, n, .{ x.ptr, ci(n), a, delta.ptr });
}

// ---------------------------------------------------------------------------
// bias / scale
// ---------------------------------------------------------------------------

pub fn addBias(output: Buf, biases: Buf, batch: usize, filters: usize, spatial: usize) void {
    launch1d(kernels.add_bias_kernel, batch * filters * spatial, .{
        output.ptr, biases.ptr, ci(batch), ci(filters), ci(spatial),
    });
}

pub fn scaleBias(output: Buf, scales: Buf, batch: usize, filters: usize, spatial: usize) void {
    launch1d(kernels.scale_bias_kernel, batch * filters * spatial, .{
        output.ptr, scales.ptr, ci(batch), ci(filters), ci(spatial),
    });
}

pub fn backwardBias(bias_updates: Buf, delta: Buf, batch: usize, filters: usize, spatial: usize) void {
    if (spatial == 1) {
        launch1d(kernels.backward_bias_conn_kernel, filters, .{
            bias_updates.ptr, delta.ptr, ci(batch), ci(filters),
        });
    } else {
        launchPerFilter(kernels.backward_bias_kernel, filters, .{
            bias_updates.ptr, delta.ptr, ci(batch), ci(filters), ci(spatial),
        });
    }
}

pub fn backwardScale(x_norm: Buf, delta: Buf, batch: usize, filters: usize, spatial: usize, scale_updates: Buf) void {
    launchPerFilter(kernels.backward_scale_kernel, filters, .{
        x_norm.ptr, delta.ptr, ci(batch), ci(filters), ci(spatial), scale_updates.ptr,
    });
}

// ---------------------------------------------------------------------------
// batch normalisation
// ---------------------------------------------------------------------------

pub fn mean(x: Buf, batch: usize, filters: usize, spatial: usize, out: Buf) void {
    launchPerFilter(kernels.fast_mean_kernel, filters, .{
        x.ptr, ci(batch), ci(filters), ci(spatial), out.ptr,
    });
}

pub fn variance(x: Buf, mean_in: Buf, batch: usize, filters: usize, spatial: usize, out: Buf) void {
    launchPerFilter(kernels.fast_variance_kernel, filters, .{
        x.ptr, mean_in.ptr, ci(batch), ci(filters), ci(spatial), out.ptr,
    });
}

pub fn normalize(x: Buf, mean_in: Buf, variance_in: Buf, batch: usize, filters: usize, spatial: usize) void {
    const n = batch * filters * spatial;
    launch1d(kernels.normalize_kernel, n, .{
        ci(n), x.ptr, mean_in.ptr, variance_in.ptr, ci(batch), ci(filters), ci(spatial),
    });
}

pub fn meanDelta(delta: Buf, variance_in: Buf, batch: usize, filters: usize, spatial: usize, out: Buf) void {
    launchPerFilter(kernels.fast_mean_delta_kernel, filters, .{
        delta.ptr, variance_in.ptr, ci(batch), ci(filters), ci(spatial), out.ptr,
    });
}

pub fn varianceDelta(x: Buf, delta: Buf, mean_in: Buf, variance_in: Buf, batch: usize, filters: usize, spatial: usize, out: Buf) void {
    launchPerFilter(kernels.fast_variance_delta_kernel, filters, .{
        x.ptr, delta.ptr, mean_in.ptr, variance_in.ptr, ci(batch), ci(filters), ci(spatial), out.ptr,
    });
}

pub fn normalizeDelta(
    x: Buf,
    mean_in: Buf,
    variance_in: Buf,
    mean_delta_in: Buf,
    variance_delta_in: Buf,
    batch: usize,
    filters: usize,
    spatial: usize,
    delta: Buf,
) void {
    const n = batch * filters * spatial;
    launch1d(kernels.normalize_delta_kernel, n, .{
        ci(n),       x.ptr,        mean_in.ptr,  variance_in.ptr, mean_delta_in.ptr,
        variance_delta_in.ptr, ci(batch), ci(filters), ci(spatial), delta.ptr,
    });
}

// ---------------------------------------------------------------------------
// softmax and losses
// ---------------------------------------------------------------------------

pub fn softmax(
    input: Buf,
    n: usize,
    batch: usize,
    batch_offset: usize,
    groups: usize,
    group_offset: usize,
    stride: usize,
    temp: f32,
    output: Buf,
) void {
    launch1d(kernels.softmax_kernel, batch * groups, .{
        input.ptr,  ci(n),            ci(batch), ci(batch_offset), ci(groups),
        ci(group_offset), ci(stride), temp,      output.ptr,
    });
}

pub fn softmaxCrossEntropy(n: usize, pred: Buf, truth: Buf, delta: Buf, err: Buf) void {
    launch1d(kernels.softmax_x_ent_kernel, n, .{ ci(n), pred.ptr, truth.ptr, delta.ptr, err.ptr });
}

pub fn l2(n: usize, pred: Buf, truth: Buf, delta: Buf, err: Buf) void {
    launch1d(kernels.l2_kernel, n, .{ ci(n), pred.ptr, truth.ptr, delta.ptr, err.ptr });
}

pub fn l1(n: usize, pred: Buf, truth: Buf, delta: Buf, err: Buf) void {
    launch1d(kernels.l1_kernel, n, .{ ci(n), pred.ptr, truth.ptr, delta.ptr, err.ptr });
}

pub fn smoothL1(n: usize, pred: Buf, truth: Buf, delta: Buf, err: Buf) void {
    launch1d(kernels.smooth_l1_kernel, n, .{ ci(n), pred.ptr, truth.ptr, delta.ptr, err.ptr });
}

// ---------------------------------------------------------------------------
// convolution helpers
// ---------------------------------------------------------------------------

pub fn im2col(im: Buf, channels: usize, height: usize, width: usize, ksize: usize, stride: usize, pad: usize, col: Buf) void {
    const height_col = (height + 2 * pad - ksize) / stride + 1;
    const width_col = (width + 2 * pad - ksize) / stride + 1;
    const n = channels * height_col * width_col;
    launch1d(kernels.im2col_kernel, n, .{
        ci(n),           im.ptr,        ci(height),    ci(width), ci(ksize),
        ci(pad),         ci(stride),    ci(height_col), ci(width_col), col.ptr,
    });
}

pub fn col2im(col: Buf, channels: usize, height: usize, width: usize, ksize: usize, stride: usize, pad: usize, im: Buf) void {
    const height_col = (height + 2 * pad - ksize) / stride + 1;
    const width_col = (width + 2 * pad - ksize) / stride + 1;
    const n = channels * height * width;
    launch1d(kernels.col2im_kernel, n, .{
        ci(n),           col.ptr,       ci(height),    ci(width), ci(ksize),
        ci(pad),         ci(stride),    ci(height_col), ci(width_col), im.ptr,
    });
}

pub fn gemm(
    ta: bool,
    tb: bool,
    m: usize,
    n: usize,
    k: usize,
    alpha: f32,
    a: Buf,
    lda: usize,
    b: Buf,
    ldb: usize,
    beta: f32,
    c: Buf,
    ldc: usize,
) void {
    if (m == 0 or n == 0) return;
    const gx: u32 = @intCast((n + gemm_tile - 1) / gemm_tile);
    const gy: u32 = @intCast((m + gemm_tile - 1) / gemm_tile);
    launchDims(kernels.gemm_kernel, gx, gy, gemm_tile, gemm_tile, .{
        @as(c_int, if (ta) 1 else 0), @as(c_int, if (tb) 1 else 0),
        ci(m),                        ci(n),
        ci(k),                        alpha,
        a.ptr,                        ci(lda),
        b.ptr,                        ci(ldb),
        beta,                         c.ptr,
        ci(ldc),
    });
}

// ---------------------------------------------------------------------------
// pooling, dropout, shortcut, adam
// ---------------------------------------------------------------------------

pub fn forwardMaxpool(
    out_n: usize,
    in_h: usize,
    in_w: usize,
    in_c: usize,
    stride: usize,
    size: usize,
    pad: usize,
    input: Buf,
    output: Buf,
    indexes: Buf,
) void {
    launch1d(kernels.forward_maxpool_kernel, out_n, .{
        ci(out_n), ci(in_h), ci(in_w), ci(in_c), ci(stride),
        ci(size),  ci(pad),  input.ptr, output.ptr, indexes.ptr,
    });
}

pub fn backwardMaxpool(
    in_n: usize,
    in_h: usize,
    in_w: usize,
    in_c: usize,
    stride: usize,
    size: usize,
    pad: usize,
    delta: Buf,
    prev_delta: Buf,
    indexes: Buf,
) void {
    launch1d(kernels.backward_maxpool_kernel, in_n, .{
        ci(in_n), ci(in_h), ci(in_w), ci(in_c), ci(stride),
        ci(size), ci(pad),  delta.ptr, prev_delta.ptr, indexes.ptr,
    });
}

pub fn forwardAvgpool(n: usize, w: usize, h: usize, c: usize, input: Buf, output: Buf) void {
    launch1d(kernels.forward_avgpool_kernel, n, .{ ci(n), ci(w), ci(h), ci(c), input.ptr, output.ptr });
}

pub fn backwardAvgpool(n: usize, w: usize, h: usize, c: usize, in_delta: Buf, out_delta: Buf) void {
    launch1d(kernels.backward_avgpool_kernel, n, .{ ci(n), ci(w), ci(h), ci(c), in_delta.ptr, out_delta.ptr });
}

pub fn dropout(input: Buf, size: usize, rand_buf: Buf, prob: f32, scale: f32) void {
    launch1d(kernels.dropout_kernel, size, .{ input.ptr, ci(size), rand_buf.ptr, prob, scale });
}

pub fn shortcut(
    batch: usize,
    w1: usize,
    h1: usize,
    c1: usize,
    add: Buf,
    w2: usize,
    h2: usize,
    c2: usize,
    s1: f32,
    s2: f32,
    out: Buf,
) void {
    var stride = w1 / w2;
    var sample = w2 / w1;
    if (stride < 1) stride = 1;
    if (sample < 1) sample = 1;
    const minw = @min(w1, w2);
    const minh = @min(h1, h2);
    const minc = @min(c1, c2);
    const size = batch * minw * minh * minc;
    launch1d(kernels.shortcut_kernel, size, .{
        ci(size),  ci(minw), ci(minh), ci(minc), ci(stride),
        ci(sample), ci(batch),
        ci(w1),    ci(h1),   ci(c1),   add.ptr,
        ci(w2),    ci(h2),   ci(c2),   s1, s2, out.ptr,
    });
}

/// darknet's `adam_update_gpu`: the moment updates are ordinary BLAS calls,
/// only the final step needs its own kernel.
pub fn adamUpdate(
    w: Buf,
    d: Buf,
    m: Buf,
    v: Buf,
    b1: f32,
    b2: f32,
    eps: f32,
    decay: f32,
    rate: f32,
    n: usize,
    batch: usize,
    t: usize,
) void {
    scal(n, b1, m);
    scal(n, b2, v);
    axpy(n, -decay * @as(f32, @floatFromInt(batch)), w, d);

    axpy(n, 1 - b1, d, m);
    mul(n, d, d);
    axpy(n, 1 - b2, d, v);

    launch1d(kernels.adam_kernel, n, .{
        ci(n), w.ptr, m.ptr, v.ptr, b1, b2, rate, eps, ci(t),
    });
    fill(d, n, 0);
}
