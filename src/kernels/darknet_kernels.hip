// =============================================================================
// Every line of C++ in darknet-zig lives in this file.
//
// Zig's compiler has no amdgcn backend, so device code has to be compiled by
// the ROCm clang toolchain. The build runs `hipcc --genco` over this file to
// produce a standalone code object (.hsaco) which the Zig host side loads at
// runtime via hipModuleLoad and dispatches with hipModuleLaunchKernel. Nothing
// else about the project touches C++: the HIP *runtime* API is plain extern "C"
// and is called directly from Zig (see src/hip/hip.zig).
//
// `extern "C"` on every kernel disables C++ name mangling so the host can look
// each one up by its plain string name.
//
// Conventions inherited from darknet:
//   * tensors are NCHW: index = ((b*channels + c)*height + y)*width + x
//   * `delta` is dL/d(output) and is always accumulated into, never assigned,
//     because a layer's output can feed more than one consumer
//   * `gradient` functions take the activation's *output*, not its input
// =============================================================================

#include <hip/hip_runtime.h>

// Threads per block for the 1-D elementwise kernels. 256 is four wave64s on
// AMD, which schedules better than the 512 darknet used for NVIDIA. The Zig
// side hardcodes the same number when computing grid sizes, and the reduction
// kernels below size their shared memory from it, so the two must agree.
#define BLOCK 256

// Tile edge for the GEMM kernel; BLOCK must equal TILE*TILE.
#define TILE 16

__device__ __forceinline__ int global_index() {
    return blockIdx.x * blockDim.x + threadIdx.x;
}

// -----------------------------------------------------------------------------
// activations
// -----------------------------------------------------------------------------
// The integer values match the Activation enum in src/activations.zig; they are
// darknet's original ACTIVATION ordering and must not be renumbered.

typedef enum {
    LOGISTIC = 0, RELU, RELIE, LINEAR, RAMP, TANH, PLSE, LEAKY,
    ELU, LOGGY, STAIR, HARDTAN, LHTAN, SELU
} ACTIVATION;

__device__ float activate_kernel(float x, ACTIVATION a) {
    switch (a) {
        case LINEAR:   return x;
        case LOGISTIC: return 1.f / (1.f + expf(-x));
        case LOGGY:    return 2.f / (1.f + expf(-x)) - 1.f;
        case RELU:     return x * (x > 0);
        case ELU:      return (x >= 0) * x + (x < 0) * (expf(x) - 1);
        case SELU:     return (x >= 0) * 1.0507f * x + (x < 0) * 1.0507f * 1.6732f * (expf(x) - 1);
        case RELIE:    return (x > 0) ? x : .01f * x;
        case RAMP:     return x * (x > 0) + .1f * x;
        case LEAKY:    return (x > 0) ? x : .1f * x;
        case TANH:     return (2.f / (1.f + expf(-2.f * x)) - 1.f);
        case PLSE:
            if (x < -4) return .01f * (x + 4);
            if (x > 4)  return .01f * (x - 4) + 1;
            return .125f * x + .5f;
        case STAIR: {
            int n = (int)floorf(x);
            if (n % 2 == 0) return floorf(x / 2.f);
            return (x - n) + floorf(x / 2.f);
        }
        case HARDTAN:
            if (x < -1) return -1;
            if (x > 1)  return 1;
            return x;
        case LHTAN:
            if (x < 0) return .001f * x;
            if (x > 1) return .001f * (x - 1) + 1;
            return x;
    }
    return 0;
}

__device__ float gradient_kernel(float x, ACTIVATION a) {
    switch (a) {
        case LINEAR:   return 1;
        case LOGISTIC: return (1 - x) * x;
        case LOGGY: {
            float y = (x + 1.f) / 2.f;
            return 2 * (1 - y) * y;
        }
        case RELU:     return (x > 0);
        case ELU:      return (x >= 0) + (x < 0) * (x + 1);
        case SELU:     return (x >= 0) * 1.0507f + (x < 0) * (x + 1.0507f * 1.6732f);
        case RELIE:    return (x > 0) ? 1 : .01f;
        case RAMP:     return (x > 0) + .1f;
        case LEAKY:    return (x > 0) ? 1 : .1f;
        case TANH:     return 1 - x * x;
        case PLSE:     return (x < 0 || x > 1) ? .01f : .125f;
        case STAIR:    return (floorf(x) == x) ? 0 : 1;
        case HARDTAN:  return (x > -1 && x < 1) ? 1 : 0;
        case LHTAN:    return (x > 0 && x < 1) ? 1 : .001f;
    }
    return 0;
}

