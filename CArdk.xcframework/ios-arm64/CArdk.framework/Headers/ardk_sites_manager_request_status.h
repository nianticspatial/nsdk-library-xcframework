// Copyright Niantic Spatial.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief   The state of a Sites Manager network request.
typedef enum ARDK_SitesManager_RequestStatus {
  /// @brief  No response has yet been received, and no errors
  ///         have yet been encountered.
  ARDK_SitesManager_RequestStatus_InProgress,

  /// @brief  A successful response was received.
  ARDK_SitesManager_RequestStatus_Success,

  /// @brief  An error occurred fulfilling the request.
  ARDK_SitesManager_RequestStatus_Failed
} ARDK_SitesManager_RequestStatus;

#ifdef __cplusplus
}
#endif

