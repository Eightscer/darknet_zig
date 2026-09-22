//! The GPU layer: device buffers, the kernel registry, and one wrapper per
//! device op.
//!
//! Everything below is backend-agnostic. The vendor-specific part is a small
//! module selected at compile time -- `hip/hip.zig` for AMD, `cuda/cuda.zig`
//! for NVIDIA -- which has to provide:
//!
//!     label, code_object_file, Error, success, Module, Function
//!     errorString, initPlatform, deviceCount, setDevice, deviceName, memInfo
//!     malloc, free, memsetZero, copyToDevice, copyToHost, synchronize
//!     moduleLoad, moduleUnload, moduleGetFunction, launchKernel
//!
//! The two are interchangeable because this port never used the `<<<>>>`
//! launch syntax: kernels live in a separately compiled code object and are
//! looked up by name and launched by handle. That is HIP's module API and it
//! is also, almost line for line, the CUDA driver API.
//!
//! Everything here compiles in a CPU-only build too -- `enabled` is false, the
//! wrappers are unreachable, and no vendor symbol is ever referenced, so
//! nothing needs to link against libamdhip64 or libcuda. That is what lets
//! the project build and its CPU path be tested on a machine with neither.
//!
//! Each wrapper corresponds to one kernel in src/kernels/darknet_kernels.hip
//! and to one function in blas.zig / im2col.zig / activations.zig. When you
//! change one of the three, change all three: `darknet-zig gputest` exists to
//! catch it when you don't.

const std = @import("std");
const build_options = @import("build_options");
const sys = @import("sys.zig");

pub const enabled = build_options.gpu;

/// The vendor backend. Both are always importable -- they are only extern
/// declarations -- but only the selected one is ever called, and an unused
/// `extern fn` creates no link dependency.
const api = if (build_options.cuda) @import("cuda/cuda.zig") else @import("hip/hip.zig");

pub const backend_label = api.label;

fn check(err: api.Error, what: []const u8) !void {
    if (err != api.success) {
        std.debug.print("{s}: {s} failed: {s}\n", .{ api.label, what, api.errorString(err) });
        return error.GpuError;
    }
}

/// For the hot path, where there is no useful recovery from a failed call and
/// threading an error return through every layer would only obscure the
/// maths. Mirrors darknet's `check_error`, which called `exit`.
fn must(err: api.Error, what: []const u8) void {
    if (err != api.success) {
        std.debug.panic("{s}: {s} failed: {s}", .{ api.label, what, api.errorString(err) });
    }
}

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

var module: api.Module = null;
var kernels: Kernels = undefined;

/// A looked-up device function plus its symbol name. The name exists purely
/// so a fault can say which kernel it came from: GPU faults surface at the
/// next synchronising call, which is usually a memcpy far away from the
/// kernel that actually misbehaved.
pub const Kernel = struct {
    f: api.Function = null,
    name: []const u8 = "",
};

/// When set (via DARKNET_GPU_SYNC=1) every launch is followed by a device
/// synchronise and an error check, so a fault is reported against the kernel
/// that caused it instead of the next memcpy. Costs a full pipeline stall per
/// launch, so it is strictly a debugging aid.
var sync_after_launch: bool = false;

/// Force per-launch synchronisation on or off at runtime. `gputest` turns it
/// on so a faulting kernel is named rather than blamed on the next memcpy.
pub fn setSyncAfterLaunch(on: bool) void {
    sync_after_launch = on;
}

