#!/usr/bin/env bash
# Downloads the benchmark datasets and converts them into darknet's layout.
#
#   ./bench/get-data.sh [mnist] [cifar10] [coco]      (default: mnist cifar10)
#
# COCO is ~1 GB and is not fetched unless asked for by name.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$here")"
raw="$here/data/raw"
prepare="$root/zig-out/bin/bench-prepare"

want=("$@")
[ ${#want[@]} -eq 0 ] && want=(mnist cifar10)

if [ ! -x "$prepare" ]; then
    echo "building the converter..."
    (cd "$root" && zig build bench-prepare -Doptimize=ReleaseFast)
fi

mkdir -p "$raw"

# Download to a sibling .part and rename only once curl reports success, so an
# interrupted transfer never leaves a file that looks finished. An earlier run
# of this script guarded on `[ -s "$dest" ]` alone and happily handed a
# half-written 17 MB CIFAR archive to tar.
#
# `-C -` resumes into an existing .part, and --speed-time gives up on a
# transfer that has stalled rather than sitting on a dead socket until the
# user notices. cs.toronto.edu serves CIFAR at about 75 KB/s and stalls
# outright often enough that a single un-resumed curl rarely finishes.
fetch() {  # fetch <url> <dest>
    local url="$1" dest="$2" part="$2.part" a
    if [ -s "$dest" ]; then echo "  have $(basename "$dest")"; return; fi
    echo "  fetching $(basename "$dest")"
    for a in $(seq 1 60); do
        if curl -fL -C - --speed-limit 2000 --speed-time 20 --connect-timeout 20 \
                --progress-bar -o "$part" "$url"; then
            mv -f "$part" "$dest"
            return
        fi
        echo "  attempt $a stalled at $(stat -c %s "$part" 2>/dev/null || echo 0) bytes; resuming"
        sleep 3
    done
    echo "  giving up on $url"
    return 1
}

# Second line of defence: the rename above can still promote a file that the
# server truncated with a clean close. Check the container before trusting it,
# and re-fetch once from scratch if it is damaged.
verify() {  # verify <url> <dest> <test-cmd...>
    local url="$1" dest="$2"; shift 2
    if "$@" "$dest" >/dev/null 2>&1; then return; fi
    echo "  $(basename "$dest") is corrupt or truncated; re-fetching from scratch"
    rm -f "$dest" "$dest.part"   # not -C - into known-bad bytes
    fetch "$url" "$dest"
    "$@" "$dest" >/dev/null 2>&1 || { echo "  still bad after re-fetch: $dest"; exit 1; }
}

get() {  # get <url> <dest> <test-cmd...>
    local url="$1" dest="$2"; shift 2
    fetch "$url" "$dest"
    verify "$url" "$dest" "$@"
}

for d in "${want[@]}"; do
case "$d" in

mnist)
    echo "== MNIST =="
    base=https://storage.googleapis.com/cvdf-datasets/mnist
    for f in train-images-idx3-ubyte train-labels-idx1-ubyte t10k-images-idx3-ubyte t10k-labels-idx1-ubyte; do
        get "$base/$f.gz" "$raw/$f.gz" gzip -t
        [ -s "$raw/$f" ] || gunzip -kf "$raw/$f.gz"
    done
    "$prepare" mnist "$raw" "$here/data/mnist"
    ;;

cifar10)
    echo "== CIFAR-10 =="
    get https://www.cs.toronto.edu/~kriz/cifar-10-binary.tar.gz "$raw/cifar-10-binary.tar.gz" gzip -t
    # Keyed on a file the archive actually contains rather than on the
    # directory: a failed extraction leaves the directory behind.
    [ -s "$raw/cifar-10-batches-bin/test_batch.bin" ] || tar -xzf "$raw/cifar-10-binary.tar.gz" -C "$raw"
    "$prepare" cifar10 "$raw" "$here/data/cifar10"
    ;;

coco)
    echo "== COCO val2017 (classification crops) =="
    get http://images.cocodataset.org/zips/val2017.zip "$raw/val2017.zip" unzip -tqq
    get http://images.cocodataset.org/annotations/annotations_trainval2017.zip "$raw/annotations.zip" unzip -tqq
    [ -d "$raw/val2017" ] || unzip -q "$raw/val2017.zip" -d "$raw"
    [ -s "$raw/annotations/instances_val2017.json" ] || \
        unzip -q "$raw/annotations.zip" -d "$raw" 'annotations/instances_val2017.json'
    "$prepare" coco "$raw" "$here/data/coco"
    ;;

*)  echo "unknown dataset: $d"; exit 1 ;;
esac
done

echo
echo "done. datasets are under $here/data/"
