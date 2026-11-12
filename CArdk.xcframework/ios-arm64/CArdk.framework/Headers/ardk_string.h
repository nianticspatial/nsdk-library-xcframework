// Copyright 2022-2026 Niantic Spatial

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief    Helper struct for passing in strings interop to ARDK's C functions
/// @details  `data` holds `data_size` bytes of UTF-8 (not Modified UTF-8 or UTF-16), and
///           `data_size` counts bytes, not characters. The data must remain in scope until
///           the ARDK function it was passed to has returned. Strings NSDK returns, as
///           ARDK_String or as `const char*` fields of result structs, are UTF-8 too.
typedef struct ARDK_String {
  const char* data;
  uint32_t data_size;
} ARDK_String;

#ifdef __cplusplus
}
#endif
