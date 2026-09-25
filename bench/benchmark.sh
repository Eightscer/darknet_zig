#!/usr/bin/env bash
# Benchmarks training throughput, inference throughput and accuracy for one or
# more platforms across one or more datasets.
#
#   ./bench/benchmark.sh [options]
#     --platforms cpu,gpu    which to run (default: cpu)
#     --datasets mnist,cifar10,coco
#     --train-batches N      timed training batches per run (default 1000,
#                            which is every config's max_batches)
#     --infer-images N       validation images to time, 0 = all (default 0)
#     --gpu-index N          device index for the gpu platform (default 0)
#     --tag NAME             label for the results file (default: hostname)
#     --out DIR              results directory (default bench/results)
#     --from-raw             re-render the tables from raw/, running nothing
#     --append               add to an existing csv instead of replacing it
#
# Writes <out>/<tag>.csv and <out>/<tag>.md, and keeps the raw key=value output
# of every run in <out>/raw/.
#
# The binary must already be built for the platform being measured: `gpu` here
# just means "pass -gpu <index>", so build with -Dgpu=true and the right
# backend first. Measuring CPU and GPU in one invocation therefore requires a
# GPU-enabled build, which runs the CPU path perfectly well.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$here")"
bin="$root/zig-out/bin/darknet-zig"

platforms=cpu
datasets=mnist,cifar10
train_batches=1000
infer_images=0
gpu_index=0
tag="$(hostname -s 2>/dev/null || echo results)"
out="$here/results"
# Re-render the tables from raw/ without re-running anything, for when the
# report format changes and the measurements have not.
from_raw=0
# Add to an existing csv rather than starting a new one, so several
# invocations on one machine land in a single table.
append=0

while [ $# -gt 0 ]; do
    case "$1" in
        --platforms)     platforms="$2"; shift 2 ;;
        --datasets)      datasets="$2"; shift 2 ;;
        --train-batches) train_batches="$2"; shift 2 ;;
        --infer-images)  infer_images="$2"; shift 2 ;;
        --gpu-index)     gpu_index="$2"; shift 2 ;;
        --tag)           tag="$2"; shift 2 ;;
        --out)           out="$2"; shift 2 ;;
        --from-raw)      from_raw=1; shift ;;
        --append)        append=1; shift ;;
        -h|--help)       sed -n '2,20p' "$0"; exit 0 ;;
        *) echo "unknown option: $1"; exit 1 ;;
    esac
done

[ -x "$bin" ] || { echo "no binary at $bin -- run: zig build -Doptimize=ReleaseFast"; exit 1; }

mkdir -p "$out/raw"
csv="$out/$tag.csv"
md="$out/$tag.md"

header="platform,dataset,device,classes,train_img_per_s,train_final_loss,infer_img_per_s,infer_e2e_img_per_s,top1,top5,majority_baseline"
if [ "$append" = 1 ] && [ -s "$csv" ]; then
    echo "appending to $csv"
else
    echo "$header" > "$csv"
fi

# Pull one key out of a key=value block.
val() { grep -m1 "^$2=" "$1" | cut -d= -f2- || true; }

# Same, but with a fallback for keys that older recorded runs predate.
vald() {  # vald <file> <key> <default>
    local v; v=$(val "$1" "$2"); echo "${v:-$3}"
}

# The share of the validation set belonging to its single most common class --
# what you would score by always guessing that class. Without it a top-1 is
# hard to read: COCO's crops are 31% `person`, so 35% top-1 is a much weaker
# result than the same number would be on a balanced set.
majority() {  # majority <valid.list>
    local total
    total=$(wc -l < "$1")
    [ "$total" -gt 0 ] || { echo ""; return; }
    sed 's|.*/images/||; s|/[^/]*$||' "$1" | sort | uniq -c | sort -rn | head -1 \
        | awk -v t="$total" '{printf "%.4f", $1/t}'
}
for platform in ${platforms//,/ }; do
    case "$platform" in
        cpu) flags=() ;;
        gpu) flags=(-gpu "$gpu_index") ;;
        *) echo "unknown platform: $platform"; exit 1 ;;
    esac

    for ds in ${datasets//,/ }; do
        base="${ds%%-*}"
        data="$here/data/$base/$base.data"
        cfg="$here/cfg/$ds.cfg"
        if [ ! -f "$data" ]; then
            echo "skipping $ds on $platform: $data not found (run ./bench/get-data.sh $base)"
            continue
        fi

        echo "== $platform / $ds =="
        raw="$out/raw/$tag-$platform-$ds.txt"
        if [ "$from_raw" = 1 ]; then
            [ -f "$raw" ] || { echo "  no recorded run at $raw"; continue; }
            echo "  re-rendering from $raw"
        else
            # Fixed seed so accuracy is comparable between platforms rather than
            # differing by initialisation luck.
            "$bin" benchmark "$data" "$cfg" \
                "${flags[@]}" \
                -seed 1 \
                -train-batches "$train_batches" \
                -infer-images "$infer_images" \
                -save-weights "$here/data/$base/backup/$ds-$platform.weights" \
                > "$raw" 2> "$raw.log" || { echo "  FAILED -- see $raw.log"; tail -5 "$raw.log"; continue; }
        fi
        cat "$raw" | sed 's/^/  /'
        printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
            "$platform" "$ds" \
            "$(vald "$raw" device CPU)" \
            "$(val "$raw" classes)" \
            "$(val "$raw" train_images_per_sec)" \
            "$(val "$raw" train_final_loss)" \
            "$(val "$raw" infer_forward_images_per_sec)" \
            "$(val "$raw" infer_end_to_end_images_per_sec)" \
            "$(val "$raw" top1)" \
            "$(val "$raw" top5)" \
            "$(majority "$here/data/$base/valid.list")" >> "$csv"
    done
done

# Render the csv as a markdown table.
{
    echo "# darknet-zig benchmark: $tag"
    echo
    echo "- date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "- host: $(uname -srm)"
    echo "- cpu: $(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //' || echo unknown)"
    echo "- timed training batches: $train_batches"
    echo
    echo "| platform | dataset | device | classes | train img/s | final loss | infer img/s | infer img/s (with decode) | top-1 | top-5 | majority-class baseline |"
    echo "|---|---|---|---|---|---|---|---|---|---|---|"
    tail -n +2 "$csv" | awk -F, '{printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'
    echo
    echo "\`infer img/s\` is the network forward pass alone; the next column"
    echo "includes JPEG/PNG decode and centre-cropping, which is what an"
    echo "end-to-end pipeline actually costs. The last column is what you would"
    echo "score by always guessing the validation set's most common class."
} > "$md"

echo
echo "wrote $csv"
echo "wrote $md"
