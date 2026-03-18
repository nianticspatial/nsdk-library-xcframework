// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief    Helper struct for passing in strings interop to ARDK's C functions
/// @details  The data must remain in scope until the ARDK function it was passed
///           to has returned.
typedef struct ARDK_String {
  const char* data;
  uint32_t data_size;
} ARDK_String;

#ifdef __cplusplus
}
#endif