extern "C" __global__ void activate_array_kernel(float *x, int n, int a) {
    int i = global_index();
    if (i < n) x[i] = activate_kernel(x[i], (ACTIVATION)a);
}

extern "C" __global__ void gradient_array_kernel(const float *x, int n, int a, float *delta) {
    int i = global_index();
    if (i < n) delta[i] *= gradient_kernel(x[i], (ACTIVATION)a);
}

// -----------------------------------------------------------------------------
// elementwise BLAS
// -----------------------------------------------------------------------------

extern "C" __global__ void fill_kernel(int N, float ALPHA, float *X) {
    int i = global_index();
    if (i < N) X[i] = ALPHA;
}

extern "C" __global__ void copy_kernel(int N, const float *X, float *Y) {
    int i = global_index();
    if (i < N) Y[i] = X[i];
}

extern "C" __global__ void axpy_kernel(int N, float ALPHA, const float *X, float *Y) {
    int i = global_index();
    if (i < N) Y[i] += ALPHA * X[i];
}

extern "C" __global__ void scal_kernel(int N, float ALPHA, float *X) {
    int i = global_index();
    if (i < N) X[i] *= ALPHA;
}

extern "C" __global__ void mul_kernel(int N, const float *X, float *Y) {
    int i = global_index();
    if (i < N) Y[i] *= X[i];
}

extern "C" __global__ void add_scalar_kernel(int N, float ALPHA, float *X) {
    int i = global_index();
    if (i < N) X[i] += ALPHA;
}

extern "C" __global__ void constrain_kernel(int N, float ALPHA, float *X) {
    int i = global_index();
    if (i < N) X[i] = fminf(ALPHA, fmaxf(-ALPHA, X[i]));
}

// Counter-based uniform RNG for the dropout mask.
//
// darknet called curand here. rocRAND is the HIP equivalent, but pulling in a
// whole RNG library for one kernel would add a second ROCm link dependency to
// a project whose entire point is that it only needs libamdhip64. Hashing the
// element index with a host-supplied seed is stateless, needs no device-side
// generator object, and is more than good enough for a dropout mask. The
// mixing constants are from Chris Wellons' "Hash Prospector" search.
__device__ __forceinline__ unsigned int hash_u32(unsigned int x) {
    x ^= x >> 16;
    x *= 0x7feb352dU;
    x ^= x >> 15;
    x *= 0x846ca68bU;
    x ^= x >> 16;
    return x;
}

extern "C" __global__ void rand_uniform_kernel(int N, float *X, unsigned int seed) {
    int i = global_index();
    if (i >= N) return;
    unsigned int h = hash_u32(seed ^ hash_u32((unsigned int)i));
    // Top 24 bits scaled into [0,1), so every value is exactly representable.
    X[i] = (float)(h >> 8) * (1.0f / 16777216.0f);
}

// -----------------------------------------------------------------------------
// bias and scale
// -----------------------------------------------------------------------------

extern "C" __global__ void add_bias_kernel(float *output, const float *biases, int batch, int n, int size) {
    int index = global_index();
    if (index >= n * size * batch) return;
    int i = index % size;
    index /= size;
    int j = index % n;
    index /= n;
    const int b = index;
    output[(b * n + j) * size + i] += biases[j];
}

extern "C" __global__ void scale_bias_kernel(float *output, const float *scales, int batch, int n, int size) {
    int index = global_index();
    if (index >= n * size * batch) return;
    int i = index % size;
    index /= size;
    int j = index % n;
    index /= n;
    const int b = index;
    output[(b * n + j) * size + i] *= scales[j];
}

// One block per filter; each block reduces over (batch x spatial).
//
// darknet's version had thread 0 walk the whole shared array serially after the
// parallel accumulate. These use a standard tree reduction instead: same result
// up to floating-point association, log(BLOCK) steps instead of BLOCK.
__device__ __forceinline__ float block_reduce_sum(float *local, float value) {
    int id = threadIdx.x;
    local[id] = value;
    __syncthreads();
    for (int offset = BLOCK / 2; offset > 0; offset >>= 1) {
        if (id < offset) local[id] += local[id + offset];
        __syncthreads();
    }
    return local[0];
}

