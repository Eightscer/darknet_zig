# darknet-zig benchmark: rx6650xt_simple

- date: 2026-09-27T19:48:16Z
- host: Linux 6.18.52 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10 | AMD Radeon RX 6650 XT | ?(stale binary) | 10 | 1000 | 2881.8 | 1.4689 | 6109.9 | 5818.1 | 0.5838 | 0.9539 | 0.1000 |
| gpu | cifar10-full | AMD Radeon RX 6650 XT | ?(stale binary) | 10 | 1000 | 229.9 | 1.0922 | 484.4 | 482.4 | 0.4942 | 0.9320 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
