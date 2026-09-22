//! NVIDIA backend: hand-written bindings for the CUDA *driver* API.
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
//! The CUDA driver API (`libcuda.so`, shipped with every NVIDIA driver) is a
//! real C library, and it is a closer match than the CUDA *runtime* API: it
//! loads separately compiled code objects and launches kernels by handle,
//! which is precisely the structure the HIP backend already uses. The runtime
//! API's `cudaLaunchKernel` instead relies on fatbin registration emitted by
//! nvcc into host code, which we have none of.
//!
//! This file implements the interface documented at the top of ../gpu.zig.

const std = @import("std");

pub const label = "CUDA";
/// PTX rather than a cubin: the driver JIT-compiles it on load, so one
/// artifact runs on any architecture at or above the one it was built for,
/// and there is no per-GPU build matrix to maintain.
pub const code_object_file = "darknet_kernels.ptx";

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

// The `_v2` suffixes are not optional. CUDA's headers `#define cuMemAlloc
// cuMemAlloc_v2`, so the unsuffixed names are not what libcuda exports.
extern fn cuInit(flags: c_uint) Error;
extern fn cuDeviceGetCount(count: *c_int) Error;
extern fn cuDeviceGet(device: *Device, ordinal: c_int) Error;
extern fn cuDeviceGetName(name: [*]u8, len: c_int, device: Device) Error;
extern fn cuDevicePrimaryCtxRetain(ctx: *Context, device: Device) Error;
extern fn cuCtxSetCurrent(ctx: Context) Error;
extern fn cuCtxSynchronize() Error;
extern fn cuMemAlloc_v2(dptr: *DevicePtr, bytesize: usize) Error;
extern fn cuMemFree_v2(dptr: DevicePtr) Error;
extern fn cuMemcpyHtoD_v2(dst: DevicePtr, src: *const anyopaque, bytesize: usize) Error;
extern fn cuMemcpyDtoH_v2(dst: *anyopaque, src: DevicePtr, bytesize: usize) Error;
extern fn cuMemsetD8_v2(dst: DevicePtr, value: u8, n: usize) Error;
extern fn cuMemGetInfo_v2(free: *usize, total: *usize) Error;
extern fn cuModuleLoad(module: *Module, fname: [*:0]const u8) Error;
extern fn cuModuleUnload(module: Module) Error;
extern fn cuModuleGetFunction(function: *Function, module: Module, name: [*:0]const u8) Error;
extern fn cuLaunchKernel(
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
) Error;
/// Unlike hipGetErrorString, this reports failure rather than returning the
/// string, so it needs wrapping.
extern fn cuGetErrorString(err: Error, str: *?[*:0]const u8) Error;
extern fn cuGetErrorName(err: Error, str: *?[*:0]const u8) Error;

inline fn toDevicePtr(p: ?*anyopaque) DevicePtr {
    return @intCast(@intFromPtr(p));
}

pub fn errorString(err: Error) [*:0]const u8 {
    var str: ?[*:0]const u8 = null;
    if (cuGetErrorString(err, &str) == success) {
        if (str) |s| return s;
    }
    if (cuGetErrorName(err, &str) == success) {
        if (str) |s| return s;
    }
    return "unknown CUDA error";
}

/// The driver API, unlike the runtime API, must be initialised explicitly
/// before any other call.
pub fn initPlatform() Error {
    return cuInit(0);
}

pub fn deviceCount(out: *c_int) Error {
    return cuDeviceGetCount(out);
}

/// There is no `cuSetDevice`. The equivalent is to retain the device's
/// primary context -- the same context the runtime API would use -- and make
/// it current on this thread.
pub fn setDevice(index: c_int) Error {
    var dev: Device = 0;
    var err = cuDeviceGet(&dev, index);
    if (err != success) return err;

    var ctx: Context = null;
    err = cuDevicePrimaryCtxRetain(&ctx, dev);
    if (err != success) return err;

    return cuCtxSetCurrent(ctx);
}

pub fn deviceName(index: c_int, buf: []u8) void {
    var dev: Device = 0;
    if (cuDeviceGet(&dev, index) != success) return;
    _ = cuDeviceGetName(buf.ptr, @intCast(buf.len - 1), dev);
}

pub fn memInfo(free_out: *usize, total_out: *usize) Error {
    return cuMemGetInfo_v2(free_out, total_out);
}

pub fn malloc(out: *?*anyopaque, bytes: usize) Error {
    var dptr: DevicePtr = 0;
    const err = cuMemAlloc_v2(&dptr, bytes);
    if (err != success) return err;
    out.* = @ptrFromInt(@as(usize, @intCast(dptr)));
    return success;
}

pub fn free(p: ?*anyopaque) Error {
    return cuMemFree_v2(toDevicePtr(p));
}

pub fn memsetZero(p: ?*anyopaque, bytes: usize) Error {
    return cuMemsetD8_v2(toDevicePtr(p), 0, bytes);
}

pub fn copyToDevice(dst: ?*anyopaque, src: *const anyopaque, bytes: usize) Error {
    return cuMemcpyHtoD_v2(toDevicePtr(dst), src, bytes);
}

pub fn copyToHost(dst: *anyopaque, src: ?*anyopaque, bytes: usize) Error {
    return cuMemcpyDtoH_v2(dst, toDevicePtr(src), bytes);
}

pub fn synchronize() Error {
    return cuCtxSynchronize();
}

pub fn moduleLoad(m: *Module, path: [*:0]const u8) Error {
    return cuModuleLoad(m, path);
}

pub fn moduleUnload(m: Module) Error {
    return cuModuleUnload(m);
}

pub fn moduleGetFunction(f: *Function, m: Module, name: [*:0]const u8) Error {
    return cuModuleGetFunction(f, m, name);
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
    return cuLaunchKernel(f, gx, gy, gz, bx, by, bz, shared_bytes, null, params, null);
}
