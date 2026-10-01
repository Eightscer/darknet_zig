# darknet-zig benchmark: rx6650xt_tiles_12

- date: 2026-10-01T23:16:45Z
- host: Linux 6.18.54 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10 | AMD Radeon RX 6650 XT | blocked | 10 | 300 | 3767.9 | 1.4343 | 9475.4 | 8909.1 | 0.5198 | 0.9389 | 0.1000 |
| gpu | coco | AMD Radeon RX 6650 XT | blocked | 80 | 300 | 1031.7 | 3.1433 | 3768.4 | 2101.7 | 0.3318 | 0.5221 | 0.3110 |
| gpu | cifar10-full | AMD Radeon RX 6650 XT | blocked | 10 | 300 | 255.9 | 1.4276 | 590.6 | 587.5 | 0.3454 | 0.8974 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
