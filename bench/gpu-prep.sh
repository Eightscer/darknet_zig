#!/usr/bin/env bash
# Reports, and optionally sets, the conditions an AMD GPU needs to be measured
# fairly: no other client holding it, no display attached to it, no runtime
# power management, and a DPM governor that recognises a compute workload.
#
#   ./bench/gpu-prep.sh                 report only, no changes, no root needed
#   sudo ./bench/gpu-prep.sh --apply    set a compute-focused state, saving the old one
#   sudo ./bench/gpu-prep.sh --restore  put back exactly what --apply saved
#     --card N   which /sys/class/drm/cardN (default: the one with most VRAM)
#
# Written after a benchmark run found an RX 6650 XT holding 1193 MHz against a
# rated 2635 MHz boost, at 42 W of a 130 W budget and 38 C -- not throttling,
# simply never leaving a low clock state. See bench/REPORT.md.
set -euo pipefail

drm="${DARKNET_DRM_ROOT:-/sys/class/drm}"
state="${DARKNET_PREP_STATE:-/tmp/darknet-gpu-prep.state}"
card=""
mode=report

while [ $# -gt 0 ]; do
    case "$1" in
        --apply)   mode=apply;   shift ;;
        --restore) mode=restore; shift ;;
        --card)    card="$2"; shift 2 ;;
        -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

# Same rule as monitor.sh: on an APU desktop the iGPU is also an amdgpu device
# and is never the card being benchmarked.
if [ -z "$card" ]; then
    best=-1
    for d in "$drm"/card*/device/mem_info_vram_total; do
        [ -r "$d" ] || continue
        v=$(cat "$d" 2>/dev/null || echo 0)
        if [ "$v" -gt "$best" ]; then
            best=$v; card=$(echo "$d" | sed "s|^$drm/card\([0-9]*\)/.*|\1|")
        fi
    done
fi
[ -n "$card" ] || { echo "no amdgpu card found under $drm" >&2; exit 1; }

dev="$drm/card$card/device"
hwmon=$(echo "$dev"/hwmon/hwmon* | awk '{print $1}')
bdf=$(basename "$(readlink -f "$dev")")
rd() { cat "$1" 2>/dev/null || echo "unavailable"; }

