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

/// @brief   Asset status enum. DEPRECATED — always reported as Unspecified.
/// @details The portal removed AssetData.asset_status and the AssetStatusType
///          enum behind it in MR !7124.
typedef enum ARDK_SitesManager_AssetStatusType {
  ARDK_SitesManager_AssetStatusType_Unspecified = 0,
  ARDK_SitesManager_AssetStatusType_Active = 1,
  ARDK_SitesManager_AssetStatusType_Inactive = 2,
  ARDK_SitesManager_AssetStatusType_Pending = 3
} ARDK_SitesManager_AssetStatusType;

/// @brief   Asset deployment type enum.
/// @details Maps to proto enum AssetDeploymentType. Localization uses Production
///          assets unless it is given an asset ID; the other two are reported as they are so a
///          caller can tell "not deployed" from "deployed, but not live".
typedef enum ARDK_SitesManager_AssetDeploymentType {
  ARDK_SitesManager_AssetDeploymentType_Unspecified = 0,
  ARDK_SitesManager_AssetDeploymentType_Production = 1,
  ARDK_SitesManager_AssetDeploymentType_Published = 2,
  ARDK_SitesManager_AssetDeploymentType_Draft = 3
} ARDK_SitesManager_AssetDeploymentType;

/// @brief   Whether a location query returns production assets only, or every asset.
typedef enum ARDK_SitesManager_AssetScope {
  /// @brief   Production assets only.
  ARDK_SitesManager_AssetScope_Production = 0,
  /// @brief   Every asset, production or not.
  ARDK_SitesManager_AssetScope_All = 1
} ARDK_SitesManager_AssetScope;

/// @brief   Asset pipeline job status enum.
/// @details Numbered independently of the portal's own enum, which disagrees on
///          two values, so the parser maps rather than casts. \c Ready is never
///          reported; it belonged to a contract the portal has retired.
typedef enum ARDK_SitesManager_AssetPipelineJobStatus {
  ARDK_SitesManager_AssetPipelineJobStatus_Unspecified = 0,
  ARDK_SitesManager_AssetPipelineJobStatus_Pending = 1,
  ARDK_SitesManager_AssetPipelineJobStatus_Running = 2,
  ARDK_SitesManager_AssetPipelineJobStatus_Succeeded = 3,
  ARDK_SitesManager_AssetPipelineJobStatus_Failed = 4,
  ARDK_SitesManager_AssetPipelineJobStatus_Unknown = 5,
  ARDK_SitesManager_AssetPipelineJobStatus_NotFound = 6,
  /// @brief   DEPRECATED on the v2 endpoints — never reported.
  ARDK_SitesManager_AssetPipelineJobStatus_Ready = 7,
  /// @brief   Stopped before finishing; no asset will arrive.
  ARDK_SitesManager_AssetPipelineJobStatus_Canceled = 8
} ARDK_SitesManager_AssetPipelineJobStatus;

// ============================================================================
// Scan Enums (matching proto definitions in enums.proto)
// ============================================================================

/// @brief   Scan type. Values match the portal's ScanType; a value this build does
///          not know is reported as Unspecified.
typedef enum ARDK_SitesManager_ScanType {
  ARDK_SitesManager_ScanType_Unspecified = 0,
  ARDK_SitesManager_ScanType_V2 = 1,
  ARDK_SitesManager_ScanType_360 = 2,
  ARDK_SitesManager_ScanType_DronePhoto = 3,
  ARDK_SitesManager_ScanType_E57 = 4,
  /// @brief   A playback (validation) capture.
  ARDK_SitesManager_ScanType_Validation = 10
} ARDK_SitesManager_ScanType;

/// @brief   Scan status. Values match the portal's ScanStatusType; a value this
///          build does not know is reported as Unspecified.
typedef enum ARDK_SitesManager_ScanStatus {
  ARDK_SitesManager_ScanStatus_Unspecified = 0,
  ARDK_SitesManager_ScanStatus_Initialized = 1,
  ARDK_SitesManager_ScanStatus_Uploading = 2,
  ARDK_SitesManager_ScanStatus_Submitted = 3,
  ARDK_SitesManager_ScanStatus_Accepted = 4,
  ARDK_SitesManager_ScanStatus_Rejected = 5,
  ARDK_SitesManager_ScanStatus_UploadedClient = 6,
  ARDK_SitesManager_ScanStatus_Transferring = 7,
  ARDK_SitesManager_ScanStatus_TransferFailed = 8
} ARDK_SitesManager_ScanStatus;

