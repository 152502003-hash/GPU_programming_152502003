

#include <cuda.h>
#include <stdio.h>

__device__ int count = 0;
__device__ int val = 0;

__device__ void barrier()
{
    __syncthreads();

    // One thread from each block reaches the counter
    if (threadIdx.x == 0)
    {
        atomicAdd(&count, 1);
        atomicAdd(&val, 10);

        printf("Block %d reached barrier, count=%d, val=%d\n",
               blockIdx.x, count, val);
    }

    __syncthreads();

    // Wait until all blocks arrive
    while (atomicAdd(&count, 0) < gridDim.x)
    {
    }

    __syncthreads();
}

__global__ void K1()
{
    printf("Before barrier: Block %d Thread %d val=%d\n",
           blockIdx.x, threadIdx.x, val);

    barrier();

    printf("After barrier: Block %d Thread %d val=%d\n",
           blockIdx.x, threadIdx.x, val);
}

int main()
{
    K1<<<2, 4>>>();

    cudaDeviceSynchronize();

    return 0;
}
