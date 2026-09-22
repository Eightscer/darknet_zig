const std = @import("std");
const hip = @import("hip.zig");

pub fn main() !void {
    const n: usize = 1024;
    const bytes = n * @sizeOf(f32);

    var h_a: [n]f32 = undefined;
    var h_b: [n]f32 = undefined;
    var h_c: [n]f32 = undefined;
    for (0..n) |i| {
        h_a[i] = @floatFromInt(i);
        h_b[i] = @floatFromInt(i * 2);
    }

    var d_a: ?*anyopaque = null;
    var d_b: ?*anyopaque = null;
    var d_c: ?*anyopaque = null;
    try hip.check(hip.hipMalloc(&d_a, bytes), "hipMalloc a");
    try hip.check(hip.hipMalloc(&d_b, bytes), "hipMalloc b");
    try hip.check(hip.hipMalloc(&d_c, bytes), "hipMalloc c");
    defer _ = hip.hipFree(d_a);
    defer _ = hip.hipFree(d_b);
    defer _ = hip.hipFree(d_c);

    try hip.check(hip.hipMemcpy(d_a, &h_a, bytes, hip.hip_memcpy_host_to_device), "memcpy a -> device");
    try hip.check(hip.hipMemcpy(d_b, &h_b, bytes, hip.hip_memcpy_host_to_device), "memcpy b -> device");

    var module: hip.hipModule_t = null;
    try hip.check(hip.hipModuleLoad(&module, "kernel.hsaco"), "hipModuleLoad");

    var kernel: hip.hipFunction_t = null;
    try hip.check(hip.hipModuleGetFunction(&kernel, module, "vecAdd"), "hipModuleGetFunction");

    var n_arg: c_int = @intCast(n);
    var kernel_params = [_]?*anyopaque{
        @ptrCast(&d_a),
        @ptrCast(&d_b),
        @ptrCast(&d_c),
        @ptrCast(&n_arg),
    };

    const block_size: c_uint = 256;
    const grid_size: c_uint = @intCast((n + block_size - 1) / block_size);

    try hip.check(hip.hipModuleLaunchKernel(
        kernel,
        grid_size,  1, 1,
        block_size, 1, 1,
        0,
        null,
        &kernel_params,
        null,
    ), "hipModuleLaunchKernel");

    try hip.check(hip.hipDeviceSynchronize(), "hipDeviceSynchronize");
    try hip.check(hip.hipMemcpy(&h_c, d_c, bytes, hip.hip_memcpy_device_to_host), "memcpy c -> host");

    std.debug.print("c[0]={d}  c[1]={d}  c[{d}]={d}\n", .{ h_c[0], h_c[1], n - 1, h_c[n - 1] });
}
