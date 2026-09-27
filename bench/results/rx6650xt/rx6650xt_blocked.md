# darknet-zig benchmark: rx6650xt_blocked

- date: 2026-09-27T18:23:07Z
- host: Linux 6.18.52 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| cpu | mnist | CPU | ?(stale binary) | 10 | 1000 | 1036.6 | 0.0649 | 3482.4 | 3434.6 | 0.9758 | 0.9996 | 0.1135 |
| cpu | cifar10 | CPU | ?(stale binary) | 10 | 1000 | 397.7 | 1.1732 | 1292.1 | 1281.1 | 0.5871 | 0.9523 | 0.1000 |
| cpu | coco | CPU | ?(stale binary) | 80 | 1000 | 96.1 | 2.9329 | 250.8 | 238.4 | 0.3445 | 0.5537 | 0.3110 |
| gpu | mnist | AMD Radeon RX 6650 XT | ?(stale binary) | 10 | 1000 | 7663.7 | 0.1429 | 24143.1 | 20715.4 | 0.9767 | 0.9997 | 0.1135 |
| gpu | cifar10 | AMD Radeon RX 6650 XT | ?(stale binary) | 10 | 1000 | 2884.5 | 1.4668 | 6102.1 | 5807.2 | 0.5827 | 0.9543 | 0.1000 |
| gpu | coco | AMD Radeon RX 6650 XT | ?(stale binary) | 80 | 1000 | 952.3 | 3.0838 | 3131.9 | 1900.7 | 0.3495 | 0.5485 | 0.3110 |
| gpu | cifar10-full | AMD Radeon RX 6650 XT | ?(stale binary) | 10 | 1000 | 230.0 | 1.1039 | 484.4 | 482.3 | 0.4855 | 0.9276 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
