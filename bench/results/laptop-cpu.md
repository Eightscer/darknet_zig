# darknet-zig benchmark: laptop-cpu

- date: 2026-09-25T18:48:16Z
- host: Linux 6.18.52 x86_64
- cpu: 11th Gen Intel(R) Core(TM) i7-1185G7 @ 3.00GHz

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cpu | mnist | CPU | 10 | 1000 | 465.6 | 0.1568 | 1275.1 | 1251.0 | 0.9775 | 0.9997 | 0.1135 |
| cpu | cifar10 | CPU | 10 | 1000 | 94.2 | 1.2884 | 230.5 | 224.6 | 0.5889 | 0.9539 | 0.1000 |
| cpu | coco | CPU | 80 | 1000 | 28.2 | 2.7687 | 81.0 | 76.1 | 0.3548 | 0.5542 | 0.3110 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
