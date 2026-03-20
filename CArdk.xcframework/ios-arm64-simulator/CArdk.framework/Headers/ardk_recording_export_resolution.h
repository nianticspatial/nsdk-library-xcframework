// Copyright 2026 Niantic Spatial, Inc. All rights reserved.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief Resolution option for exported scan images.
typedef enum NSDK_ExportResolution {
  /// Export both 720p and high resolution images when available.
  NSDK_ExportResolution_Mixed = 0,
  /// Export only the 720p resolution image.
  NSDK_ExportResolution_720_540 = 1,
  /// Export only the high resolution image when available.
  /// This is the same resolution as the camera frame passed to NSDK_SendFrame
  NSDK_ExportResolution_High = 2,
} NSDK_ExportResolution;

#ifdef __cplusplus
}
#endif
