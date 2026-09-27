# darknet-zig benchmark: rx6650xt_clean

- date: 2026-09-27T15:11:29Z
- host: Linux 6.18.52 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-full | AMD Radeon RX 6650 XT | 10 | 100 | 88.1 | 1.6098 | 256.9 | 254.0 | 0.1976 | 0.6243 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