extern "C" __global__ void backward_bias_kernel(float *bias_updates, const float *delta, int batch, int n, int size) {
    __shared__ float local[BLOCK];
    int filter = blockIdx.x;
    float sum = 0;
    for (int b = 0; b < batch; ++b) {
        for (int i = threadIdx.x; i < size; i += BLOCK) {
            sum += delta[i + size * (filter + n * b)];
        }
    }
    float total = block_reduce_sum(local, sum);
    if (threadIdx.x == 0) bias_updates[filter] += total;
}

// size == 1 (connected layers) degenerates the kernel above into one thread per
// block, so it gets a flat one-thread-per-filter version instead.
extern "C" __global__ void backward_bias_conn_kernel(float *bias_updates, const float *delta, int batch, int n) {
    int index = global_index();
    if (index >= n) return;
    float sum = 0;
    for (int b = 0; b < batch; ++b) sum += delta[index + b * n];
    bias_updates[index] += sum;
}

extern "C" __global__ void backward_scale_kernel(const float *x_norm, const float *delta, int batch, int n, int size, float *scale_updates) {
    __shared__ float local[BLOCK];
    int filter = blockIdx.x;
    float sum = 0;
    for (int b = 0; b < batch; ++b) {
        for (int i = threadIdx.x; i < size; i += BLOCK) {
            int index = i + size * (filter + n * b);
            sum += delta[index] * x_norm[index];
        }
    }
    float total = block_reduce_sum(local, sum);
    if (threadIdx.x == 0) scale_updates[filter] += total;
}

// -----------------------------------------------------------------------------
// batch normalisation
// -----------------------------------------------------------------------------

extern "C" __global__ void fast_mean_kernel(const float *x, int batch, int filters, int spatial, float *mean) {
    __shared__ float local[BLOCK];
    int filter = blockIdx.x;
    float sum = 0;
    for (int j = 0; j < batch; ++j) {
        for (int i = threadIdx.x; i < spatial; i += BLOCK) {
            sum += x[j * spatial * filters + filter * spatial + i];
        }
    }
    float total = block_reduce_sum(local, sum);
    if (threadIdx.x == 0) mean[filter] = total / (batch * spatial);
}

// Matches blas.zig: the sample variance, with the batch*spatial-1 denominator.
extern "C" __global__ void fast_variance_kernel(const float *x, const float *mean, int batch, int filters, int spatial, float *variance) {
    __shared__ float local[BLOCK];
    int filter = blockIdx.x;
    float m = mean[filter];
    float sum = 0;
    for (int j = 0; j < batch; ++j) {
        for (int i = threadIdx.x; i < spatial; i += BLOCK) {
            float d = x[j * spatial * filters + filter * spatial + i] - m;
            sum += d * d;
        }
    }
    float total = block_reduce_sum(local, sum);
    if (threadIdx.x == 0) variance[filter] = total / (batch * spatial - 1);
}

extern "C" __global__ void normalize_kernel(int N, float *x, const float *mean, const float *variance, int batch, int filters, int spatial) {
    int index = global_index();
    if (index >= N) return;
    int f = (index / spatial) % filters;
    x[index] = (x[index] - mean[f]) / (sqrtf(variance[f]) + .000001f);
}

extern "C" __global__ void fast_mean_delta_kernel(const float *delta, const float *variance, int batch, int filters, int spatial, float *mean_delta) {
    __shared__ float local[BLOCK];
    int filter = blockIdx.x;
    float sum = 0;
    for (int j = 0; j < batch; ++j) {
        for (int i = threadIdx.x; i < spatial; i += BLOCK) {
            sum += delta[j * spatial * filters + filter * spatial + i];
        }
    }
    float total = block_reduce_sum(local, sum);
    if (threadIdx.x == 0) mean_delta[filter] = total * (-1.f / sqrtf(variance[filter] + .00001f));
}

extern "C" __global__ void fast_variance_delta_kernel(const float *x, const float *delta, const float *mean, const float *variance,
                                                      int batch, int filters, int spatial, float *variance_delta) {
    __shared__ float local[BLOCK];
    int filter = blockIdx.x;
    float m = mean[filter];
    float sum = 0;
    for (int j = 0; j < batch; ++j) {
        for (int i = threadIdx.x; i < spatial; i += BLOCK) {
            int index = j * spatial * filters + filter * spatial + i;
            sum += delta[index] * (x[index] - m);
        }
    }
    float total = block_reduce_sum(local, sum);
    if (threadIdx.x == 0) {
        variance_delta[filter] = total * -.5f * powf(variance[filter] + .00001f, -1.5f);
    }
}

