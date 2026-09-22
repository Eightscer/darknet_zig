const std = @import("std");

// ---------------------------------------------------------------------------
// Minimal, hand-written bindings for the tiny slice of SDL2 this demo needs:
// open a window, create a renderer + streaming texture, push pixel data into
// it each frame, and poll for the quit event. As with hip.zig, this skips
// @cImport of SDL2's headers entirely.
// ---------------------------------------------------------------------------

pub const SDL_INIT_VIDEO: u32 = 0x00000020;
pub const SDL_WINDOW_SHOWN: u32 = 0x00000004;
pub const SDL_WINDOWPOS_UNDEFINED: c_int = 0x1FFF0000;
pub const SDL_RENDERER_ACCELERATED: u32 = 0x00000002;
pub const SDL_TEXTUREACCESS_STREAMING: c_int = 1;
pub const SDL_QUIT: u32 = 0x100;

// SDL_PIXELFORMAT_RGBA32 is a byte-order alias: on little-endian machines
// (x86_64, which is what we're targeting) it expands to
// SDL_PIXELFORMAT_ABGR8888 = SDL_DEFINE_PIXELFORMAT(PACKED32, ABGR, 8888, 32, 4)
// = 0x16762004. That's a stable, documented SDL2 ABI constant, hardcoded here
// rather than reconstructed, but it's what guarantees a byte written as
// (r, g, b, a) in the kernel lands in memory in that same order.
pub const SDL_PIXELFORMAT_RGBA32: u32 = 0x16762004;

// SDL_Event is a C union of many event-type structs; every variant starts
// with a `type: Uint32` field. Rather than translate the whole union, this
// declares just that leading field plus generous padding -- real sizeof is
// 56 bytes on 64-bit, this is comfortably larger so SDL_PollEvent never
// writes past the end.
pub const SDL_Event = extern struct {
    type: u32,
    _padding: [60]u8 = undefined,
};

pub extern fn SDL_Init(flags: u32) c_int;
pub extern fn SDL_Quit() void;
pub extern fn SDL_GetError() [*:0]const u8;
pub extern fn SDL_CreateWindow(title: [*:0]const u8, x: c_int, y: c_int, w: c_int, h: c_int, flags: u32) ?*anyopaque;
pub extern fn SDL_DestroyWindow(window: ?*anyopaque) void;
pub extern fn SDL_CreateRenderer(window: ?*anyopaque, index: c_int, flags: u32) ?*anyopaque;
pub extern fn SDL_DestroyRenderer(renderer: ?*anyopaque) void;
pub extern fn SDL_CreateTexture(renderer: ?*anyopaque, format: u32, access: c_int, w: c_int, h: c_int) ?*anyopaque;
pub extern fn SDL_DestroyTexture(texture: ?*anyopaque) void;
pub extern fn SDL_UpdateTexture(texture: ?*anyopaque, rect: ?*const anyopaque, pixels: ?*const anyopaque, pitch: c_int) c_int;
pub extern fn SDL_RenderClear(renderer: ?*anyopaque) c_int;
pub extern fn SDL_RenderCopy(renderer: ?*anyopaque, texture: ?*anyopaque, srcrect: ?*const anyopaque, dstrect: ?*const anyopaque) c_int;
pub extern fn SDL_RenderPresent(renderer: ?*anyopaque) void;
pub extern fn SDL_PollEvent(event: *SDL_Event) c_int;
pub extern fn SDL_GetTicks() u32;
