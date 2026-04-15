// Copyright 2022-2025 Niantic.
#pragma once

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/// @brief      Information about a scan recording operation.
typedef struct ARDK_Scanning_RecordingInfo {
  /// @brief Count of frames recorded in the current scan session.
  size_t frame_count;
} ARDK_Scanning_RecordingInfo;

#ifdef __cplusplus
}
#endif
