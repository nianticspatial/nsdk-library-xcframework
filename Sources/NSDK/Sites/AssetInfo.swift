// Copyright Niantic Spatial.
import CArdk

/// Represents asset information from the Sites Manager service.
/// Maps to proto messages AssetRecord, AssetData, and AssetComputedValues.
public struct AssetInfo: CustomDebugStringConvertible, Sendable {
    // MARK: - From AssetKey
    
    /// Asset identifier.
    public let id: String
    
    // MARK: - From AssetRecord
    
    /// Site identifier that owns this asset.
    public let siteId: String
    
    // MARK: - From AssetData
    
    /// Asset display name.
    public let name: String
    
    /// Asset description (nil if empty).
    public let description: String?
    
    /// Asset type - determines which typed asset data is present.
    public let assetType: AssetType
    
    /// Asset status.
    public let assetStatus: AssetStatusType
    
    /// Asset deployment type.
    public let deployment: AssetDeploymentType
    
    /// Typed asset data based on asset type.
    public let typedData: TypedAssetData
    
    // MARK: - From AssetComputedValues
    
    /// Pipeline job identifier (nil if not present).
    public let pipelineJobId: String?
    
    /// Pipeline job status.
    public let pipelineJobStatus: AssetPipelineJobStatus
    
    /// Source scan IDs used to create this asset.
    public let sourceScanIds: [String]
    
    // MARK: - Convenience accessors for typed data
    
    /// Mesh data (nil if asset type is not mesh).
    public var meshData: AssetMeshData? {
        if case .mesh(let data) = typedData { return data }
        return nil
    }
    
    /// Splat data (nil if asset type is not splat).
    public var splatData: AssetSplatData? {
        if case .splat(let data) = typedData { return data }
        return nil
    }
    
    /// VPS data (nil if asset type is not vps).
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
        self.name = String(cString: namePtr)
        self.siteId = String(cString: siteIdPtr)
        self.description = cValue.description != nil ? String(cString: cValue.description) : nil
        
        // Enums
        self.assetType = AssetType(fromC: cValue.asset_type)
        self.assetStatus = AssetStatusType(fromC: cValue.asset_status)
        self.deployment = AssetDeploymentType(fromC: cValue.deployment)
        self.pipelineJobStatus = AssetPipelineJobStatus(fromC: cValue.pipeline_job_status)
        
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
