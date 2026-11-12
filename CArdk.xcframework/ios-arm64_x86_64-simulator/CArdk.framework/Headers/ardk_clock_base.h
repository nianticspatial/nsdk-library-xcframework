// Copyright 2022-2026 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Reference clock that a timestamp is measured against.
typedef enum ARDK_ClockBase : uint32_t {
  /// @brief      Wall-clock time measured from the Unix epoch (1970-01-01 00:00:00 UTC).
  ARDK_ClockBase_Epoch = 0,

  /// @brief      Monotonic time from an arbitrary, steadily-increasing clock (e.g. time since
  ///             device boot). Comparable between readings, but not to wall-clock time.
  ARDK_ClockBase_Monotonic = 1,
} ARDK_ClockBase;

#ifdef __cplusplus
}
#endif
