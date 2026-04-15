// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

extern "C" {
#endif

/// @brief   The screen orientation of the application
typedef enum ARDK_Orientation {
  ARDK_Orientation_Unknown,

  /// @brief Portrait orientation.
  ARDK_Orientation_Portrait,

  /// @brief Portrait orientation, upside down.
  ARDK_Orientation_PortraitUpsideDown,

  /// @brief Landscape orientation, rotated counter-clockwise from the portrait orientation.
  ARDK_Orientation_LandscapeRight,

  /// @brief Landscape orientation, rotated clockwise from the portrait orientation.
  ARDK_Orientation_LandscapeLeft,
} ARDK_Orientation;

#ifdef __cplusplus
}
#endif
