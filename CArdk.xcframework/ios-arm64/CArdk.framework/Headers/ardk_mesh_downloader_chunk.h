// Copyright 2022-2026 Niantic Spatial.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_mesh_data.h"
#include "ardk_mesh_geo_reference.h"
#include "ardk_buffer.h"
#include "ardk_id_string.h"
#include "ardk_matrix4f.h"

#ifdef __cplusplus
#include <cstdint>
extern "C" {
#else
#include <stdint.h>
#endif

/// @brief  Status returned by ARDK_MeshDownloader_GetNextMeshChunk.
typedef enum ARDK_MeshDownloader_ChunkStatus {
  /// @brief  No chunk is ready yet; the download is still in progress. Poll again next frame.
  ARDK_MeshDownloader_ChunkStatus_NoChunkYet = 0,

  /// @brief  A chunk is ready. The mesh, image, and transform fields are valid.
  ///         Call ARDK_Release_Resource on \c handle when done with this chunk.
  ARDK_MeshDownloader_ChunkStatus_ChunkReady = 1,

  /// @brief  All chunks have been delivered and the request is complete. No further polling needed.
  ARDK_MeshDownloader_ChunkStatus_Complete = 2,

  /// @brief  The download encountered an error. See logs for details.
  ARDK_MeshDownloader_ChunkStatus_Error = 3,

  /// @brief  The cumulative download size cap was hit. All previously completed chunks have been
  ///         delivered; no further chunks will arrive. No further polling needed.
  ARDK_MeshDownloader_ChunkStatus_SizeLimitReached = 4,
} ARDK_MeshDownloader_ChunkStatus;

/// @brief  A single decoded mesh chunk from a streaming portal mesh download.
typedef struct ARDK_MeshDownloader_Chunk {
  /// @brief  Resource handle — must be released via ARDK_Release_Resource when done.
  ///         Only valid when status is ARDK_MeshDownloader_ChunkStatus_ChunkReady.
  ARDK_ResourceHandle handle;

  /// @brief  Status of this poll. Inspect this field first.
  ARDK_MeshDownloader_ChunkStatus status;

  /// @brief  Mesh geometry, image bytes, and local transform.
  ///         Pointers are owned by \c handle — do not access after releasing the handle.
  ///
  ///         \c transform maps the chunk's local vertex space into the asset's origin space
  ///         (the space \c geo_reference and \c ARDK_VPS2_AssetTrackingData place), with
  ///         translation in meters. To get a vertex in AR tracking space:
  ///         p_tracking = asset_to_local_tracking_transform * transform * p_vertex.
  ARDK_MeshData mesh_data;
  ARDK_Buffer image_data;
  ARDK_Matrix4f transform;

  /// @brief  Georeference of the asset this chunk belongs to. Identical on every chunk of one
  ///         download; not owned by \c handle, so it remains valid after the handle is released.
  ARDK_Mesh_GeoReference geo_reference;

  /// @brief  The VPS map asset ID the download was requested with, as passed to
  ///         \c ARDK_MeshDownloader_RequestLocationMeshByAsset. Not the ID of the mesh asset the
  ///         geometry came from, so it matches the asset VPS2 reports as localized. Identical on
  ///         every chunk of one download.
  ///
  ///         Carried by value like \c geo_reference, not owned by \c handle, so it remains valid
  ///         after the handle is released. Comparable byte for byte with
  ///         \c ARDK_VPS2_AssetIdentifier::asset_id.
  ARDK_IdString vps_map_asset_id;

  /// @brief  Portal ID of the asset area this chunk belongs to; empty when the asset has no areas.
  ///         Carried by value, not owned by \c handle. Comparable byte for byte with
  ///         \c ARDK_VPS2_AssetIdentifier::area_id.
  ARDK_IdString area_id;
} ARDK_MeshDownloader_Chunk;

#ifdef __cplusplus
}
#endif
