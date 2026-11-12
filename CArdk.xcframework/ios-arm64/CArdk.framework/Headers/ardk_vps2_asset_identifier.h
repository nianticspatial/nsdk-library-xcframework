// Copyright 2026 Niantic Spatial

#pragma once

#ifdef __cplusplus

extern "C" {
#endif

/// @brief        Size in bytes of the id buffers in VPS2 asset structs, including the NUL
///               terminator. Ids are canonical 36-character UUID strings; the headroom
///               absorbs format changes without an ABI break.
#define ARDK_VPS2_ASSET_ID_BUFFER_SIZE 64

/// @brief        Precisely identifies a VPS map asset: the site it belongs to, the asset's
///               id within that site, and the area of the asset in question.
///
/// @details      All ids name the site's VPS map asset: \c asset_id is never the id of a
///               mesh, splat, or other non-VPS asset of the site, and \c area_id is one of
///               that asset's areas.
typedef struct ARDK_VPS2_AssetIdentifier {
  /// @brief      The identifier of the site the asset belongs to, as a NUL-terminated
  ///             string.
  char site_id[ARDK_VPS2_ASSET_ID_BUFFER_SIZE];

  /// @brief      The identifier of the VPS map asset within the site, as a NUL-terminated
  ///             string.
  char asset_id[ARDK_VPS2_ASSET_ID_BUFFER_SIZE];

  /// @brief      The identifier of the asset's area, as a NUL-terminated string. A large
  ///             map is published as several areas of one asset; this names the one the
  ///             reporting struct is about. Empty when the portal publishes no area id.
  char area_id[ARDK_VPS2_ASSET_ID_BUFFER_SIZE];
} ARDK_VPS2_AssetIdentifier;

#ifdef __cplusplus
}
#endif
