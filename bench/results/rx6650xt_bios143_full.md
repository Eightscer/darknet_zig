# darknet-zig benchmark: rx6650xt_bios143_full

- date: 2026-09-27T17:28:29Z
- host: Linux 6.18.52 x86_64
- cpu: AMD Ryzen 7 5700G with Radeon Graphics

| platform | dataset | device | classes | batches | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cpu | mnist | CPU | 10 | 1000 | 816.0 | 0.1568 | 2234.5 | 2184.7 | 0.9775 | 0.9997 | 0.1135 |
| cpu | cifar10 | CPU | 10 | 1000 | 255.9 | 1.2884 | 718.1 | 713.1 | 0.5889 | 0.9539 | 0.1000 |
| cpu | coco | CPU | 80 | 1000 | 71.2 | 2.7687 | 184.8 | 173.5 | 0.3548 | 0.5542 | 0.3110 |
| gpu | mnist | AMD Radeon RX 6650 XT | 10 | 1000 | 8063.7 | 0.0897 | 24933.9 | 20415.2 | 0.9764 | 0.9997 | 0.1135 |
| gpu | cifar10 | AMD Radeon RX 6650 XT | 10 | 1000 | 3585.7 | 1.3797 | 9385.3 | 8582.3 | 0.5873 | 0.9554 | 0.1000 |
| gpu | coco | AMD Radeon RX 6650 XT | 80 | 1000 | 1008.6 | 3.2408 | 3758.2 | 1912.3 | 0.3459 | 0.5525 | 0.3110 |
| gpu | cifar10-full | AMD Radeon RX 6650 XT | 10 | 1000 | 178.6 | 0.9682 | 525.4 | 522.1 | 0.4982 | 0.9395 | 0.1000 |

`infer img/s` is the network forward pass alone; the next column
includes JPEG/PNG decode and centre-cropping, which is what an
end-to-end pipeline actually costs. The last column is what you would
score by always guessing the validation set's most common class.
Throughput is per-image, so it compares across rows; top-1 only
compares between rows that trained for the same number of batches.