/// One field per `extern "C" __global__` function in the .hip file. The field
/// name is the symbol name, so registration is a comptime loop rather than 36
/// hand-written lookups.
const Kernels = struct {
    activate_array_kernel: Kernel = .{},
    gradient_array_kernel: Kernel = .{},

    fill_kernel: Kernel = .{},
    copy_kernel: Kernel = .{},
    axpy_kernel: Kernel = .{},
    scal_kernel: Kernel = .{},
    mul_kernel: Kernel = .{},
    add_scalar_kernel: Kernel = .{},
    constrain_kernel: Kernel = .{},
    rand_uniform_kernel: Kernel = .{},

    add_bias_kernel: Kernel = .{},
    scale_bias_kernel: Kernel = .{},
    backward_bias_kernel: Kernel = .{},
    backward_bias_conn_kernel: Kernel = .{},
    backward_scale_kernel: Kernel = .{},

    fast_mean_kernel: Kernel = .{},
    fast_variance_kernel: Kernel = .{},
    normalize_kernel: Kernel = .{},
    fast_mean_delta_kernel: Kernel = .{},
    fast_variance_delta_kernel: Kernel = .{},
    normalize_delta_kernel: Kernel = .{},

    softmax_kernel: Kernel = .{},
    softmax_x_ent_kernel: Kernel = .{},
    l2_kernel: Kernel = .{},
    l1_kernel: Kernel = .{},
    smooth_l1_kernel: Kernel = .{},

    im2col_kernel: Kernel = .{},
    col2im_kernel: Kernel = .{},

    forward_maxpool_kernel: Kernel = .{},
    backward_maxpool_kernel: Kernel = .{},
    forward_avgpool_kernel: Kernel = .{},
    backward_avgpool_kernel: Kernel = .{},

    dropout_kernel: Kernel = .{},
    shortcut_kernel: Kernel = .{},
    adam_kernel: Kernel = .{},
    gemm_kernel: Kernel = .{},
};

/// Locate the compiled device code -- `darknet_kernels.hsaco` on AMD,
/// `darknet_kernels.ptx` on NVIDIA. The build installs it next to the
/// executable; $DARKNET_KERNELS overrides that, which is what you want when
/// running out of a build tree or shipping the code object separately.
/// $DARKNET_HSACO is still honoured as the older name for the same thing.
fn findCodeObject(allocator: std.mem.Allocator) ![:0]u8 {
    const override = std.c.getenv("DARKNET_KERNELS") orelse std.c.getenv("DARKNET_HSACO");
    if (override) |p| {
        return allocator.dupeZ(u8, std.mem.sliceTo(p, 0));
    }

    // Resolve the executable's own directory. Both ROCm and CUDA are
    // effectively Linux-only here, so /proc/self/exe is a fair assumption; if
    // it isn't there, fall back to the working directory and let the load
    // error say what was tried.
    var buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const len = std.Io.Dir.readLinkAbsolute(sys.io, "/proc/self/exe", &buf) catch {
        return allocator.dupeZ(u8, api.code_object_file);
    };
    const exe_path = buf[0..len];
    const exe_dir = std.fs.path.dirname(exe_path) orelse ".";
    return std.fmt.allocPrintSentinel(allocator, "{s}/{s}", .{ exe_dir, api.code_object_file }, 0);
}

pub fn init(allocator: std.mem.Allocator, index: i32) !void {
    if (!enabled) {
        std.debug.print(
            \\This binary was built without GPU support.
            \\Rebuild with one of:
            \\  AMD:    zig build -Dgpu=true -Drocm-path=$ROCM_PATH -Doffload-arch=<your gfx>
            \\  NVIDIA: zig build -Dgpu=true -Dgpu-backend=cuda -Dcuda-path=$CUDA_PATH
            \\
        , .{});
        return error.GpuNotCompiledIn;
    }

    var count: c_int = 0;
    try check(api.initPlatform(), "initialising the driver");
    try check(api.deviceCount(&count), "querying device count");
    if (index >= count) {
        std.debug.print("Requested GPU {d} but only {d} HIP device(s) present\n", .{ index, count });
        return error.NoSuchDevice;
    }
    try check(api.setDevice(index), "selecting the device");

    var name: [256]u8 = @splat(0);
    api.deviceName(index, &name);

    const path = try findCodeObject(allocator);
    defer allocator.free(path);
    check(api.moduleLoad(&module, path.ptr), "loading the device code object") catch {
        std.debug.print(
            \\Failed to load device code from: {s}
            \\On AMD the .hsaco must match the GPU architecture: check
            \\`rocminfo | grep gfx` and rebuild with -Doffload-arch=<that>.
            \\On NVIDIA the .ptx is JIT-compiled, so a failure here usually means
            \\the file is missing or the driver is older than the PTX version.
            \\
        , .{path});
        return error.CodeObjectLoadFailed;
    };

    kernels = .{};
    inline for (@typeInfo(Kernels).@"struct".fields) |f| {
        var fun: api.Function = null;
        try check(api.moduleGetFunction(&fun, module, f.name ++ ""), "looking up kernel " ++ f.name);
        @field(kernels, f.name) = .{ .f = fun, .name = f.name };
    }

    const sync_env = std.c.getenv("DARKNET_GPU_SYNC") orelse std.c.getenv("DARKNET_HIP_SYNC");
    if (sync_env) |v| {
        sync_after_launch = std.mem.sliceTo(v, 0).len > 0 and v[0] != '0';
        if (sync_after_launch) {
            std.debug.print("DARKNET_GPU_SYNC set: synchronising and checking after every kernel launch.\n", .{});
        }
    }

    device_index = index;

    var free_mem: usize = 0;
    var total_mem: usize = 0;
    _ = api.memInfo(&free_mem, &total_mem);
    std.debug.print("{s} device {d}: {s} ({d} MiB free / {d} MiB total)\n", .{
        api.label,
        index,
        std.mem.sliceTo(&name, 0),
        free_mem >> 20,
        total_mem >> 20,
    });
}

