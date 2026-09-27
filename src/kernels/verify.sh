#!/usr/bin/env sh
# Checks the device GEMM kernels for correctness without a GPU.
#
#   ./src/kernels/verify.sh
#
# `host_emulate.cpp` runs a thread block's 256 threads as real OS threads
# against a std::barrier, so `__shared__` and `__syncthreads()` behave the way
# they do on a device. The kernel text is extracted from darknet_kernels.hip
# and #included verbatim, so what gets checked is the code that ships.
#
# The criterion is bit-identity between `gemm_block_kernel` and the simpler
# `gemm_kernel` it replaces for large shapes: the two sum in the same order,
# and the simple one is the implementation already validated against upstream
# darknet on real hardware. A double-precision reference runs alongside as a
# loose sanity bound -- only loose, because relative error against it is
# dominated by float32 cancellation, not by anything the kernel does wrong.
#
# This is not a substitute for running on a GPU. It checks index arithmetic,
# tiling, bounds handling and the transpose flags; it cannot check anything
# about memory coalescing, occupancy or races the barrier model hides.
set -e
here="$(cd "$(dirname "$0")" && pwd)"
out="${TMPDIR:-/tmp}/darknet-kernel-verify"
mkdir -p "$out"

# a_at/b_at through to the end of the file: the two GEMM kernels and nothing
# that would drag in device intrinsics the host shim does not provide.
awk '/^__device__ __forceinline__ float a_at/{f=1} f' "$here/darknet_kernels.hip" > "$out/kern.inc"

cxx="${CXX:-c++}"
command -v "$cxx" >/dev/null 2>&1 || cxx="zig c++"
$cxx -std=c++20 -O1 -w -I "$out" -o "$out/emulate" "$here/host_emulate.cpp"
exec "$out/emulate"
