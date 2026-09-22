# darknet-zig

A rewrite of [pjreddie's darknet](https://github.com/pjreddie/darknet) from C to
Zig, scoped to **training and running image classifiers**, with an AMD **HIP**
backend in place of darknet's CUDA one.

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

The CPU path is verified end to end: it trains, the loss falls, checkpoints
round-trip through darknet, and it reproduces upstream's inference numerically.

**The HIP path is newly exercised and not yet trusted.** It was developed on a
machine with no AMD card. The first real run found a genuine kernel bug (a
dropped divide in `add_bias_kernel`/`scale_bias_kernel`, since fixed) and there
may be more. **Run `darknet-zig gputest -gpu 0` before anything else** -- it
compares every op against its CPU twin and would have caught that one in
seconds, whereas going straight to `predict` produced an illegal memory access
blamed on an unrelated memcpy.

## Building

```sh
nix develop                        # or bring your own Zig 0.16 + ROCm

# CPU only -- no ROCm needed
zig build -Doptimize=ReleaseFast

# With the HIP backend
rocminfo | grep gfx                # find your GPU's ISA, e.g. gfx1030
zig build -Doptimize=ReleaseFast -Dgpu=true \
          -Drocm-path=$ROCM_PATH -Doffload-arch=gfx1030
```

`-Doffload-arch` takes a comma-separated list (`gfx1030,gfx1100`), which bundles
several ISAs into one code object -- useful when the build machine and the GPU
machine differ.

Two artifacts land in `zig-out/bin`: the `darknet-zig` executable and
`darknet_kernels.hsaco`, the compiled device code. The executable looks for the
code object next to itself; `DARKNET_HSACO=/path/to/darknet_kernels.hsaco`
overrides that.

`zig build kernels` compiles only the device code, which is a fast syntax check
on a machine with `hipcc` but no GPU.

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

## Trying it on a CPU

Three checks, in increasing order of cost.

### 1. Unit tests (seconds)

```sh
zig build test
```

19 tests. The load-bearing ones are a finite-difference check of the analytic
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
  hip/hip.zig         HIP runtime bindings
  kernels/*.hip       device kernels -- the only C++ in the project
  c/                  stb_image, the only host C
  smoke_test.zig      end-to-end tests
examples/
  make_shapes.zig     generates the circle-vs-square dataset
  tiny-shapes.cfg     tiny.cfg's topology, retargeted at that dataset
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
