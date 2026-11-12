// Copyright Niantic Spatial.
import CArdk

/// Mesh-specific asset data.
/// Maps to proto message AssetMeshData.
public struct AssetMeshData: CustomDebugStringConvertible, Sendable {
    /// Root node ID of the first valid space.
    public let rootNodeId: String
    
    /// All node IDs from the space.
    public let nodeIds: [String]
    
    /// Mesh coverage in square meters.
    public let meshCoverage: Double
    
    public init?(fromC cValue: UnsafePointer<ARDK_SitesManager_AssetMeshData>?) {
        guard let ptr = cValue else { return nil }
        let meshData = ptr.pointee
        
        guard let rootNodeIdPtr = meshData.root_node_id else { return nil }
        self.rootNodeId = String(cString: rootNodeIdPtr)
        self.meshCoverage = meshData.mesh_coverage
        
        // Convert node_ids array
        self.nodeIds = {
            guard let nodeIdsPtr = meshData.node_ids else { return [] }
            let nodeIdsBuffer = UnsafeBufferPointer(start: nodeIdsPtr, count: Int(meshData.node_ids_size))
            return nodeIdsBuffer.compactMap { nodeIdPtr in
                guard let nodeId = nodeIdPtr else { return nil }
                return String(cString: nodeId)
            }
        }()
    }
    
    public var debugDescription: String {
        var desc = "MeshData:\n"
        desc += "  - Root Node ID: \(rootNodeId)\n"
        desc += "  - Mesh Coverage: \(meshCoverage) m²\n"
        if !nodeIds.isEmpty {
            desc += "  - Node IDs (\(nodeIds.count)): \(nodeIds.prefix(3).joined(separator: ", "))"
            if nodeIds.count > 3 { desc += "..." }
            desc += "\n"
        }
        return desc
    }
}

/// Splat-specific asset data.
/// Maps to proto message AssetSplatData.
public struct AssetSplatData: CustomDebugStringConvertible, Sendable {
    /// Root node ID of the first valid space.
    public let rootNodeId: String
    
    public init?(fromC cValue: UnsafePointer<ARDK_SitesManager_AssetSplatData>?) {
        guard let ptr = cValue else { return nil }
        let splatData = ptr.pointee
        
        guard let rootNodeIdPtr = splatData.root_node_id else { return nil }
        self.rootNodeId = String(cString: rootNodeIdPtr)
    }
    
    public var debugDescription: String {
        return "SplatData:\n  - Root Node ID: \(rootNodeId)\n"
    }
}

/// VPS-specific asset data.
/// Maps to proto message AssetVpsData.
public struct AssetVpsData: CustomDebugStringConvertible, Sendable {
    /// Default anchor payload used by VPS Service.
    /// Base64 encoded protobuf of ManagedPoseData.
    ///
    /// - Note: A legacy map identifier. An anchor payload is no longer the preferred method to
    ///   identify the map to localize against: pass a site ID to
    ///   `NSDKVps2Session.localize(siteId:)` or a coordinate to
    ///   `localize(latitude:longitude:radiusMeters:)`.
    public let anchorPayload: String
    
    public init?(fromC cValue: UnsafePointer<ARDK_SitesManager_AssetVpsData>?) {
        guard let ptr = cValue else { return nil }
        let vpsData = ptr.pointee
        
        guard let anchorPayloadPtr = vpsData.anchor_payload else { return nil }
        self.anchorPayload = String(cString: anchorPayloadPtr)
    }
    
    public var debugDescription: String {
        let truncated = anchorPayload.count > 50 
            ? String(anchorPayload.prefix(50)) + "..." 
            : anchorPayload
        return "VpsData:\n  - Anchor Payload: \(truncated)\n"
    }
}

/// Discriminated union for typed asset data.
/// One of mesh, splat, or vps will be set based on the asset type.
public enum TypedAssetData: CustomDebugStringConvertible, Sendable {
    case mesh(AssetMeshData)
    case splat(AssetSplatData)
    case vps(AssetVpsData)
    case none
    
    public var debugDescription: String {
        switch self {
        case .mesh(let data): return data.debugDescription
        case .splat(let data): return data.debugDescription
        case .vps(let data): return data.debugDescription
        case .none: return "No typed data"
        }
    }
}

