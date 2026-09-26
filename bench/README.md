# darknet-zig benchmark suite

Measures training throughput, inference throughput and accuracy for one
platform (CPU, or a GPU through the HIP or CUDA backend) across three
datasets. Everything the suite needs — the datasets, the network configs, the
scripts and the recorded results — lives in this directory.

```
bench/
  get-data.sh      download and convert the datasets
  benchmark.sh     run the measurements, write csv + markdown
  prepare.zig      the dataset converter (built by `zig build bench-prepare`)
  cfg/             one network per dataset
  data/            datasets in darknet layout (git-ignored, ~1.5 GB with COCO)
  results/         recorded runs
```

## Quick start

```sh
zig build -Doptimize=ReleaseFast          # or add -Dgpu=true -Dgpu-backend=...
./bench/get-data.sh mnist cifar10         # ~200 MB
./bench/benchmark.sh --platforms cpu --datasets mnist,cifar10
```

Results land in `bench/results/<tag>.csv` and `<tag>.md`, with the raw
`key=value` output of each run kept under `bench/results/raw/`.

## The datasets

| dataset | classes | train | valid | input | source |
|---|---|---|---|---|---|
| mnist   | 10 | 60 000 | 10 000 | 28×28 | cvdf-datasets mirror of the IDX files |
| cifar10 | 10 | 50 000 | 10 000 | 28×28 crop of 32×32 | cs.toronto.edu binary batches |
| coco    | 80 | 17 044 | 4 177 | 96×96 | val2017 images + instance annotations |

`get-data.sh` defaults to `mnist cifar10`. COCO is about 1 GB and is fetched
only when named explicitly:

```sh
./bench/get-data.sh coco
```

Each dataset is written in the layout darknet expects, which the Zig port
reads unchanged:

```
data/<name>/
  images/<class>/<split>_<n>.png     one file per example
  labels.list                        "/images/<class>/", in output-unit order
  names.list                         the plain class names, for display
  train.list  valid.list             absolute paths, so any cwd works
  <name>.data
  backup/                            where trained weights go
```

### Why the labels look like `/images/car/`

darknet decides an image's class by searching for each label string inside the
image's path, and sets the corresponding bit of the one-hot target on a hit.
That is fine when no class name is a substring of another, and quietly wrong
when one is. COCO breaks it several ways: `car` is inside `carrot`, `bus` is
inside `bus stop`.

Rather than rename the classes, the converter writes the labels
path-delimited. `/images/car/` occurs in `…/coco/images/car/val_3.png` and not
in `…/coco/images/carrot/val_9.png`, so the same substring search becomes
exact and nothing in the framework had to change. `names.list` keeps the plain
names for display, which is what the `.data` file's `names` key is for.

The `images/` component is in the pattern rather than a bare `/car/` because
COCO also has a class called **bench**, and this suite lives in a directory of
that name — a bare `/bench/` would have matched every path in the repository.
`prepare.zig` checks for exactly that and refuses to write rather than emit a
dataset where every image carries the same spurious label.

### A caveat on COCO

COCO is a detection dataset. To make it a classification benchmark,
`prepare.zig` crops every annotated box at least 32 px on a side and labels it
with its category: 21 221 crops from 4 847 images, split 80/20 by image id so
no photograph contributes to both halves. That is a legitimately hard 80-way
problem — the crops are low resolution, frequently occluded, and the class
distribution is dominated by `person` — so its accuracy is not comparable to
CIFAR's and is not meant to be. COCO is in the suite to exercise the pipeline
at 80-class scale on real photographs with real JPEG decode cost.

## The networks

| config | forward BFLOPs/image | notes |
|---|---|---|
| `mnist.cfg`        | 0.005 | 3 convs, fully-connected head |
| `cifar10.cfg`      | 0.032 | 5 convs, fully-connected head |
| `cifar10-full.cfg` | 1.6   | darknet's own `cifar.cfg`, 9 convs at 128/256/512 |
| `coco.cfg`         | 0.097 | 6 convs at 96×96, fully-connected head |

All four use `max_batches` values that `--train-batches 1000` completes, so
the `poly` learning-rate schedule anneals to zero inside the measured window
and the accuracy column reflects a finished run rather than an interrupted
one. The exception is `cifar10-full.cfg`, which keeps upstream's 5000.

Two things about these configs are worth knowing, because both were found the
hard way while bringing the suite up:

