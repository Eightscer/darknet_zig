//! NVIDIA backend: bindings for the CUDA *driver* API, resolved at runtime.
//!
//! Why the driver API and not HIP, given that HIP nominally targets NVIDIA?
//! Because HIP's NVIDIA support is header-only. On AMD, `hipMalloc` is a real
//! symbol exported from `libamdhip64.so`, which is what lets Zig call it with
//! an `extern fn`. On NVIDIA there is no equivalent library: the HIP headers
//! define `hipMalloc` as an inline wrapper around `cudaMalloc`, so the symbol
//! only exists inside a translation unit compiled by hipcc. Using HIP here
//! would mean compiling the host side as C++, which is exactly what this
//! project set out not to do.
//!
//! The CUDA driver API is a closer match than the CUDA *runtime* API anyway:
//! it loads separately compiled code objects and launches kernels by handle,
//! which is precisely the structure the HIP backend already uses. The runtime
//! API's `cudaLaunchKernel` instead relies on fatbin registration emitted by
//! nvcc into host code, which we have none of.
//!
//! ## Why dlopen instead of linking
//!
//! `libcuda.so` comes from the NVIDIA *driver*, not the CUDA toolkit. The
//! toolkit ships only a **stub** with the same soname, whose entry points
//! exist to satisfy the linker and do nothing useful. Linking against that
//! stub the ordinary way put its directory into the binary's RUNPATH, so at
//! run time the loader resolved `libcuda.so.1` to the stub rather than the
//! driver, and `cuInit` failed with an error code the stub could not even
//! describe.
//!
//! Loading the driver explicitly avoids that trap entirely, and fixes a
//! second one: on NixOS the real library lives in `/run/opengl-driver/lib`,
//! which is not on the default loader search path. It also means the build
//! needs no CUDA libraries at all -- only nvcc, to compile the kernels -- and
//! that a machine with no driver gets a clear message instead of failing to
//! start.
//!
//! This file implements the interface documented at the top of ../gpu.zig.

const std = @import("std");
const build_options = @import("build_options");

pub const label = "CUDA";
/// PTX by default: the driver JIT-compiles it on load, so one artifact runs
/// on any architecture at or above the one it was built for, and there is no
/// per-GPU build matrix to maintain. `-Dcuda-arch=sm_XX` instead produces a
/// cubin, which skips the JIT entirely -- see `loadJitCompiler` below.
pub const code_object_file = if (build_options.cuda_cubin)
    "darknet_kernels.cubin"
else
    "darknet_kernels.ptx";

/// CUresult. CUDA_SUCCESS is 0, same as hipSuccess.
pub const Error = c_int;
pub const success: Error = 0;

pub const Module = ?*opaque {};
pub const Function = ?*opaque {};

const Context = ?*opaque {};
const Stream = ?*anyopaque;
const Device = c_int;

/// CUdeviceptr is an integer, not a pointer -- the one real difference from
/// HIP. It is pointer-width, so the value round-trips through `?*anyopaque`
/// and the rest of the codebase can stay pointer-typed. That also means
/// `&buf.ptr` is still the right thing to hand to cuLaunchKernel for a
/// `float*` kernel parameter: eight bytes holding the device address.
const DevicePtr = c_ulonglong;

