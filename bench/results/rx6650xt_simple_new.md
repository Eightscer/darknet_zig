# darknet-zig benchmark: rx6650xt_simple_new

- date: 2026-09-27T22:57:08Z
- host: Linux 6.18.52 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10 | AMD Radeon RX 6650 XT | simple | 10 | 1000 | 3599.9 | 1.4284 | 9472.5 | 8912.2 | 0.5795 | 0.9535 | 0.1000 |
| gpu | cifar10-full | AMD Radeon RX 6650 XT | simple | 10 | 1000 | 178.7 | 1.0702 | 525.9 | 523.4 | 0.5215 | 0.9415 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
