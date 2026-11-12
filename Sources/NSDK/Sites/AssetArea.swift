// Copyright 2026 Niantic Spatial.
import CArdk

/// One independently-localizable piece of an asset.
///
/// A scan too large for a single mapping run is split, and each piece gets its own job,
/// anchor, node graph and extent. An asset mapped in one pass has exactly one area.
///
/// One shape serves every asset type. ``AssetInfo/assetType`` selects which properties carry
/// anything:
/// - mesh: `rootNodeId`, `nodeIds`, `meshCoverage`
/// - splat: `rootNodeId`
/// - VPS: `anchorPayload`, and `bounds`
public struct AssetArea: CustomDebugStringConvertible, Sendable {
    /// This area's own identifier, unique within the asset.
    public let areaId: String

    /// Status of this area's own mapping job.
    ///
    /// A job belongs to an area, so this is the only status the portal reports;
    /// ``AssetInfo/pipelineJobStatus`` is deprecated and left unset.
    public let jobStatus: AssetPipelineJobStatus

    /// The space this area was mapped into.
    public let spaceId: String

    /// Root node ID of this area's space.
    public let rootNodeId: String

    /// All node IDs from this area's space.
    public let nodeIds: [String]

    /// This area's anchor payload, base64-encoded ManagedPoseData.
    ///
    /// - Note: A legacy map identifier. An anchor payload is no longer the preferred method to
    ///   identify the map to localize against: pass a site ID to
    ///   `NSDKVps2Session.localize(siteId:)` or a coordinate to
    ///   `localize(latitude:longitude:radiusMeters:)`.
    public let anchorPayload: String

    /// This area's mesh coverage in square meters.
    public let meshCoverage: Double

    /// This area's geographic extent, or nil when the portal published none, or one describing
    /// no usable area.
    public let bounds: GeoBounds?

    /// A geographic bounding box.
    public struct GeoBounds: Sendable {
        public let minLat: Double
        public let minLng: Double
        public let maxLat: Double
        public let maxLng: Double
    }

    public init(fromC cValue: ARDK_SitesManager_AssetArea) {
        self.areaId = cValue.area_id != nil ? String(cString: cValue.area_id) : ""
        self.jobStatus = AssetPipelineJobStatus(fromC: cValue.job_status)
        self.spaceId = cValue.space_id != nil ? String(cString: cValue.space_id) : ""
        self.rootNodeId = cValue.root_node_id != nil ? String(cString: cValue.root_node_id) : ""
        self.anchorPayload =
            cValue.anchor_payload != nil ? String(cString: cValue.anchor_payload) : ""
        self.meshCoverage = cValue.mesh_coverage

        self.nodeIds = {
            guard let nodeIdsPtr = cValue.node_ids else { return [] }
            let buffer = UnsafeBufferPointer(start: nodeIdsPtr, count: Int(cValue.node_ids_size))
            return buffer.compactMap { nodeIdPtr in
                guard let nodeId = nodeIdPtr else { return nil }
                return String(cString: nodeId)
            }
        }()

        self.bounds = cValue.has_bounds
            ? GeoBounds(
                minLat: cValue.min_lat,
                minLng: cValue.min_lng,
                maxLat: cValue.max_lat,
                maxLng: cValue.max_lng)
            : nil
    }

    public var debugDescription: String {
        var desc = "Area \(areaId):\n"
        if jobStatus != .unspecified { desc += "  - Job Status: \(jobStatus)\n" }
        if !spaceId.isEmpty { desc += "  - Space ID: \(spaceId)\n" }
        if !rootNodeId.isEmpty { desc += "  - Root Node ID: \(rootNodeId)\n" }
        if meshCoverage != 0 { desc += "  - Mesh Coverage: \(meshCoverage) m²\n" }
        if !nodeIds.isEmpty {
            desc += "  - Node IDs (\(nodeIds.count)): \(nodeIds.prefix(3).joined(separator: ", "))"
            if nodeIds.count > 3 { desc += "..." }
            desc += "\n"
        }
        if let bounds {
            desc += "  - Bounds: (\(bounds.minLat), \(bounds.minLng))"
            desc += "-(\(bounds.maxLat), \(bounds.maxLng))\n"
        }
        return desc
    }
}
