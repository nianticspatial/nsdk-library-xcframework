// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_string.h"
#include "capi_common.h"
#include "ardk_mesh_downloader_chunk.h"
#include "ardk_mesh_downloader_configuration.h"
#include "ardk_mesh_downloader_results.h"
#include "ardk_network_request_id.h"
#include "ardk_api.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#endif

/// @brief        Creates a new MeshDownloader component. Call this before calling any other
///               MeshDownloader functions.
/// @note         This method must be called on the same thread that the ARDK object was
///               created on.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the MeshDownloader component.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configures the MeshDownloader's on-disk mesh cache.
/// @details      Downloaded Draco geometry and textures are cached per graph node, so revisiting
///               a location reads from disk instead of the CDN, and an interrupted download
///               resumes where it stopped rather than starting over. Cached content never goes
///               stale: a re-run of the mapping pipeline publishes new node ids, so an id always
///               names the same geometry.
///
///               Caching is off until this is called. It may be called again later. A changed
///               budget applies at once, to downloads already in progress too. Disabling only
///               affects downloads started afterward; one already in progress keeps the cache it
///               started with.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        configuration  Cache settings to apply.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_NullArgument - The \p configuration parameter was null.
///               - \c ARDK_Status_InvalidArgument - \c cache_enabled was true with a
///                 \c cache_max_mb of zero.
///               - \c ARDK_Status_FeatureDoesNotExist - The MeshDownloader component has not been
///                 created. Call \p ARDK_MeshDownloader_Create first.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_Configure(
    ARDK_Handle ardk_handle, const ARDK_MeshDownloader_Configuration* configuration);

/// @brief        [Deprecated] Requests all the meshes in the VPS location represented by the
/// payload.
///
/// @deprecated   Use \c ARDK_MeshDownloader_RequestLocationMeshByAsset instead, paired with
///               \c ARDK_MeshDownloader_GetNextMeshChunk.
/// @details      Site IDs and asset IDs are the preferred mechanisms for identifying maps in
///               NSDK. \c ARDK_MeshDownloader_RequestLocationMesh does not support maps created
///               from 360 camera captures.
///
/// @param        ardk_handle      Handle to the ARDK object.
/// @param        payload          The anchor payload of the VPS location. The payload can be
///                                obtained from the \a blob field in Geospatial Browser or from
///                                the \p default_anchor_payload field of
///                                \p ARDK_VPSCoverage_LocalizationTarget in the VPS coverage
///                                API. The char array must be null terminated.
/// @param        get_texture      If true, the response will include the mesh textures. If false,
///                                \p image_data and \p mesh_data.uvs will be empty.
/// @param[out]   request_id_out   The identifier for this request, which should be used with the
///                                \p ARDK_MeshDownloader_GetLocationMeshResults function to get the
///                                results of this request.
/// @param        max_size_kb      \a (Optional) Sets a maximum size for the meshes to be
///                                downloaded, in kilobytes. Meshes above this size will not be
///                                downloaded. The default value, 0, does not set a size limit.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_RequestLocationMesh(
    ARDK_Handle ardk_handle, const ARDK_String payload, bool get_texture,
    ARDK_NetworkRequestId* request_id_out, uint32_t max_size_kb);

/// @brief        [Deprecated] Gets the result of a previous request for a location mesh.
/// @details      This function can be polled until it returns \c ARDK_Status_OK, upon which
///               the request is complete and the \p results_out struct is populated. Any mesh data
///               returned by the results is allocated by the library and must be released once
///               it's no longer needed to avoid memory leaks.
///
/// @deprecated   Use \c ARDK_MeshDownloader_GetNextMeshChunk instead, to poll a request started by
///               \c ARDK_MeshDownloader_RequestLocationMeshByAsset.
/// @details      Site IDs and asset IDs are the preferred mechanisms for identifying maps in
///               NSDK. \c ARDK_MeshDownloader_GetLocationMeshResults does not support maps created
///               from 360 camera captures.
///
/// @param        ardk_handle      Handle to the ARDK object.
/// @param        request_id       The request ID received by a successful call to
///                                \p ARDK_MeshDownloader_RequestLocationMesh.
/// @param[out]   results_out      The query result, only valid when \c ARDK_Status_OK is returned.
///                                If this struct's \c status is \c
///                                ARDK_MeshDownloader_RequestStatus_Success, the \c results field
///                                will be populated with the mesh data.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_GetLocationMeshResults(
    ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
    ARDK_MeshDownloader_Results* results_out);

