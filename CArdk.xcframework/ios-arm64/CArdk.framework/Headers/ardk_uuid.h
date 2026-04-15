// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief 128-bit identifier
typedef uint8_t* ARDK_UUID;

#ifdef __cplusplus
}
#endif
