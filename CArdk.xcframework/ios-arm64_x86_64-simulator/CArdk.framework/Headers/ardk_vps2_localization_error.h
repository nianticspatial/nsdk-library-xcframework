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

  /// @brief    Code returned when the client could not form or issue the request,
  ///           or when the server sent a response the client could not parse.
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

  /// @brief    Code returned when a frame was rejected before dispatch because
  ///           no valid geolocation prior was available — the GPS reading was
  ///           NaN or a placeholder and no other valid prior (e.g. a WPS
  ///           estimate) could be substituted.
  ARDK_VPS2_LocalizationError_NoValidPrior,

  /// @brief    Code returned when a frame was rejected because the device was
  ///           held upside down (inverted relative to gravity).
  ARDK_VPS2_LocalizationError_DeviceUpsideDown,

  /// @brief    Code returned when a frame was flagged because the image was too
  ///           blurry or featureless to localize well. Advisory: the frame is
  ///           still sent; use this to coach the user, not to explain a drop.
  ARDK_VPS2_LocalizationError_ImageTooBlurry,

  /// @brief    Code returned when the requested site does not exist or is not
  ///           accessible to this caller.
  /// @note     Blocked on NSDK-8830: A missing or invisible site currently comes
  ///           back as 403, surfacing as
  ///           \c ARDK_VPS2_LocalizationError_AuthFailure and not this code.
  ///           For now, the only 404s that reach here are route misses.
  ARDK_VPS2_LocalizationError_SiteNotFound,

  /// @brief    Code returned when the request found nothing to localize against.
  ///           For \c ARDK_VPS2_LocalizeToSite the site was found but has no usable
  ///           assets: either none of them are deployed to production, or the
  ///           production-deployed ones were not localizable. For
  ///           \c ARDK_VPS2_LocalizeToNearbySites either no site fell within the
  ///           radius, or none of the sites that did had a localizable asset.
  ARDK_VPS2_LocalizationError_VpsAssetsNotFound,
} ARDK_VPS2_LocalizationError;

#ifdef __cplusplus
}
#endif
