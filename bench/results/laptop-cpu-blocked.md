# darknet-zig benchmark: laptop-cpu-blocked

- date: 2026-09-30T16:10:12Z
- host: Linux 6.18.52 x86_64
- cpu: 11th Gen Intel(R) Core(TM) i7-1185G7 @ 3.00GHz

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| cpu | mnist | CPU | cpu | 10 | 1000 | 762.5 | 0.1573 | 2871.2 | 2769.5 | 0.9777 | 0.9997 | 0.1135 |
| cpu | cifar10 | CPU | cpu | 10 | 1000 | 200.3 | 1.3279 | 974.6 | 886.6 | 0.5884 | 0.9542 | 0.1000 |
| cpu | coco | CPU | cpu | 80 | 1000 | 49.4 | 2.7406 | 180.9 | 162.2 | 0.3536 | 0.5514 | 0.3110 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
