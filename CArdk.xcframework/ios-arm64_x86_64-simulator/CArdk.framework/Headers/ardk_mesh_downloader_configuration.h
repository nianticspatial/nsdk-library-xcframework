// Copyright 2026 Niantic Spatial.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

/// @brief        Settings for the MeshDownloader's on-disk cache of downloaded mesh data.
///
/// @details      Downloaded Draco geometry and textures are cached per graph node, so revisiting a
///               location reads from disk instead of the CDN, and an interrupted download resumes
///               where it stopped rather than starting over. Cached content never goes stale: a
///               re-run of the mapping pipeline publishes new node ids, so an id always names the
///               same geometry.
///
///               Disabled by default. A MeshDownloader without caching does not read, write, or
///               delete anything in the cache directory, so enabling caching in one session and
///               not the next leaves the cached data intact.
typedef struct ARDK_MeshDownloader_Configuration {
  /// @brief      Whether to cache downloaded mesh data on disk. Default false.
  bool cache_enabled;

  /// @brief      Maximum disk space the cache may use, in megabytes. Once exceeded, the
  ///             least-recently-used nodes are removed until the cache fits.
  /// @details    Must be greater than zero when \c cache_enabled is true;
  ///             \c ARDK_MeshDownloader_Configure rejects the combination rather than guessing
  ///             whether zero means "no limit" or "no space".
  ///
  ///             Size this above the total download size of the locations you expect to hold. A
  ///             budget smaller than the working set does not degrade gracefully -- it evicts
  ///             nodes that are about to be needed again, and re-downloads them indefinitely.
  uint32_t cache_max_mb;
} ARDK_MeshDownloader_Configuration;

#ifdef __cplusplus
}
#endif
