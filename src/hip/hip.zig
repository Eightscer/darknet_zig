//! Hand-written bindings for the HIP runtime's C API.
//!
//! This is the entire host-side interop surface: `libamdhip64.so` exports
//! plain `extern "C"` symbols, so Zig calls them directly and no `@cImport` of
//! the HIP headers is needed anywhere. The approach is carried over from the
//! zig-hip demo this project grew out of.
//!
//! Note that kernels are dispatched through the *module* API
//! (hipModuleLoad + hipModuleLaunchKernel) rather than the `<<<>>>` launch
//! syntax, which only exists in HIP C++. That is what lets the device code
//! stay in one separately compiled .hsaco and the host stay entirely in Zig.

const std = @import("std");

pub const Error = c_int;
pub const success: Error = 0;

pub const MemcpyKind = c_int;
pub const memcpy_host_to_device: MemcpyKind = 1;
pub const memcpy_device_to_host: MemcpyKind = 2;
pub const memcpy_device_to_device: MemcpyKind = 3;

pub const Module = ?*opaque {};
pub const Function = ?*opaque {};
pub const Stream = ?*opaque {};
pub const Device = c_int;

pub extern fn hipMalloc(ptr: *?*anyopaque, size: usize) Error;
pub extern fn hipFree(ptr: ?*anyopaque) Error;
pub extern fn hipMemcpy(dst: ?*anyopaque, src: ?*const anyopaque, size_bytes: usize, kind: MemcpyKind) Error;
pub extern fn hipMemset(dst: ?*anyopaque, value: c_int, size_bytes: usize) Error;
pub extern fn hipDeviceSynchronize() Error;
pub extern fn hipGetLastError() Error;
pub extern fn hipPeekAtLastError() Error;
pub extern fn hipGetErrorString(err: Error) [*:0]const u8;
pub extern fn hipSetDevice(device: c_int) Error;
pub extern fn hipGetDeviceCount(count: *c_int) Error;
pub extern fn hipDeviceGet(device: *Device, ordinal: c_int) Error;
pub extern fn hipDeviceGetName(name: [*]u8, len: c_int, device: Device) Error;
pub extern fn hipMemGetInfo(free: *usize, total: *usize) Error;
pub extern fn hipModuleLoad(module: *Module, fname: [*:0]const u8) Error;
pub extern fn hipModuleUnload(module: Module) Error;
pub extern fn hipModuleGetFunction(function: *Function, module: Module, kname: [*:0]const u8) Error;
pub extern fn hipModuleLaunchKernel(
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

pub fn check(err: Error, comptime what: []const u8) !void {
    if (err != success) {
        std.debug.print("HIP: {s} failed: {s}\n", .{ what, hipGetErrorString(err) });
        return error.HipError;
    }
}

/// For the hot path, where there is no useful recovery from a failed launch
/// and threading an error return through every layer would only obscure the
/// maths. Mirrors darknet's `check_error`, which called `exit`.
pub fn must(err: Error, comptime what: []const u8) void {
    if (err != success) {
        std.debug.panic("HIP: {s} failed: {s}", .{ what, hipGetErrorString(err) });
    }
}
