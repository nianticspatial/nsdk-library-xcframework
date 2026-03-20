// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// A 3x3 matrix of size 9 floats
typedef float* ARDK_Matrix3f;

#ifdef __cplusplus
}
#endif
