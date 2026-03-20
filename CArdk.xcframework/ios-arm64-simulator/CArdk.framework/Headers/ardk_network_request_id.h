// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief       Unique identifier for network requests
typedef uint64_t ARDK_NetworkRequestId;

#ifdef __cplusplus
}
#endif
