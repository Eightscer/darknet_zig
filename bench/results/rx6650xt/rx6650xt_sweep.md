# darknet-zig benchmark: rx6650xt_sweep

- date: 2026-09-26T02:42:54Z
- host: Linux 6.12.93 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-fullb16 | AMD Radeon RX 6650 XT | 10 | 200 | 86.9 | 2.0068 | 257.2 | 255.9 | 0.3081 | 0.7973 | 0.1000 |
| gpu | cifar10-fullb32 | AMD Radeon RX 6650 XT | 10 | 200 | 87.5 | 1.7008 | 258.1 | 257.1 | 0.2735 | 0.8265 | 0.1000 |
| gpu | cifar10-fullb64 | AMD Radeon RX 6650 XT | 10 | 200 | 87.4 | 1.7865 | 255.6 | 254.8 | 0.2823 | 0.8260 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
