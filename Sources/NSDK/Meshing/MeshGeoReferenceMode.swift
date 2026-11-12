import CArdk

/// Whether a mesh download carries a usable georeference.
public enum MeshGeoReferenceMode: Sendable {
    /// The asset has no georeference, or its chunk transforms do not share a single frame for one
    /// to apply to. The mesh can only be placed in a local (non-geographic) frame; every other
    /// property of ``MeshGeoReference`` is zero.
    case unavailable

    /// The georeference is valid. Anchor the mesh group's world origin at the reference position
    /// and apply `trackingToReference` to the whole group, then place each chunk by its own
    /// transform.
    case georeferenced

    init(fromC cValue: ARDK_Mesh_GeoReferenceMode) {
        switch cValue {
        case ARDK_Mesh_GeoReferenceMode_Georeferenced:
            self = .georeferenced
        default:
            self = .unavailable
        }
    }
}