/// @brief        Starts a streaming portal mesh download for the Mesh sibling of a VPS map asset,
///               sorted by proximity to the provided GPS position. Resolves the VPS map asset ID to
///               the Mesh asset in the same asset group via SitesManager, then delivers chunks via
///               \p ARDK_MeshDownloader_GetNextMeshChunk as they complete.
///
/// @param        ardk_handle         Handle to the ARDK object.
/// @param        vps_map_asset_id    Portal VPS map asset ID string (null-terminated).
/// @param        latitude            User latitude in decimal degrees.
/// @param        longitude           User longitude in decimal degrees.
/// @param        get_texture         If true, texture bytes are included in each chunk.
/// @param        max_chunks          Maximum number of graph nodes to download. Pass 0 for
///                                   no limit.
/// @param        max_size_kb         Cumulative size cap in kilobytes, counted as the mesh and
///                                   texture bytes delivered, whether downloaded or served from
///                                   the on-disk cache, so a cached asset stops where a fresh
///                                   download would. Once the total reaches this limit, no new
///                                   nodes are scheduled; already-completed chunks remain
///                                   available. Pass 0 for no cap.
/// @param        max_decoded_size_kb Cumulative budget in kilobytes for what the delivered chunks
///                                   occupy once decoded, whether downloaded or served from the
///                                   cache: vertices, UVs, indices and per-vertex colours at 4
///                                   bytes per element, plus texture bytes as received. Once the
///                                   total reaches this budget, no new nodes are scheduled;
///                                   already-completed chunks remain available. Pass 0 for no
///                                   budget.
/// @param[out]   request_id_out      Identifier for this request; pass to
///                                   \p ARDK_MeshDownloader_GetNextMeshChunk each frame.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the request was started successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The MeshDownloader component has not been
///                 created. Call \p ARDK_MeshDownloader_Create first.
///               - \c ARDK_Status_NullArgument - The \p vps_map_asset_id or \p request_id_out
///                 parameter was null.
///               - \c ARDK_Status_InvalidArgument - The \p vps_map_asset_id string was empty or
///                 the request could not be started.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_RequestLocationMeshByAsset(
    ARDK_Handle ardk_handle, const ARDK_String vps_map_asset_id, double latitude, double longitude,
    bool get_texture, uint32_t max_chunks, uint32_t max_size_kb, uint32_t max_decoded_size_kb,
    ARDK_NetworkRequestId* request_id_out);

/// @brief        Polls for the next available mesh chunk from a portal streaming request.
///               Call this once per frame until \c chunk_out->status is
///               \c ARDK_MeshDownloader_ChunkStatus_Complete or
///               \c ARDK_MeshDownloader_ChunkStatus_Error.
///               When \c status is \c ARDK_MeshDownloader_ChunkStatus_ChunkReady, the
///               \c handle in \c chunk_out must be released via \c ARDK_Release_Resource
///               once the mesh data is no longer needed.
///               Per-node mesh+texture is all-or-nothing: a texture download failure fails the
///               request without emitting a mesh-only chunk for that node.
///
/// @param        ardk_handle   Handle to the ARDK object.
/// @param        request_id    The request ID returned by
///                             \p ARDK_MeshDownloader_RequestLocationMeshByAsset.
/// @param[out]   chunk_out     Populated on return; inspect \c status first.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The MeshDownloader component has not been
///                 created. Call \p ARDK_MeshDownloader_Create first.
///               - \c ARDK_Status_NullArgument - The \p chunk_out parameter was null.
///               - \c ARDK_Status_InvalidArgument - The \p request_id does not correspond to a
///                 known active request.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_MeshDownloader_GetNextMeshChunk(ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
                                     ARDK_MeshDownloader_Chunk* chunk_out);

#ifdef __cplusplus
}
#endif
