// Copyright Niantic Spatial.
#pragma once

#include "ardk_resource_handle.h"
#include "ardk_sites_manager_error_code.h"
#include "ardk_sites_manager_request_status.h"

#ifdef __cplusplus
#include <cstdint>
extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

// ============================================================================
// Asset Enums (matching proto definitions in enums.proto)
// ============================================================================

/// @brief   Asset type enum - determines which typed asset data is present.
/// @details Maps to proto enum AssetType.
typedef enum ARDK_SitesManager_AssetType {
  ARDK_SitesManager_AssetType_Unspecified = 0,
  ARDK_SitesManager_AssetType_Mesh = 1,
  ARDK_SitesManager_AssetType_Splat = 2,
  ARDK_SitesManager_AssetType_VpsInfo = 3
} ARDK_SitesManager_AssetType;

/// @brief   Asset status enum.
/// @details Maps to proto enum AssetStatusType.
typedef enum ARDK_SitesManager_AssetStatusType {
  ARDK_SitesManager_AssetStatusType_Unspecified = 0,
  ARDK_SitesManager_AssetStatusType_Active = 1,
  ARDK_SitesManager_AssetStatusType_Inactive = 2,
  ARDK_SitesManager_AssetStatusType_Pending = 3
} ARDK_SitesManager_AssetStatusType;

/// @brief   Asset deployment type enum.
/// @details Maps to proto enum AssetDeploymentType.
typedef enum ARDK_SitesManager_AssetDeploymentType {
  ARDK_SitesManager_AssetDeploymentType_Unspecified = 0,
  ARDK_SitesManager_AssetDeploymentType_Production = 1
} ARDK_SitesManager_AssetDeploymentType;

/// @brief   Asset pipeline job status enum.
/// @details Maps to proto enum AssetPipelineJobStatus.
typedef enum ARDK_SitesManager_AssetPipelineJobStatus {
  ARDK_SitesManager_AssetPipelineJobStatus_Unspecified = 0,
  ARDK_SitesManager_AssetPipelineJobStatus_Pending = 1,
  ARDK_SitesManager_AssetPipelineJobStatus_Running = 2,
  ARDK_SitesManager_AssetPipelineJobStatus_Succeeded = 3,
  ARDK_SitesManager_AssetPipelineJobStatus_Failed = 4,
  ARDK_SitesManager_AssetPipelineJobStatus_Unknown = 5,
  ARDK_SitesManager_AssetPipelineJobStatus_NotFound = 6,
  ARDK_SitesManager_AssetPipelineJobStatus_Ready = 7
} ARDK_SitesManager_AssetPipelineJobStatus;

// ============================================================================
// Typed Asset Data Structs (matching proto oneof typed_asset_data)
// ============================================================================

/// @brief   Mesh-specific asset data.
/// @details Maps to proto message AssetMeshData.
typedef struct ARDK_SitesManager_AssetMeshData {
  /// @brief   Root node ID of the first valid space.
  const char* root_node_id;
  /// @brief   Array of all node IDs from the space.
  const char** node_ids;
  /// @brief   Number of elements in node_ids array.
  int node_ids_size;
  /// @brief   Mesh coverage in square meters.
  double mesh_coverage;
} ARDK_SitesManager_AssetMeshData;

/// @brief   Splat-specific asset data.
/// @details Maps to proto message AssetSplatData.
typedef struct ARDK_SitesManager_AssetSplatData {
  /// @brief   Root node ID of the first valid space.
  const char* root_node_id;
} ARDK_SitesManager_AssetSplatData;

/// @brief   VPS-specific asset data.
/// @details Maps to proto message AssetVpsData.
typedef struct ARDK_SitesManager_AssetVpsData {
  /// @brief   Default anchor payload used by VPS Service.
  /// @details Base64 encoded protobuf of ManagedPoseData.
  const char* anchor_payload;
} ARDK_SitesManager_AssetVpsData;

// ============================================================================
// Entity Info Structs
// ============================================================================

/// @brief   Organization information.
typedef struct ARDK_SitesManager_OrganizationInfo {
  const char* id;             // organization_key.organization_id
  const char* name;           // organization_data.name
  const char* status;         // organization_metadata.status
  int64_t created_timestamp;  // organization_metadata.created_timestamp.seconds
} ARDK_SitesManager_OrganizationInfo;

/// @brief   Site information.
typedef struct ARDK_SitesManager_SiteInfo {
  const char* id;               // site_key.site_id
  const char* name;             // site_data.name
  const char* status;           // site_data.site_status
  const char* organization_id;  // organization_id
  double latitude;              // site_data.map_point.latitude (0.0 if not present)
  double longitude;             // site_data.map_point.longitude (0.0 if not present)
  bool has_location;            // indicates if lat/lng are valid
  const char* parent_site_id;   // parent_site_id (nullptr if empty)
} ARDK_SitesManager_SiteInfo;