**`cifar10-full.cfg` is a GPU config.** It is darknet's own `cifar.cfg` and it
is the right thing to compare upstream numbers against, but at 1.6 BFLOPs per
image it runs at about 4 images a second on a laptop CPU, which puts its 5000-batch
schedule at roughly 45 hours. `cifar10.cfg` is a quarter of the width and five
convolutions instead of nine so that a CPU can finish a schedule. Run the full
one on a GPU:

```sh
./bench/benchmark.sh --platforms gpu --datasets cifar10-full
```

A config name may carry a `-variant` suffix; the data is looked up under the
part before the first dash, so `cifar10-full` reuses `data/cifar10`.

**The heads are fully connected, not global average pooling.** darknet's
classification configs end with a 1×1 convolution to `classes` channels and an
`[avgpool]`, which works well when the trunk is wide. These trunks are narrow,
and average pooling discards where in the frame the evidence was — most of
what separates a 6 from a 9. Measured on MNIST at 500 batches, everything else
held equal: pooled head 51% top-1, fully-connected head 95%.

## Running the benchmark

```
./bench/benchmark.sh [options]
  --platforms cpu,gpu    which to measure (default: cpu)
  --datasets mnist,cifar10,coco,cifar10-full
  --train-batches N      timed training batches per run (default 1000)
  --infer-images N       validation images to time, 0 = all (default 0)
  --gpu-index N          device index for the gpu platform (default 0)
  --tag NAME             label for the results file (default: hostname)
  --out DIR              results directory (default bench/results)
```

`gpu` here just means "pass `-gpu <index>`", so the binary has to have been
built with a GPU backend first:

```sh
# AMD
zig build -Doptimize=ReleaseFast -Dgpu=true -Doffload-arch=gfx1030
# NVIDIA
zig build -Doptimize=ReleaseFast -Dgpu=true -Dgpu-backend=cuda
```

A GPU-enabled build still runs the CPU path perfectly well, so
`--platforms cpu,gpu` in one invocation measures both from the same binary,
which is the fairest comparison available.

Every run is given `-seed 1`. Accuracy then differs between platforms only
because of floating-point ordering, not because of initialisation luck, which
is what makes the top-1 column meaningful as a cross-platform check rather
than just as a number.

## What is measured

The `benchmark` subcommand does the work and prints `key=value` lines. It
trains for `-warmup N` untimed batches first, so page faults, lazy thread
spawning and the GPU's first kernel load do not land inside the measurement,
then times `-train-batches N`. On the GPU it calls `gpu.sync()` before
stopping the clock — without that it would be timing kernel *launches*, which
are asynchronous, and report a fictitious number.

It then saves the weights, reloads them into a fresh network sized for
inference, and runs the validation set.

| key | meaning |
|---|---|
| `train_images_per_sec` | images/second through forward + backward + update |
| `train_mean_loss`, `train_final_loss` | loss over the timed window, and at its end |
| `infer_forward_images_per_sec` | the network forward pass alone |
| `infer_end_to_end_images_per_sec` | including PNG/JPEG decode and centre crop |
| `top1`, `top5` | accuracy on the validation list |

The `majority-class baseline` column in the rendered table is not one of these
keys; `benchmark.sh` computes it from `valid.list`. It is the score you would
get by always answering with the most common class, and it is the only thing
that makes a top-1 on a skewed set readable.

The two inference numbers are reported separately because they answer
different questions. The forward-only figure is what a GPU comparison is
about; the end-to-end figure is what a deployed pipeline actually costs, and
on a fast GPU it is dominated by image decode on the CPU.

`train_final_loss` is a single batch's loss and is correspondingly noisy —
compare `train_mean_loss` between runs, not the final one.

## Expected runtimes

Measured on an 11th-gen Core i7-1185G7 laptop, at `--train-batches 1000`
(a full schedule for all three):

| dataset | training | validation | total |
|---|---|---|---|
| mnist   | 4m 35s  | 8s  | ~5 min |
| cifar10 | 22m 39s | 43s | ~24 min |
| coco    | 37m 49s | 52s | ~39 min |

So about 68 minutes for all three on a CPU. Drop `--train-batches` to 100 if
you only want the throughput columns — the accuracy will be meaningless but
the images/second figures settle within a few batches of the warmup.

## Recorded results

