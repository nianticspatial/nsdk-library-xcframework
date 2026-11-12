// Copyright 2022-2026 Niantic.
#pragma once

#include "ardk_string.h"

#ifdef __cplusplus
#include <cstdint>
extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

/// Configuration for the dashcam feature.
/// Non-boolean struct fields left zeroed-out will be internally
/// converted to default values.
typedef struct ARDK_Dashcam_Config {
  /// Target FPS for buffering frames.
  /// The dashcam will subsample the source frame stream to this rate.
  /// If set to 0, defaults to 5 FPS.
  int framerate;

  /// Maximum number of seconds of data to keep in the circular buffer.
  /// When the buffer exceeds this duration, the oldest frames are evicted.
  /// If set to 0, defaults to 60 seconds.
  int max_buffer_seconds;

  /// Maximum memory budget for the circular buffer in megabytes.
  /// When the buffer exceeds this size, the oldest frames are evicted.
  /// Whichever limit (time or memory) is hit first triggers eviction.
  /// If set to 0, defaults to 50 MB.
  int max_buffer_memory_mb;

  /// Base path for writing dashcam data.
  /// If an absolute path is provided, that directory must be writable.
  /// If left empty, ARDK uses the public application path.
  ARDK_String base_path;
} ARDK_Dashcam_Config;

/// Status of a dashcam save operation.
typedef enum ARDK_Dashcam_SaveState {
  /// No save has been requested or the save result has not yet been computed.
  ARDK_Dashcam_SaveState_NotAvailable = 0,
  /// The save completed successfully.
  ARDK_Dashcam_SaveState_Saved,
  /// The save failed (e.g. no frames in buffer, I/O error).
  ARDK_Dashcam_SaveState_Failed,
} ARDK_Dashcam_SaveState;

/// Information about the dashcam buffer state.
typedef struct ARDK_Dashcam_BufferInfo {
  /// Number of frames currently in the buffer.
  uint32_t frame_count;
  /// Approximate memory used by the buffer in bytes.
  uint64_t memory_used_bytes;
  /// Duration of buffered data in milliseconds.
  uint64_t duration_ms;
} ARDK_Dashcam_BufferInfo;

/// Result of a dashcam save operation.
typedef struct ARDK_Dashcam_SaveResult {
  /// Handle to native resources. Release with ARDK_Release_Resource
  /// once the contents are no longer needed.
  void* handle;
  /// State of the save operation.
  ARDK_Dashcam_SaveState state;
  /// Path to the saved V2 sequence directory (valid when state == Saved).
  const char* save_path;
  /// Length of save_path string.
  uint32_t save_path_len;
  /// Path to the exported .tgz archive (valid when state == Saved).
  const char* archive_path;
  /// Length of archive_path string.
  uint32_t archive_path_len;
} ARDK_Dashcam_SaveResult;

#ifdef __cplusplus
}
#endif
