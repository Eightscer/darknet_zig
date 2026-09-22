//! AMD backend: hand-written bindings for the HIP runtime's C API.
//!
//! `libamdhip64.so` exports plain `extern "C"` symbols, so Zig calls them
//! directly and no `@cImport` of the HIP headers is needed anywhere.
//!
//! Kernels are dispatched through the *module* API (hipModuleLoad +
//! hipModuleLaunchKernel) rather than the `<<<>>>` launch syntax, which only
//! exists in HIP C++. That is what lets the device code live in one
//! separately compiled .hsaco and the host stay entirely in Zig -- and it is
//! also what made the CUDA driver API a drop-in second backend, since it has
//! exactly the same shape (see ../cuda/cuda.zig).
//!
//! This file implements the interface documented at the top of ../gpu.zig.

const std = @import("std");

pub const label = "HIP";
pub const code_object_file = "darknet_kernels.hsaco";

pub const Error = c_int;
pub const success: Error = 0;

pub const Module = ?*opaque {};
pub const Function = ?*opaque {};

const Stream = ?*anyopaque;
const Device = c_int;

const memcpy_host_to_device: c_int = 1;
const memcpy_device_to_host: c_int = 2;

extern fn hipMalloc(ptr: *?*anyopaque, size: usize) Error;
extern fn hipFree(ptr: ?*anyopaque) Error;
extern fn hipMemcpy(dst: ?*anyopaque, src: ?*const anyopaque, size_bytes: usize, kind: c_int) Error;
extern fn hipMemset(dst: ?*anyopaque, value: c_int, size_bytes: usize) Error;
extern fn hipDeviceSynchronize() Error;
extern fn hipGetErrorString(err: Error) [*:0]const u8;
extern fn hipSetDevice(device: c_int) Error;
extern fn hipGetDeviceCount(count: *c_int) Error;
extern fn hipDeviceGet(device: *Device, ordinal: c_int) Error;
extern fn hipDeviceGetName(name: [*]u8, len: c_int, device: Device) Error;
extern fn hipMemGetInfo(free: *usize, total: *usize) Error;
extern fn hipModuleLoad(module: *Module, fname: [*:0]const u8) Error;
extern fn hipModuleUnload(module: Module) Error;
extern fn hipModuleGetFunction(function: *Function, module: Module, kname: [*:0]const u8) Error;
extern fn hipModuleLaunchKernel(
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

pub fn errorString(err: Error) [*:0]const u8 {
    return hipGetErrorString(err);
}

/// The HIP runtime initialises itself on first use.
pub fn initPlatform() Error {
    return success;
}

pub fn deviceCount(out: *c_int) Error {
    return hipGetDeviceCount(out);
}

pub fn setDevice(index: c_int) Error {
    return hipSetDevice(index);
}

pub fn deviceName(index: c_int, buf: []u8) void {
    var dev: Device = 0;
    if (hipDeviceGet(&dev, index) != success) return;
    _ = hipDeviceGetName(buf.ptr, @intCast(buf.len - 1), dev);
}

pub fn memInfo(free_out: *usize, total_out: *usize) Error {
    return hipMemGetInfo(free_out, total_out);
}

pub fn malloc(out: *?*anyopaque, bytes: usize) Error {
    return hipMalloc(out, bytes);
}

pub fn free(p: ?*anyopaque) Error {
    return hipFree(p);
}

pub fn memsetZero(p: ?*anyopaque, bytes: usize) Error {
    return hipMemset(p, 0, bytes);
}

pub fn copyToDevice(dst: ?*anyopaque, src: *const anyopaque, bytes: usize) Error {
    return hipMemcpy(dst, src, bytes, memcpy_host_to_device);
}

pub fn copyToHost(dst: *anyopaque, src: ?*anyopaque, bytes: usize) Error {
    return hipMemcpy(dst, src, bytes, memcpy_device_to_host);
}

pub fn synchronize() Error {
    return hipDeviceSynchronize();
}

pub fn moduleLoad(m: *Module, path: [*:0]const u8) Error {
    return hipModuleLoad(m, path);
}

pub fn moduleUnload(m: Module) Error {
    return hipModuleUnload(m);
}

pub fn moduleGetFunction(f: *Function, m: Module, name: [*:0]const u8) Error {
    return hipModuleGetFunction(f, m, name);
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
    return hipModuleLaunchKernel(f, gx, gy, gz, bx, by, bz, shared_bytes, null, params, null);
}
