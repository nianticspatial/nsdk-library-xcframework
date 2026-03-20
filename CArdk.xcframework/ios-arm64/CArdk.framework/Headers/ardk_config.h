// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_sink_callback_function_ptr.h"
#include "ardk_cloud_env_config.h"
#include "ardk_device_info.h"
#include "ardk_path_config.h"
#include "ardk_user_config.h"

#ifdef __cplusplus

extern "C" {
#else
#include <stdint.h>
#include <stdbool.h>
#endif

/// @brief        General configurations for ARDK, used when initializing the system.
typedef struct ARDK_Config {
  /// @brief      If true, disables CTrace logs.
  bool force_disable_ctrace;

  /// @brief      An optional callback function to receive logs from ARDK.
  ///             Regardless of this setting, logs will still be sent to stdout.
  ARDK_SinkCallbackFunctionPtr sink_callback;
  
  /// @brief      Information about the device ARDK is being run on.
  /// @note       This information is not currently used by ARDK.
  ARDK_DeviceInfo device_info;

  /// @brief      Configuration for endpoints.
  ARDK_CloudEnvConfig env_config;

  /// @brief      Configuration for developer settings.
  ARDK_UserConfig user_config;
  
  /// @brief      Optional field to override the public, private and temporary directories.
  ///             If this this value is null, ARDK will infer the paths based on the device.
  ARDK_PathConfig path_config;

  /// @brief      Whether ARDK should use depths provided by the platform.
  /// @details    If true, ARDK features that require depths will expect depths to be provided
  ///             via the \c ARDK_SendFrame function. If false, and ARDK features that require
  ///             depths are running, ARDK will generated estimated depths for their use.
  bool use_platform_depths;
  
} ARDK_Config;

#ifdef __cplusplus
}
#endif
