#!/usr/bin/env bash
# Samples GPU clock, power, temperature and utilisation while a command runs,
# then reports what the card actually sustained.
#
#   ./bench/monitor.sh [options] -- <command...>
#     --interval SEC   sampling period (default 0.5)
#     --out FILE       where to write the samples (default bench/results/monitor-<date>.csv)
#     --card N         AMD only: /sys/class/drm/cardN. Default is the card with
#                      the most VRAM, which picks the discrete GPU over an iGPU.
#     --busy N         ignore samples below this utilisation when summarising
#                      (default 90), so idle head and tail do not drag the
#                      averages down
#
# The question this answers is not "how fast is the clock" but "how much of its
# own maximum did this card hold under sustained load", which is the only form
# that compares across two vendors.
#
# NVIDIA goes through nvidia-smi. AMD reads sysfs directly rather than
# rocm-smi: sysfs needs no ROCm libraries (rocm-smi on at least one of our
# machines cannot load libdrm_amdgpu and fails `get_name`), it costs less per
# sample, and it sidesteps having to pick the right card out of rocm-smi's
# numbering when an iGPU is also present.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Overridable only so the AMD path can be exercised against a fake sysfs
# tree in tests; there is no reason to set it in normal use.
drm="${DARKNET_DRM_ROOT:-/sys/class/drm}"
interval=0.5
out=""
card=""
busy_floor=90

while [ $# -gt 0 ]; do
    case "$1" in
        --interval) interval="$2"; shift 2 ;;
        --out)      out="$2"; shift 2 ;;
        --card)     card="$2"; shift 2 ;;
        --busy)     busy_floor="$2"; shift 2 ;;
        --)         shift; break ;;
        -h|--help)  sed -n '2,18p' "$0"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done
