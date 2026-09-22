# Zig + AMD HIP demos

Two demos showing Zig driving the AMD HIP runtime, with the C/C++ surface
kept to the one thing that's unavoidable: GPU kernels.

## Why the split is unavoidable

HIP has two halves:

1. **Host-side runtime API** (`hipMalloc`, `hipMemcpy`, `hipModuleLoad`,
   `hipModuleLaunchKernel`, ...) — plain `extern "C"` functions exported from
   `libamdhip64.so`. Zig can call these directly with hand-written `extern
   fn` declarations; no `@cImport` of the HIP headers is needed.
2. **Device-side kernel code** — compiled to AMD GPU ISA (gfx9/gfx10/gfx11...)
   by the ROCm LLVM/clang toolchain via `hipcc`. Zig's compiler has no
   amdgcn backend, so kernels have to be written in HIP C++ and built
   separately, then loaded as a code object at runtime.

Same pattern for the display side: SDL2's C API is called through a handful
of hand-written `extern fn`s (`src/sdl.zig`), not a `@cImport` of its headers.

## Demo 1: vector-add (`hip_zig_demo`)

The original minimal example: HIP computes `c[i] = a[i] + b[i]` on the GPU.

```sh
zig build run -Drocm-path=$ROCM_PATH -Doffload-arch=<yours>
```

## Demo 2: GPU plasma (`gpu_plasma`)

Each frame, the `plasma` HIP kernel (`src/plasma_kernel.hip`) computes an
animated plasma effect — a handful of summed sine waves over position and
time — directly into a device buffer, one thread per pixel. The buffer is
copied back to host memory and blitted into an SDL2 streaming texture, which
gets presented to the window. It's the "simple" integration path: no
zero-copy GPU-to-display interop, just compute-then-copy-then-blit, which is
far more robust to get running than true GL/HIP interop.

```sh
zig build run-plasma -Drocm-path=$ROCM_PATH -Dsdl2-path=$SDL2_PATH -Doffload-arch=<yours>
```

Close the window (or Ctrl+C the process) to quit.

## Files

- `src/hip.zig` — shared HIP runtime bindings, used by both demos.
- `src/sdl.zig` — minimal SDL2 bindings (window/renderer/texture/events).
- `src/kernel.hip`, `src/vecadd_main.zig` — demo 1.
- `src/plasma_kernel.hip`, `src/plasma_main.zig` — demo 2.
- `build.zig` — compiles both kernels with `hipcc --genco`, builds/links
  both Zig binaries, installs each kernel's `.hsaco` next to its executable.
- `flake.nix` — NixOS devShell with Zig, `rocmPackages` (hipcc, HIP runtime,
  `rocminfo`), and SDL2.

## Usage on NixOS

```sh
nix develop
rocminfo | grep gfx   # find your GPU's arch string, e.g. gfx1030, gfx1100, gfx90a
zig build run        -Drocm-path=$ROCM_PATH -Doffload-arch=gfx1030
zig build run-plasma -Drocm-path=$ROCM_PATH -Dsdl2-path=$SDL2_PATH -Doffload-arch=gfx1030
```

## Notes and caveats

- **GPU support**: ROCm only supports specific AMD GPUs officially. If yours
  isn't on the supported list, HIP calls may fail at runtime even though
  everything compiles; you may need `HSA_OVERRIDE_GFX_VERSION` set to a
  supported version close to your card's actual architecture.
- **`rocmPackages` attribute names drift**: nixpkgs occasionally reshuffles
  ROCm package names/splits across releases. Run `nix search nixpkgs rocm`
  if `rocmPackages.clr` / `rocmPackages.hipcc` don't exist in your pinned
  `nixpkgs`.
- **SDL_PIXELFORMAT_RGBA32** is hardcoded in `src/sdl.zig` as its known,
  stable numeric ABI value rather than reconstructed via SDL's internal
  macro, so no SDL headers are needed. It's specific to little-endian
  (x86_64) hosts — see the comment in that file if you ever port this to a
  big-endian target.
- **`SDL_Event` struct**: `src/sdl.zig` only declares the leading `type`
  field plus padding, rather than translating the full C union — enough to
  detect the quit event, nothing more. If you extend the demo to handle
  keyboard/mouse input, you'll need to widen that struct to match the real
  field layout for the event variant(s) you care about.
- **Zig build API**: written against Zig 0.16's module-based `b.addExecutable`
  (`.root_module` via `b.createModule()`, `linkSystemLibrary`/`addLibraryPath`
  on `.root_module` rather than the `Compile` step directly). If you're on a
  different version and hit API errors, check `zig build --help` and your
  installed Zig's `std.Build` docs.
