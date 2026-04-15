// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief      Configuration for developer settings.
typedef struct ARDK_UserConfig {
  /// @brief    API key for the project. This is required for using features that utilize
  ///           cloud services (VPS, VPS Coverage).
  /// @details  This is the key that you can find at lightship.dev/account/projects.
  ///           If you are not using features that require an API key, this can safely by
  ///           left as a nullptr.
  ARDK_String api_key;

  /// @brief    Access token for authentication. This is used instead of API key for
  ///           token-based authentication.
  ARDK_String access_token;

  /// @brief    Refresh token for obtaining new access tokens at runtime.
  ARDK_String refresh_token;

  // TODO(?) still need?
  ARDK_String feature_flag_file_path;
} ARDK_UserConfig;

#ifdef __cplusplus
}
#endif