[ $# -gt 0 ] || { echo "nothing to run -- put the command after --" >&2; exit 1; }

mkdir -p "$here/results"
[ -n "$out" ] || out="$here/results/monitor-$(date -u +%Y%m%dT%H%M%SZ).csv"

# ---------------------------------------------------------------------------
# backend selection
# ---------------------------------------------------------------------------
backend=
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
    backend=nvidia
elif ls "$drm"/card*/device/mem_info_vram_total >/dev/null 2>&1; then
    backend=amd
else
    echo "no usable GPU interface: need nvidia-smi, or amdgpu sysfs" >&2
    exit 1
fi

# Newer drivers renamed clocks_throttle_reasons to clocks_event_reasons and
# keep the old spelling as a deprecated alias that some builds reject.
reason_field=
if [ "$backend" = nvidia ]; then
    if nvidia-smi --help-query-gpu 2>/dev/null | grep -q clocks_event_reasons; then
        reason_field=clocks_event_reasons.active
    elif nvidia-smi --help-query-gpu 2>/dev/null | grep -q clocks_throttle_reasons; then
        reason_field=clocks_throttle_reasons.active
    fi
fi

# Pick the AMD card with the most VRAM: on a desktop with an APU the iGPU is
# also an amdgpu device, and it is never the one being benchmarked.
if [ "$backend" = amd ] && [ -z "$card" ]; then
    best=-1
    for d in "$drm"/card*/device/mem_info_vram_total; do
        [ -r "$d" ] || continue
        v=$(cat "$d" 2>/dev/null || echo 0)
        if [ "$v" -gt "$best" ]; then
            best=$v
            card=$(echo "$d" | sed "s|^$drm/card\\([0-9]*\\)/.*|\\1|")
        fi
    done
    [ -n "$card" ] || { echo "no amdgpu card found" >&2; exit 1; }
fi

if [ "$backend" = amd ]; then
    dev=$drm/card$card/device
    hwmon=$(echo "$dev"/hwmon/hwmon* | awk '{print $1}')
    vram_mb=$(( $(cat "$dev/mem_info_vram_total") / 1048576 ))
    echo "monitoring amdgpu card$card (${vram_mb} MiB VRAM) via sysfs"
else
    echo "monitoring $(nvidia-smi --query-gpu=name --format=csv,noheader | head -1) via nvidia-smi"
fi

# ---------------------------------------------------------------------------
# sampling
# ---------------------------------------------------------------------------
echo "t_s,sclk_mhz,sclk_max_mhz,busy_pct,power_w,power_cap_w,temp_c,reasons" > "$out"

sample_amd() {
    local t0 now sclk smax busy pw cap tc
    t0=$(date +%s.%N)
    # freq1_input is the real shader clock in Hz; pp_dpm_sclk only reports the
    # coarse DPM state, which on RDNA 2 is three values and hides throttling.
    smax=$(awk '{gsub(/Mhz|MHz/,"",$2); if ($2+0>m) m=$2+0} END{print m+0}' "$dev/pp_dpm_sclk" 2>/dev/null || echo 0)
    cap=$(awk '{printf "%.0f", $1/1000000}' "$hwmon/power1_cap" 2>/dev/null || echo 0)
    while :; do
        now=$(date +%s.%N)
        sclk=$(awk '{printf "%.0f", $1/1000000}' "$hwmon/freq1_input" 2>/dev/null || echo 0)
        busy=$(cat "$dev/gpu_busy_percent" 2>/dev/null || echo 0)
        pw=$(awk '{printf "%.1f", $1/1000000}' "$hwmon/power1_average" 2>/dev/null || echo 0)
        tc=$(awk '{printf "%.0f", $1/1000}' "$hwmon/temp1_input" 2>/dev/null || echo 0)
        awk -v a="$now" -v b="$t0" -v s="$sclk" -v sm="$smax" -v u="$busy" \
            -v p="$pw" -v c="$cap" -v t="$tc" \
            'BEGIN{printf "%.2f,%s,%s,%s,%s,%s,%s,\n", a-b, s, sm, u, p, c, t}' >> "$out"
        sleep "$interval"
    done
}

sample_nvidia() {
    local t0 now line q
    t0=$(date +%s.%N)
    q="clocks.sm,clocks.max.sm,utilization.gpu,power.draw,enforced.power.limit,temperature.gpu"
    [ -n "$reason_field" ] && q="$q,$reason_field"
    while :; do
        now=$(date +%s.%N)
        line=$(nvidia-smi --query-gpu="$q" --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
        [ -n "$reason_field" ] || line="$line,"
        awk -v a="$now" -v b="$t0" -v l="$line" 'BEGIN{printf "%.2f,%s\n", a-b, l}' >> "$out"
        sleep "$interval"
    done
}

if [ "$backend" = amd ]; then sample_amd & else sample_nvidia & fi
sampler=$!
trap 'kill "$sampler" 2>/dev/null || true' EXIT INT TERM

echo "sampling every ${interval}s into $out"
echo "== running: $* =="
status=0
"$@" || status=$?
kill "$sampler" 2>/dev/null || true
wait "$sampler" 2>/dev/null || true
trap - EXIT INT TERM

# ---------------------------------------------------------------------------
# summary
# ---------------------------------------------------------------------------
echo
echo "== sustained behaviour while busy >= ${busy_floor}% =="
awk -F, -v floor="$busy_floor" '
NR==1 {next}
{
    total++
    if ($4+0 < floor) next
    n++
    clk[n]=$1+0; c[n]=$2+0; if ($3+0>smax) smax=$3+0
    psum+=$5; if ($5+0>pmax) pmax=$5+0; if ($6+0>cap) cap=$6+0
    if ($7+0>tmax) tmax=$7+0
    if ($8 != "" && $8 != "Notactive" && $8 != "N/A") r[$8]++
}
END {
    if (n == 0) {
        printf "  no samples above %d%% utilisation (%d total) -- the run may be\n", floor, total
        printf "  too short for a %ss interval, or bottlenecked off the GPU\n", "'"$interval"'"
        exit
    }
    # median and 10th percentile of the clock
    for (i=1;i<=n;i++) v[i]=c[i]
    for (i=1;i<n;i++) for (j=i+1;j<=n;j++) if (v[j]<v[i]) {t=v[i];v[i]=v[j];v[j]=t}
    med = v[int((n+1)/2)]; p10 = v[int(n*0.1)+1]; lo = v[1]; hi = v[n]
    printf "  samples          %d of %d\n", n, total
    printf "  clock median     %d MHz", med
    if (smax>0) printf "  (%.0f%% of the %d MHz maximum)", 100*med/smax, smax
    printf "\n"
    printf "  clock p10 / min  %d / %d MHz\n", p10, lo
    printf "  clock max        %d MHz\n", hi
    if (psum>0) printf "  power mean/max   %.0f / %.0f W", psum/n, pmax
    if (cap>0)  printf "  (cap %.0f W)", cap
    if (psum>0) printf "\n"
    if (tmax>0) printf "  temp max         %d C\n", tmax
    if (length(r)) { printf "  throttle reasons seen:\n"; for (k in r) printf "    %-40s %d samples\n", k, r[k] }
    else printf "  throttle reasons: none reported\n"
    printf "\n  A median well under 100%% of maximum, or a p10 far below the median,\n"
    printf "  is sustained throttling. A steady clock at the cap is not.\n"
}' "$out"

echo
echo "wrote $out"
exit "$status"
