# darknet-zig benchmark: rx6650xt_bench

- date: 2026-09-25T20:41:15Z
- host: Linux 6.12.93 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cpu | mnist | CPU | 10 | 1000 | 781.1 | 0.1568 | 2148.1 | 2118.3 | 0.9775 | 0.9997 | 0.1135 |
| cpu | cifar10 | CPU | 10 | 1000 | 244.9 | 1.2884 | 689.9 | 685.0 | 0.5889 | 0.9539 | 0.1000 |
| cpu | coco | CPU | 80 | 1000 | 67.8 | 2.7687 | 172.5 | 164.5 | 0.3548 | 0.5542 | 0.3110 |
| gpu | mnist | AMD Radeon RX 6650 XT | 10 | 1000 | 4306.8 | 0.0897 | 13290.1 | 12181.9 | 0.9764 | 0.9997 | 0.1135 |
| gpu | cifar10 | AMD Radeon RX 6650 XT | 10 | 1000 | 1975.0 | 1.3797 | 5464.5 | 5176.6 | 0.5873 | 0.9554 | 0.1000 |
| gpu | coco | AMD Radeon RX 6650 XT | 80 | 1000 | 557.7 | 3.2408 | 2264.0 | 1412.3 | 0.3459 | 0.5525 | 0.3110 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
