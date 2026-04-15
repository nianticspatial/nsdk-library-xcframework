// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

typedef enum ARDK_VPS2_LocalizationRequestStatus : uint8_t {
  /// Status is unknown or uninitialized.
  ARDK_VPS2_LocalizationRequestStatus_Unknown = 0,
  /// The request has been sent and is awaiting a response.
  ARDK_VPS2_LocalizationRequestStatus_Pending,
  /// The request completed and a response was received. Note: the localization itself may still
  /// have failed — check the localization error for details.
  ARDK_VPS2_LocalizationRequestStatus_Completed,
  /// The request failed (e.g. network error, HTTP error, or unparseable response).
  ARDK_VPS2_LocalizationRequestStatus_Failed,
  /// The request was not sent because the frame was rejected (e.g. camera pointed downward).
  ARDK_VPS2_LocalizationRequestStatus_FrameRejected,
} ARDK_VPS2_LocalizationRequestStatus;

#ifdef __cplusplus
}
#endif
