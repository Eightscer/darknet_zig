const std = @import("std");
const hip = @import("hip.zig");
const sdl = @import("sdl.zig");

const width: c_int = 800;
const height: c_int = 600;

pub fn main() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        std.debug.print("SDL_Init failed: {s}\n", .{sdl.SDL_GetError()});
        return error.SdlInitFailed;
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "Zig + HIP: GPU Plasma",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        width,
        height,
        sdl.SDL_WINDOW_SHOWN,
    ) orelse {
        std.debug.print("SDL_CreateWindow failed: {s}\n", .{sdl.SDL_GetError()});
        return error.SdlWindowFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_ACCELERATED) orelse {
        std.debug.print("SDL_CreateRenderer failed: {s}\n", .{sdl.SDL_GetError()});
        return error.SdlRendererFailed;
    };
    defer sdl.SDL_DestroyRenderer(renderer);

    const texture = sdl.SDL_CreateTexture(
        renderer,
        sdl.SDL_PIXELFORMAT_RGBA32,
        sdl.SDL_TEXTUREACCESS_STREAMING,
        width,
        height,
    ) orelse {
        std.debug.print("SDL_CreateTexture failed: {s}\n", .{sdl.SDL_GetError()});
        return error.SdlTextureFailed;
    };
    defer sdl.SDL_DestroyTexture(texture);

    // --- HIP setup: one persistent device buffer, refilled every frame ---
    const frame_bytes: usize = @as(usize, @intCast(width)) * @as(usize, @intCast(height)) * 4;

    var d_pixels: ?*anyopaque = null;
    try hip.check(hip.hipMalloc(&d_pixels, frame_bytes), "hipMalloc pixels");
    defer _ = hip.hipFree(d_pixels);

    var module: hip.hipModule_t = null;
    try hip.check(hip.hipModuleLoad(&module, "plasma_kernel.hsaco"), "hipModuleLoad plasma");

    var kernel: hip.hipFunction_t = null;
    try hip.check(hip.hipModuleGetFunction(&kernel, module, "plasma"), "hipModuleGetFunction plasma");

    const host_pixels = try std.heap.page_allocator.alloc(u8, frame_bytes);
    defer std.heap.page_allocator.free(host_pixels);

    const block_x: c_uint = 16;
    const block_y: c_uint = 16;
    const w: c_uint = @intCast(width);
    const h: c_uint = @intCast(height);
    const grid_x: c_uint = (w + block_x - 1) / block_x;
    const grid_y: c_uint = (h + block_y - 1) / block_y;

    const start_ticks = sdl.SDL_GetTicks();
    var event_buf: sdl.SDL_Event = undefined;
    var quit = false;

    while (!quit) {
        while (sdl.SDL_PollEvent(&event_buf) != 0) {
            if (event_buf.type == sdl.SDL_QUIT) quit = true;
        }

        const t: f32 = @as(f32, @floatFromInt(sdl.SDL_GetTicks() - start_ticks)) / 1000.0;

        var width_arg: c_int = width;
        var height_arg: c_int = height;
        var t_arg: f32 = t;
        var kernel_params = [_]?*anyopaque{
            @ptrCast(&d_pixels),
            @ptrCast(&width_arg),
            @ptrCast(&height_arg),
            @ptrCast(&t_arg),
        };

        try hip.check(hip.hipModuleLaunchKernel(
            kernel,
            grid_x,  grid_y,  1,
            block_x, block_y, 1,
            0,
            null,
            &kernel_params,
            null,
        ), "launch plasma kernel");

        try hip.check(hip.hipDeviceSynchronize(), "hipDeviceSynchronize");
        try hip.check(hip.hipMemcpy(host_pixels.ptr, d_pixels, frame_bytes, hip.hip_memcpy_device_to_host), "memcpy pixels -> host");

        _ = sdl.SDL_UpdateTexture(texture, null, host_pixels.ptr, width * 4);
        _ = sdl.SDL_RenderClear(renderer);
        _ = sdl.SDL_RenderCopy(renderer, texture, null, null);
        sdl.SDL_RenderPresent(renderer);
    }
}
