// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Codes returned by the Awareness functions including depth and semantics to indicate
///             surface errors that have occured in the surfacing their respective data.
typedef enum ARDK_Awareness_Status : uint8_t {
  /// @brief    Default value.
  ARDK_Awareness_Status_Unset = 0,

  /// @brief    The system is not ready for computation
  ARDK_Awareness_Status_NotReady,

  /// @brief    The system has data available to read
  ARDK_Awareness_Status_Available,

  /// @brief    The system has tried and failed to read a model
  ARDK_Awareness_Status_ModelReadFailed,

  /// @brief    The system has failed to download the model
  ARDK_Awareness_Status_ModelDownloadFailed,

  /// @brief    Something went wrong internally.
  ARDK_Awareness_Status_InternalError,
} ARDK_Awareness_Status;

#ifdef __cplusplus
}
#endif
