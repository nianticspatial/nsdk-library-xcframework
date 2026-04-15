// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_awareness_result_context.h"
#include "ardk_awareness_status.h"
#include "ardk_object_detection_image_params.h"

#ifdef __cplusplus
extern "C" {
#else
#endif

/// @brief       Container for image parameters output by the object detection
///              feature.
typedef struct ARDK_ObjectDetection_Metadata {
  /// @brief    Status code signaling if this result has valid non-zero data or the
  ///           reason it does not.
  enum ARDK_Awareness_Status status;

  /// @brief    Context information about this frame of object detection data,
  ///           such as timestamp, frame index, or other metadata.
  ARDK_Awareness_ResultContext context;

  /// @brief    Dimenisions of the source image and model input image size.
  ARDK_ObjectDetection_ImageParams image_params;
} ARDK_ObjectDetection_Metadata;

#ifdef __cplusplus
}
#endif
