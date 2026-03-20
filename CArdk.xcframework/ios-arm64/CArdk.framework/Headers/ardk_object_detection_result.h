// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_awareness_result_context.h"
#include "ardk_awareness_status.h"
#include "ardk_object_detection_image_params.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Container for confidence data output by the object detection
///             feature.
/// @note       Make sure to release this object once it's no longer needed by
///             calling the \c ARDK_Release_Resource function for this struct's
///             \c handle.
typedef struct ARDK_ObjectDetectionResult {
  /// @brief    Status code signaling if this result has valid non-zero data or the
  ///           reason it does not.
  ARDK_Awareness_Status status;

  /// @brief    Context information about this frame of object detection data,
  ///           such as timestamp, frame index, or other metadata.
  ARDK_Awareness_ResultContext context;

  /// @brief    Handle to the object detection buffer's underlying memory.
  ///           Must be released using \c ARDK_Release_Resource when finished.
  ARDK_ResourceHandle handle;

  /// @brief    Number of objects detected in the current frame.
  uint32_t num_detections;

  /// @brief    Number of distinct object classes recognized by the detector.
  uint32_t num_classes;

  /// @brief    Pointer to a flattened array of bounding box locations.
  float* bounding_box_locations;

  /// @brief    Pointer to a flattened array of probabilities for each detected object.
  float* probabilities;

  /// @brief    Pointer to an array of tracking IDs for each detected object.
  uint32_t* tracking_ids;

  /// @brief    Dimenisions of the source image and models input dimensions.
  ARDK_ObjectDetection_ImageParams image_params;
} ARDK_ObjectDetectionResult;

#ifdef __cplusplus
}
#endif
