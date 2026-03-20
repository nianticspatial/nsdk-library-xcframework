// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_resource_handle.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief       Represents a scan that has been exported.
typedef struct ARDK_Scanning_Export {
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;

  /// @brief   Path of the exported scan.
  const char *export_path;

  /// @brief   Length of \c export_path string
  int export_path_len;
} ARDK_Scanning_Export;

#ifdef __cplusplus
}
#endif