// ============================================================================
// Asset Areas
// ============================================================================

/// @brief   One independently-localizable piece of an asset.
/// @details A scan too large for a single mapping run is split, and each piece
///          gets its own job, anchor, node graph and extent. An asset mapped in
///          one pass has exactly one area.
///
///          One flat shape serves every asset type. Which fields are meaningful
///          follows ARDK_SitesManager_AssetInfo.asset_type:
///          - Mesh:    root_node_id, node_ids, mesh_coverage
///          - Splat:   root_node_id
///          - VpsInfo: anchor_payload, and the bounds
typedef struct ARDK_SitesManager_AssetArea {
  /// @brief   This area's own identifier, unique within the asset.
  const char* area_id;
  /// @brief   Status of this area's own mapping job.
  /// @details A job belongs to an area, so this is the only status the portal
  ///          reports. ARDK_SitesManager_AssetInfo.pipeline_job_status is
  ///          deprecated and left unset.
  ARDK_SitesManager_AssetPipelineJobStatus job_status;
  /// @brief   The space this area was mapped into.
  const char* space_id;
  /// @brief   Root node ID of this area's space.
  const char* root_node_id;
  /// @brief   All node IDs from this area's space.
  const char** node_ids;
  /// @brief   Number of elements in the \c node_ids array.
  int node_ids_size;
  /// @brief   This area's anchor payload, base64-encoded ManagedPoseData.
  /// @details Legacy map identifier. An anchor payload is no longer a
  ///          preferred method to identify the map to localize against: pass a
  ///          site ID to ARDK_VPS2_LocalizeToSite or a coordinate to
  ///          ARDK_VPS2_LocalizeToNearbySites.
  const char* anchor_payload;
  /// @brief   This area's mesh coverage in square meters.
  double mesh_coverage;
  /// @brief   This area's geographic extent. Valid only when \c has_bounds.
  double min_lat;
  double min_lng;
  double max_lat;
  double max_lng;
  /// @brief   False when the portal published no extent, or one describing no
  ///          usable area. The four bounds above are then zero.
  bool has_bounds;
} ARDK_SitesManager_AssetArea;

// ============================================================================
// Typed Asset Data Structs — DEPRECATED
//
// Wholly replaced by ARDK_SitesManager_AssetInfo.areas: every field below also
// exists on ARDK_SitesManager_AssetArea. Each describes the asset's first area
// only, so they are partial for an asset with multiple areas.
// ============================================================================

/// @brief   DEPRECATED. Mesh-specific asset data, from the asset's first area.
typedef struct ARDK_SitesManager_AssetMeshData {
  /// @brief   Root node ID of the first area's space.
  const char* root_node_id;
  /// @brief   All node IDs from the first area's space, not from the asset.
  const char** node_ids;
  /// @brief   Number of elements in the \c node_ids array.
  int node_ids_size;
  /// @brief   The first area's mesh coverage in square meters.
  /// @details Not the asset's total: for a split asset this understates it. Sum
  ///          ARDK_SitesManager_AssetInfo.areas instead, if those areas are
  ///          known not to overlap.
  double mesh_coverage;
} ARDK_SitesManager_AssetMeshData;

/// @brief   DEPRECATED. Splat-specific asset data, from the asset's first area.
typedef struct ARDK_SitesManager_AssetSplatData {
  /// @brief   Root node ID of the first area's space.
  const char* root_node_id;
} ARDK_SitesManager_AssetSplatData;

