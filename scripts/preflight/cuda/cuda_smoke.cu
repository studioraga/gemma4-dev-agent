#include <cuda_runtime.h>
#include <cstdio>

#define CUDA_CHECK(call)                                                   \
    do {                                                                   \
        cudaError_t err__ = (call);                                        \
        if (err__ != cudaSuccess) {                                        \
            std::fprintf(stderr,                                           \
                         "CUDA error at %s:%d: %s\n",                       \
                         __FILE__,                                          \
                         __LINE__,                                          \
                         cudaGetErrorString(err__));                        \
            return 1;                                                      \
        }                                                                  \
    } while (0)

__global__ void add_one(int *value)
{
    if (blockIdx.x == 0 && threadIdx.x == 0) {
        *value += 1;
    }
}

int main()
{
    int host_value = 41;
    int *device_value = nullptr;

    int device_count = 0;
    CUDA_CHECK(cudaGetDeviceCount(&device_count));

    if (device_count < 1) {
        std::fprintf(stderr, "No CUDA device detected\n");
        return 2;
    }

    cudaDeviceProp prop{};
    CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));

    std::printf("CUDA_DEVICE=%s\n", prop.name);
    std::printf("CUDA_CC=%d.%d\n", prop.major, prop.minor);
    std::printf("CUDA_GLOBAL_MEMORY_BYTES=%zu\n",
                static_cast<size_t>(prop.totalGlobalMem));

    CUDA_CHECK(cudaMalloc(&device_value, sizeof(int)));

    CUDA_CHECK(cudaMemcpy(
        device_value,
        &host_value,
        sizeof(int),
        cudaMemcpyHostToDevice));

    add_one<<<1, 1>>>(device_value);

    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    CUDA_CHECK(cudaMemcpy(
        &host_value,
        device_value,
        sizeof(int),
        cudaMemcpyDeviceToHost));

    CUDA_CHECK(cudaFree(device_value));

    std::printf("CUDA_RESULT=%d\n", host_value);

    if (host_value != 42) {
        std::fprintf(stderr,
                     "Expected 42 but got %d\n",
                     host_value);
        return 3;
    }

    std::puts("CUDA_SMOKE=PASS");
    return 0;
}
