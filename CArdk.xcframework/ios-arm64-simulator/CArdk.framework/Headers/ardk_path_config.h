// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief      Configuration for optionally overriding the paths ARDK uses as public, private and
///             temporary file paths. When the fields are set to null or empty strings, ARDK will
///             use auto-detected paths instead.
typedef struct ARDK_PathConfig {
  /// @brief    Override for the public folder path.
  ARDK_String public_application_path;

  /// @brief    Override for the private folder path.
  ARDK_String private_application_path;

  /// @brief    Override for the temporary folder path
  ARDK_String tmp_path;
} ARDK_PathConfig;

#ifdef __cplusplus
}
#endif
