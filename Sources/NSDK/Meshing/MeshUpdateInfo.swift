import CArdk
import Foundation

extension NSDKMeshingSession {
    /// Contains information about all mesh chunk updates from live meshing operations.
    ///
    /// Returned by ``NSDKMeshingSession.updatedMeshInfos()`` to indicate which
    /// mesh chunks have been modified or removed since the last update.
    struct MeshUpdateInfo {
        private var resourceOwner: ResourceOwner?

        /// Array of all mesh chunk IDs.
        ///
        /// When a chunk is removed from the mesh, it will no longer be present in this array.
        /// The application should keep track of its current mesh chunk IDs to determine when
        /// a chunk has been removed.
        public var ids: UnsafeBufferPointer<Int64>

        /// Array indicating whether each chunk was updated or removed.
        ///
        /// For each corresponding ID in `ids`, this array indicates:
        /// - **Non-zero value**: The chunk has been updated since the last call to `meshDataById`.
        ///                       Call `meshDataById` to read the latest mesh data.
        ///                       Calling `meshDataById` will reset the update status for that chunk to 0.
        /// - **Zero value**:     The chunk has not been updated since the last call to
        ///                       `meshDataById`, so there is no need to read its mesh data.
        public var updated: UnsafeBufferPointer<UInt8>

        init(fromC cInfo: ARDK_Meshing_UpdateInfo, owner: ResourceOwner?) {
            resourceOwner = owner

            let numIds = Int(cInfo.numIds)

            ids = UnsafeBufferPointer(start: cInfo.ids, count: numIds)
            updated = UnsafeBufferPointer(start: cInfo.updated, count: numIds)
        }
    }
}
