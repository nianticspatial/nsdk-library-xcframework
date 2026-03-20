// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      A wrapper for some allocated memory.
/// @details    If the memory was allocated outside of ARDK, ARDK does not assume
///             the buffer is valid outside the scope of the called function.
typedef struct ARDK_Buffer {
  const uint8_t* data;
  uint32_t data_size;
} ARDK_Buffer;

#ifdef __cplusplus
}
#endif
