// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief   The state of a VPS Coverage network request.
typedef enum ARDK_VPSCoverage_RequestStatus {
  /// @brief  No response has yet been received, and no errors
  ///         have yet been encountered.
  ARDK_VPSCoverage_RequestStatus_InProgress,

  /// @brief  A successful reponse was received.
  ARDK_VPSCoverage_RequestStatus_Success,

  /// @brief  An error occured fulfilling the request.
  ARDK_VPSCoverage_RequestStatus_Failed
} ARDK_VPSCoverage_RequestStatus;

#ifdef __cplusplus
}
#endif
