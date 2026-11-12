import CArdk
import Combine
import Foundation

extension NSDKSession {
    /// Returns the shared meshing session, creating it on first call.
    ///
    /// Subsequent calls return the same instance. The session is inactive until `start()` is
    /// called. `NSDKSession.update()` will call `update()` on it automatically each frame once
    /// it is started.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireMeshingSession() -> NSDKMeshingSession {
        let key = ObjectIdentifier(NSDKMeshingSession.self)
        if let existing = disposables[key] as? NSDKMeshingSession {
            return existing
        }
        let session = NSDKMeshingSession(nsdkHandle: nativeHandle, meshingApi: CMeshingApi())
        disposables[key] = session
        return session
    }
}

/// A session for real-time 3D mesh generation from AR camera frames, with Combine publisher support.
///
/// The meshing feature provides capabilities for processing AR session data and generating
/// a triangle mesh representation of the physical environment in real-time. The mesh is
/// divided into chunks that are individually tracked as they are inserted, updated, or removed.
///
/// `meshUpdates` emits each frame a non-empty batch of chunk changes is available, driven by
/// `NSDKSession.update()` while the session is active. Subscribe to it with Combine:
///
/// ```swift
/// meshingSession.meshUpdates
///     .sink { updates in ... }
///     .store(in: &cancellables)
/// ```
public final class NSDKMeshingSession: NSDKSession.IDisposable, NSDKUpdatableSession {

    // MARK: - Combine Publishers

    /// Emits incremental mesh updates each frame new changes are available.
    ///
    /// Each emission contains a non-empty array of chunk insertions, updates, and removals
    /// since the previous frame. Frames with no mesh changes produce no emission.
    public let meshUpdates = PassthroughSubject<[NSDKMeshingSession.MeshChunkUpdate], Never>()

    // MARK: - Private

    internal let nsdkHandle: NSDKHandle
    private let meshingApi: MeshingApi
    private var isActive = false
    private var lastUpdateTime: UInt64? = nil
    private var chunkIds = Set<Int64>()

    // MARK: - Init

