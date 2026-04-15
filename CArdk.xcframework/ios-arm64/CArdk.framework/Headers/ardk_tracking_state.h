// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

extern "C" {
#endif

/// @brief   The general quality of position tracking available when the camera captured a frame.
typedef enum ARDK_TrackingState {
  ARDK_TrackingState_Unknown,
  ARDK_TrackingState_Failed,
  ARDK_TrackingState_Poor,
  ARDK_TrackingState_Normal,
} ARDK_TrackingState;

#ifdef __cplusplus
}
#endif