Results live in `results/<machine>/<tag>.md`, with the raw key=value
records kept alongside in `raw/` so any table can be re-rendered with
`--from-raw` without re-running anything. Three machines have been
measured so far:

| directory | CPU | GPU | backend |
|---|---|---|---|
| `results/` | Core i7-1185G7 | -- | CPU only |
| `results/rx6650xt/` | Ryzen 7 5700G | Radeon RX 6650 XT (gfx1032) | HIP |
| `results/rtx3060ti/` | Xeon E5-1680 v3 | GeForce RTX 3060 Ti | CUDA |

Each GPU directory also holds `info.txt` (host `nproc` and the vendor SMI
dump), `kernel_info.txt` (per-kernel register, spill and occupancy data
from `-Dkernel-stats=true`) and the disassembled device code (`*.s`), plus a
`_sweep` table from the batch-size sweep.

**[`REPORT.md`](REPORT.md) is the full CPU vs HIP vs CUDA analysis** of
those runs -- where each backend spends its time, why NVIDIA leads AMD by
a constant 2.2x, and why the faster GPU lost the COCO end-to-end number.

`results/laptop-cpu.md` is the CPU run described above. Two things in it
are worth reading carefully rather than at a glance:

**CIFAR-10 at 58.9% is an under-trained number, not a broken one.** 1000
batches of 128 is about 2.5 passes over 50 000 images. The loss is still
falling when the schedule ends. The config is sized so that a CPU can finish
it, not so that it converges.

**COCO at 35.5% top-1 is barely above the majority-class baseline of 31.1%.**
That is what the last column of the table is for. `person` accounts for 1 299
of the 4 177 validation crops, so a model that answered "person" every time
would score 31.1%, and top-5 has a 43.6% baseline against the measured 55.4%.
The network is learning something, but not much, and the honest reading is
that 80-way classification of small occluded crops needs either a bigger net
or far more than four epochs. COCO earns its place in the suite by being the
only dataset here with real JPEG decode cost and an 80-wide output, both of
which are what the throughput columns are measuring.

## Watching the clocks

`monitor.sh` samples GPU clock, power, temperature and utilisation while
something runs, and reports what the card actually sustained:

```sh
./bench/monitor.sh -- ./bench/benchmark.sh --platforms gpu \
    --datasets cifar10-full --train-batches 1000 --tag <machine>
```

It wraps the command rather than running alongside it, so sampling starts and
stops with the work and the exit status is passed through. Samples land in
`results/monitor-<timestamp>.csv`; the summary only counts samples taken while
the GPU was at least 90% busy (`--busy`), so idle startup and the weight-saving
tail do not drag the averages down.

What it prints is the median clock **as a fraction of that card's own
maximum**, which is the only form that compares across vendors -- 2310 MHz
means nothing next to 1800 MHz until you know both cards' ceilings. A median
well below 100%, or a 10th percentile far below the median, is sustained
throttling; a steady clock at the cap is not. On NVIDIA it also reports the
driver's own throttle reasons (`SwPowerCap`, `HwSlowdown`, `SwThermalSlowdown`
and so on), which name the cause directly.

NVIDIA goes through `nvidia-smi`. **AMD reads sysfs rather than `rocm-smi`**,
for three reasons: it needs no ROCm libraries, which matters because `rocm-smi`
on our test machine cannot load `libdrm_amdgpu` and fails `get_name`; sysfs
reports the real shader clock from `freq1_input`, whereas `rocm-smi`'s DPM
state is three coarse values on RDNA 2 and would hide exactly the throttling
being looked for; and it sidesteps card numbering. That last point matters on
any desktop with an AMD APU, where the iGPU is a second `amdgpu` device --
the script defaults to the card with the most VRAM and prints which it chose,
and `--card N` overrides it.

If you want `rocm-smi` anyway as a cross-check, `rocm-smi --showgpuclocks
--showpower` works even when `get_name` does not.

## Notes

`get-data.sh` downloads to a `.part` file and renames it only after curl
reports success, then verifies the container with `gzip -t` or `unzip -t`
before extracting, re-fetching once if it is damaged. This is not
belt-and-braces for its own sake: an earlier version guarded on "the file
exists and is non-empty", and a transfer that cs.toronto.edu throttled to a
halt left a half-written archive that looked complete to the script and blew
up inside `tar`.

That server is slow — expect CIFAR-10 to take half an hour or so, against
about two minutes for COCO's much larger download. The transfer resumes, so
interrupting it is safe.
