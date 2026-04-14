import CArdk
import Foundation

extension NSDKMeshingSession {
    /// Describes a change to a specific mesh chunk.
    ///
    /// Each case represents how a chunk identified by `id` should be handled:
    /// - `insert`: A new chunk should be added.
    /// - `update`: An existing chunk has new mesh data.
    /// - `remove`: A chunk should be removed.
    public enum MeshChunkUpdate {

        /// A new mesh chunk.
        case insert(id: Int64, data: MeshData)

        /// Updated data for an existing mesh chunk.
        case update(id: Int64, data: MeshData)

        /// Removal of an existing mesh chunk.
        case remove(id: Int64)
    }
}
