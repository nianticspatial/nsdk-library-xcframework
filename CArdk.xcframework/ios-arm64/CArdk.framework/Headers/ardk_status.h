// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   Codes returned by most ARDK functions to indicate success or failure.
typedef enum ARDK_Status {
  /// @brief  The function executed successfully.
  /// @note   Some ARDK functions execute the meat of their work asynchronously, and 
  ///         for those functions a return value of \c ARDK_Status_OK does not indicate
  ///         anything about the success of the asynchronous work. When such functions
  ///         exist for a feature, the feature will provide a way to check the status
  ///         of asynchronous work (ex. \c ARDK_VPS_GetFeatureStatus for the VPS feature).
  ARDK_Status_OK = 0,

  /// @brief  Code that is returned when a null pointer is passed to a function that does not
  ///         accept it has a valid argument.
  ARDK_Status_NullArgument,

  /// @brief  Code that is returned when a function is called with an invalid argument.
  ARDK_Status_InvalidArgument,

  /// @brief  Code that is returned when a function call is invalid for the current state
  ///         of the feature.
  ARDK_Status_InvalidOperation,

  /// @brief  Code that is returned when a null \c ARDK_Handle is passed to a function that
  ///         does not accept it as a valid argument.
  ARDK_Status_NullArdkHandle,

  /// @brief  Code that is returned when a function is called that requires a feature to first
  ///         be created, but the feature has not been created yet.
  ARDK_Status_FeatureDoesNotExist,

  /// @brief  Code that is returned when a function is called that requires a feature to be
  ///         not yet have been created, but the feature has already been created.
  ARDK_Status_FeatureAlreadyExists,
  
  // deprecated
  ARDK_Status_NoData,
  ARDK_Status_InternalError
} ARDK_Status;

#ifdef __cplusplus
}
#endif
