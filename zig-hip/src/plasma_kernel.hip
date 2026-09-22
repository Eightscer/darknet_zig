#include <hip/hip_runtime.h>

// Classic plasma effect: sum a handful of sine waves over position and time,
// then map the result through three phase-shifted sine waves to get RGB.
// One thread per pixel, in a 2D grid.
extern "C" __global__ void plasma(unsigned char* out, int width, int height, float t) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    if (x >= width || y >= height) return;

    float fx = (float)x;
    float fy = (float)y;

    float v = sinf(fx * 0.02f + t)
            + sinf(fy * 0.03f + t * 1.3f)
            + sinf((fx + fy) * 0.02f + t * 0.7f)
            + sinf(sqrtf(fx * fx + fy * fy) * 0.03f - t * 1.7f);

    float n = (v + 4.0f) / 8.0f; // roughly normalize to [0, 1]

    unsigned char r = (unsigned char)(128.0f + 127.0f * sinf(n * 6.2831853f));
    unsigned char g = (unsigned char)(128.0f + 127.0f * sinf(n * 6.2831853f + 2.0943951f));
    unsigned char b = (unsigned char)(128.0f + 127.0f * sinf(n * 6.2831853f + 4.1887902f));

    int idx = (y * width + x) * 4;
    out[idx + 0] = r;
    out[idx + 1] = g;
    out[idx + 2] = b;
    out[idx + 3] = 255;
}