extern "C" __global__ void normalize_delta_kernel(int N, const float *x, const float *mean, const float *variance,
                                                  const float *mean_delta, const float *variance_delta,
                                                  int batch, int filters, int spatial, float *delta) {
    int index = global_index();
    if (index >= N) return;
    int f = (index / spatial) % filters;
    delta[index] = delta[index] * 1.f / (sqrtf(variance[f] + .00001f))
                 + variance_delta[f] * 2.f * (x[index] - mean[f]) / (spatial * batch)
                 + mean_delta[f] / (spatial * batch);
}

// -----------------------------------------------------------------------------
// softmax and losses
// -----------------------------------------------------------------------------

__device__ void softmax_device(const float *input, int n, float temp, int stride, float *output) {
    float largest = -INFINITY;
    for (int i = 0; i < n; ++i) largest = fmaxf(largest, input[i * stride]);
    float sum = 0;
    for (int i = 0; i < n; ++i) {
        float e = expf(input[i * stride] / temp - largest / temp);
        sum += e;
        output[i * stride] = e;
    }
    for (int i = 0; i < n; ++i) output[i * stride] /= sum;
}

extern "C" __global__ void softmax_kernel(const float *input, int n, int batch, int batch_offset,
                                          int groups, int group_offset, int stride, float temp, float *output) {
    int id = global_index();
    if (id >= batch * groups) return;
    int b = id / groups;
    int g = id % groups;
    int off = b * batch_offset + g * group_offset;
    softmax_device(input + off, n, temp, stride, output + off);
}

extern "C" __global__ void softmax_x_ent_kernel(int n, const float *pred, const float *truth, float *delta, float *error) {
    int i = global_index();
    if (i >= n) return;
    float t = truth[i];
    float p = pred[i];
    error[i] = (t != 0) ? -logf(fmaxf(p, 1e-20f)) : 0;
    delta[i] = t - p;
}

extern "C" __global__ void l2_kernel(int n, const float *pred, const float *truth, float *delta, float *error) {
    int i = global_index();
    if (i >= n) return;
    float diff = truth[i] - pred[i];
    error[i] = diff * diff;
    delta[i] = diff;
}

extern "C" __global__ void l1_kernel(int n, const float *pred, const float *truth, float *delta, float *error) {
    int i = global_index();
    if (i >= n) return;
    float diff = truth[i] - pred[i];
    error[i] = fabsf(diff);
    delta[i] = (diff > 0) ? 1 : -1;
}

extern "C" __global__ void smooth_l1_kernel(int n, const float *pred, const float *truth, float *delta, float *error) {
    int i = global_index();
    if (i >= n) return;
    float diff = truth[i] - pred[i];
    float a = fabsf(diff);
    if (a < 1) {
        error[i] = diff * diff;
        delta[i] = diff;
    } else {
        error[i] = 2 * a - 1;
        delta[i] = (diff < 0) ? 1 : -1;
    }
}

// -----------------------------------------------------------------------------
// im2col / col2im
// -----------------------------------------------------------------------------
// Both from Caffe by way of darknet; see src/im2col.zig for the host twin.

extern "C" __global__ void im2col_kernel(int n, const float *data_im,
                                         int height, int width, int ksize, int pad, int stride,
                                         int height_col, int width_col, float *data_col) {
    for (int index = global_index(); index < n; index += blockDim.x * gridDim.x) {
        int w_out = index % width_col;
        int h_index = index / width_col;
        int h_out = h_index % height_col;
        int channel_in = h_index / height_col;
        int channel_out = channel_in * ksize * ksize;
        int h_in = h_out * stride - pad;
        int w_in = w_out * stride - pad;

        float *col_ptr = data_col + (channel_out * height_col + h_out) * width_col + w_out;
        const float *im_ptr = data_im + (channel_in * height + h_in) * width + w_in;

        for (int i = 0; i < ksize; ++i) {
            for (int j = 0; j < ksize; ++j) {
                int h = h_in + i;
                int w = w_in + j;
                *col_ptr = (h >= 0 && w >= 0 && h < height && w < width) ? im_ptr[i * width + j] : 0;
                col_ptr += height_col * width_col;
            }
        }
    }
}

