import CArdk
import simd

/// A single decoded mesh chunk from a streaming portal mesh download.
///
/// Chunks are delivered incrementally via
/// ``NSDKMeshDownloader/requestLocationMeshByAsset(vpsMapAssetId:latitude:longitude:getTexture:maxChunks:maxSizeKb:maxDecodedSizeKb:pollingInterval:)``
/// as each graph node finishes downloading, rather than waiting for the full download to complete.
public struct MeshDownloaderChunk: @unchecked Sendable {
    /// The mesh geometry data containing vertices, faces, and texture coordinates.
    public let meshData: MeshData

    /// The texture image data for the mesh, or an empty buffer if texture was not requested.
    public let imageData: NSDKBuffer

    /// Transform from this chunk's local vertex space into the asset's origin space, in ARKit
    /// axes with translation in meters. The asset's origin space is the one
    /// ``Vps2AssetTrackingData/assetToTrackingTransform`` places in AR tracking space, so a vertex
    /// lands in tracking space at `assetToTrackingTransform * transform * v`, where `v` is the
    /// vertex converted to ARKit axes (see ``MeshData/verticesPtr``).
    public let transform: simd_float4x4

    /// The georeference of the asset this chunk belongs to. Identical on every chunk of one
    /// download; compose it with `transform` to place this chunk geographically.
    public let geoReference: MeshGeoReference

    /// The VPS map asset ID the download was requested with. Not the ID of the
    /// mesh asset the geometry came from, so it matches the asset
    /// ``Vps2LocalizedAsset/assetId`` reports. Identical on every chunk of one download.
    public let vpsMapAssetId: String

    /// Identifier of subarea in the site this chunk belongs to, or an empty string when the asset
    /// has no subareas. This identifier can be used to optimize which mesh chunk to render
    /// depending on localization result.
    public let areaId: String

    // Keeps the native memory alive until this struct is deallocated.
    private let resourceOwner: ResourceOwner?

    init(fromC cChunk: ARDK_MeshDownloader_Chunk, owner: ResourceOwner?) {
        self.resourceOwner = owner
        self.meshData = MeshData(fromC: cChunk.mesh_data, owner: owner)
        self.imageData = NSDKBuffer(fromC: cChunk.image_data, owner: owner)
        let rawTransform = simd_float4x4(fromColumnMajorArray: cChunk.transform)
        self.transform = rawTransform.fromNSDKToARKit()
        self.geoReference = MeshGeoReference(fromC: cChunk.geo_reference)
        self.vpsMapAssetId = String(fixedCString: cChunk.vps_map_asset_id) ?? ""
        self.areaId = String(fixedCString: cChunk.area_id) ?? ""
    }
}