/// Every driver entry point this backend uses. The field name *is* the
/// symbol name, so loading is a comptime loop rather than 19 hand-written
/// dlsym calls -- the same trick the kernel registry in gpu.zig uses.
///
/// The `_v2` suffixes are not optional: CUDA's headers `#define cuMemAlloc
/// cuMemAlloc_v2`, so the unsuffixed names are not what libcuda exports.
const Driver = struct {
    cuInit: *const fn (flags: c_uint) callconv(.c) Error,
    cuDeviceGetCount: *const fn (count: *c_int) callconv(.c) Error,
    cuDeviceGet: *const fn (device: *Device, ordinal: c_int) callconv(.c) Error,
    cuDeviceGetName: *const fn (name: [*]u8, len: c_int, device: Device) callconv(.c) Error,
    cuDevicePrimaryCtxRetain: *const fn (ctx: *Context, device: Device) callconv(.c) Error,
    cuCtxSetCurrent: *const fn (ctx: Context) callconv(.c) Error,
    cuCtxSynchronize: *const fn () callconv(.c) Error,
    cuMemAlloc_v2: *const fn (dptr: *DevicePtr, bytesize: usize) callconv(.c) Error,
    cuMemFree_v2: *const fn (dptr: DevicePtr) callconv(.c) Error,
    cuMemcpyHtoD_v2: *const fn (dst: DevicePtr, src: *const anyopaque, bytesize: usize) callconv(.c) Error,
    cuMemcpyDtoH_v2: *const fn (dst: *anyopaque, src: DevicePtr, bytesize: usize) callconv(.c) Error,
    cuMemsetD8_v2: *const fn (dst: DevicePtr, value: u8, n: usize) callconv(.c) Error,
    cuMemGetInfo_v2: *const fn (free: *usize, total: *usize) callconv(.c) Error,
    cuModuleLoad: *const fn (module: *Module, fname: [*:0]const u8) callconv(.c) Error,
    cuModuleUnload: *const fn (module: Module) callconv(.c) Error,
    cuModuleGetFunction: *const fn (function: *Function, module: Module, name: [*:0]const u8) callconv(.c) Error,
    cuLaunchKernel: *const fn (
        f: Function,
        grid_dim_x: c_uint,
        grid_dim_y: c_uint,
        grid_dim_z: c_uint,
        block_dim_x: c_uint,
        block_dim_y: c_uint,
        block_dim_z: c_uint,
        shared_mem_bytes: c_uint,
        stream: Stream,
        kernel_params: ?[*]?*anyopaque,
        extra: ?[*]?*anyopaque,
    ) callconv(.c) Error,
    /// Unlike hipGetErrorString, this reports failure rather than returning
    /// the string, so it needs wrapping.
    cuGetErrorString: *const fn (err: Error, str: *?[*:0]const u8) callconv(.c) Error,
    cuGetErrorName: *const fn (err: Error, str: *?[*:0]const u8) callconv(.c) Error,
};

var driver: Driver = undefined;
var loaded = false;

/// Where to look for the driver, in order. The bare soname covers the normal
/// case; the rest are distributions that put it somewhere the default search
/// path misses. `/run/opengl-driver/lib` is NixOS.
const candidates = [_][:0]const u8{
    "libcuda.so.1",
    "/run/opengl-driver/lib/libcuda.so.1",
    "/usr/lib/x86_64-linux-gnu/libcuda.so.1",
    "/usr/lib64/libcuda.so.1",
    "/usr/lib/libcuda.so.1",
};

/// Errors from this backend that are not CUresult values.
const load_failed: Error = -1;
const symbol_missing: Error = -2;

var detail_buf: [512]u8 = @splat(0);
var detail: []const u8 = "";

fn setDetail(comptime fmt: []const u8, args: anytype) void {
    detail = std.fmt.bufPrint(&detail_buf, fmt, args) catch "(message truncated)";
}

pub fn errorString(err: Error) [*:0]const u8 {
    if (err == load_failed or err == symbol_missing or !loaded) {
        // Not a CUresult, or the driver is not loaded so we cannot ask it.
        detail_buf[@min(detail.len, detail_buf.len - 1)] = 0;
        return @ptrCast(detail_buf[0.. :0].ptr);
    }
    var str: ?[*:0]const u8 = null;
    if (driver.cuGetErrorString(err, &str) == success) {
        if (str) |s| return s;
    }
    if (driver.cuGetErrorName(err, &str) == success) {
        if (str) |s| return s;
    }
    // The driver could not describe its own error. That is itself a signal:
    // it happens when the "driver" is really the toolkit's stub. Fall back to
    // a small table rather than printing nothing useful.
    setDetail("{s} (CUresult {d})", .{ fallbackName(err), err });
    detail_buf[@min(detail.len, detail_buf.len - 1)] = 0;
    return @ptrCast(detail_buf[0.. :0].ptr);
}