extern "C" __global__ void col2im_kernel(int n, const float *data_col,
                                         int height, int width, int ksize, int pad, int stride,
                                         int height_col, int width_col, float *data_im) {
    for (int index = global_index(); index < n; index += blockDim.x * gridDim.x) {
        float val = 0;
        int w = index % width + pad;
        int h = (index / width) % height + pad;
        int c = index / (width * height);

        int w_col_start = (w < ksize) ? 0 : (w - ksize) / stride + 1;
        int w_col_end = min(w / stride + 1, width_col);
        int h_col_start = (h < ksize) ? 0 : (h - ksize) / stride + 1;
        int h_col_end = min(h / stride + 1, height_col);

        int offset = (c * ksize * ksize + h * ksize + w) * height_col * width_col;
        int coeff_h_col = (1 - stride * ksize * height_col) * width_col;
        int coeff_w_col = (1 - stride * height_col * width_col);
        for (int h_col = h_col_start; h_col < h_col_end; ++h_col) {
            for (int w_col = w_col_start; w_col < w_col_end; ++w_col) {
                val += data_col[offset + h_col * coeff_h_col + w_col * coeff_w_col];
            }
        }
        data_im[index] += val;
    }
}

// -----------------------------------------------------------------------------
// pooling
// -----------------------------------------------------------------------------

extern "C" __global__ void forward_maxpool_kernel(int n, int in_h, int in_w, int in_c, int stride, int size, int pad,
                                                  const float *input, float *output, int *indexes) {
    int h = (in_h + pad - size) / stride + 1;
    int w = (in_w + pad - size) / stride + 1;
    int c = in_c;

    int id = global_index();
    if (id >= n) return;

    int j = id % w; id /= w;
    int i = id % h; id /= h;
    int k = id % c; id /= c;
    int b = id;

    int w_offset = -pad / 2;
    int h_offset = -pad / 2;

    int out_index = j + w * (i + h * (k + c * b));
    float max = -INFINITY;
    int max_i = -1;
    for (int l = 0; l < size; ++l) {
        for (int m = 0; m < size; ++m) {
            int cur_h = h_offset + i * stride + l;
            int cur_w = w_offset + j * stride + m;
            int index = cur_w + in_w * (cur_h + in_h * (k + b * in_c));
            int valid = (cur_h >= 0 && cur_h < in_h && cur_w >= 0 && cur_w < in_w);
            float val = valid ? input[index] : -INFINITY;
            max_i = (val > max) ? index : max_i;
            max = (val > max) ? val : max;
        }
    }
    output[out_index] = max;
    indexes[out_index] = max_i;
}

// One thread per *input* element, gathering from every output window that could
// have selected it. Scattering from outputs instead would need atomics.
extern "C" __global__ void backward_maxpool_kernel(int n, int in_h, int in_w, int in_c, int stride, int size, int pad,
                                                   const float *delta, float *prev_delta, const int *indexes) {
    int h = (in_h + pad - size) / stride + 1;
    int w = (in_w + pad - size) / stride + 1;
    int c = in_c;
    int area = (size - 1) / stride;

    int id = global_index();
    if (id >= n) return;

    int index = id;
    int j = id % in_w; id /= in_w;
    int i = id % in_h; id /= in_h;
    int k = id % in_c; id /= in_c;
    int b = id;

    int w_offset = -pad / 2;
    int h_offset = -pad / 2;

    float d = 0;
    for (int l = -area; l < area + 1; ++l) {
        for (int m = -area; m < area + 1; ++m) {
            int out_w = (j - w_offset) / stride + m;
            int out_h = (i - h_offset) / stride + l;
            int out_index = out_w + w * (out_h + h * (k + c * b));
            int valid = (out_w >= 0 && out_w < w && out_h >= 0 && out_h < h);
            d += (valid && indexes[out_index] == index) ? delta[out_index] : 0;
        }
    }
    prev_delta[index] += d;
}

extern "C" __global__ void forward_avgpool_kernel(int n, int w, int h, int c, const float *input, float *output) {
    int id = global_index();
    if (id >= n) return;
    int k = id % c;
    int b = id / c;
    float sum = 0;
    for (int i = 0; i < w * h; ++i) sum += input[i + h * w * (k + b * c)];
    output[k + c * b] = sum / (w * h);
}

