// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_resource_handle.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief      The state of a requested save operation for a scan.
typedef enum ARDK_Scanning_SaveState {
  ARDK_Scanning_SaveState_NotAvailable,
  ARDK_Scanning_SaveState_Discarded,
  ARDK_Scanning_SaveState_Saved,
} ARDK_Scanning_SaveState;

/// @brief      Information about a scan save operation.
typedef struct ARDK_Scanning_SaveInfo {
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;

  /// @brief State of the requested save
  ARDK_Scanning_SaveState state;

  /// @brief Unique identifier of the scan
  const char *scan_id;

  /// @brief Length of \ref scan_id string
  int scan_id_len;

  /// @brief Path of the saved scan
  const char *save_path;

  /// @brief Length of \ref save_path string
  int save_path_len;
} ARDK_Scanning_SaveInfo;

#ifdef __cplusplus
}
#endif