/// Only consulted when `cuGetErrorString` itself fails. Covers the codes
/// worth recognising before a working driver is established.
fn fallbackName(err: Error) []const u8 {
    return switch (err) {
        3 => "CUDA_ERROR_NOT_INITIALIZED",
        // What libcuda.so from a CUDA *toolkit* returns, as opposed to the
        // driver's. Usually LD_LIBRARY_PATH or RUNPATH pointing into a
        // toolkit's lib/stubs directory.
        34 => "CUDA_ERROR_STUB_LIBRARY -- a stub libcuda was loaded instead of the driver's",
        100 => "CUDA_ERROR_NO_DEVICE -- no CUDA-capable GPU visible",
        101 => "CUDA_ERROR_INVALID_DEVICE",
        218 => "CUDA_ERROR_INVALID_PTX -- the .ptx is corrupt or built by a newer toolkit than the driver knows",
        222 => "CUDA_ERROR_UNSUPPORTED_PTX_VERSION -- driver older than the PTX; lower -Dcuda-arch or update the driver",
        999 => "CUDA_ERROR_UNKNOWN",
        else => "unrecognised CUresult",
    };
}

fn loadDriver() Error {
    if (loaded) return success;

    var handle: ?*anyopaque = null;
    var loaded_from: []const u8 = "";
    for (candidates) |path| {
        handle = std.c.dlopen(path.ptr, .{ .NOW = true });
        if (handle != null) {
            loaded_from = path;
            break;
        }
    }
    const h = handle orelse {
        setDetail(
            "could not load libcuda.so.1 (tried the loader path, /run/opengl-driver/lib, " ++
                "/usr/lib/x86_64-linux-gnu, /usr/lib64, /usr/lib). " ++
                "It ships with the NVIDIA driver, not the CUDA toolkit",
            .{},
        );
        return load_failed;
    };

    inline for (@typeInfo(Driver).@"struct".fields) |f| {
        const sym = std.c.dlsym(h, f.name ++ "") orelse {
            setDetail("libcuda.so.1 has no symbol {s}; driver is too old", .{f.name});
            return symbol_missing;
        };
        @field(driver, f.name) = @ptrCast(@alignCast(sym));
    }

    loadJitCompiler(loaded_from);
    loaded = true;
    return success;
}

/// Pull `libnvidia-ptxjitcompiler.so.1` into the process, best effort.
///
/// Loading PTX makes the driver dlopen this itself, by bare soname. When
/// libcuda was found somewhere the default loader path does not cover -- a
/// container that bind-mounts only part of the driver, or NixOS's
/// /run/opengl-driver/lib -- that second lookup fails even though the file is
/// sitting next to libcuda, and `cuModuleLoad` returns
/// CUDA_ERROR_JIT_COMPILER_NOT_FOUND. Loading it here first means the driver's
/// dlopen finds it already resident and succeeds.
///
/// Irrelevant when the kernels were built as a cubin (`-Dcuda-arch=sm_XX`),
/// since nothing is JIT-compiled then, but harmless.
fn loadJitCompiler(cuda_lib_path: []const u8) void {
    const soname = "libnvidia-ptxjitcompiler.so.1";
    const flags: std.c.RTLD = .{ .NOW = true, .GLOBAL = true };

    // Next to whichever libcuda actually loaded: the most likely place, and
    // guaranteed to be the matching driver version.
    if (std.fs.path.dirname(cuda_lib_path)) |dir| {
        var buf: [512]u8 = undefined;
        if (std.fmt.bufPrintZ(&buf, "{s}/{s}", .{ dir, soname })) |p| {
            if (std.c.dlopen(p.ptr, flags) != null) return;
        } else |_| {}
    }

    if (std.c.dlopen(soname, flags) != null) return;

    for (candidates) |cand| {
        const dir = std.fs.path.dirname(cand) orelse continue;
        var buf: [512]u8 = undefined;
        const p = std.fmt.bufPrintZ(&buf, "{s}/{s}", .{ dir, soname }) catch continue;
        if (std.c.dlopen(p.ptr, flags) != null) return;
    }
    // Not found. Say nothing here: a cubin build does not need it, and if a
    // PTX build does, cuModuleLoad reports it with better context.
}

