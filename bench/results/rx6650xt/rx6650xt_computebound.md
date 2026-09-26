# darknet-zig benchmark: rx6650xt_computebound

- date: 2026-09-25T22:04:59Z
- host: Linux 6.12.93 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-full | AMD Radeon RX 6650 XT | 10 | 1000 | 87.4 | 0.9682 | 254.4 | 253.7 | 0.4982 | 0.9395 | 0.1000 |
| cpu | cifar10-full | CPU | 10 | 20 | 6.5 | 2.1326 | 20.2 | 20.2 | 0.1750 | 0.5437 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
