// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_string.h"
#include "capi_common.h"
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

/// @brief        Requests all the meshes in the VPS location represented by the payload.
///
/// @param        ardk_handle      Handle to the ARDK object.
/// @param        payload          The anchor payload of the VPS location. The payload can be
///                                obtained from the \a blob field in Geospatial Browser or from
///                                the \p default_anchor field of
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
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_RequestLocationMesh(ARDK_Handle ardk_handle,
                                                                      const ARDK_String payload,
                                                                      bool get_texture,
                                                                      ARDK_NetworkRequestId* request_id_out,
                                                                      uint32_t max_size_kb);

/// @brief        Gets the result of a previous request for a location mesh.
/// @details      This function can be polled until it returns \c ARDK_Status_OK, upon which
///               the request is complete and the \p results_out struct is populated. Any mesh data
///               returned by the results is allocated by the library and must be released once
///               it's no longer needed to avoid memory leaks.
///
/// @param        ardk_handle      Handle to the ARDK object.
/// @param        request_id       The request ID received by a successful call to
///                                \p ARDK_MeshDownloader_RequestLocationMesh.
/// @param[out]   results_out      The query result, only valid when \c ARDK_Status_OK is returned.
///                                If this struct's \c status is \c ARDK_MeshDownloader_RequestStatus_Success,
///                                the \c results field will be populated with the mesh data.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_MeshDownloader_GetLocationMeshResults(ARDK_Handle ardk_handle,
                                                                         ARDK_NetworkRequestId request_id,
                                                                         ARDK_MeshDownloader_Results* results_out);

#ifdef __cplusplus
}
#endif
