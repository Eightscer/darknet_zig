# darknet-zig benchmark: rx6650xt_tiles_16

- date: 2026-10-01T23:20:08Z
- host: Linux 6.18.54 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10 | AMD Radeon RX 6650 XT | blocked | 10 | 300 | 3769.7 | 1.4552 | 9496.3 | 8893.4 | 0.5022 | 0.9298 | 0.1000 |
| gpu | coco | AMD Radeon RX 6650 XT | blocked | 80 | 300 | 1033.9 | 3.1433 | 3767.2 | 2107.0 | 0.3318 | 0.5221 | 0.3110 |
| gpu | cifar10-full | AMD Radeon RX 6650 XT | blocked | 10 | 300 | 255.9 | 1.4536 | 590.4 | 587.2 | 0.4028 | 0.9101 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
