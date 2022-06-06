#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <cuda/std/iterator>

#ifdef __CUDACC__
#define CUDA_CALLABLE_MEMBER __host__ __device__
#else
#define CUDA_CALLABLE_MEMBER
#endif
namespace cudacpp {

	template <typename T>
	class cudaVector {
		T* mainMemory = nullptr;
		T* tempMemory = nullptr;
		uint_fast64_t SIZE = 0;

	public:

		using iterator = T*;
		using const_iterator = const T* const;

		CUDA_CALLABLE_MEMBER cudaVector() = default;
		CUDA_CALLABLE_MEMBER cudaVector(uint_fast64_t allocSize) :mainMemory(new T[allocSize]) {}
		CUDA_CALLABLE_MEMBER cudaVector(cudaVector&& lVector) : SIZE(lVector->SIZE), mainMemory(lVector->mainMemory) {
			lVector->mainMemory = nullptr;
			lVector->SIZE = 0;
		}
		CUDA_CALLABLE_MEMBER inline constexpr void clear() noexcept {
			delete[] mainMemory;
			mainMemory = nullptr;
			SIZE = 0;
		}
		CUDA_CALLABLE_MEMBER inline constexpr void erase(const_iterator eraseBegin, const_iterator eraseEnd) noexcept {
			if (eraseBegin >= eraseEnd)
				return;

			uint_fast64_t startDistance = cuda::std::distance(begin(), eraseBegin);
			uint_fast64_t deleteDistance = cuda::std::distance(eraseBegin, eraseEnd);
			uint_fast64_t endDistance = cuda::std::distance(eraseEnd, end());
			if (deleteDistance == SIZE) {
				SIZE = 0;
				delete[] mainMemory;
				mainMemory = nullptr;
				return;
			}

			for (uint_fast64_t idx = 0; idx < endDistance; ++idx)
				mainMemory[startDistance += idx] = mainMemory[startDistance + deleteDistance];

			SIZE -= deleteDistance;


		}
		CUDA_CALLABLE_MEMBER inline constexpr void insert(const_iterator insertPos, T value) noexcept{
			if (insertPos > end() || insertPos < begin())
				return;

			uint_fast64_t startDistance = cuda::std::distance(begin(), insertPos);
			uint_fast64_t endDistance = cuda::std::distance(insertPos, end());
			tempMemory = new T[SIZE];
			memcpy((void*)tempMemory, (void*)mainMemory, sizeof(T) * SIZE);
			delete[] mainMemory;
			mainMemory = new T[++SIZE];
			memcpy((void*)mainMemory, (void*)tempMemory, sizeof(T) * startDistance);
			mainMemory[startDistance] = value;
			memcpy((void*)(mainMemory + startDistance + 1), (void*)(tempMemory + startDistance), sizeof(T) * endDistance);
			delete[] tempMemory;
		}
		CUDA_CALLABLE_MEMBER inline constexpr T& at(uint_fast64_t pos) noexcept {
			return mainMemory[pos];
		}

		CUDA_CALLABLE_MEMBER inline constexpr T& operator[](uint_fast64_t index) noexcept {
			return mainMemory[index];
		}
		CUDA_CALLABLE_MEMBER inline cudaVector(cudaVector& lVector) :SIZE(lVector->SIZE) {
			for (uint_fast64_t idx = 0; idx < this->SIZE; ++idx)
				this->mainMemory[idx] = lVector->mainMemory[idx];
		}
		CUDA_CALLABLE_MEMBER inline constexpr const_iterator begin() noexcept {
			return mainMemory;
		}
		CUDA_CALLABLE_MEMBER inline constexpr const_iterator end() noexcept {
			return (mainMemory + SIZE);
		}

		CUDA_CALLABLE_MEMBER inline constexpr T front() noexcept {
			return mainMemory[0];
		}
		CUDA_CALLABLE_MEMBER inline constexpr T back() noexcept {
			return mainMemory[(SIZE - 1)];
		}

		CUDA_CALLABLE_MEMBER inline constexpr void push_back(T value) noexcept {
			if (SIZE == 0) {
				mainMemory = new T(value);
				++SIZE;
			}
			else {
				tempMemory = new T[SIZE];
				memcpy((void*)tempMemory, (void*)mainMemory, sizeof(T) * SIZE);
				delete[] mainMemory;
				mainMemory = new T[++SIZE];
				memcpy((void*)mainMemory, (void*)tempMemory, sizeof(T) * SIZE);
				mainMemory[(SIZE - 1)] = value;
				delete[] tempMemory;
			}

		}

		CUDA_CALLABLE_MEMBER inline constexpr void pop_back() noexcept {
			if (SIZE == 0) {
				printf("\nPopping empty Queue\n");
				exit(-1); //popping empty Queue
			}
			tempMemory = new T[SIZE];
			memcpy((void*)tempMemory, (void*)mainMemory, sizeof(T) * SIZE);
			delete[] mainMemory;
			mainMemory = new T[--SIZE];
			memcpy((void*)mainMemory, (void*)tempMemory, sizeof(T) * SIZE);
			delete[] tempMemory;
		}


		CUDA_CALLABLE_MEMBER inline constexpr bool empty() noexcept {
			return SIZE == 0;
		}

		CUDA_CALLABLE_MEMBER inline constexpr uint_fast64_t size() noexcept {
			return SIZE;
		}

		CUDA_CALLABLE_MEMBER inline ~cudaVector() noexcept {
			delete[] mainMemory;
		}


	};
};