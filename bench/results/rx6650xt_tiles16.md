# darknet-zig benchmark: rx6650xt_tiles16

- date: 2026-10-01T20:04:04Z
- host: Linux 6.18.54 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-full | AMD Radeon RX 6650 XT | blocked | 10 | 1000 | 255.9 | 1.0911 | 590.4 | 587.4 | 0.4739 | 0.9315 | 0.1000 |
| gpu | cifar10 | AMD Radeon RX 6650 XT | blocked | 10 | 1000 | 3772.0 | 1.4663 | 9491.0 | 8868.7 | 0.5821 | 0.9543 | 0.1000 |
| gpu | coco | AMD Radeon RX 6650 XT | blocked | 80 | 1000 | 1032.5 | 3.0838 | 3764.8 | 2105.6 | 0.3495 | 0.5485 | 0.3110 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