# --------------------------------------------------------------------------
# report
# --------------------------------------------------------------------------
if [ "$mode" = report ] || [ "$mode" = apply ]; then
    echo "== card$card ($bdf, $(( $(cat "$dev/mem_info_vram_total") / 1048576 )) MiB) =="
    echo
    echo "-- clock governance (the 1200 MHz question) --"

    # The VBIOS identity, and where the driver got it. A dual-BIOS switch
    # changes the first; whether amdgpu read the board ROM at all changes
    # the second, and the two questions are easy to confuse.
    vb=$(dmesg 2>/dev/null | grep -m1 'ATOM BIOS:' | sed 's/.*ATOM BIOS: //') || true
    vs=$(dmesg 2>/dev/null | grep -m1 'Fetched VBIOS from' | sed 's/.*Fetched VBIOS from //') || true
    printf '  vbios               %s\n' "${vb:-unreadable (try as root)}"
    printf '  vbios source        %s\n' "${vs:-unreadable (try as root)}"
    printf '  performance level   %s\n' "$(rd "$dev/power_dpm_force_performance_level")"
    printf '  sclk DPM levels     %s\n' "$(tr '\n' ' ' < "$dev/pp_dpm_sclk" 2>/dev/null || echo unavailable)"
    printf '  mclk DPM levels     %s\n' "$(tr '\n' ' ' < "$dev/pp_dpm_mclk" 2>/dev/null || echo unavailable)"
    printf '  power profile       %s\n' "$(grep '\*' "$dev/pp_power_profile_mode" 2>/dev/null | sed 's/^ *//;s/  */ /g' || echo unavailable)"
    printf '  runtime PM          %s\n' "$(rd "$dev/power/control")"
    # The DPM table is a summary; pp_od_clk_voltage reports the range the
    # card will actually accept, which is the way to tell a genuinely
    # capped ceiling from a misread of the three-entry pp_dpm_sclk format.
    if [ -r "$dev/pp_od_clk_voltage" ]; then
        echo '  od clk ranges'
        sed 's/^/    /' "$dev/pp_od_clk_voltage"
    else
        echo '  od clk ranges       unavailable'
    fi
    printf '  power cap / ceiling %s / %s W\n' \
        "$(awk '{printf "%.0f", $1/1000000}' "$hwmon/power1_cap" 2>/dev/null || echo ?)" \
        "$(awk '{printf "%.0f", $1/1000000}' "$hwmon/power1_cap_max" 2>/dev/null || echo ?)"
    echo "-- is anything else using it --"
    disp=no
    for s in "$drm"/card$card-*/status; do
        [ -r "$s" ] || continue
        [ "$(cat "$s")" = connected ] && { disp=yes; echo "  display connected:  $(basename "$(dirname "$s")")"; }
    done
    [ "$disp" = no ] && echo "  display connected:  none (good -- nothing is driving a screen off this card)"
    [ "$disp" = yes ] && echo "  WARNING: this card drives a display; a compositor competes for it and"
    [ "$disp" = yes ] && echo "           holds it in display-oriented power states"
    users=$(for f in /proc/[0-9]*/fd/*; do
                l=$(readlink "$f" 2>/dev/null) || continue
                case "$l" in /dev/dri/*) echo "$(echo "$f" | cut -d/ -f3)";; esac
            done 2>/dev/null | sort -u)
    if [ -n "$users" ]; then
        echo "  WARNING: other clients hold /dev/dri; quiesce these before measuring"
        echo "  processes on /dev/dri:"
        for p in $users; do printf '    pid %-7s %s\n' "$p" "$(tr '\0' ' ' < /proc/$p/cmdline 2>/dev/null | cut -c1-70)"; done
    else
        echo "  processes on /dev/dri: none"
    fi
    echo
    echo "-- host --"
    printf '  cpu governor        %s\n' "$(rd /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
    printf '  gpu busy now        %s%%\n' "$(rd "$dev/gpu_busy_percent")"
    echo
fi
[ "$mode" = report ] && { echo "no changes made; re-run with --apply (as root) to set a compute state"; exit 0; }

# --------------------------------------------------------------------------
# apply / restore
# --------------------------------------------------------------------------
[ "$(id -u)" = 0 ] || { echo "--$mode needs root" >&2; exit 1; }

set_to() {  # set_to <file> <value> [value-to-record]; records the old value once
    # Some nodes report a table but accept only an index, so the caller can
    # override what gets written to the restore file.
    local f="$1" v="$2" old="${3-}"
    [ -w "$f" ] || { echo "  skip $(basename "$f") (not writable)"; return; }
    [ -n "$old" ] || old=$(cat "$f" 2>/dev/null || echo "")
    grep -qF "$f|" "$state" 2>/dev/null || echo "$f|$old" >> "$state"
    if echo "$v" > "$f" 2>/dev/null; then
        echo "  $(basename "$f"): $old -> $v"
    else
        echo "  $(basename "$f"): FAILED to set $v (was $old)"
    fi
}

if [ "$mode" = restore ]; then
    [ -s "$state" ] || { echo "nothing saved at $state" >&2; exit 1; }
    echo "== restoring from $state =="
    # Reverse order, so performance level goes back after the profile it gated.
    tac "$state" | while IFS='|' read -r f v; do
        [ -n "$f" ] || continue
        # A saved profile line is the whole table row; only its index is writable.
        if echo "$v" > "$f" 2>/dev/null; then echo "  $(basename "$f") <- $v"
        else echo "  $(basename "$f"): could not restore '$v'"; fi
    done
    rm -f "$state"
    exit 0
fi

echo "== applying compute state (previous values -> $state) =="
: > "$state"

# Keeping the device out of runtime suspend first: a card that is being
# power-managed will not hold a raised DPM level.
set_to "$dev/power/control" on

# The profile the DPM governor uses to decide how eagerly to raise clocks.
# Its heuristics are tuned for graphics; a compute kernel that leaves the
# shader array waiting on LDS can look idle enough not to warrant boosting.
prof=$(awk '/COMPUTE/{gsub(/[^0-9]/,"",$1); print $1; exit}' "$dev/pp_power_profile_mode" 2>/dev/null || true)
if [ -n "${prof:-}" ]; then
    # Record only the active index, not the whole table it prints.
    cur=$(awk '/\*/{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+$/) {print $i; exit}}' \
        "$dev/pp_power_profile_mode" 2>/dev/null || true)
    set_to "$dev/pp_power_profile_mode" "$prof" "${cur:-0}"
else
    echo "  pp_power_profile_mode: no COMPUTE profile listed, leaving alone"
fi

# The blunt instrument, and the one that actually tests the hypothesis.
set_to "$dev/power_dpm_force_performance_level" high

echo
echo "now:"
printf '  performance level   %s\n' "$(rd "$dev/power_dpm_force_performance_level")"
printf '  sclk DPM levels     %s\n' "$(tr '\n' ' ' < "$dev/pp_dpm_sclk" 2>/dev/null || echo unavailable)"
echo
echo "run the benchmark, then: sudo $0 --restore"
