# darknet-zig

A rewrite of [pjreddie's darknet](https://github.com/pjreddie/darknet) from C to
Zig, scoped to **training and running image classifiers**, with GPU backends for
both **AMD** (HIP) and **NVIDIA** (CUDA driver API).

Weights and `.cfg` files are byte-compatible with upstream darknet in both
directions. Running the stock `tiny.cfg` + `tiny.weights` ImageNet model through
both programs gives identical predictions:

```
$ darknet      classifier predict cfg/imagenet1k.data cfg/tiny.cfg tiny.weights data/dog.jpg
$ darknet-zig  classifier predict cfg/imagenet1k.data cfg/tiny.cfg tiny.weights data/dog.jpg
14.51%: malamute
 6.09%: Newfoundland
 5.59%: dogsled
 4.55%: standard schnauzer
 4.05%: Eskimo dog
```

## Status

| | |
|---|---|
| CPU | verified end to end: trains, checkpoints round-trip through darknet, reproduces upstream's inference numerically |
| AMD (HIP) | **working on hardware** -- an RX 6650 XT runs ~10x the speed of an 8-core CPU |
| NVIDIA (CUDA) | **compiles and links, never executed** -- no NVIDIA GPU was available |

The NVIDIA backend is in the state the AMD one was in before its first real
run, and that run found a genuine out-of-bounds write in a kernel. The kernels
are shared between the two backends and are now known-good on AMD, which is
real evidence, but the host side -- 19 driver-API entry points, device pointers
represented as integers, a different context model -- has only ever been
checked by the compiler and the linker.

**Run `darknet-zig gputest -gpu 0` first, on each backend.** It compares every
op against its CPU twin and names the kernel that disagrees. Going straight to
`predict` is how the AMD bug presented as an illegal memory access blamed on an
unrelated memcpy three layers away.

## Building

```sh
nix develop                        # or bring your own Zig 0.16 + ROCm

# CPU only -- no ROCm needed
zig build -Doptimize=ReleaseFast

# AMD, via HIP
rocminfo | grep gfx                # find your GPU's ISA, e.g. gfx1030
zig build -Doptimize=ReleaseFast -Dgpu=true \
          -Drocm-path=$ROCM_PATH -Doffload-arch=gfx1030

# NVIDIA, via the CUDA driver API
zig build -Doptimize=ReleaseFast -Dgpu=true -Dgpu-backend=cuda \
          -Dcuda-path=$CUDA_PATH
```

On AMD, `-Doffload-arch` takes a comma-separated list (`gfx1030,gfx1100`),
bundling several ISAs into one code object -- useful when the build machine and
the GPU machine differ. On NVIDIA there is no equivalent list: the kernels are
emitted as PTX and JIT-compiled by the driver, so one artifact runs on any GPU
at or above `-Dcuda-arch` (default `compute_52`).

Two artifacts land in `zig-out/bin`: the `darknet-zig` executable and the
compiled device code -- `darknet_kernels.hsaco` on AMD, `darknet_kernels.ptx`
on NVIDIA. The executable looks for it next to itself;
`DARKNET_KERNELS=/path/to/it` overrides that.

`zig build kernels` compiles only the device code, which is a fast syntax check
on a machine that has the compiler but no matching card.

The CUDA build links against no CUDA library at all: `libcuda.so.1` is opened
with `dlopen` at startup. So `-Dcuda-path` is needed only to find **nvcc** and
`cuda_runtime.h` for compiling the kernels -- it must point at a directory with
`bin/nvcc` and `include/cuda_runtime.h`. A distro CUDA install already looks
like that; on NixOS the pieces live in separate store paths, so the `cuda` dev
shell joins them into one root and exports it as `$CUDA_PATH`.

The binary itself has no CUDA dependency, runs on a machine with no driver
(reporting so cleanly), and finds the driver at run time -- including in
`/run/opengl-driver/lib`, where NixOS puts it and the default loader path does
not look. See the note on the stub library below for why it is done this way.

## Running

```sh
# train
darknet-zig classifier train my.data cfg/cifar.cfg [weights] [-clear] [-gpu 0]

# top-1 / top-k accuracy over the validation list
darknet-zig classifier valid my.data cfg/cifar.cfg backup/cifar.weights [-gpu 0]

# classify one image
darknet-zig classifier predict cfg/imagenet1k.data cfg/tiny.cfg tiny.weights dog.jpg [-top 5]

# CPU-vs-GPU kernel comparison
darknet-zig gputest -gpu 0

# timed training + inference + accuracy, machine-readable
darknet-zig benchmark my.data cfg/cifar.cfg -train-batches 1000 [-gpu 0]
```

Flags: `-gpu <index>`, `-seed <n>`, `-threads <n>` (loader workers), `-top <k>`,
`-clear`.

The `.data` and `.cfg` files are darknet's, unchanged. A `.data` file for
training looks like this — a class name must appear somewhere in each image's
path, which is how labels are assigned:

```
classes = 2
train   = /data/mine/train.list
valid   = /data/mine/valid.list
labels  = /data/mine/labels.list
names   = /data/mine/labels.list
backup  = /data/mine/backup
top     = 2
```

`labels` is what assigns the class (substring match against the path);
`names` is only displayed, so the two can differ — `bench/prepare.zig` uses
that to write unambiguous labels for datasets whose class names overlap.

For a ready-made comparison across CPU and GPU on MNIST, CIFAR-10 and COCO,
see [`bench/README.md`](bench/README.md):

```sh
./bench/get-data.sh mnist cifar10
./bench/benchmark.sh --platforms cpu,gpu --datasets mnist,cifar10
```

## Trying it on a CPU

Three checks, in increasing order of cost.

### 1. Unit tests (seconds)

```sh
zig build test
```

20 tests. The load-bearing ones are a finite-difference check of the analytic
gradients, a weights round-trip through the binary format, and a small network
learning a separable task.

### 2. Inference against upstream darknet (seconds)

The strongest single check, because it compares the entire forward path --
config parsing, weight loading, all sixteen layers, JPEG decode, letterbox --
against a known-good implementation on a real 1000-class model:

```sh
cd darknet
diff <(./darknet              classifier predict cfg/imagenet1k.data cfg/tiny.cfg tiny.weights data/dog.jpg) \
     <(../zig-out/bin/darknet-zig classifier predict cfg/imagenet1k.data cfg/tiny.cfg tiny.weights data/dog.jpg)
```

Prints nothing when the two agree. A from-scratch training run cannot give you
this: it tells you the network learned *something*, not that it computes the
same thing darknet does.

### 3. Training the tiny.cfg topology (~17 minutes)

`examples/` has a self-contained task: classify a circle against a square,
where position, size, background colour and foreground colour are all
randomised and the validation split is generated from a different seed. Colour
is useless as a cue by construction, so accuracy on the held-out split only
rises if the network has learned shape.

```sh
zig run examples/make_shapes.zig -- /tmp/shapes      # 400 train + 100 valid
zig build -Doptimize=ReleaseFast

./zig-out/bin/darknet-zig classifier train /tmp/shapes/shapes.data examples/tiny-shapes.cfg -seed 1
./zig-out/bin/darknet-zig classifier valid /tmp/shapes/shapes.data examples/tiny-shapes.cfg /tmp/shapes/backup/tiny-shapes.weights
./zig-out/bin/darknet-zig classifier predict /tmp/shapes/shapes.data examples/tiny-shapes.cfg \
    /tmp/shapes/backup/tiny-shapes.weights /tmp/shapes/images/circle/valid_0007.ppm
```

`examples/tiny-shapes.cfg` is tiny.cfg's topology unchanged -- 16 convolutional
layers, 4 maxpools, global average pool, softmax -- at 64x64 with two classes.
Its header lists every value that differs from `cfg/tiny.cfg` and why.

Measured on an 8-core laptop (i7-1185G7), `-Doptimize=ReleaseFast`:

| | |
|---|---|
| 800 batches of 16 | 1008 s |
| training loss | 0.80 -> 0.047 |
| validation, 100 unseen images | **100%** |
| single-image prediction | 99.99% circle / 99.73% square |

Per-batch time is not constant, and not because of anything in the code: a
cold machine does a batch in ~0.4 s, and after a few minutes of all-core load
this laptop throttles to ~1400 MHz and takes ~1.3 s. Four back-to-back 30-batch
runs went 15.2 s, 16.8 s, 17.3 s, 19.4 s. Judge a change by total time from a
comparable thermal state, not by the per-batch figure in the first few lines.

Two things worth watching as it runs. `load` time should drop to `0.000 s`
after the first batch -- that is the image loader fully overlapping the
forward/backward pass. And total CPU time should exceed wall-clock by a good
margin, which is the threaded GEMM working: about 3.4x on 8 cores (42.2 s CPU
against 12.2 s elapsed over 30 batches). Do not expect 8x -- at 64x64 the
per-layer matrices are small, and the loader wants cores too.

The resulting weights load in upstream darknet and give the same prediction,
which is a stronger round-trip than the unit test: this model has fifteen
batch-normalised layers, so the scales and rolling statistics have to be
written in exactly the right order.

### Why 800 batches, when the loss is flat after 150

Because of batch norm, and it is worth understanding before you train anything
real. Accuracy on the held-out split, by checkpoint:

| batches | rolling stats converged | validation top-1 |
|---|---|---|
| 50 | 39% | 50% (chance) |
| 200 | 87% | 74% |
| 400 | 98% | **100%** |
| 800 | 99.97% | **100%** |

Training loss was already 0.065 at batch 232. The gap is entirely the
inference-time normalisation statistics: they are an exponential moving average
with a 1% step starting from zero, so after *n* batches they have covered only
`1 - 0.99^n` of the distance to the true values. Each batch-normalised layer
then divides by an under-estimated standard deviation, and tiny.cfg stacks
fifteen of them, so the error compounds into saturated logits and a constant
prediction.

Stop too early and you get the confusing failure mode of a near-zero training
loss next to exactly chance accuracy -- on the *training* set too, which is how
you tell it apart from overfitting. This is darknet's behaviour, reproduced
here deliberately; the EMA constants are upstream's. `src/smoke_test.zig` pins
it down with a closed-form test.

## Verifying the GPU backend

`gputest` runs every op on both backends over the same random input and prints
the largest absolute and relative difference:

```
$ darknet-zig gputest -gpu 0
axpy                         ok    max abs diff ...  max rel ...
activate leaky               ok    max abs diff ...  max rel ...
add_bias                     ok    max abs diff ...  max rel ...
mean                         ok    max abs diff ...  max rel ...
softmax                      ok    max abs diff ...  max rel ...
im2col                       ok    max abs diff ...  max rel ...
gemm NN                      ok    max abs diff ...  max rel ...
maxpool forward              ok    max abs diff ...  max rel ...
...
27/27 checks passed.
```

It exits non-zero if any check fails.

`gputest` synchronises after every launch, so a kernel that walks off its
buffer is named directly instead of surfacing as an "illegal memory access" at
the next memcpy. Outside `gputest` that costs a stall per launch, so it is off
by default; set `DARKNET_HIP_SYNC=1` to turn it on for a training or prediction
run you are debugging.

Anything above single-precision rounding error means a kernel and its host twin
have diverged. Run this first. After it passes, the next check is to train the
same config on CPU and GPU for a few hundred batches and confirm the loss curves
track each other.

## What is implemented

Layers: `convolutional` (with `groups`, `batch_normalize`), `connected`,
`maxpool`, `avgpool`, `softmax`, `dropout`, `batchnorm`, `cost`, `shortcut`,
`route`. That covers the stock classification configs: `cifar`, `tiny`,
`darknet`, `darknet19`, `alexnet`, `resnet*`, `extraction`, `densenet201`,
`resnext*`.

Also: SGD with momentum and weight decay, Adam, all seven learning-rate
policies, the full augmentation pipeline (random crop/scale/rotate, flip, HSV
distortion), threaded image loading overlapped with training, and darknet's
`.weights` format.

## What is not

Everything outside classification: detection (`yolo`, `region`, `detection`),
segmentation, RNN/LSTM/GRU, and the `local`, `crop`, `reorg`, `upsample`,
`normalization` (LRN) and `l2norm` layers. Also dropped: binary/XNOR
convolutions, hierarchical (tree) softmax, multi-scale `random=1` training, and
multi-GPU. The parser prints a note rather than failing silently when a config
asks for one of the features that has a sensible fallback, and errors on layer
types it does not know.

## Layout

```
src/
  main.zig            CLI
  classifier.zig      train / valid / predict
  network.zig         layer list, forward, backward, update, schedules
  parser.zig          .cfg -> network, .weights load/save
  cfg.zig             the INI-ish config format
  layer.zig           the Layer record and the state a layer may see
  layers/             one file per layer family
  blas.zig            array primitives
  gemm.zig            CPU matrix multiply (threaded)
  im2col.zig          convolution lowering
  activations.zig     activation functions and gradients
  image.zig           decode, resize, crop, colour, augmentation
  data.zig            dataset loading, overlapped with training
  gpu.zig             HIP backend: buffers, kernel registry, op wrappers
  hip/hip.zig         AMD backend: HIP runtime bindings
  cuda/cuda.zig       NVIDIA backend: CUDA driver API bindings
  kernels/*.hip       device kernels -- the only C++ in the project
  c/                  stb_image, the only host C
  smoke_test.zig      end-to-end tests
  benchmark.zig       the `benchmark` subcommand: timed training + inference
examples/
  make_shapes.zig     generates the circle-vs-square dataset
  tiny-shapes.cfg     tiny.cfg's topology, retargeted at that dataset
bench/
  see bench/README.md -- benchmark suite over MNIST, CIFAR-10 and COCO
```

## Notes on the port

**Where the C survives.** Two places, both deliberate. Device kernels must be
compiled by the ROCm clang toolchain, because Zig has no amdgcn backend; they
live in one `.hip` file loaded at runtime through `hipModuleLoad`. And
`stb_image` decodes JPEG/PNG -- vendored rather than rewritten so that decoded
pixels match darknet's bit for bit. The HIP *runtime* API is called directly
from Zig through hand-written `extern fn` declarations; there is no `@cImport`
anywhere.

**No cuBLAS equivalent.** darknet delegated GEMM to cuBLAS. The HIP counterpart
is rocBLAS, a second and much larger ROCm dependency. `gemm_kernel` in the
`.hip` file is a hand-written shared-memory tiled kernel instead: slower than
rocBLAS on large matrices, still far faster than the CPU, and it keeps
`libamdhip64` as the only thing this links. If throughput matters more than the
dependency count, that one function is the thing to replace.

**No curand either.** Dropout masks come from a counter-based hash of the
element index and a host-supplied seed, which needs no device-side generator
state.

**Function pointers became a switch.** darknet stored `forward`/`backward`
pointers in each layer. Here `network.zig` switches on `l.kind`.

**The network is no longer passed by value.** darknet handed each layer a copy
of the whole `network` struct. Layers now get a `State` naming only what they
may touch, which also breaks what would otherwise be an import cycle.

**Randomness is explicit.** darknet used libc `rand()` plus a hidden static in
`rand_normal()`, which is neither reproducible nor safe from the loader threads.
Generators are values here: the main thread owns one, each loader task gets its
own seeded instance, and `-seed` makes a run repeatable.

**One upstream inconsistency was resolved rather than copied.** darknet's
`normalize` divides by `sqrt(v) + 1e-6` on the CPU and `sqrt(v + 1e-5)` on the
GPU. Both backends here use the CPU form, so `gputest` can hold them to the same
standard. The difference is far below single precision either way.

**`[net] flip` is honoured.** Upstream reads a `flip` option (default 1) in the
net section and passes it to the loader, which mirrors each training crop with
probability a half. An early version of this port hardcoded the mirroring, and
it went unnoticed until the benchmark suite trained on MNIST and stalled at 80%
top-1: a mirrored digit is not that digit, so half the training signal was
wrong. Setting `flip=0` in the config now works as it does upstream.

Two darknet quirks *are* reproduced on purpose, because augmentation and weight
layout have to match upstream: `random_augment_args` measures vertical slack
against the output width rather than its height (harmless for the square crops
every classification config uses), and the variance used in batch norm is the
unbiased one while the normalisation that consumes it is the biased form.

## CPU performance notes

Two measured differences from upstream darknet, both worth knowing if you are
comparing the two.

**Inference builds at batch=1.** Every activation buffer is sized
`batch * outputs`, and `[net] batch` in a training config is large -- 128 in
`tiny.cfg`. darknet allocates for that and then calls `set_batch_network(net, 1)`
before predicting, so 127/128 of the allocation is never touched; `calloc`
hands back lazily-zeroed pages and the resident set stays around 73 MB.

This port originally did the same thing but zeroed its buffers eagerly, which
touched all of it: **6.6 GB resident, 1.65 M page faults, 3.1 s of wall clock
before the first pixel was read**. Rather than chase `calloc` semantics through
Zig's allocator interface, `classifier valid` and `classifier predict` now pass
`BuildOptions{ .batch = 1 }` and the buffers are simply never allocated at the
training size. 78 MB resident, 0.15 s wall, and the prediction is unchanged.
Training is untouched -- there every buffer really is used every step.

**The GEMM is threaded, and needs to be.** darknet ships with `OPENMP=0`, so its
`gemm_nn` is single-threaded. Predicting `tiny.cfg` on `dog.jpg`:

| | |
|---|---|
| darknet (`-Ofast`, 1 thread) | ~0.105 s |
| darknet-zig, GEMM threading off | ~0.228 s |
| darknet-zig, threading on | ~0.087 s |

So the 17% win is entirely threading, and it is covering for a scalar GEMM that
is **2.2x slower than the C**. Benchmarked on tiny.cfg's actual shapes, gcc's
`gemm_nn` sustains 17-25 GFLOP/s while this one manages 4-5. The assembly says
why: gcc emits packed SSE, LLVM emits `vfmadd213ss` -- scalar FMA. It unrolls
the inner loop but will not vectorize it, because it cannot prove the output
row and the input row do not overlap and will not hoist a runtime alias check
out of the enclosing `k` loop. Marking the innermost pointers `noalias` does
make LLVM emit packed FMAs, but measured no faster, so vectorization alone is
not the whole story and the honest fix is a blocked GEMM that reuses each `B`
row across several `C` rows. Not attempted; the GPU backend is the answer to
throughput here, and on the CPU the thread pool hides most of it.

## Why NVIDIA goes through the CUDA driver API, not HIP

HIP does target NVIDIA, but not in a way this project can use.

On AMD, `hipMalloc` is a real symbol exported from `libamdhip64.so`, which is
what lets Zig call it with an `extern fn` and keep the host side entirely in
Zig. On NVIDIA, HIP is header-only: `hip/nvidia_detail/` defines `hipMalloc` as
an inline wrapper around `cudaMalloc`, so the symbol exists only inside a
translation unit compiled by hipcc. There is no `libhip-nvidia.so` to link
against. Using HIP here would mean compiling the host code as C++, which is the
one thing the port set out to avoid.

The CUDA *driver* API (`libcuda.so`, shipped with every NVIDIA driver) is a
real C library and turned out to be a near drop-in replacement, because this
port never used the `<<<>>>` launch syntax. Kernels already lived in a
separately compiled code object, looked up by name and launched by handle --
which is HIP's module API, and is also, almost line for line, the driver API:

| HIP | CUDA driver |
|---|---|
| `hipModuleLoad` | `cuModuleLoad` |
| `hipModuleGetFunction` | `cuModuleGetFunction` |
| `hipModuleLaunchKernel` | `cuLaunchKernel` |
| `hipMalloc` | `cuMemAlloc_v2` |
| `hipMemcpy` | `cuMemcpyHtoD_v2` / `cuMemcpyDtoH_v2` |
| `hipSetDevice` | `cuDevicePrimaryCtxRetain` + `cuCtxSetCurrent` |

The CUDA *runtime* API would not have worked: `cudaLaunchKernel` resolves
kernels through fatbin registration that nvcc emits into host code, and there
is no host code here for it to emit into.

Three differences were worth handling rather than papering over:

- **`CUdeviceptr` is an integer**, not a pointer. It is pointer-width, so the
  value round-trips through `?*anyopaque` and the 36 op wrappers stay
  pointer-typed. It also means `&buf.ptr` is still the right thing to hand to
  `cuLaunchKernel` for a `float*` parameter: eight bytes holding the address.
- **The `_v2` suffixes are mandatory.** CUDA's headers `#define cuMemAlloc
  cuMemAlloc_v2`, so the unsuffixed names are not what `libcuda` exports. A
  wrong name here is a link error rather than a runtime surprise, which is
  exactly why linking against the stub is a useful check.
- **`cuInit(0)` must come first.** The runtime API initialises lazily; the
  driver API does not.

The kernels needed one conditional include and nothing else -- `__global__`,
`__shared__`, `__syncthreads`, the block and thread builtins and the float math
functions are spelled identically in both. `nvcc -ptx` emits all 36 entry
points, the same set `hipcc --genco` produces.

PTX rather than a cubin, so the driver JIT-compiles on load and one artifact
runs on any architecture at or above `-Dcuda-arch`. That is strictly nicer than
the AMD side, where `--offload-arch` has to name every ISA up front.

### The PTX JIT trap

Loading PTX makes the driver `dlopen` `libnvidia-ptxjitcompiler.so.1` by bare
soname. That file ships with the driver, but it is missing from some container
images, and on systems where libcuda lives off the default loader path
(NixOS's `/run/opengl-driver/lib`, partially bind-mounted containers) the
second lookup fails even with the file sitting next to libcuda. `cuModuleLoad`
then returns `CUDA_ERROR_JIT_COMPILER_NOT_FOUND`.

Two mitigations, in order:

1. The backend preloads the JIT compiler itself, looking first beside
   whichever libcuda actually loaded, so the driver's own `dlopen` finds it
   already resident. Best effort and silent when it fails.
2. If the library genuinely is not on the machine, skip the JIT entirely by
   building a cubin for your exact GPU:

   ```sh
   nvidia-smi --query-gpu=compute_cap --format=csv,noheader   # e.g. 8.6
   zig build -Doptimize=ReleaseFast -Dgpu=true -Dgpu-backend=cuda \\
             -Dcuda-path=$CUDA_PATH -Dcuda-arch=sm_86
   ```

   A `sm_XX` value for `-Dcuda-arch` emits `darknet_kernels.cubin` (real SASS,
   loaded directly) instead of `darknet_kernels.ptx`. It only runs on that
   architecture, which is exactly the trade PTX exists to avoid -- but it
   needs nothing from the driver beyond the loader.

### The stub library trap

`libcuda.so` exists in two forms, with the same soname:

- the **driver's**, installed with the NVIDIA kernel driver -- the real thing;
- a **stub** shipped in the CUDA toolkit's `lib/stubs`, which exists only so
  programs can be linked on machines without a driver. Its entry points
  resolve, and do nothing.

Link against the stub in the ordinary way and Zig writes that directory into
the binary's `RUNPATH`, so at run time the loader finds the stub *before* the
driver. Every call then fails, and unhelpfully: the stub cannot describe its
own errors either, so `cuGetErrorString` returns nothing and you get

```
CUDA: initialising the driver failed: unknown CUDA error
```

The actual code is `CUresult 34`, `CUDA_ERROR_STUB_LIBRARY` -- "the CUDA driver
that the application has loaded is a stub library". Which says precisely what
is wrong, if you can get at it.

This backend sidesteps the whole thing by not linking `libcuda` at all and
`dlopen`ing the driver, trying the loader path first and then the places
distributions hide it. Two smaller benefits fall out: the CUDA toolkit becomes
a build-time-only dependency, and the binary starts (and explains itself) on a
machine with no driver rather than failing to load.

`cuGetErrorString` is still used for error text, but when it fails there is now
a fallback table naming the codes worth recognising before a working driver is
established -- 34 above, plus `CUDA_ERROR_NO_DEVICE`,
`CUDA_ERROR_UNSUPPORTED_PTX_VERSION` (driver older than the PTX; lower
`-Dcuda-arch`) and `CUDA_ERROR_INVALID_PTX`.
