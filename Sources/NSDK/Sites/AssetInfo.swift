// Copyright Niantic Spatial.
import CArdk

/// Represents an asset, and the areas it is split into, from the Sites Manager service.
public struct AssetInfo: CustomDebugStringConvertible, Sendable {
    // MARK: - Identity

    /// Asset identifier.
    public let id: String

    /// Asset key timestamp in Unix seconds (0 if unset).
    public let assetTimestamp: Int64

    /// Site identifier that owns this asset.
    public let siteId: String

    // MARK: - Details

    /// Asset display name.
    public let name: String

    /// Asset description (nil if empty).
    public let description: String?

    /// Asset type - determines which fields of `AssetArea` are meaningful.
    public let assetType: AssetType

    /// DEPRECATED - always `.unspecified`.
    public let assetStatus: AssetStatusType

    /// Asset deployment type.
    public let deployment: AssetDeploymentType

    /// DEPRECATED - read `areas[0]` instead. Every field here is a copy of one on that area,
    /// so this describes the first area only and is partial for an asset with multiple areas.
    public let typedData: TypedAssetData

    /// Every area of this asset.
    ///
    /// An asset mapped in a single pass has exactly one. Empty while the asset's job has
    /// produced no output yet.
    public let areas: [AssetArea]

    /// DEPRECATED - read ``AssetArea/jobStatus`` on each entry of `areas`. The portal leaves
    /// the asset-level status unset, since a job belongs to an area, so expect `.unspecified`.
    public let pipelineJobStatus: AssetPipelineJobStatus

    /// DEPRECATED - always nil. The portal has no source for it; retained so existing
    /// callers keep compiling.
    public let pipelineJobId: String?

    /// DEPRECATED - always empty. The portal has no source for it; retained so existing
    /// callers keep compiling.
    public let sourceScanIds: [String]

    // MARK: - DEPRECATED: convenience accessors for typed data
    //
    // All three are nil unless the first area carries the field this type is read
    // through: the anchor for vpsInfo, the root node for mesh and splat.

    /// DEPRECATED - read `areas[0]` instead. Nil unless the asset type is mesh and `areas` is
    /// non-empty.
    public var meshData: AssetMeshData? {
        if case .mesh(let data) = typedData { return data }
        return nil
    }

    /// DEPRECATED - read `areas[0]` instead. Nil unless the asset type is splat and `areas` is
    /// non-empty.
    public var splatData: AssetSplatData? {
        if case .splat(let data) = typedData { return data }
        return nil
    }

    /// DEPRECATED - read `areas[0]` instead. Nil unless the asset type is vps and `areas` is
    /// non-empty.
    public var vpsData: AssetVpsData? {
        if case .vps(let data) = typedData { return data }
        return nil
    }
    
    // MARK: - Initialization
    
    public init?(fromC cValue: ARDK_SitesManager_AssetInfo) {
        guard let idPtr = cValue.id else { return nil }
        guard let namePtr = cValue.name else { return nil }
        guard let siteIdPtr = cValue.site_id else { return nil }
        
        self.id = String(cString: idPtr)
        self.assetTimestamp = cValue.asset_timestamp
        self.name = String(cString: namePtr)
        self.siteId = String(cString: siteIdPtr)
        self.description = cValue.description != nil ? String(cString: cValue.description) : nil
        
        // Enums
        self.assetType = AssetType(fromC: cValue.asset_type)
        self.assetStatus = AssetStatusType(fromC: cValue.asset_status)
        self.deployment = AssetDeploymentType(fromC: cValue.deployment)
        self.pipelineJobStatus = AssetPipelineJobStatus(fromC: cValue.pipeline_job_status)
        
        // Areas
        self.areas = {
            guard let areasPtr = cValue.areas else { return [] }
            let buffer = UnsafeBufferPointer(start: areasPtr, count: Int(cValue.areas_size))
            return buffer.map { AssetArea(fromC: $0) }
        }()

        // Pipeline job ID
        self.pipelineJobId = cValue.pipeline_job_id != nil ? String(cString: cValue.pipeline_job_id) : nil
        
        // Typed asset data based on asset type
        switch assetType {
        case .mesh:
            if let meshData = AssetMeshData(fromC: cValue.mesh_data) {
                self.typedData = .mesh(meshData)
            } else {
                self.typedData = .none
            }
        case .splat:
            if let splatData = AssetSplatData(fromC: cValue.splat_data) {
                self.typedData = .splat(splatData)
            } else {
                self.typedData = .none
            }
        case .vpsInfo:
            if let vpsData = AssetVpsData(fromC: cValue.vps_data) {
                self.typedData = .vps(vpsData)
            } else {
                self.typedData = .none
            }
        case .unspecified:
            self.typedData = .none
        }
        
        // Convert source scan IDs array
        self.sourceScanIds = {
            guard let scanIdsPtr = cValue.source_scan_ids else { return [] }
            let scanIdsBuffer = UnsafeBufferPointer(start: scanIdsPtr, count: Int(cValue.source_scan_ids_size))
            return scanIdsBuffer.compactMap { scanIdPtr in
                guard let scanId = scanIdPtr else { return nil }
                return String(cString: scanId)
            }
        }()
    }
    
    // MARK: - CustomDebugStringConvertible
    
    public var debugDescription: String {
        var desc = """
Asset
- ID: \(id)
- Name: \(name)
- Type: \(assetType)
- Status: \(assetStatus)
- Site ID: \(siteId)
"""
        if let descText = description {
            desc += "- Description: \(descText)\n"
        }
        if deployment != .unspecified {
            desc += "- Deployment: \(deployment)\n"
        }
        if let jobId = pipelineJobId {
            desc += "- Pipeline Job ID: \(jobId)\n"
        }
        if pipelineJobStatus != .unspecified {
            desc += "- Pipeline Status: \(pipelineJobStatus)\n"
        }
        if !sourceScanIds.isEmpty {
            desc += "- Source Scan IDs: \(sourceScanIds.joined(separator: ", "))\n"
        }
        if !areas.isEmpty {
            desc += "- Areas (\(areas.count)):\n"
            for area in areas {
                desc += "  \(area.debugDescription)"
            }
        }

        // Typed data
        switch typedData {
        case .mesh(let data):
            desc += "- \(data.debugDescription)"
        case .splat(let data):
            desc += "- \(data.debugDescription)"
        case .vps(let data):
            desc += "- \(data.debugDescription)"
        case .none:
            break
        }
        
        return desc
    }
}
