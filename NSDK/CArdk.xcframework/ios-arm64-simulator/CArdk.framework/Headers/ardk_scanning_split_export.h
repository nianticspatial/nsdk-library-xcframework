// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_resource_handle.h"
#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     Represents a scan that has been exported as multiple archive files.
typedef struct ARDK_Scanning_Split_Export {
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;

  /// @brief   Array of paths to the exported scan archives.
  const ARDK_String* export_paths;

  /// @brief   Number of exported archives.
  /// @details This is the length of the \c export_paths array.
  int export_paths_size;
} ARDK_Scanning_Split_Export;

#ifdef __cplusplus
}
#endif
