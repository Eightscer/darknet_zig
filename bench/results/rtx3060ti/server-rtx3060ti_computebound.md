# darknet-zig benchmark: server-rtx3060ti_computebound

- date: 2026-09-26T00:11:06Z
- host: Linux 5.15.0-191-generic x86_64
- cpu: Intel(R) Xeon(R) CPU E5-1680 v3 @ 3.20GHz

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10-full | NVIDIA GeForce RTX 3060 Ti | 10 | 1000 | 205.9 | 0.9671 | 578.0 | 562.9 | 0.5242 | 0.9482 | 0.1000 |
| cpu | cifar10-full | CPU | 10 | 20 | 2.6 | 2.1326 | 8.9 | 8.9 | 0.1750 | 0.5437 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
