# cudaVector

- Vector Datastructure for Nvidia Cuda Devices.
- Optimized all memory is allocated on Cuda Device for optimal use.
- Usable in device code
- maintainer of cudacpp Library


EXAMPLE:

```

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include "cudaVector.cuh"

__global__ void do_something() {
    cudacpp::cudaVector<int> var;
    var.push_back(1);
    var.push_back(2);
    var.push_back(3);
    var.push_back(4);
    var.push_back(5);
    var.erase(var.begin() + 3, var.end() - 1);
    printf("%i\n\n\n", var.size());
    for (uint_fast64_t i = 0; i < var.size(); ++i)
      printf("%i\n", var[i]);

    var.insert(var.begin(), 99);
    printf("%i\n", var.at(0));
    printf("%i\n", var.at(3));
}

int main()
{
    do_something << < 1, 1 >> > ();
    return 0;
}

```
