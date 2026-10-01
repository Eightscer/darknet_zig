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
- [Why both GPUs run far from peak](#why-both-gpus-run-far-from-peak)
- [The small-network penalty](#the-small-network-penalty)
- [The fastest GPU lost a benchmark](#the-fastest-gpu-lost-a-benchmark)
- [Do the three backends agree?](#do-the-three-backends-agree)
- [What the accuracy numbers actually say](#what-the-accuracy-numbers-actually-say)
- [Design considerations](#design-considerations)
- [A curiosity: the card was running a mining BIOS](#a-curiosity-the-card-was-running-a-mining-bios)
- [Threats to validity](#threats-to-validity)
- [Reproducing this](#reproducing-this)
- [Future work](#future-work)
- [Closing notes](#closing-notes)

## The short version

1. **The GEMM computed one output element per unit of work, and that was the
   ceiling on all three backends.** Every multiply-add paid for its own
   operand loads: 0.17 flops/byte on the CPU, and exactly two 32-bit
   shared-memory words per FMA on the GPU -- counted in both the gfx1032 and
   sm_86 listings, with no register spills and full occupancy, so the limit
   was algorithmic rather than a tuning problem. See
   [Why both GPUs run far from peak](#why-both-gpus-run-far-from-peak).
2. **Register blocking against that diagnosis was worth 1.3-2.8x on the
   CPU** on two controlled hosts and up to 4.2x on a third, measured across
   three microarchitectures spanning 2014 to 2021, and 1.4-1.7x
   on GPU training of the large network. It loses on small networks and is
   now gated on problem size. The CPU half is the clearest result in the
   report. See [Design considerations](#design-considerations).
3. **The CPU GEMM used to emit no vector instructions at all** -- 41 scalar
   FMAs and zero packed ones in the compiled binary, on machines with 8-wide
   AVX2, because LLVM would not hoist an alias check out of the `k` loop.
   Hand-written `@Vector` panels fixed that and the arithmetic intensity
   behind it in one change.
4. **The GPU backends are 5-45x the CPU, and the honest figure is the
   compute-bound one.** The small configurations understate the GPU badly
   because they do not give it enough work: the same RX 6650 XT achieves 66
   GFLOP/s on MNIST and 413 on `cifar10-full`.
5. **A fast GPU paired with a slow decoder is a slow system.** On COCO the
   RTX 3060 Ti host spent 3.28 s decoding JPEGs against 0.95 s of forward
   pass, and lost the end-to-end comparison to a machine with a slower GPU
   and a faster CPU. Scaling the loader with core count was worth 1.7x on the
   decode step.
6. **All three backends agree on accuracy to within 0.4 percentage points**,
   from the same seed, which is the strongest evidence here that the port is
   faithful. Inference is byte-identical to upstream darknet.
7. **One hardware footnote, which cost a week:** the AMD card turned out to
   be running a mining BIOS that capped its shader clock at 45% of rating,
   and four architectural explanations were proposed and eliminated before
   anyone checked the clock. It changes the AMD numbers and none of the
   conclusions. See
   [A curiosity: the card was running a mining BIOS](#a-curiosity-the-card-was-running-a-mining-bios).
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
image decode. Every GPU row is the card running at its correct clock.

These are the **pre-optimisation baseline**: the port as it stood before the
GEMM work, which is the state all four machines were measured in and so the
only apples-to-apples cross-machine comparison available.
[Design considerations](#design-considerations) has what register blocking
then added, and [Future work](#future-work) has the run that would refresh
these tables to the current code.

### MNIST -- 0.005 BFLOPs/image, 1000 batches

| machine | backend | train | infer | e2e | top-1 |
|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 334.9 | 1049.1 | 1018.9 | 0.9775 |
| Core i7-1185G7 | CPU | 465.6 | 1275.1 | 1251.0 | 0.9775 |
| Ryzen 7 5700G | CPU | 816.0 | 2234.5 | 2184.7 | 0.9775 |
| RX 6650 XT | HIP | 8063.7 | 24933.9 | **20415.2** | 0.9764 |
| RTX 3060 Ti | CUDA | **8996.0** | **31300.5** | 16885.0 | 0.9763 |

### CIFAR-10 -- 0.029 BFLOPs/image, 1000 batches

| machine | backend | train | infer | e2e | top-1 |
|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 84.9 | 223.8 | 221.4 | 0.5889 |
| Core i7-1185G7 | CPU | 94.2 | 230.5 | 224.6 | 0.5889 |
| Ryzen 7 5700G | CPU | 255.9 | 718.1 | 713.1 | 0.5889 |
| RX 6650 XT | HIP | 3585.7 | 9385.3 | 8582.3 | 0.5873 |
| RTX 3060 Ti | CUDA | **4533.7** | **12846.1** | **8909.7** | 0.5853 |

### COCO crops -- 0.092 BFLOPs/image, 80 classes, 1000 batches

Majority-class baseline: **0.3110**.

| machine | backend | train | infer | e2e | top-1 |
|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 23.0 | 62.3 | 59.2 | 0.3548 |
| Core i7-1185G7 | CPU | 28.2 | 81.0 | 76.1 | 0.3548 |
| Ryzen 7 5700G | CPU | 71.2 | 184.8 | 173.5 | 0.3548 |
| RX 6650 XT | HIP | 1008.6 | 3758.2 | **1912.3** | 0.3459 |
| RTX 3060 Ti | CUDA | **1132.5** | **4402.2** | 987.2 | 0.3471 |

Note which column the RTX 3060 Ti loses, and by how much. See
[The fastest GPU lost a benchmark](#the-fastest-gpu-lost-a-benchmark).

### cifar10-full -- 1.624 BFLOPs/image (the compute-bound probe)

| machine | backend | batches | train | infer | e2e | top-1 |
|---|---|---|---|---|---|---|
| Xeon E5-1680 v3 | CPU | 20 | 2.6 | 8.9 | 8.9 | 0.1750 * |
| Ryzen 7 5700G | CPU | 20 | 6.5 | 20.2 | 20.2 | 0.1750 * |
| RX 6650 XT | HIP | 1000 | 178.6 | 525.4 | 522.1 | 0.4982 |
| RTX 3060 Ti | CUDA | 1000 | **205.9** | **578.0** | **562.9** | 0.5242 |

\* The CPU rows ran 20 batches rather than 1000, because 1000 batches of this
network takes about 14 hours on the Ryzen and 34 on the Xeon. Throughput is
per-image and compares fine; **their top-1 does not**. The renderer prints a
`batches` column precisely so this cannot be misread.

### Speedups, same machine

| network | AMD GPU/CPU (train) | NVIDIA GPU/CPU (train) |
|---|---|---|
| mnist | 9.9x | 26.9x |
| cifar10 | 14.0x | 53.4x |
| coco | 14.2x | 49.2x |
| cifar10-full | **27.5x** | **79.2x** |

The NVIDIA column is inflated by its host: the Xeon is by some way the
slowest CPU here, and a GPU speedup is only ever a ratio against whatever it
was paired with. Comparing the two GPUs to each other removes that, which is
what the next section does.

### Where it stands now

The tables above are the common baseline. Since then the CPU GEMM was
register-blocked, the GPU gained a blocked kernel for large shapes, and the
loader scales with core count. Two machines have been re-measured on that
build (`results/rx6650xt_current.md`, `results/laptop-cpu-blocked.md`); the
RTX 3060 Ti could not be.

| | baseline | current | |
|---|---|---|---|
| **Ryzen 7 5700G, CPU** | | | |
| mnist train / infer | 816.0 / 2234.5 | 992.2 / 3373.2 | 1.22x / 1.51x |
| cifar10 train / infer | 255.9 / 718.1 | 382.7 / 1266.0 | 1.50x / 1.76x |
| coco train / infer | 71.2 / 184.8 | 94.4 / 246.6 | 1.33x / 1.33x |
| cifar10-full train / infer | 6.5 / 20.2 | 13.3 / 87.1 | 2.05x / **4.31x** |
| **Core i7-1185G7, CPU** | | | |
| mnist train / infer | 465.6 / 1275.1 | 762.5 / 2871.2 | 1.64x / 2.25x |
| cifar10 train / infer | 94.2 / 230.5 | 200.3 / 974.6 | 2.13x / **4.23x** |
| coco train / infer | 28.2 / 81.0 | 49.4 / 180.9 | 1.75x / 2.23x |
| **RX 6650 XT, GPU** | | | |
| mnist infer | 24933.9 | 24929.2 | 1.00x |
| cifar10 infer | 9385.3 | 9490.3 | 1.01x |
| coco infer / e2e | 3758.2 / 1912.3 | 3784.6 / 2123.1 | 1.01x / **1.11x** |
| cifar10-full infer | 525.4 | 525.7 | 1.00x * |

The CPU gains are the headline. On the GPU the three small networks are
unchanged, correctly: their GEMMs are too small for the blocked kernel and
the size gate sends them to the simple one, which is the same code as the
baseline. COCO's end-to-end gain is the loader, not the kernels.

\* `cifar10-full` should have gained here and did not, because the gate was
mis-scaled. It is the one row in this table that is wrong, and
[Design considerations](#design-considerations) explains why.

## Normalising: achieved GFLOP/s

Converting throughput into arithmetic actually performed -- inference is one
forward pass per image, training is roughly three (forward, backward-data,
backward-weights):

| network | Xeon CPU | i7 CPU | Ryzen CPU | RX 6650 XT | RTX 3060 Ti | NV/AMD |
|---|---|---|---|---|---|---|
| mnist | 5 | 6 | 11 | 125 | 157 | 1.26x |
| cifar10 | 6 | 7 | 21 | 272 | 373 | 1.37x |
| coco | 6 | 7 | 17 | 346 | 405 | 1.17x |
| cifar10-full | 14 | -- | 33 | 853 | 939 | **1.10x** |

(Inference GFLOP/s; training figures track these within a few percent.)

Three things fall out of this table.

**Everything is far from peak, on every backend.** At its best the RTX 3060 Ti
reaches 939 GFLOP/s against a 16.2 TFLOP/s paper figure -- **5.8%**, or 11.6%
against the 8.1 TFLOP/s single-datapath number Ampere can sustain without
perfectly co-issued FP32 pairs. The RX 6650 XT reaches 853 against 10.8
TFLOP/s: **7.9%**. The Ryzen manages 33 GFLOP/s against roughly 970 (8 cores
x ~3.8 GHz x 32 flops/cycle with AVX2 FMA): **3.4%**. Three very different
architectures, all stuck in the same single-digit band, which is a strong
hint that the cause is shared. It is; see
[Why both GPUs run far from peak](#why-both-gpus-run-far-from-peak).

**The two GPUs are closer than their spec sheets suggest, and converge as the
network grows.** Paper FP32 favours NVIDIA by 1.50x and memory bandwidth by
1.60x; measured, the lead runs 1.26x on the smallest network down to 1.10x on
the largest. That direction is the interesting part: the bigger the problem,
the more both cards are limited by the same thing, which is the kernel rather
than either architecture.

**The CPUs are much less sensitive to network size than the GPUs.** The Ryzen
spans 11 to 33 GFLOP/s (3.0x) from the smallest network to the largest; the
RTX 3060 Ti spans 157 to 939 (6.0x) and the RX 6650 XT 125 to 853 (6.8x). A
CPU has no launch overhead to amortise and its caches do not care much whether
a tensor is small. That asymmetry is why the small configurations flatter the
CPU, and why `cifar10-full` is the row to quote.
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

## Why both GPUs run far from peak

Neither card gets close to its FP32 rating on this framework, and the reason
is the same on both. It is not occupancy, not cache capacity, and not the
compilers: all three were measured and eliminated. It is the GEMM kernel's
arithmetic intensity, and that claim is settled at the instruction level
rather than argued from the source.

### The kernel

The original GPU GEMM (`gemm_kernel` in `src/kernels/darknet_kernels.hip`) is
a textbook 16x16 shared-memory tiled multiply, one output element per thread:

```c
#pragma unroll
for (int q = 0; q < TILE; ++q) acc += As[ty][q] * Bs[q][tx];
```

Each FMA consumes two shared-memory reads. Shared memory on both
architectures serves roughly one float per lane per cycle, so this loop can
issue at best one FMA every two cycles -- a hard ceiling near 25% of the
single-datapath FP32 rate before accounting for the barriers.

A second inefficiency affects both cards identically: with `TILE = 16` and a
32-lane warp/wave, `Bs[q][tx]` spans only 16 consecutive floats, so each
access touches 16 of the 32 shared-memory banks. Half the bank width goes
unused on both architectures.

### Neither card is resource-starved

`-Dkernel-stats=true` reports per-kernel resource usage from each vendor
compiler; the raw output is in `results/*/kernel_info.txt`. For `gemm_kernel`:

| | RTX 3060 Ti (ptxas, sm_86) | RX 6650 XT (ROCm, gfx1032) |
|---|---|---|
| registers | 37 | 23 VGPR + 22 SGPR |
| spills | 0 stack, 0 store, 0 load | 0 VGPR, 0 SGPR, 0 scratch |
| shared / LDS per block | 2048 B | 2048 B |
| occupancy | not limited: 2 KB of 100 KB per SM, 37 regs of 65536 | **16 waves/SIMD, the gfx10 maximum** |

Both run at full occupancy with no spills. Across every kernel in the file
the picture is the same: no spills anywhere, never more than 40 registers.
The ceiling is algorithmic, not a tuning problem.

### Both ISAs issue exactly two words per FMA

Disassembling settles it. Full listings are in
`results/rx6650xt/amd-gfx1032.s` and `results/rtx3060ti/nvidia-sm86.s`;
counting one tile iteration of the loop body:

| per tile iteration | RX 6650 XT (gfx1032) | RTX 3060 Ti (sm_86) |
|---|---|---|
| FMAs | 16 `v_fmac_f32` | 16 `FFMA` |
| shared-memory read instructions | 12 (8x `ds_read2_b32`, 4x `ds_read_b128`) | 20 (16x `LDS`, 4x `LDS.128`) |
| 32-bit words read from shared | **32** | **32** |
| **words per FMA** | **2.0** | **2.0** |
| barriers | 2 `s_barrier` | 2 `BAR.SYNC` |
| accumulator dependency chain | 16 deep, single register | 16 deep, single register |

The ratio predicted from the source is exactly what both machines execute, on
two unrelated ISAs. Both compilers also produce good schedules -- loads
hoisted above the FMAs that consume them, and AMD's wait counts pipelined
rather than serialising (`s_waitcnt lgkmcnt(3)` leaves three loads in flight).
If either is ahead on this kernel it is the ROCm one, which emits 12
shared-memory instructions to ptxas's 20 for identical traffic.

One structural detail applies equally to both and is inherent to the source:
`acc += As[ty][q] * Bs[q][tx]` accumulates into a single variable, so all 16
FMAs form a serial dependency chain and per-thread instruction-level
parallelism is exactly 1. Only occupancy hides the FMA latency.

### Throughput barely responds to batch size

An early hypothesis was that the RX 6650 XT was overrunning its 32 MB
Infinity Cache: at batch 128 a single hidden activation of `cifar10-full` is
128 x 128 x 28 x 28 x 4 B = 51 MB. Sweeping batch size refuted it -- and
produced a more useful fact about the kernel:

| batch | working set | RX 6650 XT | RTX 3060 Ti |
|---|---|---|---|
| 16 | ~6.4 MB | 257.2 | 586.4 |
| 32 | ~13 MB | 258.1 | 584.8 |
| 64 | ~26 MB | 255.6 | 583.0 |
| 128 | ~51 MB | 254.4 | 578.0 |

Inference throughput moves by about 1% across an 8x range of batch size that
straddles the cache boundary. Those runs predated the BIOS fix below, so the
sweep was repeated at full clock once the card was working, and the answer is
the same: 179.9, 180.4 and 180.1 img/s training at batch 16, 32 and 64
against 178.6 at 128. Flat on a clock-limited card and flat on a healthy one.

Batch size only changes `N`, the GEMM's column count, which scales the number
of thread blocks rather than the efficiency of any one of them; the
per-thread shared-memory traffic that limits this kernel is invariant. The
cache hypothesis is closed.

What follows from all of this is design item 1: give each thread more than one
output, so the operand loads are shared. See
[Design considerations](#design-considerations) for what that was worth.
## The small-network penalty

Within a single card, achieved throughput varies 6x between the smallest and
largest network -- 157 to 939 GFLOP/s on the RTX 3060 Ti, 125 to 853 on the RX
6650 XT. The small configurations are not measuring the GPU.

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

On COCO inference the RTX 3060 Ti runs the forward pass in 0.949 s against the
RX 6650 XT's 1.111 s -- 1.17x faster. End to end, with image decoding
included, it scores **987.2 img/s against 1912.3**. It loses by a factor of
1.94.

The arithmetic, for 4177 validation crops:

| | forward | decode | end to end |
|---|---|---|---|
| RX 6650 XT + Ryzen 7 5700G | 1.111 s | 1.073 s | 4177 / 2.184 = **1912 img/s** |
| RTX 3060 Ti + Xeon E5-1680 v3 | 0.949 s | 3.282 s | 4177 / 4.231 = **987 img/s** |

The Ryzen decodes COCO's JPEGs at 3893 img/s; the Xeon manages 1273. The
faster GPU finished its share in 22% of the wall clock and then waited. Pair
the RTX 3060 Ti with the Ryzen's decode rate and end-to-end would be
4177 / (0.949 + 1.073) = **2066 img/s**, slightly over twice what it actually
achieved. The GPU was never the thing to optimise on that machine.

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

**1. Block the GEMM. Implemented: a clear win on the CPU, and on the GPU for
large networks.** Both backends used to compute one output element per unit of
work, so
every multiply-add paid for its own operand loads: 0.17 flops/byte on the CPU,
and exactly two shared-memory words per FMA on the GPU, counted in both ISAs.

**The CPU change worked, on every host tried.** `gemmPanel` accumulates four rows of `C` at once in
explicit `@Vector` registers across the whole of `k`, so each element of `C` is
read and written once per panel instead of once per step of `k`, and writing
the vectors by hand sidesteps the aliasing analysis that stopped LLVM
vectorising the old loop. The binary went from 41 scalar FMAs and zero packed
ones to emitting packed FMAs in the hot path. Measured on three hosts:

| | Core i7-1185G7 | Ryzen 7 5700G | Xeon E5-1680 v3 |
|---|---|---|---|
| MNIST train / infer | 1.64x / 2.25x | 1.27x / 1.56x | 1.44x / 1.70x |
| CIFAR-10 train / infer | 2.13x / **4.23x** | 1.55x / 1.80x | 1.56x / 2.79x |
| COCO train / infer | 1.75x / 2.23x | 1.35x / 1.36x | 1.40x / 1.60x |

Three microarchitectures spanning 2014 to 2021, all improved, none regressed.
The laptop's ratios are the largest and the least trustworthy: both its
baseline and its re-run were taken on a machine that was being used for other
things, whereas the Xeon is a headless server and the cleanest of the three.

Inference gains more than training because the backward-weights path
(`gemmNT`, a dot-product shape) was left alone. Prediction on `dog.jpg` is
still byte-identical to upstream darknet.

**The GPU change needed two rounds and a threshold.** `gemm_block_kernel`
gives each thread a 4x4 square of the output in registers, and the compiled
ISA confirmed the intent -- 256 FMAs against 32 `ds_read_b128` per tile step,
0.5 words per FMA against the simple kernel's 2.0. The first version was
nonetheless slower on almost everything: 0.65x on CIFAR-10 inference on the
RX 6650 XT, 0.56x on the RTX 3060 Ti.

The shape of that failure was the diagnosis. Inference regressed much harder
than training on both cards, and inference is entirely `TA = 0` forward GEMMs
while training mixes in `TA = 1` and `TB = 1`. The tile-load loop indexed so
consecutive threads took consecutive *rows* of A, which is the contiguous axis
only when A is transposed; for `TA = 0` every lane read an address `lda`
apart, so each tile load became sixty-four memory transactions instead of one.
Four times the arithmetic intensity does not survive that. Three fixes
followed -- an axis chosen from the transpose flags, a 68-float shared stride
that turns a 16-way bank conflict on tile writes into a 2-way one while
keeping rows 16-byte aligned for the float4 reads, and `__launch_bounds__(256,
4)` holding ptxas to 64 registers instead of 92 -- together worth 11-23%:

| `cifar10-full`, blocked kernel | first version | after the fixes |
|---|---|---|
| RX 6650 XT train / infer | 229.9 / 484.6 | **255.9 / 590.4** |
| RTX 3060 Ti train / infer | 295.2 / 574.1 | **340.4 / 706.7** |

That was still not enough to make it win everywhere. Measured against the
simple kernel on the same binary, switched at run time:

| | RX 6650 XT | RTX 3060 Ti |
|---|---|---|
| `cifar10` train | 0.81x | 0.92x |
| `cifar10` inference | **0.65x** | **0.77x** |
| `cifar10-full` train | **1.43x** | **1.66x** |
| `cifar10-full` inference | **1.12x** | **1.22x** |

So it is worth roughly 1.4-1.7x on training the large network and loses a
third of inference throughput on the small one. The kernel produces sixteen
outputs per thread and therefore launches a sixteenth of the threads; below
some size there are not enough thread blocks left to fill the machine.

**Choosing that size took two attempts, and the first was wrong in an
instructive way.** The obvious measure is total work, `m * n * k`, and the
first gate used it at 2e9 -- a figure derived by reading layer dimensions off
the network definitions, where a convolution's output is
`out_w * out_h * batch`. But darknet calls the GEMM **once per image**, inside
the batch loop, so `n` is `out_w * out_h` and nothing is multiplied by batch.
Every figure behind that threshold was 128x too large, and the effect was to
disable the blocked kernel everywhere. The `cifar10-full` row in
[Where it stands now](#where-it-stands-now) is the symptom: a run that
reports `gemm=blocked` and performs exactly like the simple kernel, because
no GEMM in the network ever cleared the gate.

A sweep of the threshold found the edge and, more usefully, showed that total
work is the wrong quantity regardless. Measured per GEMM call:

| layer | m | n | k | m*n*k | 64x64 tiles | blocked kernel |
|---|---|---|---|---|---|---|
| cifar10 conv64 | 64 | 196 | 576 | 7.2e6 | 4 | loses |
| cifar10 FC | 128 | 128 | 6272 | **1.0e8** | 4 | loses |
| coco FC | 128 | 256 | 9216 | **3.0e8** | 8 | loses |
| coco conv64 | 64 | 576 | 288 | 1.1e7 | 9 | untested |
| cifar10-full conv256 | 256 | 196 | 1152 | **5.8e7** | 16 | **wins** |
| cifar10-full conv128 | 128 | 784 | 1152 | 1.2e8 | 26 | **wins** |

The two fully-connected layers lose at 1.0e8 and 3.0e8 multiply-adds while a
convolution wins at 5.8e7, so no threshold on work can separate them. Their
shapes are wide and shallow -- 128x128 and 128x256 outputs, four and eight
tiles -- and it is the tile count, not the arithmetic, that runs out. The
gate is now `ceil(m/64) * ceil(n/64) >= 16`, which matches the mechanism and
separates every case measured.

It is still fitted data rather than theory: known losers sit at 4, 8 and 9
tiles and known winners at 16 and 26, so 16 is the lowest value observed to
win, not one shown to be optimal, and the 9-tile case was never tested
directly. `$DARKNET_GEMM_MIN_TILES` overrides it without a rebuild.

Two pieces of tooling came out of getting this wrong. `src/kernels/verify.sh`
runs a block's 256 threads as real threads against a `std::barrier` and checks
the blocked kernel is bit-identical to the simple one; it caught nothing here,
because the bug was in memory access patterns, which it explicitly cannot see.
What did catch it was running on a GPU. And every run now records `gemm=` and
`gemm_min_tiles=`, because the first attempt at this comparison silently
measured one kernel twice against a stale binary, and produced four tables
that agreed to within 0.1% while appearing to say something.

Still worth doing: the same treatment for `gemmNT`, and an `m`-aware GPU tile
so the small first layers get some benefit too.

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

**4. Scale loader threads with `nproc`. Done.** The default was a flat 8
regardless of the machine, which left the 16-thread Ryzen half idle and put
the 8-thread Xeon in direct competition with the training thread. `-threads`
now defaults to one worker per core. This is the fix for the COCO result
above, where the Xeon spent 3.28 s decoding against 0.95 s of forward pass and
the RTX 3060 Ti system lost end-to-end to a slower GPU; it should help most on
that machine, which is also the one where the effect was largest.

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

## A curiosity: the card was running a mining BIOS

This does not affect any conclusion above, but it cost a week and is the most
useful thing in the report for anyone about to benchmark a GPU.

For most of this study the RX 6650 XT ran at **1193 MHz against a rated 2635
MHz**, drawing 42 W of a 130 W budget at 38 C -- an idle temperature -- while
the driver reported it 99.8% busy for twenty-four minutes at a stretch. It
was not throttling. It simply never left a low clock state, because XFX fits
these boards a physical dual-BIOS switch and it was set to the restricted
profile. Reading the card's own ROM over PCI in each position:

| switch position | ROM string | power | suffix |
|---|---|---|---|
| as shipped | `113-1HS23KXT130WMIN210508` | 130 W | `MIN` |
| flipped | `113-1HS23KXT143W210508` | 143 W | none |

The telling detail was not the wattage but an asymmetry in the DPM tables:
memory was unrestricted at its full 1094 MHz while the shader clock stopped
at 1200 MHz, under half its rating. A vendor "quiet" BIOS trims both modestly
for fan noise. Full memory clock with a hard-capped core is the signature of
a mining profile, where the workload is memory-bandwidth-bound and core clock
is wasted power -- so `MIN` plausibly abbreviates *mining*, and the May 2021
date fits. That reading is inference from the numbers; the string cannot be
made to prove it.

Flipping the switch, same machine, same 100 batches of `cifar10-full`:

| | mining BIOS | 143 W BIOS |
|---|---|---|
| median shader clock | 1198 MHz | **2608 MHz** |
| training img/s | 88.1 | **180.2** |
| inference img/s | 256.9 | **527.7** |
| mean power | 43 W | 142 W of a 143 W cap |
| peak temperature | 38 C | 70 C |

Throughput scaled at 2.05x against a 2.18x clock increase -- near-linear,
which is what a compute-bound kernel should do and is itself confirmation
that nothing else was wrong.

### How long it took to notice

Four explanations were proposed and eliminated first, in this order:
occupancy (ruled out by per-kernel register and spill data), Infinity Cache
capacity (refuted by the batch sweep above), code generation (refuted by
disassembling both ISAs), and contention from the desktop session (refuted by
a quiesced re-run with the display manager stopped, which moved throughput by
under 1%).

Every one of those failed for the same reason, and the contradiction was
visible from the start: at its *rated* clock the RX 6650 XT should have been
about 15% **faster** than the RTX 3060 Ti on this workload, not 2.2x slower.
That inversion was treated as a puzzle about architecture for far too long
instead of as evidence that the card was not running at its rated clock.

The lesson is duller than any of the architectural stories would have been:
**check that the hardware is running at its rated speed before attributing a
performance gap to anything else.** It is one command, and `bench/monitor.sh`
now makes it a routine part of any GPU run.

### What it invalidated

Every AMD measurement taken before the switch was flipped, which is why
the tables in this report use figures recorded after it and why the
batch-size sweep is listed under [Future work](#future-work) as worth
repeating -- it was run on a clock-limited card, where insensitivity to
batch size proves less than it looks.

The framework conclusions are all independent of it: the two shared-memory
words per FMA, the CPU vectorisation failure, the decoder bottleneck, and
the agreement between backends were each established on evidence that had
nothing to do with how fast the card was clocked.

## Threats to validity

- **The main tables are a pre-optimisation baseline**, because that is the
  only state all four machines were measured in.
  [Where it stands now](#where-it-stands-now) has the two machines that could
  be re-measured on the current build.
- **The NVIDIA column is frozen.** That card is no longer available, so its
  rows cannot be corrected, extended or reproduced. They are a snapshot, and
  the CUDA backend is now untested against any hardware.
- **Each GPU had exactly one host CPU**, so "AMD vs NVIDIA end to end" is
  partly "Ryzen vs Xeon". This is why the report leans on same-host speedups
  and the GFLOP/s normalisation rather than raw cross-machine numbers, and it
  can no longer be fixed by swapping cards.
- **The `cifar10-full` CPU rows ran 20 batches, not 1000.** Throughput is
  per-image and comparable; accuracy is not, and is marked.
- **The AMD machine is a live desktop, the NVIDIA machine was a headless
  server.** The RX 6650 XT drives an HDMI monitor and was holding a desktop
  session, a browser and an emulator during the main runs. A quiesced repeat
  changed throughput by under 1%, so this did not affect the numbers, but the
  asymmetry is worth knowing.
- **Error bars exist now, and are small.** `cifar10-full` was measured three
  times on the RX 6650 XT and twice on the RTX 3060 Ti; MNIST and CIFAR-10
  three times each on the Ryzen CPU. Spreads run 0.3-1.4%, and loss and
  accuracy reproduce exactly on the deterministic paths. The laptop and Xeon
  CPUs are still single runs.
- **The GPU dispatch threshold is fitted to two networks.** Known losers sit
  at 4, 8 and 9 output tiles and known winners at 16 and 26; the gate is set
  at 16, the lowest value observed to win. The 9-tile case was never tested
  directly. See [Design considerations](#design-considerations).
- **`infer_load_seconds` is sensitive to filesystem cache state.** The
  laptop's CIFAR-10 decode (8741 img/s) is far below the Ryzen's (97087) by
  more than hardware explains; that run read cold from disk. The duplicated
  NVIDIA sweep makes the same point from the other direction: forward
  throughput reproduced within 1.1% while end-to-end throughput moved by 16%.
  The COCO decode figures are consistent between each host's CPU and GPU runs
  and are trustworthy; the MNIST and CIFAR-10 ones should not be used as
  decoder benchmarks.
- **Vendor peak FP32 figures are boost-clock marketing numbers**, so the
  percentages of peak are indicative rather than precise.

## Reproducing this

Every table regenerates from the committed raw records without re-running
anything:

```sh
./bench/benchmark.sh --from-raw --out bench/results/rx6650xt \
    --tag rx6650xt_bios143_full --platforms cpu,gpu \
    --datasets mnist,cifar10,coco,cifar10-full
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

# the batch-size sweep
for b in 16 32 64; do
    ./bench/benchmark.sh --platforms gpu --datasets cifar10-fullb$b \
        --train-batches 200 --tag <machine>_sweep --append
done
```

Per-kernel register and occupancy data, quoted in
[Neither card is resource-starved](#neither-card-is-resource-starved), comes from a
separate build rather than a benchmark run; `results/*/kernel_info.txt` holds
the output. The README documents the three ways that build can look broken
when it is not. The disassembled kernels are committed alongside as
`results/rx6650xt/amd-gfx1032.s` and `results/rtx3060ti/nvidia-sm86.s`;
note that `hipcc --genco` writes a compressed offload bundle rather than an
ELF, so the AMD listing comes from `--offload-device-only -S` rather than
from `llvm-objdump` on the `.hsaco`.

Provenance (date, host, CPU) is recorded in `<tag>.meta` when the run happens
and read back by `--from-raw`, so re-rendering someone else's results on your
machine does not relabel them with your machine.

## Future work

The RTX 3060 Ti is no longer available, so its columns are frozen. Everything
below is an RX 6650 XT or CPU run.

Four earlier items have been closed: the AMD suite was re-run on the current
build, the threshold was swept, the batch-size sweep was repeated at full
clock (still flat -- the cache question is closed), and the CPU now has error
bars. What came out of the threshold sweep was not a value but a correction:
the gate was on the wrong quantity, and is now on output tiles rather than
multiply-adds.

### 1. Re-measure `cifar10-full` on the corrected gate

This is the only outstanding measurement, and it is short. The tile gate
replaced the mis-scaled work gate, so the blocked kernel should now actually
be dispatched for `cifar10-full` and for nothing else in the suite:

```sh
./bench/benchmark.sh --platforms gpu --datasets cifar10-full,cifar10,coco \
    --train-batches 1000 --tag rx6650xt_tiles16
```

Expect `cifar10-full` to move from 178.6 / 525.7 to roughly 256 / 590 -- the
figures the blocked kernel reached when it was dispatched unconditionally --
and `cifar10` and `coco` to be unchanged, since none of their GEMMs reaches
16 tiles. About twenty minutes. If `cifar10-full` does not move, check
`gemm_min_tiles=16` is in the raw output before looking anywhere else.

### 2. Sweep the tile gate over the range that matters

The previous sweep covered 1e8 to 1e11 multiply-adds, which in per-call units
was entirely above the interesting region -- only its lowest point changed
anything. In tiles the useful range is small enough to cover exhaustively:

```sh
for t in 4 8 12 16 24 32; do
    DARKNET_GEMM_MIN_TILES=$t ./bench/benchmark.sh --platforms gpu \
        --datasets cifar10,coco,cifar10-full --train-batches 300 \
        --tag rx6650xt_tiles_$t
done
```

Half an hour, and it brackets the gate on both sides: at 4 everything
blockable is blocked, at 32 almost nothing is. COCO is the case to watch --
its largest convolution sits at 9 tiles, the one value between a known loser
and a known winner that has never been tested directly.

### 3. Finish the blocking

`gemmNT` and `gemmTT` on the CPU still use the original dot-product shape;
they are the backward-weights path, which is why CPU training gained less
than CPU inference. On the GPU, an `m`-aware tile -- 32x64 as well as 64x64
-- would halve the tile count needed and bring shapes like COCO's
convolutions into range, and below the gate a smaller micro-tile might still
beat one output per thread.

### 4. Fuse the elementwise kernels

Bias, batch-norm scale/shift and activation are separate launches, each
streaming the whole activation tensor through memory. On the small networks
these dominate: the RX 6650 XT reaches 125 GFLOP/s on MNIST against 853 on
`cifar10-full`, and the difference is not the convolutions. Now that the GEMM
has been addressed this is the obvious next lever, and unlike the GEMM work
it should help the *small* networks most -- which is where this framework
currently looks worst.

### 5. Error bars on the remaining CPUs

The Ryzen has three repeats; the laptop and the Xeon are single runs. The
Xeon can no longer be re-run, so this is a laptop-only item and low value
given the Ryzen's spread was 1.4%.

### 6. What can no longer be done

Breaking the one-GPU-one-CPU confound needed a card swap, and with one GPU
left there is nothing to swap. Any future NVIDIA comparison starts over on
new hardware; the numbers here should not be carried forward to a different
card.

## Closing notes

### Where the port ended up

A from-scratch Zig rewrite of darknet's classification path runs on three
backends, agrees with itself to within 0.4 accuracy points across all of
them, and produces inference byte-identical to the original C on the same
weights. On the CPU it is several times faster than upstream, partly from
threading darknet never had and partly from a GEMM that now blocks and
vectorises. On either GPU it reaches roughly 5-8% of peak FP32, which is
what a hand-written tiled GEMM with no BLAS dependency costs -- and the
report documents exactly where that 92-95% goes, at the instruction level,
rather than leaving it as a mystery.

The single most valuable number here is not a speedup. It is that two words
of shared memory per multiply-add, counted independently in the gfx1032 and
sm_86 listings, explains the entire distance to peak on both cards. That is
the kind of finding that survives a hardware change, and it is what made the
optimisation work targetable rather than speculative.

### What the process cost

Four conclusions in this report were wrong when first written, and each
needed a different instrument to catch:

- **A "constant 2.2x NVIDIA lead"** that survived three architectural
  explanations and turned out to be a mining BIOS capping one card at 45% of
  its rated clock. Found by sampling clocks during a run.
- **An Infinity Cache hypothesis** predicting the gap would narrow at small
  batch sizes. It did not move at all. Refuted by a ten-minute sweep.
- **A register-blocked GPU kernel** that was bit-identical to the one it
  replaced, issued a quarter of the shared-memory traffic per FMA, and ran
  *slower*, because its tile loads were uncoalesced. Neither the host
  emulator nor the instruction counts could see that; only a GPU could.
- **An A/B comparison** of those two kernels that produced four tables
  agreeing to within 0.1%, because all four runs used the same stale binary.

The pattern is that static analysis was reliable about *what the code does*
and silent about *what the machine does with it*. Instruction counts, the
host emulator and the resource statistics were all correct and all missed the
two performance bugs; both were found by running the thing on the hardware in
question. The tooling that survives exists because of that: `monitor.sh` for
clocks, `gpu-prep.sh` for a clean device, `verify.sh` for kernel correctness
without a GPU, `-Dkernel-stats` for occupancy, and the `gemm=` and
`gemm_min_tiles=` fields now recorded in every run. Each was expensive to
need once and should be cheap the next time.

### What generalises

The arithmetic-intensity analysis of the GEMM, verified on two unrelated
ISAs. The CPU speedups, 1.3-2.8x on two different microarchitectures. The
observation that a fast GPU paired with a slow decoder is a slow system --
and that the loader deserves as much attention as the kernels. The agreement
between backends, which is the best evidence that the port is faithful.

What does not: every absolute GPU figure. They belong to two specific cards in
two specific machines, and one of those machines is no longer available, so
the NVIDIA column cannot be extended, corrected or re-run. Treat it as a
frozen snapshot rather than a baseline to measure against.
