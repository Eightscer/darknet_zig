# darknet-zig benchmark: rx6650xt_monitor

- date: 2026-09-26T21:22:28Z
- host: Linux 6.12.93 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-full | AMD Radeon RX 6650 XT | 10 | 1000 | 87.5 | 0.9682 | 255.7 | 254.1 | 0.4982 | 0.9395 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
