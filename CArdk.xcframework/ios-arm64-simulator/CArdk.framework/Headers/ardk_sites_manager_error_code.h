// Copyright Niantic Spatial.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief   Error codes for Sites Manager requests.
typedef enum ARDK_SitesManager_Error {
  /// @brief  No error occurred.
  ARDK_SitesManager_Error_None = 0,

  /// @brief  A network error occurred (e.g., connection failure, timeout).
  ARDK_SitesManager_Error_NetworkError,

  /// @brief  The request was invalid (e.g., missing required parameters).
  ARDK_SitesManager_Error_InvalidRequest,

  /// @brief  HTTP 403 Forbidden - insufficient permissions.
  ARDK_SitesManager_Error_HttpForbidden,

  /// @brief  HTTP 404 Not Found - the requested resource doesn't exist.
  ARDK_SitesManager_Error_HttpNotFound,

  /// @brief  HTTP 429 Too Many Requests - rate limit exceeded.
  ARDK_SitesManager_Error_HttpTooManyRequests,

  /// @brief  HTTP 5xx - server error.
  ARDK_SitesManager_Error_HttpServerError,

  /// @brief  Failed to parse the response data.
  ARDK_SitesManager_Error_ParseError,

  /// @brief  An unexpected error occurred.
  ARDK_SitesManager_Error_UnexpectedError
} ARDK_SitesManager_Error;

#ifdef __cplusplus
}
#endif

