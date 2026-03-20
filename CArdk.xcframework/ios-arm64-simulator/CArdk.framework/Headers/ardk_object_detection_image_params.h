// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_awareness_status.h"

#ifdef __cplusplus
extern "C" {
#else
#endif

/// @brief       Container for information about the camera image input that generated
///              an awareness image, along with the model input size.
typedef struct ARDK_ObjectDetection_ImageParams {
  /// @brief    Width of the source image that was used for object detection.
  ///           This usually corresponds to the resolution of the camera image.
  uint32_t source_frame_width;

  /// @brief    Height of the source image that was used for object detection.
  ///           This usually corresponds to the resolution of the camera image.
  uint32_t source_frame_height;

  /// @brief    Width of the object detection model's input size.
  ///           The source image is resized to this resolution before being processed by the
  ///           predictor.
  uint32_t model_frame_width;

  /// @brief    Height of the object detection model's input size.
  ///           The source image is resized to this resolution before being processed by the
  ///           predictor.
  uint32_t model_frame_height;
} ARDK_ObjectDetection_ImageParams;

#ifdef __cplusplus
}
#endif
