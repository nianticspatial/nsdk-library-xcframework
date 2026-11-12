import CArdk

/// Georeference of a mesh download's asset: the geodetic origin its chunk transforms are expressed
/// relative to, plus the transform into that origin's frame.
///
/// Identical on every ``MeshDownloaderChunk`` / ``MeshDownloaderResult`` of one download, because
/// it describes the space rather than any single node. A chunk's own geographic position is
/// obtained by composing this with that chunk's transform — not from anything inside ``MeshData``,
/// which carries no geographic data at all.
///
/// Both the origin and the transform are required: depending on the asset, the altitude offset may
/// live entirely in ``referenceAltitude`` (with ``trackingToReference`` carrying no vertical
/// translation) or entirely in ``trackingToReference`` (with ``referenceAltitude`` zero). Applying the origin
/// without the transform is wrong in the general case.
public struct MeshGeoReference: Sendable {
    /// Whether the properties below are valid. Inspect this first.
    public let mode: MeshGeoReferenceMode

    /// WGS84 latitude of the origin `trackingToReference` maps into, in decimal degrees.
    public let referenceLatitude: Double
    /// WGS84 longitude of that origin, in decimal degrees.
    public let referenceLongitude: Double
    /// Altitude of that origin, in meters above the WGS84 ellipsoid.
    public let referenceAltitude: Double

    /// Column-major 4x4 matrix (16 elements) mapping the asset's origin space (the space the chunk
    /// transforms are expressed in, not the device's AR tracking space) into meters relative to the
    /// reference origin, exactly as delivered by Portal — this implementation does not transpose
    /// it or convert it to ARKit axes. The frame is East-Down-North, so +Y is downward.
    public let trackingToReference: [Float]

    init(fromC cValue: ARDK_Mesh_GeoReference) {
        mode = MeshGeoReferenceMode(fromC: cValue.mode)
        referenceLatitude = cValue.reference_latitude
        referenceLongitude = cValue.reference_longitude
        referenceAltitude = cValue.reference_altitude

        // Fixed-size C arrays imported into Swift as part of a C struct are kept in contiguous
        // memory even as a tuple; reinterpret rather than copy element-by-element.
        let cMatrix = cValue.tracking_to_reference
        trackingToReference = withUnsafeBytes(of: cMatrix) { ptr in
            Array(ptr.bindMemory(to: Float.self))
        }
    }
}
