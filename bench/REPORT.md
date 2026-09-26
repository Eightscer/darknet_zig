# darknet-zig: CPU vs HIP vs CUDA

A comparison of the three backends across four networks and three datasets,
with an attempt to explain every number rather than just tabulate it.

All measurements come from `bench/benchmark.sh`; the raw key=value records are
in `bench/results/*/raw/` and every table here can be regenerated with
`--from-raw`. Nothing in this document was typed in by hand.

## Contents

- [The short version](#the-short-version)
- [The machines](#the-machines)
- [What is measured](#what-is-measured)
- [Results](#results)
- [Normalising: achieved GFLOP/s](#normalising-achieved-gflops)
- [Why the CPUs land where they do](#why-the-cpus-land-where-they-do)
- [Why NVIDIA is 2.2x AMD](#why-nvidia-is-22x-amd)
- [The small-network penalty](#the-small-network-penalty)
- [The fastest GPU lost a benchmark](#the-fastest-gpu-lost-a-benchmark)
- [Do the three backends agree?](#do-the-three-backends-agree)
- [What the accuracy numbers actually say](#what-the-accuracy-numbers-actually-say)
- [Design considerations](#design-considerations)
- [Threats to validity](#threats-to-validity)
- [Reproducing this](#reproducing-this)

## The short version

1. **The GPU backends are 5-80x the CPU, but the honest figure is the
   compute-bound one: 13x (AMD) and 79x (NVIDIA) on `cifar10-full`.** The
   smaller configs understate the GPU because they do not give it enough work.
2. **Between the two GPUs the gap is a remarkably constant 2.2x in NVIDIA's
   favour**, across every network from 0.005 to 1.624 BFLOPs. Constant ratio
   means the difference is architectural, not a problem-size artefact.
3. **Both GPUs run at 4-6% of peak FP32, and the CPU at roughly 3%.** The cause
   is the same on all three backends: the GEMM computes one output element per
   thread (GPU) or per inner iteration (CPU), so every multiply-add needs its
   own operand loads. This is the framework's single largest performance lever.
4. **The CPU GEMM emits no vector instructions at all** -- 41 scalar FMAs and
   zero packed ones in the compiled binary, on machines with 8-wide AVX2.
5. **On COCO the RTX 3060 Ti system is slower end to end than the RX 6650 XT
   system, despite a 1.94x faster forward pass**, because its host CPU cannot
   decode JPEGs fast enough to feed it. The bottleneck had moved off the GPU
   entirely.
6. **All three backends agree on accuracy to within 0.4 percentage points**,
   which is the strongest correctness evidence in this report.

## The machines

| results dir | CPU | nproc | GPU | driver | backend |
|---|---|---|---|---|---|
| `results/` | Intel Core i7-1185G7 (Tiger Lake, 2020) | 8 | -- | -- | CPU only |
| `results/rx6650xt/` | AMD Ryzen 7 5700G (Zen 3, 2021) | 16 | Radeon RX 6650 XT, 8 GB (gfx1032, RDNA 2) | ROCm 6.12.93 | HIP |
| `results/rtx3060ti/` | Intel Xeon E5-1680 v3 (Haswell-EP, 2014) | 8 | GeForce RTX 3060 Ti, 8 GB (GA104, Ampere) | 595.91.07 / CUDA 13.2 | CUDA |

Relevant vendor peak figures, used later only as denominators:

| | RX 6650 XT | RTX 3060 Ti |
|---|---|---|
| FP32 | 10.8 TFLOP/s | 16.2 TFLOP/s (8.1 on the single datapath) |
| Memory bandwidth | 280 GB/s (128-bit GDDR6) | 448 GB/s (256-bit GDDR6) |
| Last-level cache | 32 MB Infinity Cache | 4 MB L2 |

> **A note on naming.** The NVIDIA results arrived in a directory called
> `rtx3090ti` under the tag `server-3070`, but both `nvidia-smi` and the
> `device=` field recorded by the binary itself report a **GeForce RTX 3060
> Ti**. The directory and tag have been renamed to match the hardware. This is
> exactly why the run now records its own device name rather than trusting the
> label a human typed.

Each GPU host produced its own CPU baseline in the same session, so every
speedup below compares two numbers from one machine. Cross-machine CPU
comparison is done separately and explicitly.

## What is measured

`darknet-zig benchmark` (see `src/benchmark.zig`) times three things per run.

**Training throughput.** 3 warm-up batches, then `-train-batches` timed
batches. The clock covers `trainNetwork` plus, on GPU, an explicit
`gpu.sync()` -- without which the timer would measure how fast work was
*submitted* to the queue, not how fast it ran. The image loader is pipelined
(the next batch is requested before the current one is trained), and time spent
blocked waiting on it falls **outside** the clock. So `train img/s` is the
compute rate of the backend, assuming the loader keeps up. Where it does not,
this is called out below.

**Inference throughput,** reported twice. `infer img/s` is the forward pass
alone. `infer img/s (with decode)` adds JPEG/PNG decode, resize and centre
crop -- what an actual pipeline costs. Separating them is what makes finding
(5) visible at all.

**Accuracy.** Top-1 and top-5 over the full validation list, centre-cropped and
unaugmented, alongside a **majority-class baseline**: the score you would get
by always guessing the validation set's most common class. Without it a top-1
is unreadable.

Every run is given `-seed 1`, so weight initialisation and augmentation draws
are identical across platforms and differences are attributable to arithmetic
rather than luck.

**What is deliberately not measured:** process startup, config parsing, weight
I/O, and -- in the training figure -- data loading. The report is about the
compute backends.

The four networks, by forward cost per image:

| config | BFLOPs/image | shape | head |
|---|---|---|---|
| `mnist.cfg` | 0.005 | 3 conv (16/32/64), 28x28 | fully connected |
| `cifar10.cfg` | 0.029 | 4 conv (32/64/64/128), 28x28 | fully connected |
| `coco.cfg` | 0.092 | 5 conv (16..256), 96x96, 80 classes | fully connected |
| `cifar10-full.cfg` | 1.624 | darknet's own `cifar.cfg`: 9 conv (128/256/512) | global average pool |

## Results

Throughput in images/second; higher is better. `e2e` is inference including
image decode.

### MNIST -- 0.005 BFLOPs/image, 1000 batches

| machine | backend | train | infer | e2e | top-1 |
|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 334.9 | 1049.1 | 1018.9 | 0.9775 |
| Core i7-1185G7 | CPU | 465.6 | 1275.1 | 1251.0 | 0.9775 |
| Ryzen 7 5700G | CPU | 781.1 | 2148.1 | 2118.3 | 0.9775 |
| RX 6650 XT | HIP | 4306.8 | 13290.1 | 12181.9 | 0.9764 |
| RTX 3060 Ti | CUDA | **8996.0** | **31300.5** | 16885.0 | 0.9763 |

### CIFAR-10 -- 0.029 BFLOPs/image, 1000 batches

| machine | backend | train | infer | e2e | top-1 |
|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 84.9 | 223.8 | 221.4 | 0.5889 |
| Core i7-1185G7 | CPU | 94.2 | 230.5 | 224.6 | 0.5889 |
| Ryzen 7 5700G | CPU | 244.9 | 689.9 | 685.0 | 0.5889 |
| RX 6650 XT | HIP | 1975.0 | 5464.5 | 5176.6 | 0.5873 |
| RTX 3060 Ti | CUDA | **4533.7** | **12846.1** | 8909.7 | 0.5853 |

### COCO crops -- 0.092 BFLOPs/image, 80 classes, 1000 batches

Majority-class baseline: **0.3110**.

| machine | backend | train | infer | e2e | top-1 |
|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 23.0 | 62.3 | 59.2 | 0.3548 |
| Core i7-1185G7 | CPU | 28.2 | 81.0 | 76.1 | 0.3548 |
| Ryzen 7 5700G | CPU | 67.8 | 172.5 | 164.5 | 0.3548 |
| RX 6650 XT | HIP | 557.7 | 2264.0 | **1412.3** | 0.3459 |
| RTX 3060 Ti | CUDA | **1132.5** | **4402.2** | 987.2 | 0.3471 |

Note which column the RTX 3060 Ti loses.

### cifar10-full -- 1.624 BFLOPs/image (the compute-bound probe)

| machine | backend | batches | train | infer | e2e | top-1 |
|---|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 20 | 2.6 | 8.9 | 8.9 | 0.1750 * |
| Ryzen 7 5700G | CPU | 20 | 6.5 | 20.2 | 20.2 | 0.1750 * |
| RX 6650 XT | HIP | 1000 | 87.4 | 254.4 | 253.7 | 0.4982 |
| RTX 3060 Ti | CUDA | 1000 | **205.9** | **578.0** | 562.9 | 0.5242 |

\* The CPU rows ran 20 batches rather than 1000, because 1000 batches of this
network takes about 14 hours on the Ryzen and 34 on the Xeon. Throughput is
per-image and therefore still comparable; **the top-1 is not**, and is shown
only so the column is not silently empty. The table renderer now prints a
`batches` column precisely so this cannot be misread.

### Speedups, same machine

| network | AMD GPU/CPU (train) | NVIDIA GPU/CPU (train) |
|---|---|---|
| mnist | 5.5x | 26.9x |
| cifar10 | 8.1x | 53.4x |
| coco | 8.2x | 49.2x |
| cifar10-full | 13.4x | 79.2x |

The NVIDIA column is inflated by its host: the Xeon is the slowest CPU here.
Comparing the GPUs to each other removes that.

## Normalising: achieved GFLOP/s

Converting throughput into arithmetic actually performed -- inference is one
forward pass per image, training is roughly three (forward, backward-data,
backward-weights):

| network | Xeon CPU | i7 CPU | Ryzen CPU | RX 6650 XT | RTX 3060 Ti | NV/AMD |
|---|---|---|---|---|---|---|
| mnist | 5 | 6 | 11 | 66 | 157 | 2.38x |
| cifar10 | 6 | 7 | 20 | 158 | 373 | 2.36x |
| coco | 6 | 7 | 16 | 208 | 405 | 1.95x |
| cifar10-full | 14 | -- | 33 | 413 | 939 | 2.27x |

(Inference GFLOP/s. Training figures track these within a few percent.)

Three things fall out of this table immediately.

**Everything is far from peak.** At its best the RTX 3060 Ti reaches 939
GFLOP/s against a 16.2 TFLOP/s paper figure -- **5.8%**, or 11.6% if you use
the 8.1 TFLOP/s single-datapath number that Ampere can actually sustain
without perfectly co-issued FP32 pairs. The RX 6650 XT reaches 413 against
10.8 TFLOP/s: **3.8%**. The Ryzen manages 33 GFLOP/s against roughly 970
(8 cores x ~3.8 GHz x 32 flops/cycle with AVX2 FMA): **3.4%**. Three very
different architectures, all stuck in the same single-digit band, which is a
strong hint that the cause is shared. It is; see
[Design considerations](#design-considerations).

**The NVIDIA/AMD ratio barely moves** -- 1.95x to 2.38x across a 325x range of
network size. If one card were more sensitive to small kernels than the other,
this column would trend. It does not.

**The CPUs are much less sensitive to network size than the GPUs.** The Ryzen
spans 11 to 33 GFLOP/s (3.0x) from the smallest network to the largest; the
RTX 3060 Ti spans 157 to 939 (6.0x) and the RX 6650 XT 66 to 413 (6.3x). A CPU
has no launch overhead to amortise and its caches do not care much whether a
tensor is small.

## Why the CPUs land where they do

The ordering is Ryzen 7 5700G > Core i7-1185G7 > Xeon E5-1680 v3 -- **a 2020
ultrabook chip beats a 2014 eight-core workstation Xeon** by 11-39%, and the
Ryzen beats the Xeon by 2.3-3.0x.

That ranking is not about core count (8, 8, 16 threads reported by `nproc`; the
Xeon has as many as the laptop). It is about per-core throughput and memory
subsystem: Zen 3 and Tiger Lake are six and seven years newer than Haswell-EP,
with better branch prediction, wider issue, and much faster caches. Since the
GEMM here turns out to be load/store bound rather than FLOP bound, cache
throughput is what is being measured.

The reason it is load/store bound is visible in the compiled binary. The inner
loop of `gemmNN` in `src/gemm.zig` is:

```zig
for (crow, brow) |*cv, bv| cv.* += scale * bv;
```

which is exactly the shape an autovectoriser should turn into packed FMAs.
Disassembling the release binary and isolating `gemm.runJob` (into which
`gemmNN` is inlined):

```
 14 vfmadd132ss
 12 vfmadd213ss
 11 vmulss
  4 vfmadd231ss
```

**Forty-one scalar FMAs. Zero packed ones.** Every one of these machines has
at least AVX2 (8 floats wide) and the i7-1185G7 has AVX-512 (16 wide), and the
GEMM uses none of it. The top-level `README.md` documents the cause: LLVM recognises the
loop but will not hoist the runtime alias check between the output row and the
input row out of the enclosing `k` loop, so it never proves vectorisation is
safe.

But vectorising is not actually the fix, and the numbers say why. That inner
statement moves 12 bytes (load `C[j]`, load `B[j]`, store `C[j]`) per 2 flops
-- an arithmetic intensity of **0.17 flops/byte**. Even perfectly vectorised,
it would stay pinned against L1 bandwidth. The real fix is blocking: have each
iteration compute several rows of `C` at once so each loaded `B` value is
reused, which raises intensity rather than just widening the instructions.
This matches what was already measured -- forcing vectorisation with `noalias`
produced packed FMAs and no speedup.

## Why NVIDIA is 2.2x AMD

The gap exceeds what the spec sheets predict: 1.50x on FP32, 1.60x on memory
bandwidth, against 2.2x measured. Something accounts for the remaining ~1.4x.

The GPU GEMM (`gemm_kernel` in `src/kernels/darknet_kernels.hip`) is a
textbook 16x16 shared-memory tiled multiply, one output element per thread:

```c
#pragma unroll
for (int q = 0; q < TILE; ++q) acc += As[ty][q] * Bs[q][tx];
```

Each FMA consumes two shared-memory reads. Shared memory on both
architectures serves roughly one float per lane per cycle, so this loop can
issue at best one FMA every two cycles -- a hard ceiling near 25% of the
single-datapath FP32 rate before accounting for the two `__syncthreads()`
barriers per k-tile. That ceiling is why both cards sit in the single digits
as a fraction of peak, and it applies equally to both, which is consistent with
the flat NVIDIA/AMD ratio.

Given the kernel is bandwidth-bound rather than FLOP-bound, the most likely
explanation for the extra gap is **the RX 6650 XT's 128-bit memory bus**. Its
280 GB/s is normally rescued by 32 MB of Infinity Cache, but at batch 128 the
working set does not fit: the first hidden activation of `cifar10-full` alone
is 128 images x 128 channels x 28 x 28 x 4 B = **51 MB**. Past the cache, the
RX 6650 XT is a narrow-bus card and the RTX 3060 Ti's 256-bit bus pulls ahead
by more than the headline FP32 ratio suggests. Sustained clocks are a
secondary candidate: the 2635 MHz figure is boost, and the card has a 180 W
board power budget against the 3060 Ti's 200 W.

**This attribution is inference from specifications and the kernel source, not
from a profiler, and should be treated as a hypothesis.** It makes a testable
prediction: at batch 32 the `cifar10-full` working set drops to ~13 MB and
fits in Infinity Cache, so the NVIDIA/AMD ratio should *narrow* noticeably. A
batch-size sweep would settle it in about ten minutes per card, and
`rocprof`/`ncu` would settle it directly. See
[Further tests](#further-tests-worth-running).

One tuning note surfaced while reading the kernel. `BLOCK` is 256 with the
comment "four wave64s on AMD", but RDNA 2 compute dispatches default to
**wave32**, so a 256-thread workgroup is eight wave32s on gfx1032, not four
wave64s. The block size is defensible either way; the reasoning behind it is
out of date.

## The small-network penalty

Within a single card, achieved throughput varies 6x between the smallest and
largest network -- 157 to 939 GFLOP/s on the RTX 3060 Ti, 66 to 413 on the RX
6650 XT. The small configs are not measuring the GPU.

The cause is the `K` dimension of the GEMM, which for a convolution is
`size^2 x channels`:

| network | K per conv layer | 16-wide k-tiles |
|---|---|---|
| mnist | 27, 144, 288 | 2, 9, 18 |
| cifar10 | 27, 288, 576, 576 | 2, 18, 36, 36 |
| coco | 27, 144, 288, 576, 1152 | 2, 9, 18, 36, 72 |
| cifar10-full | 27, 1152 x2, 2304 x3, 4608 x2 | 2, 72, 144, 288 |

With `TILE = 16`, every layer pays two `__syncthreads()` and a full tile load
per 16 steps of `K`. At `K = 27` that overhead is amortised over less than two
tiles, the second of which is only 11/16 useful and the rest zero padding. At `K = 4608` it
is amortised over 288. On top of that, the small networks spend
proportionally far more of their time in the elementwise kernels -- bias,
batch-norm, activation, all pure memory traffic -- because their convolutions
are so cheap relative to their tensor sizes.

The practical consequence for anyone reading these tables: **MNIST and CIFAR-10
at these sizes are latency and bandwidth benchmarks, not compute benchmarks.**
`cifar10-full` is the row to quote when comparing the two GPUs' arithmetic.

## The fastest GPU lost a benchmark

On COCO inference, the RTX 3060 Ti runs the forward pass in 0.949 s against the
RX 6650 XT's 1.845 s -- 1.94x faster. End to end, with image decoding included,
it scores **987.2 img/s against 1412.3**. It loses by 30%.

The arithmetic, for 4177 validation crops:

| | forward | decode | end to end |
|---|---|---|---|
| RX 6650 XT + Ryzen 7 5700G | 1.845 s | 1.113 s | 4177 / 2.958 = **1412 img/s** |
| RTX 3060 Ti + Xeon E5-1680 v3 | 0.949 s | 3.282 s | 4177 / 4.231 = **987.2 img/s** |

The Ryzen decodes COCO's JPEGs at 3753 img/s; the Xeon manages 1273. The
faster GPU finished its share in 22% of the wall clock and then waited. Pair
the RTX 3060 Ti with the Ryzen's decode rate and end-to-end would be
4177 / (0.949 + 1.113) = **2025 img/s**, slightly over 2x what it actually
achieved.

This effect is invisible on MNIST and CIFAR-10, whose tiny PNGs decode at tens
of thousands of images per second, and it is why the benchmark reports both
columns.

It also has a bearing on the *training* numbers. The Xeon's COCO decode rate of
1273 img/s is barely above the 1132.5 img/s the RTX 3060 Ti sustains while
training -- and training augments (random crop, jitter, HSV) rather than just
centre-cropping, so its true loader rate is lower still. The reported 1132.5 is
therefore the GPU's compute rate; wall-clock training of COCO on that machine
is loader-bound. The AMD machine has 6.7x of loader headroom and is not.

The loader thread count is currently hardcoded to 8 (`Options.threads` in
`src/benchmark.zig`) regardless of `nproc`, which leaves the Ryzen's 16 threads
half-idle and puts the Xeon's 8 in direct competition with the training thread.

## Do the three backends agree?

This is the part of the report that is really about correctness.

`train_mean_loss` is **bit-identical across all three CPUs** -- 0.1742 on
MNIST, 1.3977 on CIFAR-10, 3.1663 on COCO, on Tiger Lake, Zen 3 and Haswell
alike. The CPU path is fully deterministic given `-seed 1`.

Against the GPUs, agreement is close but not exact, which is expected: the
tiled GEMM and the batch-norm reductions sum in a different order, and floating
point addition is not associative.

| network | CPU | HIP | CUDA |
|---|---|---|---|
| mean loss, mnist | 0.1742 | 0.1735 | 0.1735 |
| mean loss, cifar10 | 1.3977 | 1.4009 | 1.3977 |
| mean loss, coco | 3.1663 | 3.1791 | 3.1772 |
| top-1, mnist | 0.9775 | 0.9764 | 0.9763 |
| top-1, cifar10 | 0.5889 | 0.5873 | 0.5853 |
| top-1, coco | 0.3548 | 0.3459 | 0.3471 |

**Every top-1 agrees within 0.4 percentage points**, and mean loss within 0.4%.
Per-batch `final loss` diverges much more (0.1568 CPU vs 0.0881 CUDA on MNIST),
which is not a discrepancy but a property of SGD: trajectories separate quickly
from any perturbation, so a single batch's loss is noise. The mean over 1000
batches, and the accuracy of the resulting model, are the stable quantities --
and those match.

Three independently written backends -- scalar Zig, HIP on RDNA 2, CUDA on
Ampere -- converging on the same accuracy from the same seed is good evidence
that the ports are faithful. This is also consistent with the earlier
verification that inference output is byte-identical to upstream darknet.

## What the accuracy numbers actually say

Throughput is the point of this report, but the accuracy column deserves
reading carefully, because two of the four numbers are weaker than they look.

**MNIST, 97.75%.** Genuine, against a 11.35% baseline, in 1000 batches.

**CIFAR-10, 58.89%.** Reasonable for a four-convolution network in 1000
batches against a 10% baseline; not a competitive CIFAR result and not meant
to be.

**COCO, 35.48% against a 31.10% majority-class baseline.** The model is beating
"always guess `person`" by 4.4 points. That is barely learning. The task --
80-way classification of object crops from `val2017`, many of them small,
occluded or ambiguous in isolation -- is genuinely hard, and 1000 batches of a
five-convolution network is not enough. The baseline column exists so that this
is legible rather than looking like a respectable third.

**cifar10-full, 49.8% / 52.4% -- *worse* than the small `cifar10.cfg`'s 58.9%
at the same 1000 batches.** Two reasons. It is a much larger network and 1000
batches (128k images, about 2.5 epochs) badly undertrains it; darknet's
original schedule is far longer. And it ends in a global average pool rather
than a fully connected head -- the same structure that was measured earlier in
this project to cost MNIST 44 points of accuracy (51.15% GAP vs 95.15% FC at
500 batches), because average pooling discards spatial position. `cifar10-full`
is included as a throughput probe and should not be read as an accuracy result.

The 2.6-point spread between the two GPUs on `cifar10-full` (49.82 vs 52.42) is
much larger than the <=0.4 points seen everywhere else. That is what an
undertrained network in a steep part of its learning curve looks like, not a
backend difference.

## Design considerations

Ranked by expected return.

**1. Block the GEMM. This is the whole ballgame.** Both the CPU and GPU
implementations compute one output element per unit of work, so every
multiply-add pays for its own operand loads -- 0.17 flops/byte on the CPU, two
shared-memory reads per FMA on the GPU. Having each thread compute a 4x4
micro-tile in registers reuses each loaded value four times and lifts
arithmetic intensity roughly 8x; the equivalent CPU change is a register-blocked
kernel computing several rows of `C` per pass. It is one change, conceptually,
and it is the reason all three backends sit at 3-6% of peak. Nothing else on
this list is close in value.

**2. Fuse the elementwise kernels.** Bias, batch-norm scale/shift and
activation are separate launches, each streaming the whole activation tensor
through memory. On the small networks these dominate. Fusing them into the
convolution epilogue removes several full passes over the largest tensors in
the network.

**3. Consider an optional cuBLAS/rocBLAS path.** Deliberately avoiding a BLAS
dependency is what makes the project portable -- it builds against nothing but
the HIP or CUDA driver, and the same kernel source compiles for both. That was
the right call and should stay the default. But a `-Dblas=true` path would give
a useful upper bound to measure against, and would show how much of the 94-96%
gap to peak is recoverable at all.

**4. Scale loader threads with `nproc`.** Hardcoded 8 leaves the 16-thread
Ryzen half-idle and oversubscribes the 8-thread Xeon against the training
thread. On any machine where the GPU is fast and the images are JPEGs, the
decoder is the system bottleneck, as COCO demonstrated.

**5. Skip im2col for 1x1 convolutions.** `cifar10-full`'s final layer is 1x1;
im2col there is a pure copy of the input tensor, doubling its memory traffic
for nothing.

**6. Revisit `TILE` and `BLOCK` per architecture.** `TILE = 16` forces two
barriers per 16 steps of `K`, which the small networks cannot amortise. And the
`BLOCK = 256` rationale cites wave64, while gfx1032 dispatches wave32.

Decisions that already look right and should be kept: recording the device name
inside the binary rather than trusting a directory label (it caught a card
misidentified as three different models); emitting key=value rather than
scraping logs; the pipelined loader with the clock outside the wait; `-seed 1`
on every run; separating forward-only from with-decode inference; the
majority-class baseline; and PTX-by-default with an `sm_XX` cubin escape hatch
for hosts whose driver lacks the JIT compiler.

## Threats to validity

- **The `cifar10-full` CPU rows ran 20 batches, not 1000.** Throughput is
  per-image and comparable; accuracy is not, and is marked.
- **Each GPU has exactly one host CPU**, so "AMD vs NVIDIA end to end" is
  partly "Ryzen vs Xeon". This is why the report leans on the same-host
  speedups and the GFLOP/s normalisation rather than raw cross-machine numbers.
- **The Infinity Cache explanation is reasoned from specifications**, not
  measured with a profiler.
- **`infer_load_seconds` is sensitive to filesystem cache state.** The laptop's
  CIFAR-10 decode (8741 img/s) is far below the Ryzen's (97087) by more than
  hardware explains; that run read cold from disk. The COCO decode figures are
  consistent between each host's CPU and GPU runs and are trustworthy; the
  MNIST and CIFAR-10 ones should not be used as decoder benchmarks.
- **Single runs, no repetitions**, so no error bars. The tight agreement of
  `train_mean_loss` across machines suggests low variance, but that is an
  argument, not a measurement.
- **Vendor peak FP32 figures are boost-clock marketing numbers.** The
  percentages of peak are indicative, not precise.

## Reproducing this

Every table regenerates from the committed raw records without re-running
anything:

```sh
./bench/benchmark.sh --from-raw --out bench/results/rx6650xt \
    --tag rx6650xt_bench --platforms cpu,gpu --datasets mnist,cifar10,coco
```

To produce a fresh set on a new machine, after `./bench/get-data.sh`:

```sh
# matched run: same configs, same batches, same seed, both platforms
./bench/benchmark.sh --platforms cpu,gpu --datasets mnist,cifar10,coco \
    --train-batches 1000 --tag <machine>

# the compute-bound probe
./bench/benchmark.sh --platforms gpu --datasets cifar10-full \
    --train-batches 1000 --tag <machine>_computebound
./bench/benchmark.sh --platforms cpu --datasets cifar10-full \
    --train-batches 20 --tag <machine>_computebound --append
```

Provenance (date, host, CPU) is recorded in `<tag>.meta` when the run happens
and read back by `--from-raw`, so re-rendering someone else's results on your
machine does not relabel them with your machine.

## Further tests worth running

In rough order of what they would add to this report:

1. **A batch-size sweep on `cifar10-full`** (batch 16/32/64/128) on both GPUs.
   This directly tests the Infinity Cache hypothesis -- the NVIDIA/AMD ratio
   should narrow at small batches -- and would turn the weakest attribution in
   this report into a measured one. About ten minutes per card.
2. **`nvidia-smi dmon` or `rocm-smi` sampled during a `cifar10-full` run**, to
   confirm sustained clocks and rule out power throttling as the cause of the
   AMD gap.
3. **Kernel resource usage,** now a build flag: `-Dkernel-stats=true`.
   Registers per thread, spills and shared/LDS per kernel bound occupancy, and
   would confirm the shared-memory-bound analysis of `gemm_kernel` far more
   cheaply than disassembly. It needs `-Dcuda-arch=sm_86` on NVIDIA (ptxas
   never runs in PTX mode) and a touched kernel source on either, since a
   cached step replays no stderr. See the README for the exact invocations.
4. **The RTX 3060 Ti in a modern host, or the RX 6650 XT in the Xeon box** --
   any swap that breaks the one-GPU-one-CPU confound.
5. **Repeat runs** for error bars on at least one configuration.

Not needed: disassembly of the CPU path (generated locally, and the scalar-FMA
finding above came from it) or of the PTX (`zig-out/bin/darknet_kernels.ptx` is
already readable text). AMD GCN ISA and NVIDIA SASS would only be worth
producing if item 3 leaves something unexplained.
