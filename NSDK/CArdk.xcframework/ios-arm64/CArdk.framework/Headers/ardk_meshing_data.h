// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   The ID and update status for each mesh chunk.
typedef struct ARDK_Meshing_UpdateInfo {
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;

  /// @brief   An array of all chunk IDs present in the mesh.
  /// @details When a chunk is removed from the mesh, it will no longer be present in this array.
  int64_t* ids;

  /// @brief   An array containing the update status for each chunk in the mesh.
  /// @details Each element in the array corresponds to the chunk ID at the same index in the \c ids
  ///          array. If the value is 1, the chunk has been updated since the last call to
  ///          \c ARDK_Meshing_GetMeshDataById for that ID. Calling \c ARDK_Meshing_GetMeshDataById
  ///          will reset the update status for that chunk to 0.
  uint8_t* updated;

  /// @brief   The number of elements in the \c ids and \c updated arrays.
  int numIds;
} ARDK_Meshing_UpdateInfo;

/// @brief   Vertices, indices and normals of a single mesh chunk.
typedef struct ARDK_Meshing_ChunkData {
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;

  /// @brief   An array of all vertices in the mesh chunk.
  /// @details The position of each vertex is given by three floats in the \c vertices array.
  ///          For example, the position of the first vertex in the chunk is stored in the first
  ///          three elements of the \c vertices array in (x, y, z) order.
  float* vertices;

  /// @brief   The number of floats in the \c vertices and \c normals arrays.
  /// @details Keep in mind that each vertex is defined by three floats.
  int verticesSize;

  /// @brief   An array of all indices, or faces, in the mesh chunk.
  /// @details Each face of the mesh is defined by three indices in the \c indices array.
  ///          For example, the first face in the chunk is defined by the first three elements of
  ///          the \c indices array. The index values correspond to the indices of the \c vertices
  ///          array.
  uint32_t* indices;

  /// @brief   The number of ints in the \c indices array.
  /// @details Keep in mind that each face is defined by three uint32.
  int indicesSize;

  /// @brief   An array of all vertex normals in the mesh chunk.
  /// @details Each vertex in \c vertices has a normal which corresponds to three floats
  ///          in the \c normals array. For example, the normal for the first vertex in the chunk
  ///          is stored in the first three elements of the \c normals array in (x, y, z) order.
  float* normals;
} ARDK_Meshing_ChunkData;

#ifdef __cplusplus
}
#endif
