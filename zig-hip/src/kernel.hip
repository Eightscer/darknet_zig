// This is the ONLY piece of C/C++ in the project. HIP device kernels must be
// compiled by the ROCm/HIP clang toolchain (via hipcc) for the amdgcn target;
// Zig's own compiler cannot target GPU ISAs, so there is no way around having
// at least this much C++.
//
// `extern "C"` disables C++ name mangling so the host side can look the
// function up by its plain string name via hipModuleGetFunction.
//
// blockIdx/blockDim/threadIdx aren't bare compiler builtins in HIP -- they're
// macros defined in hip_runtime.h that wrap clang's underlying builtins, so
// the include below is required even for a single tiny kernel like this one.
#include <hip/hip_runtime.h>

extern "C" __global__ void vecAdd(const float* a, const float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}
