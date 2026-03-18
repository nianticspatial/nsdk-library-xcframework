// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief    Flags representing the types of input data requested by ARDK.
enum ARDK_InputDataFlags : uint32_t {
  /// @brief No data
  ARDK_InputData_None = 0,

  /// @brief The AR camera pose, consisting of the timestamp and transform
  ARDK_InputData_Pose = 1 << 0,

  /// @brief Device orientation data
  ARDK_InputData_DeviceOrientation = 1 << 1,

  /// @brief AR tracking state
  ARDK_InputData_TrackingState = 1 << 2,

  /// @brief Camera image, consisting of all the planes, the intrinsics,
  ///        and other metadata.
  ARDK_InputData_CameraImage = 1 << 3,

  /// @brief GPS location data
  ARDK_InputData_GpsLocation = 1 << 4,

  /// @brief Compass data
  ARDK_InputData_Compass = 1 << 5,

  /// @brief Depth data sourced from outside ARDK, such as LiDAR data
  ARDK_InputData_PlatformDepth = 1 << 6,

  /// @brief Last item in the enum to help iterate over all flags
  ARDK_InputData_EndOfFormats = 1 << 7,
};

#ifdef __cplusplus
}
#endif
