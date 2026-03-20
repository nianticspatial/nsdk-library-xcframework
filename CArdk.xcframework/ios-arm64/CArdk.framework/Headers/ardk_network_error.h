// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   Possible errors when from VPS network operations.
typedef enum ARDK_NetworkError : uint8_t {
  kNetworkError_Unknown = 0,

  /// @brief    Code returned when no error has occurred.
  kNetworkError_None,

  /// @brief    Code returned when the device cannot connect to the server
  kNetworkError_BadNetworkConnection,

  /// @brief    Code returned when the API key specified when initializing ARDK
  ///           is invalid.
  kNetworkError_BadApiKey,

  /// @brief    Deprecated, but kept for backwards (Unity) compatibility.
  /// @details  This code is not surfaced as a network error, but
  ///           instead as a anchor tracking failure reason.
  kNetworkError_PermissionDenied,

  /// @brief    Deprecated, but kept for backwards (Unity) compatibility.
  kNetworkError_RequestsLimitExceeded,

  /// @brief    Code returned when the server could not process the request
  ///           due to an internal error, not due to malformed input.
  kNetworkError_InternalServer,

  /// @brief    Code returned when the server sent a response that could not
  ///           be parsed by the client.
  kNetworkError_InternalClient,
} ARDK_NetworkError;

#ifdef __cplusplus
}
#endif
