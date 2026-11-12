// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief      Configuration for developer settings.
typedef struct ARDK_UserConfig {
  /// @brief    Access token for authentication.
  ARDK_String access_token;

  // TODO(?) still need?
  ARDK_String feature_flag_file_path;
} ARDK_UserConfig;

#ifdef __cplusplus
}
#endif
