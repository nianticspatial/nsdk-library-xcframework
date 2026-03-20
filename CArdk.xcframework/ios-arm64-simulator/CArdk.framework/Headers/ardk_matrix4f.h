// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief A 4x4 matrix of 16 floats
typedef float* ARDK_Matrix4f;

#ifdef __cplusplus
}
#endif
