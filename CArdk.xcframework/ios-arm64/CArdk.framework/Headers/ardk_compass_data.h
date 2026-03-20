// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Compass readings 
typedef struct ARDK_CompassData {
  /// @brief      Timestamp of the reading in milliseconds. This may be in either posix
  ///             or monotonic time.
  uint64_t timestamp_ms;

  /// @brief      Accuracy of heading reading in degrees.
  /// @details    If accuracy is not supported or not available, 0 is returned. A negative value
  ///             means unreliable readings. Not all platforms provide a precise measure of
  ///             accuracy, so the value may vary between a few constant values.
  float heading_accuracy;

  /// @brief      Heading in degrees relative to the magnetic North Pole, measured from the
  ///             top of the screen in its current orientation.
  /// @remark     ARDK does not currently have a use for this data.
  float magnetic_heading;

  /// @brief      X value of the raw geomagnetic data measured in microteslas.
  /// @remark     ARDK does not currently have a use for this data.
  float raw_data_x;

  /// @brief      Y value of the raw geomagnetic data measured in microteslas.
  /// @remark     ARDK does not currently have a use for this data.
  float raw_data_y;

  /// @brief      Z value of the raw geomagnetic data measured in microteslas.
  /// @remark     ARDK does not currently have a use for this data.
  float raw_data_z;

  /// @brief      Heading in degrees relative to the geographic North Pole, measured from the
  ///             top of the screen in its current orientation.
  float true_heading;
} ARDK_CompassData;

#ifdef __cplusplus
}
#endif