pub fn deinit() void {
    if (!enabled) return;
    if (module != null) {
        _ = api.moduleUnload(module);
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
    must(api.malloc(&ptr, n * @sizeOf(f32)), "device allocation");
    must(api.memsetZero(ptr, n * @sizeOf(f32)), "zeroing device memory");
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
    if (b.ptr) |p| must(api.free(p), "device free");
}

pub fn push(b: Buf, host: []const f32) void {
    if (!enabled) unreachable;
    if (host.len == 0 or b.ptr == null) return;
    must(api.copyToDevice(b.ptr, host.ptr, host.len * @sizeOf(f32)), "copy host to device");
}

pub fn pull(b: Buf, host: []f32) void {
    if (!enabled) unreachable;
    if (host.len == 0 or b.ptr == null) return;
    must(api.copyToHost(host.ptr, b.ptr, host.len * @sizeOf(f32)), "copy device to host");
}

pub fn pullInts(b: Buf, host: []i32) void {
    if (!enabled) unreachable;
    if (host.len == 0 or b.ptr == null) return;
    must(api.copyToHost(host.ptr, b.ptr, host.len * @sizeOf(i32)), "copy device to host (ints)");
}

pub fn sync() void {
    if (!enabled) return;
    must(api.synchronize(), "device synchronise");
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
    k: Kernel,
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

    const launch_err = api.launchKernel(k.f, gx, gy, 1, bx, by, 1, 0, &params);
    if (launch_err != api.success) {
        std.debug.panic(
            "{s}: launching {s} <<<({d},{d}),({d},{d})>>> failed: {s}",
            .{ api.label, k.name, gx, gy, bx, by, api.errorString(launch_err) },
        );
    }

    // A launch is asynchronous, so a bad memory access inside the kernel is
    // not reported here -- it surfaces at the next synchronising call, which
    // is typically a memcpy several layers later and tells you nothing about
    // the cause. Under DARKNET_GPU_SYNC we pay for a stall to get the blame
    // attached to the right kernel.
    if (sync_after_launch) {
        const err = api.synchronize();
        if (err != api.success) {
            std.debug.panic(
                "{s}: {s} <<<({d},{d}),({d},{d})>>> faulted: {s}",
                .{ api.label, k.name, gx, gy, bx, by, api.errorString(err) },
            );
        }
    }
}

fn launch1d(k: Kernel, n: usize, args: anytype) void {
    if (n == 0) return;
    launchDims(k, grid(n), 1, block_size, 1, args);
}

/// For the per-filter reduction kernels: one block per filter, BLOCK threads
/// cooperating inside it.
fn launchPerFilter(k: Kernel, filters: usize, args: anytype) void {
    if (filters == 0) return;
    launchDims(k, @intCast(filters), 1, block_size, 1, args);
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
