#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>

__global__ void kernel(int *a)
{
	a[blockIdx.x * blockDim.x + threadIdx.x ] = 0;
}

double tiempo( void )
{
	struct timeval  tv;
	gettimeofday(&tv, NULL);

	return (double) (tv.tv_usec) / 1000000 + (double) (tv.tv_sec);
}

int main(int argc, char** argv)
{
	double tiempoInicio;
	double tiempoFin;
	
	int n;
	if (argc == 2)
	{
		n = atoi(argv[1]);
	} else {
		n = 64;
	}

	printf("\nElementos a reservar: %d\n\n\n", n);

	int numBytes = n * sizeof(int);

	int *d_a;
	int *h_a;

	cudaMalloc((void **) &d_a, numBytes );

	h_a = (int *)malloc(numBytes);

	dim3 blockSize(8);
	dim3 gridSize(8);


	tiempoInicio = tiempo();
	kernel <<<gridSize, blockSize>>>(d_a);
	cudaThreadSynchronize();
	tiempoFin = tiempo();
	
	if ( cudaSuccess != cudaGetLastError() )
		printf( "Error!\n" );

	printf("Tiempo de inicio Kernel: %lf\n", tiempoInicio);
	printf("Tiempo de fin Kernel: %lf\n", tiempoFin);
	printf("Tiempo total: %lf\n\n\n", tiempoFin - tiempoInicio);


	tiempoInicio = tiempo();
	cudaMemcpy (d_a, h_a, numBytes, cudaMemcpyDeviceToHost);
	tiempoFin = tiempo();

	printf("Tiempo de inicio Transferencia: %lf\n", tiempoInicio);
	printf("Tiempo de fin Transferencia: %lf\n", tiempoFin);
	printf("Tiempo total: %lf\n", tiempoFin - tiempoInicio);

	printf("Done.\n");

	return 0;
}