    init(nsdkHandle: NSDKHandle, meshingApi: MeshingApi) {
        self.nsdkHandle = nsdkHandle
        self.meshingApi = meshingApi
        let cStatus = meshingApi.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            nsdkUnexpected(cStatus, returning: ())
            return
        }
    }

    internal func destroy() {
        let cStatus = meshingApi.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    // MARK: - NSDKUpdatableSession

    /// Polls the meshing API for the latest mesh updates and publishes them on `$latestMeshUpdates`.
    ///
    /// Called automatically by `NSDKSession` each frame — you do not need to call this directly.
    /// No-op when the session is not active.
    func update() {
        guard isActive else { return }
        let updates = computeUpdates()
        if !updates.isEmpty {
            meshUpdates.send(updates)
        }
    }

    // MARK: - Lifecycle

    /// Reports the current status of the meshing session.
    ///
    /// Check this periodically to see if any errors have occurred with processes running
    /// inside this feature. Once an error has been flagged, it will remain flagged until the
    /// culprit process has been run again and completed successfully.
    ///
    /// - Returns: A flag indicating the current status of the meshing session.
    public func featureStatus() -> NSDKFeatureStatus {
        let flags = meshingApi.getFeatureStatus(nsdkHandle: nsdkHandle)
        return NSDKFeatureStatus(rawValue: flags.rawValue)
    }

    /// Configures the meshing feature with the specified settings.
    ///
    /// - Attention: If this method is called while meshing is running, the meshing feature will
    ///   restart with the new configuration, and any mesh data that has been produced will
    ///   be lost.
    ///
    /// - Parameter config: An object that defines the meshing behavior.
    /// - Throws: ``NSDKError.invalidArgument`` if the configuration is invalid.
    ///   Check NSDK's C logs for more information.
    public func configure(with config: Configuration) throws {
        let cStruct = config.convertToC()
        let cStatus = withUnsafePointer(to: cStruct) { ptr in
            meshingApi.configure(nsdkHandle: nsdkHandle, config: ptr)
        }

        if cStatus.isError {
            throw NSDKError(fromC: cStatus)
        }
    }

    /// Starts the meshing feature.
    ///
    /// The feature will begin processing AR frame data and building a mesh according to the
    /// currently applied configuration.
    public func start() {
        // A second start() without an intervening stop() is not supported.
        guard !isActive else {
            return nsdkUnexpected(
                "session is already started; call stop() before starting it again",
                returning: ()
            )
        }

        let cStatus = meshingApi.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            // Leave `isActive` false: the session did not start.
            return nsdkUnexpected(cStatus, returning: ())
        }
        isActive = true
    }

    /// Stops the meshing feature.
    ///
    /// - Note: This will clear previously generated mesh data.
    public func stop() {
        // Reset state first, so a failed stop cannot leave the session permanently
        // unable to start again.
        isActive = false
        lastUpdateTime = nil
        chunkIds = []

        let cStatus = meshingApi.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    // MARK: - Private helpers

    internal func lastMeshUpdateTime() -> UInt64? {
        var timestampMs: UInt64 = 0
        let cStatus = meshingApi.getLastMeshUpdateTime(nsdkHandle: nsdkHandle, timestampMsOut: &timestampMs)
        if cStatus.isError { return nsdkUnexpected(cStatus, returning: nil) }
        return timestampMs == 0 ? nil : timestampMs
    }

    internal func updatedMeshInfos() -> NSDKMeshingSession.MeshUpdateInfo? {
        var cInfo = ARDK_Meshing_UpdateInfo()
        let cStatus = meshingApi.getUpdatedMeshInfos(nsdkHandle: nsdkHandle, infoOut: &cInfo)
        if cStatus.isError { return nsdkUnexpected(cStatus, returning: nil) }
        if cInfo.numIds == 0 { return nil }
        let owner = meshingApi.createResourceOwner(handle: cInfo.handle!)
        return NSDKMeshingSession.MeshUpdateInfo(fromC: cInfo, owner: owner)
    }

    internal func meshDataById(id: Int64) -> MeshData? {
        var cChunk = ARDK_Meshing_ChunkData()
        let cStatus = meshingApi.getMeshDataById(nsdkHandle: nsdkHandle, id: id, meshChunkOut: &cChunk)
        if cStatus == ARDK_Status_OK {
            let owner = meshingApi.createResourceOwner(handle: cChunk.handle!)
            return MeshData(fromC: cChunk, owner: owner)
        }
        if cStatus == ARDK_Status_InvalidArgument {
            return nil
        }
        return nsdkUnexpected(cStatus, returning: nil)
    }

    private func computeUpdates() -> [NSDKMeshingSession.MeshChunkUpdate] {
        guard let timestamp = lastMeshUpdateTime(),
              lastUpdateTime != timestamp else {
            return []
        }

        guard let meshInfos = updatedMeshInfos() else {
            return []
        }

        guard meshInfos.ids.count == meshInfos.updated.count else {
            return nsdkUnexpected(
                "meshInfos.ids and meshInfos.updated must have the same count",
                returning: []
            )
        }

        var allChunkIds = chunkIds
        var chunksToRemove = chunkIds
        var result: [NSDKMeshingSession.MeshChunkUpdate] = []

        for (index, id) in meshInfos.ids.enumerated() {
            let wasPresent = chunksToRemove.remove(id) != nil

            if !wasPresent {
                if let chunkData = meshDataById(id: id) {
                    result.append(.insert(id: id, data: chunkData))
                    allChunkIds.insert(id)
                }
                continue
            }

            let didUpdate = meshInfos.updated[index] == 1
            if didUpdate, let chunkData = meshDataById(id: id) {
                result.append(.update(id: id, data: chunkData))
            }
        }

        for id in chunksToRemove {
            result.append(.remove(id: id))
            allChunkIds.remove(id)
        }

        lastUpdateTime = timestamp
        chunkIds = allChunkIds

        return result
    }
}
