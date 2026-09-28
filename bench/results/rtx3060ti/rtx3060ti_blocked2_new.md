# darknet-zig benchmark: rtx3060ti_blocked2_new

- date: 2026-09-27T22:51:50Z
- host: Linux 5.15.0-191-generic x86_64
- cpu: Intel(R) Xeon(R) CPU E5-1680 v3 @ 3.20GHz

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gpu | cifar10 | NVIDIA GeForce RTX 3060 Ti | blocked | 10 | 1000 | 4183.9 | 1.4526 | 9936.5 | 8399.6 | 0.5808 | 0.9551 | 0.1000 |
| gpu | cifar10-full | NVIDIA GeForce RTX 3060 Ti | blocked | 10 | 1000 | 340.4 | 1.0657 | 706.7 | 694.4 | 0.5056 | 0.9386 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