/// @brief   DEPRECATED. VPS-specific asset data, from the asset's first area.
typedef struct ARDK_SitesManager_AssetVpsData {
  /// @brief   The first area's anchor payload, used by VPS Service.
  /// @details Base64 encoded protobuf of ManagedPoseData. A legacy map
  ///          identifier: an anchor payload is no longer the preferred method to
  ///          identify the map to localize against. Pass a site ID to
  ///          ARDK_VPS2_LocalizeToSite or a coordinate to
  ///          ARDK_VPS2_LocalizeToNearbySites.
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
/// @details Maps to the portal's ApiAssetResponse, flattening its assetKey and
///          assetData blocks. An asset carries 0..N areas; see \c areas.
typedef struct ARDK_SitesManager_AssetInfo {
  // --- From assetKey ---
  /// @brief   Asset identifier (assetKey.assetId).
  const char* id;
  /// @brief   Asset key timestamp in Unix seconds (0 if unset).
  int64_t asset_timestamp;

  // --- From the response root ---
  /// @brief   Site ID this asset belongs to.
  const char* site_id;

  // --- From assetData ---
  /// @brief   Asset display name.
  const char* name;
  /// @brief   Asset description (nullptr if empty).
  const char* description;
  /// @brief   Asset type. See ARDK_SitesManager_AssetArea for what it selects.
  ARDK_SitesManager_AssetType asset_type;
  /// @brief   DEPRECATED — always Unspecified.
  ARDK_SitesManager_AssetStatusType asset_status;
  /// @brief   Asset deployment type (assetData.deploymentType).
  ARDK_SitesManager_AssetDeploymentType deployment;

  // --- Typed Asset Data: DEPRECATED, replaced by `areas` below ---
  //
  // All three are nullptr unless the first area carries the field this type is
  // read through: the anchor for VpsInfo, the root node for Mesh and Splat.
  /// @brief   DEPRECATED — every field here is a copy of one on \c areas[0].
  ///          Read \c root_node_id, \c node_ids and \c mesh_coverage from there
  ///          instead, and the other areas of an asset that has several.
  /// @details nullptr unless asset_type == Mesh and \c areas is non-empty.
  ARDK_SitesManager_AssetMeshData* mesh_data;
  /// @brief   DEPRECATED — every field here is a copy of one on \c areas[0].
  ///          Read \c root_node_id from there instead.
  /// @details nullptr unless asset_type == Splat and \c areas is non-empty.
  ARDK_SitesManager_AssetSplatData* splat_data;
  /// @brief   DEPRECATED — every field here is a copy of one on \c areas[0].
  ///          Read \c anchor_payload from there instead.
  /// @details nullptr unless asset_type == VpsInfo and \c areas is non-empty.
  ARDK_SitesManager_AssetVpsData* vps_data;

  // Field order is ABI — do not reorder.
  /// @brief   DEPRECATED — always nullptr. The portal has no source for it;
  ///          retained so existing callers keep compiling.
  const char* pipeline_job_id;
  /// @brief   DEPRECATED — read the \c job_status of each entry in \c areas.
  /// @details Parsed from assetData.jobStatus, which the portal leaves unset: a
  ///          job belongs to an area, so every area reports its own. Expect
  ///          Unspecified.
  ARDK_SitesManager_AssetPipelineJobStatus pipeline_job_status;
  /// @brief   DEPRECATED — always nullptr. The portal has no source for it;
  ///          retained so existing callers keep compiling.
  const char** source_scan_ids;
  /// @brief   Always 0.
  int source_scan_ids_size;

  /// @brief   Every area of this asset, in the order the portal published them.
  /// @details An asset mapped in a single pass has exactly one. Empty, with a
  ///          nullptr array, while the asset's job has produced no output yet.
  ARDK_SitesManager_AssetArea* areas;
  /// @brief   Number of elements in the \c areas array.
  int areas_size;
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

/// @brief   Scan information, as the portal lists it for a site.
typedef struct ARDK_SitesManager_ScanInfo {
  /// @brief   Scan identifier (scanKey.scanId).
  const char* id;
  /// @brief   Display name (scanData.name).
  const char* name;
  ARDK_SitesManager_ScanType scan_type;
  ARDK_SitesManager_ScanStatus scan_status;
  /// @brief   Total capture length in seconds (scanComputedValues.totalDuration).
  /// @details Sums every chunk of a chunked scan, while opening the scan for
  ///          playback plays only the first.
  double duration_seconds;
  /// @brief   Earliest capture time in Unix seconds (0 if unset).
  int64_t capture_timestamp;
  /// @brief   Record creation time in Unix seconds (0 if unset).
  int64_t created_timestamp;
  /// @brief   Capture location in degrees. Valid only when \c has_location.
  double latitude;
  double longitude;
  bool has_location;
  /// @brief   Total size of the scan's capture files in bytes.
  int64_t total_size;
  /// @brief   The scan has a thumbnail image file.
  bool has_thumbnail;
  /// @brief   The scan has a preview video file.
  bool has_preview;
  /// @brief   ID of the user who uploaded the scan (empty for a community scan).
  const char* user_id;
} ARDK_SitesManager_ScanInfo;

/// @brief   Result of a scan request: a site's scans, or the single scan requested.
typedef struct ARDK_SitesManager_ScanResult {
  /// @brief   The last known status of the server request.
  ARDK_SitesManager_RequestStatus status;
  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_SitesManager_Error error;
  /// @brief   The scans returned (array, even for a single scan).
  ARDK_SitesManager_ScanInfo* scans;
  /// @brief   Number of elements in the \c scans array.
  int scans_size;
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_SitesManager_ScanResult;

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