/// The driver API, unlike the runtime API, must be initialised explicitly
/// before any other call.
pub fn initPlatform() Error {
    const err = loadDriver();
    if (err != success) return err;
    return driver.cuInit(0);
}

pub fn deviceCount(out: *c_int) Error {
    return driver.cuDeviceGetCount(out);
}

/// There is no `cuSetDevice`. The equivalent is to retain the device's
/// primary context -- the same context the runtime API would use -- and make
/// it current on this thread.
pub fn setDevice(index: c_int) Error {
    var dev: Device = 0;
    var err = driver.cuDeviceGet(&dev, index);
    if (err != success) return err;

    var ctx: Context = null;
    err = driver.cuDevicePrimaryCtxRetain(&ctx, dev);
    if (err != success) return err;

    return driver.cuCtxSetCurrent(ctx);
}

pub fn deviceName(index: c_int, buf: []u8) void {
    var dev: Device = 0;
    if (driver.cuDeviceGet(&dev, index) != success) return;
    _ = driver.cuDeviceGetName(buf.ptr, @intCast(buf.len - 1), dev);
}

pub fn memInfo(free_out: *usize, total_out: *usize) Error {
    return driver.cuMemGetInfo_v2(free_out, total_out);
}

inline fn toDevicePtr(p: ?*anyopaque) DevicePtr {
    return @intCast(@intFromPtr(p));
}

pub fn malloc(out: *?*anyopaque, bytes: usize) Error {
    var dptr: DevicePtr = 0;
    const err = driver.cuMemAlloc_v2(&dptr, bytes);
    if (err != success) return err;
    out.* = @ptrFromInt(@as(usize, @intCast(dptr)));
    return success;
}

pub fn free(p: ?*anyopaque) Error {
    return driver.cuMemFree_v2(toDevicePtr(p));
}

pub fn memsetZero(p: ?*anyopaque, bytes: usize) Error {
    return driver.cuMemsetD8_v2(toDevicePtr(p), 0, bytes);
}

pub fn copyToDevice(dst: ?*anyopaque, src: *const anyopaque, bytes: usize) Error {
    return driver.cuMemcpyHtoD_v2(toDevicePtr(dst), src, bytes);
}

pub fn copyToHost(dst: *anyopaque, src: ?*anyopaque, bytes: usize) Error {
    return driver.cuMemcpyDtoH_v2(dst, toDevicePtr(src), bytes);
}

pub fn synchronize() Error {
    return driver.cuCtxSynchronize();
}

pub fn moduleLoad(m: *Module, path: [*:0]const u8) Error {
    return driver.cuModuleLoad(m, path);
}

pub fn moduleUnload(m: Module) Error {
    return driver.cuModuleUnload(m);
}

pub fn moduleGetFunction(f: *Function, m: Module, name: [*:0]const u8) Error {
    return driver.cuModuleGetFunction(f, m, name);
}

pub fn launchKernel(
    f: Function,
    gx: c_uint,
    gy: c_uint,
    gz: c_uint,
    bx: c_uint,
    by: c_uint,
    bz: c_uint,
    shared_bytes: c_uint,
    params: ?[*]?*anyopaque,
) Error {
    return driver.cuLaunchKernel(f, gx, gy, gz, bx, by, bz, shared_bytes, null, params, null);
}
