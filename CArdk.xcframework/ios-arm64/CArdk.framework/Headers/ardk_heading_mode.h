// Copyright 2022-2026 Niantic.
#pragma once
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   Controls how the heading is computed from the device's orientation.
typedef enum ARDK_HeadingMode : uint32_t {
  /// @brief Heading from the camera's forward axis (+Z in RDF, perpendicular to screen).
  ///        Best when the device is held upright in portrait or landscape.
  ARDK_HeadingMode_CameraDirection = 0,

  /// @brief Heading from the top edge of the screen, accounting for display orientation.
  ///        Best when the device is held face-up or for compass widgets.
  ARDK_HeadingMode_DeviceTop = 1,
} ARDK_HeadingMode;

#ifdef __cplusplus
}
#endif
