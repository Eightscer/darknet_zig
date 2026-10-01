# darknet-zig benchmark: rx6650xt_cpu_rep3

- date: 2026-10-01T19:26:29Z
- host: Linux 6.18.54 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | gemm | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| cpu | mnist | CPU | cpu | 10 | 300 | 986.8 | 0.1981 | 3346.8 | 3301.9 | 0.9736 | 0.9995 | 0.1135 |
| cpu | cifar10 | CPU | cpu | 10 | 300 | 380.8 | 1.3838 | 1272.2 | 1261.4 | 0.4778 | 0.9279 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
