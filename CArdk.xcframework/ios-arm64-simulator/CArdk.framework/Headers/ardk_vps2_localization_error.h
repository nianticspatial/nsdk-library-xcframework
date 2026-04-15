// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   Possible errors from VPS localization operations.
typedef enum ARDK_VPS2_LocalizationError : uint8_t {
  ARDK_VPS2_LocalizationError_Unknown = 0,

  /// @brief    Code returned when no error has occurred.
  ARDK_VPS2_LocalizationError_None,

  /// @brief    Code returned when the device cannot connect to the server.
  ARDK_VPS2_LocalizationError_BadNetworkConnection,

  /// @brief    Code returned when the API gateway rejects the request due to an
  ///           authentication or authorization failure (e.g. missing, invalid, or
  ///           revoked credentials).
  ARDK_VPS2_LocalizationError_AuthFailure,

  /// @brief    Code returned when the server denies permission for the request.
  ARDK_VPS2_LocalizationError_PermissionDenied,

  /// @brief    Code returned when the request rate limit has been exceeded.
  ARDK_VPS2_LocalizationError_RequestsLimitExceeded,

  /// @brief    Code returned when the server could not process the request
  ///           due to an internal error, not due to malformed input.
  ARDK_VPS2_LocalizationError_InternalServer,

  /// @brief    Code returned when the server sent a response that could not
  ///           be parsed by the client.
  ARDK_VPS2_LocalizationError_InternalClient,

  /// @brief    Code returned when the server could not find a map near the
  ///           request GPS location.
  ARDK_VPS2_LocalizationError_NoMapFound,

  /// @brief    Code returned when the server processed the request but
  ///           localization failed.
  ARDK_VPS2_LocalizationError_LocalizationFailed,

  /// @brief    Code returned when the API gateway rejects the request because
  ///           the account or project quota has been exceeded (HTTP 429).
  ARDK_VPS2_LocalizationError_QuotaExceeded,

  /// @brief    Code returned when a frame was rejected because tracking state
  ///           is not normal.
  ARDK_VPS2_LocalizationError_BadTracking,

  /// @brief    Code returned when a frame was rejected because the camera is
  ///           pointing at the ground or sky (no horizon crossing).
  ARDK_VPS2_LocalizationError_BadCameraAngle,
} ARDK_VPS2_LocalizationError;

#ifdef __cplusplus
}
#endif
