# darknet-zig benchmark: rtx3060ti_sweep

- date: 2026-09-26T20:16:29Z
- host: Linux 5.15.0-191-generic x86_64
- cpu: Intel(R) Xeon(R) CPU E5-1680 v3 @ 3.20GHz

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-fullb16 | NVIDIA GeForce RTX 3060 Ti | 10 | 200 | 203.3 | 2.0166 | 582.3 | 564.0 | 0.2652 | 0.8039 | 0.1000 |
| gpu | cifar10-fullb32 | NVIDIA GeForce RTX 3060 Ti | 10 | 200 | 204.9 | 1.7293 | 585.6 | 569.3 | 0.3417 | 0.8587 | 0.1000 |
| gpu | cifar10-fullb64 | NVIDIA GeForce RTX 3060 Ti | 10 | 200 | 207.0 | 1.7624 | 583.9 | 569.3 | 0.2479 | 0.8026 | 0.1000 |
| gpu | cifar10-fullb16 | NVIDIA GeForce RTX 3060 Ti | 10 | 200 | 205.6 | 2.0166 | 586.4 | 479.7 | 0.2652 | 0.8039 | 0.1000 |
| gpu | cifar10-fullb32 | NVIDIA GeForce RTX 3060 Ti | 10 | 200 | 205.1 | 1.7293 | 584.8 | 496.8 | 0.3417 | 0.8587 | 0.1000 |
| gpu | cifar10-fullb64 | NVIDIA GeForce RTX 3060 Ti | 10 | 200 | 205.5 | 1.7624 | 583.0 | 479.8 | 0.2479 | 0.8026 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
