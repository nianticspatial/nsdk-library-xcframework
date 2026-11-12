// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Codes returned by the GetFeatureStatus functions to indicate
///             surface errors that have occured in the feature's async processes.
/// @details    While there is some error checking that happens immediately when
///             an ARDK function is called (those are returned as \c ARDK_Status
///             codes), most ARDK feature functions do the bulk of their work on
///             task threads, and so these codes exist to surface errors that
///             arise on those threads.
typedef enum ARDK_FeatureStatus : uint32_t {
  /// @brief    The feature is in a non-error state
  ARDK_FeatureStatus_None = 0,

  /// @brief    The function used to retrieve the feature status failed because
  ///           it was passed a null \c ARDK_Handle.
  ARDK_FeatureStatus_NullArdkHandle = 1 << 0,

  /// @brief    The feature has not been created.
  ARDK_FeatureStatus_DoesNotExist = 1 << 1,

  /// @brief    Configuration failed
  /// @details  This can happen if a method to configure the feature was called
  ///           while the feature was in a state that does not allow configuration
  ///           (ex. while the feature has started), or if the configuration was
  ///           invalid in some way that could not be detected synchronously.
  ///           Read the feature's specific documentation for more details on why
  ///           this error might occur.
  ARDK_FeatureStatus_ConfigurationFailed = 1 << 2,

  /// @brief    The authentication credentials used to initialize ARDK are invalid
  ///           for this feature.
  /// @deprecated Read \c ARDK_VPS2_GetLocalizationRequestRecords instead.
  /// @details  A single bit cannot describe the authorization state of more than one service,
  ///           and VPS2 talks to two that authorize independently: the localization gateway and
  ///           the portal. A token can be entitled to one and not the other, so this bit is
  ///           forced to report one verdict for two different answers. Each localization request
  ///           record instead carries both a request type and an error, so a failure can be
  ///           attributed to the service that produced it.
  ///
  ///           For the remainder of its life this bit reports localization failures only; a
  ///           portal rejection never sets it.
  /// @note     Value \c 1 << 3 is reserved permanently and must not be reused once this is
  ///           removed. The Unity and Python bindings mirror this enum by hardcoded value, so
  ///           renumbering would silently change their meaning with nothing failing to build.
  ARDK_FeatureStatus_BadAuth = 1 << 3
} ARDK_FeatureStatus;

#ifdef __cplusplus
}
#endif
