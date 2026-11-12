// Copyright 2026 Niantic Spatial.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief  Whether a mesh download carries a usable georeference.
typedef enum ARDK_Mesh_GeoReferenceMode {
  /// @brief  The asset has no georeference, or its chunk transforms do not share a single frame
  ///         for one to apply to. The mesh can only be placed in a local (non-geographic) frame;
  ///         every other field is zero.
  ARDK_Mesh_GeoReferenceMode_Unavailable = 0,

  /// @brief  The fields below are valid. Anchor the mesh group's world origin at
  ///         (reference_latitude, reference_longitude, reference_altitude) and apply
  ///         tracking_to_reference to the whole group, then place each chunk by its own
  ///         `transform`.
  ARDK_Mesh_GeoReferenceMode_Georeferenced = 1,
} ARDK_Mesh_GeoReferenceMode;

/// @brief  Georeference of a mesh download's asset: the geodetic origin its chunk transforms are
///         expressed relative to, plus the transform into that origin's frame.
///
/// @details Identical on every ARDK_MeshDownloader_Chunk / ARDK_MeshDownloader_Data of one
///          download, because it describes the space rather than any single node. A chunk's own
///          geographic position is obtained by composing this with that chunk's `transform` — not
///          from anything inside ARDK_MeshData, which carries no geographic data at all.
///
///          Both the origin and the transform are required: depending on the asset, the altitude
///          offset may live entirely in reference_altitude (with tracking_to_reference carrying no
///          vertical translation) or entirely in tracking_to_reference (with reference_altitude
///          zero).
///          Applying the origin without the transform is wrong in the general case.
typedef struct ARDK_Mesh_GeoReference {
  /// @brief  Whether the fields below are valid. Inspect this first.
  ARDK_Mesh_GeoReferenceMode mode;

  /// @brief  Padding to align the doubles below to 8 bytes.
  uint32_t _padding;

  /// @brief  WGS84 latitude of the origin tracking_to_reference maps into, decimal degrees.
  double reference_latitude;
  /// @brief  WGS84 longitude of the origin tracking_to_reference maps into, decimal degrees.
  double reference_longitude;
  /// @brief  Altitude of that origin, in meters above the WGS84 ellipsoid.
  double reference_altitude;

  /// @brief  Column-major 4x4 matrix mapping the asset's origin space (the space the chunk
  ///         transforms are expressed in, not the device's AR tracking space) into meters
  ///         relative to the reference origin, exactly as delivered by Portal — this
  ///         implementation does not transpose it. The frame is East-Down-North, so +Y is
  ///         downward.
  float tracking_to_reference[16];
} ARDK_Mesh_GeoReference;

#ifdef __cplusplus
}
#endif
