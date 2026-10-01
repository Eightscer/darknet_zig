# darknet-zig benchmark: rx6650xt_sweep_fixed

- date: 2026-10-01T19:18:43Z
- host: Linux 6.18.54 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-fullb16 | AMD Radeon RX 6650 XT | blocked | 10 | 200 | 179.9 | 2.2075 | 536.0 | 528.5 | 0.1973 | 0.7458 | 0.1000 |
| gpu | cifar10-fullb32 | AMD Radeon RX 6650 XT | blocked | 10 | 200 | 180.4 | 1.9544 | 537.8 | 532.7 | 0.2728 | 0.7723 | 0.1000 |
| gpu | cifar10-fullb64 | AMD Radeon RX 6650 XT | blocked | 10 | 200 | 180.1 | 1.4222 | 535.1 | 531.6 | 0.3816 | 0.8870 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
