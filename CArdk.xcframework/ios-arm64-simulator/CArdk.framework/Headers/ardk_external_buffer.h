// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      A wrapper for memory allocated by ARDK, used to pass data
//              from ARDK out to a caller of some C API function.
/// @note       The caller must eventually release the included handle to
///             avoid memory leaks.
typedef struct ARDK_ExternalBuffer {
  const uint8_t* data;
  uint32_t data_size;
  ARDK_ResourceHandle handle;
} ARDK_ExternalBuffer;

#ifdef __cplusplus
}
#endif
