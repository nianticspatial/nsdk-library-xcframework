// Copyright 2022-2024 Niantic.

#pragma once

#include "ardk_string.h"
#include "capi_common.h"
#include "ardk_map_metadata.h"
#include "ardk_buffer.h"
#include "ardk_external_buffer.h"
#include "ardk_matrix4f.h"
#include "ardk_status.h"
#include "ardk_uuid.h"
#include "ardk_api.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Initialize the map storage feature. Call this before calling any other
///               map storage functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK object was
///               created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the map storage feature, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_Destroy(ARDK_Handle ardk_handle);

/// @brief        Get the current map data.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   map_out        The serialized map data will be written to this buffer. The data is
///                              encoded as a DeviceMap proto (ardk_device_map.proto).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_GetMapData(ARDK_Handle ardk_handle,
                                                         ARDK_ExternalBuffer *map_out);

/// @brief        Get the latest map update data, which consists of the new nodes and edges
///               that have been added since the last call to this function.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   map_update_out The serialized map update data, encoded as a DeviceMap proto. 
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_GetMapUpdate(ARDK_Handle ardk_handle,
                                                           ARDK_ExternalBuffer *map_update_out);

/// @brief        Add serialized map data to the map storage.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        map            The serialized map data to add. The data should be encoded as a
///                              DeviceMap proto. It can be obtained from \c ARDK_MapStorage_GetMapData,
///                              \c ARDK_MapStorage_GetMapUpdate, or \c ARDK_MapStorage_MergeMapUpdate.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_AddMap(ARDK_Handle ardk_handle,
                                                     ARDK_Buffer map);

/// @brief        Clear the map storage.
/// @note         Must not be called if VPS is running.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_Clear(ARDK_Handle ardk_handle);

/// @brief        Merge a map update into an existing map.
///
/// @param        existing_map   The existing map to merge the update into.
/// @param        map_update     The map update to merge into the existing map.
/// @param        merged_map_out The merged map will be written to this buffer.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_MergeMapUpdate(ARDK_Buffer existing_map,
                                                             ARDK_Buffer map_update,
                                                             ARDK_ExternalBuffer *merged_map_out);

/// @brief        Creates an anchor on the existing map located at the origin of the current
///               AR session, if possible.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   payload_out     The payload of the anchor, encoded as a base64 string.
///                               Make sure to release the handle once it's no longer neede
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_CreateRootAnchor(ARDK_Handle handle,
                                                               ARDK_ExternalBuffer *payload_out);

/// @brief        Extract the metadata from a map relative to an anchor on the map.
/// @details      Render the feature points in the metadata relative to the specified anchor to
///               visualize the map. This is only possible when the anchor is linked directly to
///               the map's node(s), or if the anchor's nodes are reachable to the map's nodes
///               from the currently active transform graph.
///
/// @param        handle         Handle to the ARDK object.
/// @param        anchor_payload The base64-encoded anchor payload. The returned map metadata
///                              will be relative to this anchor.
/// @param        map                    The map to extract the metadata from.
/// @param[out]   map_metadata_out       The metadata of the map.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MapStorage_ExtractMapMetadata(
    ARDK_Handle handle,
    const ARDK_String anchor_payload,
    ARDK_Buffer map,
    ARDK_Mapping_MapMetadata *map_metadata_out
);



// Actions to add data

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_AddMap(void *storage_handle,
                                                                   ARDK_Buffer data_buffer);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_AddGraph(void *storage_handle,
                                                                     ARDK_Buffer data_buffer);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_Clear(void *storage_handle);

// Actions to manage internal upload/download

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_StartUploadingMaps(
    void *storage_handle);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_StopUploadingMaps(void *storage_handle);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_StartDownloadingMaps(
    void *storage_handle);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_StopDownloadingMaps(
    void *storage_handle);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_StartGettingGraphData(
    void *storage_handle);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_StopGettingGraphData(
    void *storage_handle);

ARDK_CAPI_VISIBLE bool Lightship_ARDK_Core_MapStorageAccess_MarkNodeForUpload(
    void *storage_handle, ARDK_UUID node_identifier_in);

ARDK_CAPI_VISIBLE bool Lightship_ARDK_Core_MapStorageAccess_HasNodeBeenUploaded(
    void *storage_handle, ARDK_UUID node_identifier_in);

// Action to get new data





// Static function to extract data



// Static Functions Utilities

// Creates anchor from node identifier. Anchor is returned as ARDK_ResourceHandle
// Use ARDK_Release_Resource to dispose ARDK_ResourceHandle when done.
ARDK_CAPI_VISIBLE ARDK_ResourceHandle Lightship_ARDK_Core_MapStorageAccess_CreateAnchor(
    ARDK_UUID node_identifier_in, ARDK_Matrix4f local_pose_in);

// Extract anchor payload as ardk_buffer from anchor handle.
ARDK_CAPI_VISIBLE ARDK_Buffer
Lightship_ARDK_Core_MapStorageAccess_ExtractAnchor(ARDK_ResourceHandle anchor_handle);

ARDK_CAPI_VISIBLE void *Lightship_ARDK_Core_MapStorageAccess_ExtractMapMetadata(
    uint8_t *map_blob, uint64_t map_blob_size, float **points_xyz, float **errors,
    uint64_t *points_count, float *center_x, float *center_y, float *center_z,
    unsigned char **decriptor_name);

ARDK_CAPI_VISIBLE void Lightship_ARDK_Core_MapStorageAccess_ReleaseMapMetadata(
    void *map_metadata_handle);

#ifdef __cplusplus
}
#endif
