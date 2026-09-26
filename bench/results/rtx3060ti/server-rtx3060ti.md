# darknet-zig benchmark: server-rtx3060ti

- date: 2026-09-25T22:22:57Z
- host: Linux 5.15.0-191-generic x86_64
- cpu: Intel(R) Xeon(R) CPU E5-1680 v3 @ 3.20GHz

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cpu | mnist | CPU | 10 | 1000 | 334.9 | 0.1568 | 1049.1 | 1018.9 | 0.9775 | 0.9997 | 0.1135 |
| cpu | cifar10 | CPU | 10 | 1000 | 84.9 | 1.2884 | 223.8 | 221.4 | 0.5889 | 0.9539 | 0.1000 |
| cpu | coco | CPU | 80 | 1000 | 23.0 | 2.7687 | 62.3 | 59.2 | 0.3548 | 0.5542 | 0.3110 |
| gpu | mnist | NVIDIA GeForce RTX 3060 Ti | 10 | 1000 | 8996.0 | 0.0881 | 31300.5 | 16885.0 | 0.9763 | 0.9997 | 0.1135 |
| gpu | cifar10 | NVIDIA GeForce RTX 3060 Ti | 10 | 1000 | 4533.7 | 1.4101 | 12846.1 | 8909.7 | 0.5853 | 0.9542 | 0.1000 |
| gpu | coco | NVIDIA GeForce RTX 3060 Ti | 80 | 1000 | 1132.5 | 3.2635 | 4402.2 | 987.2 | 0.3471 | 0.5518 | 0.3110 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
