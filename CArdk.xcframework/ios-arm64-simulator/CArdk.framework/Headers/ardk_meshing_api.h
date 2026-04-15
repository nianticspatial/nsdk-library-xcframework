// Copyright 2022-2025 Niantic.
#pragma once

#include "capi_common.h"
#include "ardk_meshing_configuration.h"
#include "ardk_meshing_data.h"
#include "ardk_feature_status.h"
#include "ardk_api.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Initialize the meshing feature. Call this before calling any other
///               meshing functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK object was
///               created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the meshing feature, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_Destroy(ARDK_Handle ardk_handle);

/// @brief        Start the meshing feature.
/// @details      The feature will begin processing input data and building a mesh according to the
///               configuration.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         After starting, call ARDK_Meshing_GetFeatureStatus to confirm that the feature is
///               in a good state.
/// @note         After starting, periodically call ARDK_Meshing_GetUpdatedMeshInfos and
///               ARDK_Meshing_GetMeshDataById to read new mesh data.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_Start(ARDK_Handle ardk_handle);

/// @brief        Stop the meshing feature.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This will clear the mesh data.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_Stop(ARDK_Handle ardk_handle);

/// @brief        Configure the meshing feature.
///
/// @note         If this method is called while meshing is running, the meshing feature will
///               restart with the new configuration, and any mesh data that has been produced will
///               be lost.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        config         A pointer to a struct with the configuration to use.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_Configure(ARDK_Handle ardk_handle,
                                                     const ARDK_Meshing_Configuration* configuration);

/// @brief        Reports errors that have occured with internal processes.
/// @details      Check this periodically to see if any errors have occured with
///               processes running inside this feature. Once an error has been flagged,
///               it will remain flagged until the culprit process has been run again
///               and completed successfully.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_FeatureStatus enum value that indicates the current state of the
///               meshing feature.
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_Meshing_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Gets the ids of all chunks in the current mesh and their update status.
/// @details      \p info_out will be populated with the IDs and update status for all chunks
///               currently in the mesh. If updated is true, the mesh chunk ID at that index has
///               been updated since the last time the user read its data with
///               ARDK_Meshing_GetMeshDataById.
///
/// @note         The data must be released after use by calling
///               \c ARDK_Release_Resource(info_out.handle).
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        info_out       A pointer to a struct that will be populated with the IDs and
///                              update status for all chunks currently in the mesh.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_GetUpdatedMeshInfos(ARDK_Handle ardk_handle,
                                                               ARDK_Meshing_UpdateInfo* info_out);

/// @brief        Get the data for a single mesh chunk.
/// @details      \p mesh_chunk_out will be populated with the vertices, indices and normals
///               for the mesh chunk with the given ID.
///
/// @note         The data must be released after use by calling
///               \c ARDK_Release_Resource(mesh_chunk_out.handle).
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        id                The ID of the mesh chunk to read, from
///                                 ARDK_Meshing_GetUpdatedMeshInfos.
/// @param        mesh_chunk_out    A pointer to astruct that will be populated with the data for
///                                 the mesh chunk.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_GetMeshDataById(ARDK_Handle ardk_handle, int64_t id,
                                                           ARDK_Meshing_ChunkData* mesh_chunk_out);

/// @brief        Get the timestamp of the latest mesh update produced by the feature, in Unix epoch
///               milliseconds.
///
/// @note         This is useful to check how frequently the underlying mesh is being updated.
///               To poll for new mesh data, it is recommended to use
///               ARDK_Meshing_GetUpdatedMeshInfos and check the updated flag for each chunk.
///
/// @param        ardk_handle         Handle to the ARDK object.
/// @param        timestamp_ms_out    A pointer to a uint64_t that will be populated with the
///                                   timestamp of the latest mesh update. If the timestamp is 0,
///                                   no mesh data has been produced yet.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Meshing_GetLastMeshUpdateTime(ARDK_Handle ardk_handle,
                                                                 uint64_t* timestamp_ms_out);

#ifdef __cplusplus
}
#endif
