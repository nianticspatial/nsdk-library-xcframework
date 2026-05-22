// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#endif

// Recording export paths buffer.
// Contains an array of file paths for exported scan archives. When an export is split
// across multiple archives (based on max_frames_per_archive), this will contain
// multiple paths, one for each archive chunk.
// The native API will own the data in the buffer. Once the buffer is finished
// being used, free the data in this buffer using the ARDK_ResourceHandle
// calling ARDK_Release_Resource(handle)
typedef struct ARDK_RecordingExportPaths {
  /// @brief      Resource handle for memory management. Must be released with
  ///             \c ARDK_Release_Resource once it's no longer needed.
  ARDK_ResourceHandle handle;

  /// @brief      Array of exported path strings. Each path points to an archive file
  ///             containing exported scan data.
  const ARDK_String* paths;

  /// @brief      Number of paths in the \p paths array.
  int num_paths;
} ARDK_RecordingExportPaths;

#ifdef __cplusplus
}
#endif