/// @brief   Asset information.
/// @details Maps to proto messages AssetRecord, AssetData, and AssetComputedValues.
typedef struct ARDK_SitesManager_AssetInfo {
  // --- From AssetKey ---
  /// @brief   Asset identifier (asset_key.asset_id).
  const char* id;

  // --- From AssetRecord ---
  /// @brief   Site ID this asset belongs to.
  const char* site_id;

  // --- From AssetData ---
  /// @brief   Asset display name.
  const char* name;
  /// @brief   Asset description (nullptr if empty).
  const char* description;
  /// @brief   Asset type - determines which typed_asset_data is valid.
  ARDK_SitesManager_AssetType asset_type;
  /// @brief   Asset status.
  ARDK_SitesManager_AssetStatusType asset_status;
  /// @brief   Asset deployment type.
  ARDK_SitesManager_AssetDeploymentType deployment;

  // --- Typed Asset Data (oneof based on asset_type) ---
  /// @brief   Mesh-specific data. Valid when asset_type == Mesh.
  /// @details Pointer is nullptr if asset_type is not Mesh.
  ARDK_SitesManager_AssetMeshData* mesh_data;
  /// @brief   Splat-specific data. Valid when asset_type == Splat.
  /// @details Pointer is nullptr if asset_type is not Splat.
  ARDK_SitesManager_AssetSplatData* splat_data;
  /// @brief   VPS-specific data. Valid when asset_type == VpsInfo.
  /// @details Pointer is nullptr if asset_type is not VpsInfo.
  ARDK_SitesManager_AssetVpsData* vps_data;

  // --- From AssetComputedValues ---
  /// @brief   Pipeline job ID (nullptr if not present).
  const char* pipeline_job_id;
  /// @brief   Pipeline job status.
  ARDK_SitesManager_AssetPipelineJobStatus pipeline_job_status;
  /// @brief   Source scan IDs used to create this asset.
  const char** source_scan_ids;
  /// @brief   Number of elements in source_scan_ids array.
  int source_scan_ids_size;
} ARDK_SitesManager_AssetInfo;

/// @brief   User information.
typedef struct ARDK_SitesManager_UserInfo {
  const char* id;             // user_key.user_id
  const char* first_name;     // user_data.first_name
  const char* last_name;      // user_data.last_name
  const char* email;          // user_data.email
  const char* status;         // user_metadata.status
  int64_t created_timestamp;  // user_metadata.created_timestamp.seconds
} ARDK_SitesManager_UserInfo;

/// @brief   Information about a site and its assets, returned by a location-based query.
typedef struct ARDK_SitesManager_SiteAssetsInfo {
  /// @brief   Site information.
  ARDK_SitesManager_SiteInfo site;
  /// @brief   Assets belonging to this site (array).
  ARDK_SitesManager_AssetInfo* assets;
  /// @brief   Number of elements in the \c assets array.
  int assets_size;
  /// @brief   Distance from the query coordinate to the site, in meters.
  double distance;
} ARDK_SitesManager_SiteAssetsInfo;

/// @brief   Result of an organization request (single or collection).
typedef struct ARDK_SitesManager_OrganizationResult {
  /// @brief   The last known status of the server request.
  ARDK_SitesManager_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_SitesManager_Error error;

  /// @brief   All the organizations returned (array, even for single item).
  ARDK_SitesManager_OrganizationInfo* organizations;

  /// @brief   Number of elements in the \c organizations array.
  int organizations_size;

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_SitesManager_OrganizationResult;

/// @brief   Result of a site request (single or collection).
typedef struct ARDK_SitesManager_SiteResult {
  /// @brief   The last known status of the server request.
  ARDK_SitesManager_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_SitesManager_Error error;

  /// @brief   All the sites returned (array, even for single item).
  ARDK_SitesManager_SiteInfo* sites;

  /// @brief   Number of elements in the \c sites array.
  int sites_size;

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_SitesManager_SiteResult;

/// @brief   Result of an asset request (single or collection).
typedef struct ARDK_SitesManager_AssetResult {
  /// @brief   The last known status of the server request.
  ARDK_SitesManager_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_SitesManager_Error error;

  /// @brief   All the assets returned (array, even for single item).
  ARDK_SitesManager_AssetInfo* assets;

  /// @brief   Number of elements in the \c assets array.
  int assets_size;

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_SitesManager_AssetResult;

/// @brief   Result of a site-assets location query.
typedef struct ARDK_SitesManager_SiteAssetsResult {
  /// @brief   The last known status of the server request.
  ARDK_SitesManager_RequestStatus status;
  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_SitesManager_Error error;
  /// @brief   Array of site-assets info, ordered by distance from the query coordinate.
  ARDK_SitesManager_SiteAssetsInfo* site_assets;
  /// @brief   Number of elements in the \c site_assets array.
  int site_assets_size;
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_SitesManager_SiteAssetsResult;

/// @brief   Result of a user request.
typedef struct ARDK_SitesManager_UserResult {
  /// @brief   The last known status of the server request.
  ARDK_SitesManager_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_SitesManager_Error error;

  /// @brief   The user information returned.
  ARDK_SitesManager_UserInfo* user;  // Single item pointer (or nullptr)

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_SitesManager_UserResult;

#ifdef __cplusplus
}
#endif