extern "C" __global__ void backward_avgpool_kernel(int n, int w, int h, int c, float *in_delta, const float *out_delta) {
    int id = global_index();
    if (id >= n) return;
    int k = id % c;
    int b = id / c;
    float d = out_delta[k + c * b] / (w * h);
    for (int i = 0; i < w * h; ++i) in_delta[i + h * w * (k + b * c)] += d;
}

// -----------------------------------------------------------------------------
// dropout and shortcut
// -----------------------------------------------------------------------------

extern "C" __global__ void dropout_kernel(float *input, int size, const float *rand, float prob, float scale) {
    int id = global_index();
    if (id < size) input[id] = (rand[id] < prob) ? 0 : input[id] * scale;
}

extern "C" __global__ void shortcut_kernel(int size, int minw, int minh, int minc, int stride, int sample, int batch,
                                           int w1, int h1, int c1, const float *add,
                                           int w2, int h2, int c2, float s1, float s2, float *out) {
    int id = global_index();
    if (id >= size) return;
    int i = id % minw; id /= minw;
    int j = id % minh; id /= minh;
    int k = id % minc; id /= minc;
    int b = id % batch;

    int out_index = i * sample + w2 * (j * sample + h2 * (k + c2 * b));
    int add_index = i * stride + w1 * (j * stride + h1 * (k + c1 * b));
    out[out_index] = s1 * out[out_index] + s2 * add[add_index];
}

// -----------------------------------------------------------------------------
// Adam
// -----------------------------------------------------------------------------

extern "C" __global__ void adam_kernel(int N, float *x, const float *m, const float *v,
                                       float B1, float B2, float rate, float eps, int t) {
    int index = global_index();
    if (index >= N) return;
    float mhat = m[index] / (1.f - powf(B1, t));
    float vhat = v[index] / (1.f - powf(B2, t));
    x[index] = x[index] + rate * mhat / (sqrtf(vhat) + eps);
}

// -----------------------------------------------------------------------------
// GEMM
// -----------------------------------------------------------------------------
// C = ALPHA*op(A)*op(B) + BETA*C, all row-major, matching gemm_cpu's contract.
//
// darknet delegated this to cuBLAS. The HIP equivalent would be rocBLAS, but
// that is a second, much larger ROCm dependency, and the project's premise is
// that libamdhip64 is the only thing it links. So this is a hand-written
// shared-memory tiled kernel: substantially slower than rocBLAS on large
// matrices, still one to two orders of magnitude faster than the CPU path. If
// throughput ever matters more than the dependency count, this is the single
// function to replace.
//
// Launched as a 2-D grid of TILE x TILE blocks over the output.

__device__ __forceinline__ float a_at(const float *A, int TA, int lda, int row, int k) {
    return TA ? A[k * lda + row] : A[row * lda + k];
}

__device__ __forceinline__ float b_at(const float *B, int TB, int ldb, int k, int col) {
    return TB ? B[col * ldb + k] : B[k * ldb + col];
}

extern "C" __global__ void gemm_kernel(int TA, int TB, int M, int N, int K, float ALPHA,
                                       const float *A, int lda, const float *B, int ldb,
                                       float BETA, float *C, int ldc) {
    __shared__ float As[TILE][TILE];
    __shared__ float Bs[TILE][TILE];

    int ty = threadIdx.y;
    int tx = threadIdx.x;
    int row = blockIdx.y * TILE + ty;
    int col = blockIdx.x * TILE + tx;

    float acc = 0.f;
    int tiles = (K + TILE - 1) / TILE;
    for (int t = 0; t < tiles; ++t) {
        int ak = t * TILE + tx;
        int bk = t * TILE + ty;
        As[ty][tx] = (row < M && ak < K) ? a_at(A, TA, lda, row, ak) : 0.f;
        Bs[ty][tx] = (bk < K && col < N) ? b_at(B, TB, ldb, bk, col) : 0.f;
        __syncthreads();

        #pragma unroll
        for (int q = 0; q < TILE; ++q) acc += As[ty][q] * Bs[q][tx];
        __syncthreads();
    }

    if (row < M && col < N) {
        int idx = row * ldc + col;
        // BETA == 0 is a plain overwrite, not a multiply: the destination is
        // often the shared workspace, whose previous contents are unrelated
        // to this call, and 0 * inf would be NaN rather than 0.
        C[idx] = (BETA == 0.f) ? ALPHA * acc : ALPHA * acc + BETA * C[idx];
    }
}
