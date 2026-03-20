// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   The state of a Mesh Downloader network request.
typedef enum ARDK_MeshDownloader_RequestStatus {
  /// @brief  No response has yet been received, and no errors
  ///         have yet been encountered.
  ARDK_MeshDownloader_RequestStatus_InProgress,

  /// @brief  A successful response was received.
  ARDK_MeshDownloader_RequestStatus_Success,

  /// @brief  An error occurred fulfilling the request.
  ARDK_MeshDownloader_RequestStatus_Failed
} ARDK_MeshDownloader_RequestStatus;

#ifdef __cplusplus
}
#endif
