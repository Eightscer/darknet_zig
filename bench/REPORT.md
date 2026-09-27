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
- [The AMD card was running a mining BIOS](#the-amd-card-was-running-a-mining-bios)
- [The small-network penalty](#the-small-network-penalty)
- [The fastest GPU lost a benchmark](#the-fastest-gpu-lost-a-benchmark)
- [Do the three backends agree?](#do-the-three-backends-agree)
- [What the accuracy numbers actually say](#what-the-accuracy-numbers-actually-say)
- [Design considerations](#design-considerations)
- [Threats to validity](#threats-to-validity)
- [Reproducing this](#reproducing-this)

## The short version

1. **The RX 6650 XT spent this entire study running a mining BIOS.** Its
   physical dual-BIOS switch was set to a profile that caps the shader clock
   at 1200 MHz against a rated 2635 MHz while leaving memory at full speed.
   Flipping it took `cifar10-full` from 88.1 to **180.2 training img/s** and
   the clock from 1198 to 2608 MHz. Everything below that involves an AMD
   number has to be read in that light. See
   [The AMD card was running a mining BIOS](#the-amd-card-was-running-a-mining-bios).
2. **The "constant 2.2x NVIDIA lead" was an artefact of that.** Corrected, the
   RTX 3060 Ti leads the RX 6650 XT by **1.10x on inference and 1.14x on
   training** -- a margin architecture explains easily. Three architectural
   hypotheses were proposed and measured away before the real cause turned
   up: occupancy, cache capacity, and code generation. The lesson is duller
   than any of them: check that the hardware runs at its rated speed before
   attributing a gap to anything else.
3. **The GPU backends are 5-80x the CPU; the honest figure is the
   compute-bound one.** On `cifar10-full`, 79x for NVIDIA and, with the card
   working, roughly 28x for AMD. The smaller configs understate both because
   they do not give the GPU enough work.
4. **Both GPUs run at single-digit percentages of peak FP32, and the CPU at
   roughly 3%, for the same reason on all three backends:** the GEMM computes
   one output element per thread (GPU) or per inner iteration (CPU), so every
   multiply-add needs its own operand loads. On the GPUs this is verified at
   the instruction level -- both ISAs issue exactly **two 32-bit
   shared-memory words per FMA** -- with zero register spills and full
   occupancy, so the ceiling is algorithmic rather than a tuning problem.
   Fixing it is the framework's single largest performance lever, and it is
   the one conclusion here that none of the hardware drama touches.
5. **The CPU GEMM emits no vector instructions at all** -- 41 scalar FMAs and
   zero packed ones in the compiled binary, on machines with 8-wide AVX2.
6. **On COCO the RTX 3060 Ti system was slower end to end than the RX 6650 XT
   system even while the AMD card was crippled**, because the Xeon host cannot
   decode JPEGs fast enough to feed it: 3.28 s of decode against 0.95 s of
   forward pass. The bottleneck had moved off the GPU entirely, and that
   conclusion is independent of the BIOS problem.
7. **All three backends agree on accuracy to within 0.4 percentage points**,
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

> **Read every RX 6650 XT row below with one caveat.** All of them except the
> `cifar10-full` re-measurement were taken while the card was running a mining
> BIOS that capped its shader clock at 1200 MHz, under half its rating. They
> understate it -- by 2.05x on the one configuration that has been re-run, and
> by an unknown but probably smaller factor on the latency-bound smaller
> networks. See
> [The AMD card was running a mining BIOS](#the-amd-card-was-running-a-mining-bios).

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
| RX 6650 XT (mining BIOS) | HIP | 1000 | 87.4 | 254.4 | 253.7 | 0.4982 |
| RX 6650 XT (143 W BIOS) | HIP | 100 | 180.2 | 527.7 | 514.5 | 0.1976 * |
| RTX 3060 Ti | CUDA | 1000 | **205.9** | **578.0** | 562.9 | 0.5242 |

\* Rows marked with an asterisk ran fewer than 1000 batches -- 20 for the CPUs,
100 for the re-measured AMD row -- so **their top-1 is not comparable** with
the others. Throughput is per-image and compares fine. The CPU rows are short
because 1000 batches of this network takes about 14 hours on the Ryzen and 34
on the Xeon. The renderer prints a `batches` column precisely so this cannot
be misread.

The two AMD rows are the same card on the same machine, differing only in
which of its two BIOSes was active. The 143 W row is the one that describes
the hardware.

### Speedups, same machine

| network | AMD GPU/CPU (train) | NVIDIA GPU/CPU (train) |
|---|---|---|
| mnist | 5.5x | 26.9x |
| cifar10 | 8.1x | 53.4x |
| coco | 8.2x | 49.2x |
| cifar10-full (mining BIOS) | 13.4x | 79.2x |
| cifar10-full (143 W BIOS) | **27.7x** | -- |

The NVIDIA column is inflated by its host: the Xeon is the slowest CPU here.
The AMD column is deflated by the mining BIOS in every row but the last.
Comparing the GPUs to each other removes that.

## Normalising: achieved GFLOP/s

Converting throughput into arithmetic actually performed -- inference is one
forward pass per image, training is roughly three (forward, backward-data,
backward-weights):

| network | Xeon CPU | i7 CPU | Ryzen CPU | RX 6650 XT | RTX 3060 Ti | NV/AMD |
|---|---|---|---|---|---|---|
| mnist | 5 | 6 | 11 | 66 * | 157 | 2.38x * |
| cifar10 | 6 | 7 | 20 | 158 * | 373 | 2.36x * |
| coco | 6 | 7 | 16 | 208 * | 405 | 1.95x * |
| cifar10-full (mining BIOS) | 14 | -- | 33 | 413 | 939 | 2.27x |
| **cifar10-full (143 W BIOS)** | 14 | -- | 33 | **857** | 939 | **1.10x** |

(Inference GFLOP/s. Training figures track these within a few percent.
Rows marked \* are AMD figures taken on the mining BIOS and understate the
card; only the last row reflects working hardware on both sides.)

Two things fall out of this table.

**Everything is far from peak, on every backend.** At its best the RTX 3060 Ti
reaches 939 GFLOP/s against a 16.2 TFLOP/s paper figure -- **5.8%**, or 11.6%
against the 8.1 TFLOP/s single-datapath number Ampere can sustain without
perfectly co-issued FP32 pairs. The RX 6650 XT, once it is allowed to clock
properly, reaches 857 against 10.8 TFLOP/s: **7.9%**. The Ryzen manages 33
GFLOP/s against roughly 970 (8 cores x ~3.8 GHz x 32 flops/cycle with AVX2
FMA): **3.4%**. Three very different architectures, all stuck in the same
single-digit band, which is a strong hint that the cause is shared. It is; see
[Design considerations](#design-considerations).

**The two GPUs are close once both are working.** 857 against 939 GFLOP/s is a
10% margin on the only configuration large enough to be compute-bound. The
2.0-2.4x spread in the starred rows is the mining BIOS, not architecture --
which is exactly the trap this table was built to avoid and did not.

**The CPUs are much less sensitive to network size than the GPUs.** The Ryzen
spans 11 to 33 GFLOP/s (3.0x) from the smallest network to the largest; the
RTX 3060 Ti spans 157 to 939 (6.0x) and the RX 6650 XT 66 to 413 (6.3x) on the
mining BIOS. A CPU has no launch overhead to amortise and its caches do not
care much whether a tensor is small. That asymmetry is why the small configs
flatter the CPU and why `cifar10-full` is the row to quote.

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

## The AMD card was running a mining BIOS

The gap exceeds what the spec sheets predict: 1.50x on FP32, 1.60x on memory
bandwidth, against 2.2x measured. Three candidate explanations were proposed and
then tested, and **all were wrong**. The answer turned out not to be
architectural at all: one of the two cards was never running at speed. The
eliminations are recorded here as carefully as a confirmation would have
been, because each one is what forced the search somewhere less flattering.

### The kernel

The GPU GEMM (`gemm_kernel` in `src/kernels/darknet_kernels.hip`) is a
textbook 16x16 shared-memory tiled multiply, one output element per thread:

```c
#pragma unroll
for (int q = 0; q < TILE; ++q) acc += As[ty][q] * Bs[q][tx];
```

Each FMA consumes two shared-memory reads -- confirmed below at the
instruction level on both ISAs. Shared memory on both
architectures serves roughly one float per lane per cycle, so this loop can
issue at best one FMA every two cycles -- a hard ceiling near 25% of the
single-datapath FP32 rate before accounting for the barriers. That ceiling is
why both cards sit in the single digits as a fraction of peak, and it applies
equally to both, which is consistent with the flat NVIDIA/AMD ratio.

A second inefficiency affects both cards identically: with `TILE = 16` and a
32-lane warp/wave, `Bs[q][tx]` spans only 16 consecutive floats, so each access
touches 16 of the 32 shared-memory banks. Half the bank width goes unused on
both architectures.

### Occupancy is not the answer

`-Dkernel-stats=true` reports per-kernel resource usage from each vendor
compiler. The raw output is in `results/rtx3060ti/kernel_info.txt` and
`results/rx6650xt/kernel_info.txt`; for `gemm_kernel`:

| | RTX 3060 Ti (ptxas, sm_86) | RX 6650 XT (ROCm, gfx1032) |
|---|---|---|
| registers | 37 | 23 VGPR + 22 SGPR |
| spills | 0 stack, 0 store, 0 load | 0 VGPR, 0 SGPR, 0 scratch |
| shared / LDS per block | 2048 B | 2048 B |
| barriers | 1 | 1 (`__syncthreads`) |
| occupancy | not limited: 2 KB of 100 KB per SM, 37 regs of 65536 per SM | **16 waves/SIMD, the gfx10 maximum** |

Both run at full occupancy with no spills and identical shared-memory
footprints. Across every kernel in the file the picture is the same: no spills
anywhere, and never more than 40 registers. Neither card is resource-starved,
so occupancy cannot explain the gap -- and more usefully, this confirms the
central claim of this report, that the ceiling is **algorithmic** (two operand
loads per FMA) rather than a tuning problem.

### Cache capacity is not the answer either

The earlier draft of this report hypothesised that the RX 6650 XT's 32 MB
Infinity Cache was being overrun: at batch 128 a single hidden activation of
`cifar10-full` is 128 x 128 x 28 x 28 x 4 B = 51 MB, past which the card falls
back to a narrow 128-bit bus. That predicts the NVIDIA/AMD ratio should
**narrow at smaller batches**, whose working sets fit.

It does not. Inference throughput on `cifar10-full` across an 8x range of
batch size:

| batch | working set | RX 6650 XT | RTX 3060 Ti | ratio |
|---|---|---|---|---|
| 16 | ~6.4 MB | 257.2 | 586.4 | 2.28x |
| 32 | ~13 MB | 258.1 | 584.8 | 2.27x |
| 64 | ~26 MB | 255.6 | 583.0 | 2.28x |
| 128 | ~51 MB | 254.4 | 578.0 | 2.27x |

The ratio is flat to within 1%. The hypothesis is refuted. (The NVIDIA
column quotes the second of two passes, which is what `--from-raw`
regenerates; the first pass differed by at most 0.7%.)

Two further things fall out of the sweep. **Throughput barely responds to batch
size at all** -- 254 to 258 img/s on AMD, 578 to 586 on NVIDIA, across an 8x
range. Batch size only changes `N`, the GEMM's column count, which scales the
number of thread blocks rather than the efficiency of any one of them; the
per-thread shared-memory traffic that limits this kernel is invariant. And the
NVIDIA sweep was accidentally run twice, which supplies the repeat measurement
this report otherwise lacked: **timings reproduced to within 1.1%**, and loss
and accuracy reproduced *exactly*, so GPU runs are deterministic run-to-run on
a fixed machine and the 2.27x ratio is far outside measurement noise.

### The instruction streams are equivalent

The last cheap hypothesis was compiler quality: that one toolchain promotes
more of the tile into registers than the other, changing the real ratio of
operand loads to FMAs. Disassembling both settles it. Full listings are in
`results/rx6650xt/amd-gfx1032.s` and `results/rtx3060ti/nvidia-sm86.s`;
counting one tile iteration of `gemm_kernel`'s loop body:

| per tile iteration | RX 6650 XT (gfx1032) | RTX 3060 Ti (sm_86) |
|---|---|---|
| FMAs | 16 `v_fmac_f32` | 16 `FFMA` |
| shared-memory read instructions | 12 (8x `ds_read2_b32`, 4x `ds_read_b128`) | 20 (16x `LDS`, 4x `LDS.128`) |
| 32-bit words read from shared | **32** | **32** |
| **words per FMA** | **2.0** | **2.0** |
| barriers | 2 `s_barrier` | 2 `BAR.SYNC` |
| accumulator dependency chain | 16 deep, single register | 16 deep, single register |

**The 2:1 ratio predicted from the source is exactly what both machines
execute.** That is the single strongest confirmation in this report: the claim
that the kernel is bound by operand loads per multiply-add is no longer an
inference from reading C++, it is a count of issued instructions on two
unrelated ISAs.

It also kills the compiler hypothesis, and in the opposite direction to the one
suggested by the register counts. AMD's compiler emits **fewer** instructions
for identical traffic -- 12 shared-memory reads against NVIDIA's 20 -- because
it used paired and 128-bit forms (`ds_read2_b32`, `ds_read_b128`) where ptxas
mostly emitted scalar `LDS`. Both schedules are good: loads are hoisted above
the FMAs that consume them, and AMD's wait counts are pipelined rather than
serialising (`s_waitcnt lgkmcnt(3)` leaves three loads in flight; only the
final wait before the barrier is `lgkmcnt(0)`). Neither compiler is leaving
anything meaningful on the table, and if either is ahead on this kernel it is
the ROCm one.

One structural detail is worth noting because it applies equally to both and
is inherent to the source. `acc += As[ty][q] * Bs[q][tx]` accumulates into a
single variable, so all 16 FMAs form a serial dependency chain -- per-thread
instruction-level parallelism is exactly 1, and the only thing hiding FMA
latency is occupancy. Both cards have full occupancy, so this is survivable,
but a register-blocked rewrite (design item 1) would fix it for free by giving
each thread several independent accumulators.

### The RX 6650 XT never boosts

Three explanations were proposed and measured away: occupancy, cache capacity,
and code generation. The instruction streams are equivalent, so the gap was not
in what the two GPUs are asked to do. Sampling the clocks during a
`cifar10-full` run (`bench/monitor.sh`, summaries in
`results/*/monitor_output.txt`) found the difference is in what the two cards
were *doing while asked*:

| while >=90% busy | RX 6650 XT | RTX 3060 Ti |
|---|---|---|
| samples | 2914 of 2920, over ~1460 s | 1151 of 1172, over 649 s |
| median shader clock | **1193 MHz** | 1935 MHz |
| reported ceiling | 1200 MHz (DPM table) | 2100 MHz |
| rated boost | 2635 MHz | 1665 MHz |
| 10th percentile | 1192 MHz | 1935 MHz |
| mean power | **42 W of a 130 W cap** | 189 W of a 200 W cap |
| peak temperature | **38 C** | 64 C |
| driver throttle reasons | none | none |

The RTX 3060 Ti behaves exactly as a healthy card should: pinned against its
power limit at 189 of 200 W, holding 1935 MHz with a 10th percentile identical
to the median, and *above* its 1665 MHz rated boost. There is nothing wrong
with it and nothing throttling it.

The RX 6650 XT is drawing a third of its power budget at 38 C -- an idle
temperature -- while the driver reports it 99.8% busy for twenty-four minutes,
and its DPM table tops out at 1200 MHz against a rated 2635 MHz boost. It is
not throttling in the thermal or power sense. **It appears never to leave a
low clock state at all.**

That single fact reverses the paradox. Modelling throughput as compute units
times sustained clock:

| | product | predicted NVIDIA lead |
|---|---|---|
| 38 SMs x 1935 MHz (measured) | 73,530 | -- |
| 32 CUs x 1193 MHz (measured) | 38,176 | **1.93x** |
| 32 CUs x 2635 MHz (rated) | 84,320 | 0.87x -- AMD *faster* |
| measured performance gap | | 2.27x |

At the rated clock the model says the RX 6650 XT should beat the RTX 3060 Ti
by 15%, which is precisely why every specification-based explanation in this
report failed. At the clock it actually ran, the model predicts a 1.93x NVIDIA
lead against the 2.27x measured -- about 85% of the gap, leaving a 1.18x
residual that is unremarkable for two different architectures.

**Confirmed, and it is not contention.** The obvious objection was that the
AMD machine is a live desktop -- the card drives an HDMI monitor and was
holding an XFCE session, a compositor, a browser, an Electron application and
an emulator on `/dev/dri` -- while the NVIDIA machine is a headless server.
So the run was repeated with the display manager stopped, every GPU client
closed, runtime power management disabled and
`power_dpm_force_performance_level` forced to `high`:

| | live desktop | quiesced + forced | change |
|---|---|---|---|
| training img/s | 87.5 | 88.1 | +0.7% |
| inference img/s | 255.7 | 256.9 | +0.5% |
| median shader clock | 1193 MHz | 1198 MHz | +0.4% |
| mean power | 42 W | 43 W | -- |
| peak temperature | 38 C | 38 C | -- |

Nothing moved. Forced to its highest performance state on an otherwise idle
machine, the card pins to **1200 MHz exactly** -- the top of its DPM table --
and delivers the same throughput it did while running a desktop. The ceiling
is real, and the desktop was never the problem.

What it is instead is now largely pinned down, and it is on the board rather
than in any software this project controls.

- **The SMU is healthy.** `SMU is initialized successfully`, all 32 CUs
  detected, no firmware load failures, and no `amdgpu.ppfeaturemask` on the
  kernel command line.
- **The card carries two BIOSes, and it was running the restricted one.**
  XFX fits a physical dual-BIOS switch to these boards. Reading the card's own
  ROM over PCI in each position gives two different images:

  | switch position | ROM string | power | suffix |
  |---|---|---|---|
  | as shipped | `113-1HS23KXT130WMIN210508` | 130 W | `MIN` |
  | flipped | `113-1HS23KXT143W210508` | 143 W | none |

- **The ACPI path was a red herring.** The as-shipped ROM string is byte
  identical to what the driver reported after `Fetched VBIOS from VFCT`, so
  the ACPI copy was faithful and the switchable-graphics route was never the
  problem. That hypothesis is dead.

The most telling detail is not the power figure but an asymmetry in the two
DPM tables. Memory is unrestricted -- `0: 96Mhz 1: 541Mhz 2: 675Mhz
3: 1094Mhz`, and 1094 MHz is exactly right for this card's 17.5 Gbps GDDR6 --
while the shader table stops at 1200 MHz, under half its rated 2635 MHz. A
vendor "quiet" BIOS trims both modestly in exchange for fan noise. **Full
memory clock with a hard-capped core is instead the signature of a
mining-oriented profile**, where the workload is memory-bandwidth-bound and
core clock is wasted power. Read that way, `MIN` plausibly abbreviates
*mining* rather than *minimum*, and the May 2021 date sits squarely in that
era. That reading is an inference from the numbers, not something the string
can be made to prove.

### Flipping the switch fixed it

Rebooting on the 143 W BIOS, same machine, same quiesced conditions, same 100
batches:

| | mining BIOS | 143 W BIOS | gain |
|---|---|---|---|
| median shader clock | 1198 MHz | **2608 MHz** | 2.18x |
| training img/s | 88.1 | **180.2** | 2.05x |
| inference img/s | 256.9 | **527.7** | 2.05x |
| mean power | 43 W | 142 W of a 143 W cap | 3.3x |
| peak temperature | 38 C | 70 C | -- |

The card now behaves like the RTX 3060 Ti did all along: pinned against its
power limit, warm, and holding a clock near its rating. Throughput scaled
almost exactly with clock -- 2.05x against 2.18x -- which is what a
compute-bound kernel should do and is further confirmation that nothing else
was wrong.

The consequence for this report's central comparison:

| `cifar10-full` | mining BIOS | 143 W BIOS |
|---|---|---|
| training, NVIDIA lead | 2.33x | **1.14x** |
| inference, NVIDIA lead | 2.25x | **1.10x** |

**The "remarkably constant 2.2x" was an artefact of a crippled card.** The
real gap between an RTX 3060 Ti and an RX 6650 XT on this workload is about
10%, and that is comfortably explained by architecture. Counting shaders
rather than compute units, NVIDIA has 4864 lanes at 1935 MHz against AMD's
2048 at 2611 MHz. If Ampere's dual FP32 datapath were fully usable that
predicts a 1.76x NVIDIA lead; if only the guaranteed 64 lanes per SM count,
it predicts AMD ahead by 1.14x. The measured 1.10x sits between those bounds,
which is exactly where a kernel that cannot perfectly co-issue FP32 pairs
should land.

Three architectural hypotheses were eliminated before this one, and the
elimination was not wasted: each failure sharpened the contradiction that at
its *rated* clock the AMD card should have been winning, which is what
eventually pointed at the clock itself rather than at the code. The lesson is
narrower and more uncomfortable than any of the architectural stories would
have been -- **validate that the hardware is running at its rated speed
before attributing a performance gap to anything else.**

### What this does and does not invalidate

Only `cifar10-full` has been re-measured on the working BIOS. **Every other
AMD row in this report -- MNIST, CIFAR-10, COCO, and the batch-size sweep --
was taken on the mining BIOS and understates the card**, most likely by
something near 2x but not necessarily by exactly that: the smaller networks
are latency- and bandwidth-bound rather than clock-bound, so they may gain
less. Those rows are marked where they appear, and re-running the suite is
the first item under [Further tests](#further-tests-worth-running).

Nothing about the *framework* conclusions changes. Both backends still issue
two shared-memory words per FMA, confirmed at the instruction level; both
still run at single-digit percentages of peak; and blocking the GEMM is still
the single largest available win. What changes is that the two GPUs turn out
to be far more evenly matched than the measurements suggested, and that HIP
on RDNA 2 is not the weaker backend it appeared to be.

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

**1. Block the GEMM. Implemented; a clear win on the CPU, unresolved on the
GPU.** Both backends used to compute one output element per unit of work, so
every multiply-add paid for its own operand loads: 0.17 flops/byte on the CPU,
and exactly two shared-memory words per FMA on the GPU, counted in both ISAs.

**The CPU change worked.** `gemmPanel` accumulates four rows of `C` at once in
explicit `@Vector` registers across the whole of `k`, so each element of `C` is
read and written once per panel instead of once per step of `k`, and writing
the vectors by hand sidesteps the aliasing analysis that stopped LLVM
vectorising the old loop. The binary went from 41 scalar FMAs and zero packed
ones to emitting packed FMAs in the hot path. Measured on two hosts:

| | Ryzen 7 5700G | Xeon E5-1680 v3 |
|---|---|---|
| MNIST train / infer | 1.27x / 1.56x | 1.44x / 1.70x |
| CIFAR-10 train / infer | 1.55x / 1.80x | 1.56x / **2.79x** |
| COCO train / infer | 1.35x / 1.36x | 1.40x / 1.60x |

Inference gains more than training because the backward-weights path
(`gemmNT`, a dot-product shape) was left alone. Prediction on `dog.jpg` is
still byte-identical to upstream darknet.

**The first GPU attempt was slower than what it replaced**, which is worth
recording rather than quietly fixing. `gemm_block_kernel` gives each thread a
4x4 square of the output in registers, and the compiled ISA confirmed the
intent -- 256 FMAs against 32 `ds_read_b128` per tile step, 0.5 words per FMA,
a 4x improvement. It still lost:

| | RX 6650 XT | RTX 3060 Ti |
|---|---|---|
| MNIST inference | 0.97x | 0.96x |
| CIFAR-10 inference | **0.65x** | **0.56x** |
| COCO inference | 0.83x | 0.81x |
| cifar10-full training | 1.29x | -- |

The shape of that table is the diagnosis. Inference regressed much harder than
training on both cards, and inference is entirely `TA = 0` forward GEMMs while
training mixes in `TA = 1` and `TB = 1`. The tile-load loop indexed so that
consecutive threads took consecutive *rows* of A, which is the contiguous axis
only when A is transposed; for `TA = 0` every lane in a wave read an address
`lda` apart, so each tile load became sixty-four memory transactions instead
of one. Four times the arithmetic intensity does not survive that.

The host emulation that verified this kernel could not have caught it, and
says so: it checks index arithmetic, tiling, bounds and the transpose flags,
and explicitly cannot check coalescing. Arithmetic-intensity counting from the
ISA could not have caught it either, because the instruction mix was correct.
Only running it on a GPU found it.

Three fixes followed, all re-verified bit-identical against the original
kernel: the load mapping now picks its axis from the transpose flags so both
operands are read along their contiguous dimension; the shared tiles are
padded to a 68-float stride, which turns a 16-way bank conflict on every tile
write into a 2-way one while keeping the rows 16-byte aligned for the float4
reads; and `__launch_bounds__(256, 4)` holds ptxas to 64 registers instead of
92, recovering NVIDIA occupancy from a third to two thirds. AMD sits at 68
VGPRs and 12 waves/SIMD, neither card spills.

**Whether that is enough is not yet known.** `$DARKNET_GEMM_SIMPLE=1` disables
the blocked kernel at run time so both can be compared on one build without a
rebuild, which is the cheap way to settle it.

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

## Threats to validity

- **The `cifar10-full` CPU rows ran 20 batches, not 1000.** Throughput is
  per-image and comparable; accuracy is not, and is marked.
- **Each GPU has exactly one host CPU**, so "AMD vs NVIDIA end to end" is
  partly "Ryzen vs Xeon". This is why the report leans on the same-host
  speedups and the GFLOP/s normalisation rather than raw cross-machine numbers.
- **The AMD machine is a live desktop, the NVIDIA machine a headless server.**
  The RX 6650 XT drives an HDMI monitor and was holding a desktop session, a
  browser and an emulator during the main runs. A quiesced repeat changed
  throughput by under 1%, so this did not affect the numbers, but the
  asymmetry is worth knowing.
- **Most AMD rows describe a card running a mining BIOS.** Only `cifar10-full`
  has been re-measured on the working 143 W BIOS, where it gained 2.05x. MNIST,
  CIFAR-10, COCO and the batch-size sweep all still reflect a shader clock
  capped at 1200 MHz, and should be treated as lower bounds of unknown
  tightness -- the smaller networks are latency-bound rather than clock-bound,
  so they will probably gain less than 2x. Re-running the suite is follow-up
  item 1.
- **Three architectural hypotheses were published before the real cause was
  found.** Occupancy, Infinity Cache capacity and code generation were each
  proposed and then refuted by measurement. They are left in the report
  deliberately, because the eliminations are what eventually forced the search
  towards the hardware, but none of them was ever the answer.
- **`infer_load_seconds` is sensitive to filesystem cache state.** The laptop's
  CIFAR-10 decode (8741 img/s) is far below the Ryzen's (97087) by more than
  hardware explains; that run read cold from disk. The duplicated NVIDIA sweep
  makes the same point from the other direction: forward throughput reproduced
  within 1.1% while end-to-end throughput moved by 16%. The COCO decode figures
  are consistent between each host's CPU and GPU runs and are trustworthy; the
  MNIST and CIFAR-10 ones should not be used as decoder benchmarks.
- **Repeats are now available on both GPUs and agree closely.** `cifar10-full`
  has been run twice on each card: training 87.4 then 87.5 img/s on AMD,
  205.9 then 205.4 on NVIDIA; inference 254.4/255.7 and 578.0/579.0. That is
  0.5% or better, and loss and accuracy reproduce exactly. The CPU
  configurations still have no error bars.
- **Vendor peak FP32 figures are boost-clock marketing numbers.** Sustained
  clocks have now been sampled, and on the AMD side the gap between rated and
  sustained turned out to be the story rather than a footnote. The
  percentages of peak quoted earlier are indicative, not precise.

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

# the batch-size sweep
for b in 16 32 64; do
    ./bench/benchmark.sh --platforms gpu --datasets cifar10-fullb$b \
        --train-batches 200 --tag <machine>_sweep --append
done
```

Per-kernel register and occupancy data, quoted in
[Occupancy is not the answer](#occupancy-is-not-the-answer), comes from a
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

## Further tests worth running

Six of the tests originally listed here have been run. Four came back
negative -- the batch-size sweep refuted the Infinity Cache hypothesis,
`-Dkernel-stats=true` ruled out occupancy, the ISA listings showed the two
instruction streams to be equivalent, and a quiesced re-run ruled out
contention. Clock sampling then found the symptom, and reading the card's
ROM in both dual-BIOS positions found the cause. All six are folded into
[The AMD card was running a mining BIOS](#the-amd-card-was-running-a-mining-bios). What is left:

1. **Re-run the whole AMD suite on the 143 W BIOS.** This is now the only thing
   standing between this report and a clean comparison. Every AMD row except
   `cifar10-full` was measured on the mining BIOS:

   ```sh
   ./bench/benchmark.sh --platforms cpu,gpu --datasets mnist,cifar10,coco \
       --train-batches 1000 --tag rx6650xt_bios143_full
   ./bench/benchmark.sh --platforms gpu --datasets cifar10-full \
       --train-batches 1000 --tag rx6650xt_bios143_full --append
   for b in 16 32 64; do
       ./bench/benchmark.sh --platforms gpu --datasets cifar10-fullb$b \
           --train-batches 200 --tag rx6650xt_bios143_sweep --append
   done
   ```

   About an hour, most of it the CPU baseline. Worth predicting in advance:
   `cifar10-full` should land near 2x its old figure, but the small networks
   are latency- and bandwidth-bound rather than clock-bound and should gain
   noticeably less. If they gain the full 2x as well, the small-network
   penalty analysis in this report needs revisiting too.

2. **Prototype the register-blocked GEMM** -- a 4x4 micro-tile per thread --
   and re-run `cifar10-full` on both cards. This is design item 1 and would
   simultaneously test the diagnosis: if the ceiling really is two shared
   words per FMA, the fix should move both cards several-fold.

3. **Repeat runs on the CPU configurations**, which still have no error bars.
   Both GPUs now have them: `cifar10-full` was measured three times on the
   RX 6650 XT (87.4 / 87.5 / 88.1 img/s training) and twice on the RTX 3060 Ti
   (205.9 / 205.4), so GPU variance is under 1%.

4. **The RTX 3060 Ti in a modern host, or the RX 6650 XT in the Xeon box** --
   any swap that breaks the one-GPU-one-CPU confound.

Nothing further is needed on the static side. The CPU assembly, the PTX, the
per-kernel resource statistics and both GPU ISA listings are in the
repository, and between them they establish what the bottleneck is: two
shared-memory words per multiply-add, on both architectures, confirmed at the
instruction level. The performance *gap* between the two cards turned out not
to be a property of the code at all.
