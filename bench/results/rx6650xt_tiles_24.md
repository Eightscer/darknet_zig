# darknet-zig benchmark: rx6650xt_tiles_24

- date: 2026-10-01T23:23:32Z
- host: Linux 6.18.54 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10 | AMD Radeon RX 6650 XT | blocked | 10 | 300 | 3795.1 | 1.4663 | 9489.5 | 8900.6 | 0.5073 | 0.9293 | 0.1000 |
| gpu | coco | AMD Radeon RX 6650 XT | blocked | 80 | 300 | 1031.2 | 3.1433 | 3766.4 | 2103.2 | 0.3318 | 0.5221 | 0.3110 |
| gpu | cifar10-full | AMD Radeon RX 6650 XT | blocked | 10 | 300 | 255.1 | 1.4618 | 585.8 | 582.7 | 0.3238 | 0.8912 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
