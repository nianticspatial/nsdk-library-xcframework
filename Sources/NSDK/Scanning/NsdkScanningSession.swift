// Copyright 2022-2026 Niantic.

import CArdk
import Combine
import Foundation

extension NSDKSession {
    /// Returns the shared Scanning session, creating it on first call.
    ///
    /// Subsequent calls return the same instance. The session is inactive until `start()` is
    /// called. `NSDKSession.update()` will call `update()` on it automatically each frame once
    /// it is started.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireScanningSession() -> NSDKScanningSession {
        let key = ObjectIdentifier(NSDKScanningSession.self)
        if let existing = disposables[key] as? NSDKScanningSession {
            return existing
        }
        let session = NSDKScanningSession(nsdkHandle: nativeHandle, api: CScanningApi())
        disposables[key] = session
        return session
    }
}

/// A session for 3D scanning and visualization with Combine publisher support.
///
/// The scanning feature provides capabilities for capturing, processing, and exporting
/// 3D scan data from AR sessions. Scans of a location can be processed by the Visual
/// Positioning System's (VPS's) cloud services to enable VPS localization.
///
/// ## Overview
///
/// Use `$latestRaycastBuffer` and `$latestVoxelBuffer` to reactively update your UI or
/// visualization in response to new scan data, rather than polling each frame manually.
///
/// ## Usage Pattern
///
/// ```swift
/// let scanSession = nsdkSession.acquireScanningSession()
/// let config = NSDKScanningSession.Configuration(
///     enableRaycastVisualization: true,
///     enableVoxelVisualization: true
/// )
/// try scanSession.configure(with: config)
/// scanSession.start()
///
/// // Subscribe to raycast buffer updates
/// scanSession.$latestRaycastBuffer
///     .compactMap { $0 }
///     .sink { buffer in
///         // Update raycast visualization
///     }
///     .store(in: &cancellables)
///
/// // Trigger voxel computation and subscribe to results
/// scanSession.computeVoxels()
/// scanSession.$latestVoxelBuffer
///     .compactMap { $0 }
///     .sink { buffer in
///         // Update voxel visualization
///     }
///     .store(in: &cancellables)
/// ```
///
/// `$latestRaycastBuffer` is updated automatically each frame by `NSDKSession.update()` while
/// the session is active and raycast visualization is enabled. `$latestVoxelBuffer` is updated
/// each frame when new voxel data is available after `computeVoxels()` has been called.
public final class NSDKScanningSession: NSDKSession.IDisposable, NSDKUpdatableSession {

    // MARK: - Combine Publishers

    /// The most recently computed raycast buffer. Updated each frame by `NSDKSession` while active.
    ///
    /// `nil` until the first buffer arrives after `start()`. Requires `enableRaycastVisualization`
    /// to be set in the configuration.
    @Published public private(set) var latestRaycastBuffer: RaycastBuffer?

    /// The most recently computed voxel buffer. Updated each frame when new voxel data is ready.
    ///
    /// `nil` until `computeVoxels()` has been called and results become available. Requires
    /// `enableVoxelVisualization` to be set in the configuration.
    @Published public private(set) var latestVoxelBuffer: VoxelBuffer?

    // MARK: - Private

    private let nsdkHandle: NSDKHandle
    private let api: ScanningApi
    private var lastConfig: Configuration?
    private var isActive = false

    // MARK: - Init

    init(nsdkHandle: NSDKHandle, api: ScanningApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        let cStatus = api.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            nsdkUnexpected(cStatus, returning: ())
            return
        }
    }

    internal func destroy() {
        let cStatus = api.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    // MARK: - NSDKUpdatableSession

    /// Reports errors that have occurred within processes running inside this feature.
    ///
    /// Check this periodically to see if any errors have occurred with processes running
    /// inside this feature. Once an error has been flagged, it will remain flagged until the
    /// culprit process has been run again and completed successfully.
    ///
    /// - Returns: Feature status flags for any issues that have occurred
    public func featureStatus() -> NSDKFeatureStatus {
        let flags = api.getFeatureStatus(nsdkHandle: nsdkHandle)
        return NSDKFeatureStatus(rawValue: flags.rawValue)
    }

    /// Configures the session with the specified settings.
    ///
    /// - Attention: This method must be called while the session is stopped,
    ///   or else configuration will fail. In that case, while this function returns without
    ///   throwing, configuration will still fail asynchronously. Use ``featureStatus()``
    ///   to check that configuration has not failed.
    /// - Parameter config: An object that defines this session's behavior.
    ///   Only settings that differ from the defaults will be applied.
    /// - Throws: ``NSDKError.invalidArgument`` if the configuration is invalid.
    ///   Check NSDK's C logs for more information.
    public func configure(with config: Configuration) throws {
        let cStatus = config.withCStruct { ptr in
            api.configure(nsdkHandle: nsdkHandle, config: ptr)
        }
        if cStatus.isError {
            if cStatus.isInvalidArgument {
                throw NSDKError.invalidArgument
            } else {
                throw nsdkUnexpectedError(cStatus)
            }
        }
        lastConfig = config
    }

    /// Starts scanning.
    ///
    /// "Scanning" here may include up to three processes — recording input AR data, raycasting,
    /// and voxelization — depending on how the feature is configured.
    ///
    /// Raycasting and voxelization are useful for visualizing scanned areas and
    /// providing feedback to the user about their scan.
    ///
    /// - SeeAlso: `stop()`
    /// - SeeAlso: `configure(_:)`
    public func start() {
        // A second start() without an intervening stop() is not supported.
        guard !isActive else {
            return nsdkUnexpected(
                "session is already started; call stop() before starting it again",
                returning: ()
            )
        }

        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            // Leave `isActive` false: the session did not start.
            return nsdkUnexpected(cStatus, returning: ())
        }
        isActive = true
    }

    /// Stops scanning and discards any unsaved scan data.
    ///
    /// Halts any active scanning while keeping the scanner instance alive.
    /// You can restart scanning later by calling `start()`.
    ///
    /// - SeeAlso: `start()`
    public func stop() {
        // Reset state first, so a failed stop cannot leave the session permanently
        // unable to start again.
        latestRaycastBuffer = nil
        latestVoxelBuffer = nil
        isActive = false
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    // MARK: - Frame Update

    func update() {
        guard isActive else { return }

        // Only poll buffers when their visualization was enabled in the config, as the native
        // SDK returns an error if polled without the corresponding visualization enabled.
        if lastConfig?.enableRaycastVisualization == true {
            if let buffer = pollRaycastBuffer() {
                latestRaycastBuffer = buffer
            }
        }

        if lastConfig?.enableVoxelVisualization == true {
            if let buffer = pollVoxelBuffer() {
                latestVoxelBuffer = buffer
            }
        }
    }

    // MARK: - Recording

    /// Returns information about the current recording.
    ///
    /// Call this method **before** `saveCurrentScan()` to ensure that the recording
    /// contains frames to save. Otherwise, the save operation may fail.
    ///
    /// - Returns: A `RecordingInfo` object containing details about the current recording.
    /// - Note: Make sure to call this method before `saveCurrentScan()` if you plan to
    ///         save the current scan; otherwise, the save may fail.
    public func recordingInfo() -> NSDKScanningSession.RecordingInfo {
        var cRecordingInfo = ARDK_Scanning_RecordingInfo()
        let cStatus = api.getRecordingInfo(nsdkHandle: nsdkHandle, recordingOut: &cRecordingInfo)
        if cStatus.isError {
            // `cRecordingInfo` was never written, so do not convert it.
            return nsdkUnexpected(cStatus, returning: .empty)
        }
        return NSDKScanningSession.RecordingInfo(fromC: cRecordingInfo)
    }

    /// Stops recording and asynchronously saves the recording to the configured path.
    ///
    /// Calling this function will stop the active recording, but ``stop`` must still be called
    /// afterward to completely shut down this session.
    ///
    /// - Parameters:
    ///   - timeout: The maximum duration in seconds to wait for the save operation
    ///     (default is 10 seconds).
    ///   - pollingInterval: The interval in seconds to wait between progress checks
    ///     (default is 0.1 seconds)
    /// - Returns: Information about the saved scan, including it's id and file location.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``NSDKScanningSession.SaveError`` if there was an error specific to the
    ///     save operation.
    /// - SeeAlso:
    ///   - ``stop``
    ///   - ``configure(with:)``
    /// - Important: Runs on the main actor, where the session is created and updated.
    @MainActor
    public func saveCurrentScan(
        timeout: Double = 10.0,
        pollingInterval: TimeInterval = 0.1
    ) async throws -> NSDKScanningSession.SaveInfo {
        try saveRecording()

        let deadline = Date(timeIntervalSinceNow: timeout)
        while true {
            if Date() > deadline {
                throw TimeoutError()
            }
            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
            if let saveInfo = currentSaveInfo() {
                return saveInfo
            }
        }
    }

    // MARK: - Export

    /// Exports the scan data as an archive file.
    ///
    /// This method processes the saved scan data and exports it to a standard archive format
    /// that can be used with external 3D processing tools or Niantic's VPS map.
    ///
    /// - Note: This function is blocking and may take a while to execute. See
    ///      ``NSDKRecordingExporter`` for a non-blocking alternative.
    ///
    /// - Precondition: Argument ``metadata`` must be a valid JSON object string.
    /// - Parameter metadata: Metadata dictionary to include with the export. Can be left empty.
    /// - Parameter exportAsVideo: If true, the RGB frames in the scan will be exported as an
    ///                            .mp4 video. If false, they will be individual image files.
    /// - Returns: The path of the archive file, if the export was successful, `nil` if otherwise.
    ///   Export failure indicates something was wrong with the saved scan.
    /// - Throws:
    ///   - ``NSDKError.invalidOperation`` if the scanning session did not have a saved scan to export.
    public func exportArchive(metadata: [String: Any]? = nil, exportAsVideo: Bool = true, exportResolution: ExportResolution = .high) throws -> String? {
        var cArchive = ARDK_Scanning_Export()
        defer {
            if cArchive.handle != nil {
                api.releaseResource(handle: cArchive.handle)
            }
        }

        let cStatus = try withMetadataJsonString(metadata) { ardk_str in
            api.exportArchive(nsdkHandle: nsdkHandle, metadataJson: ardk_str, exportAsVideo: exportAsVideo, exportResolution: exportResolution.toC, exportOut: &cArchive)
        }

        if cStatus == ARDK_Status_InvalidOperation {
            throw NSDKError.invalidOperation
        } else if cStatus.isError {
            throw nsdkUnexpectedError(cStatus)
        }

        if cArchive.handle != nil {
            return String(ptr: cArchive.export_path, len: cArchive.export_path_len)
        }
        return nil
    }

    /// Exports the scan data as multiple archive files.
    ///
    /// This method processes the saved scan data and exports it to multiple archive files
    /// based on the maxFramesPerArchive parameter. Each archive will contain at most
    /// maxFramesPerArchive frames.
    ///
    /// - Note: This function is blocking and may take a while to execute. See
    ///      ``NSDKRecordingExporter`` for a non-blocking alternative.
    ///
    /// - Precondition: Argument ``metadata`` must be a valid JSON object string.
    /// - Parameter metadata: Metadata dictionary to include with the export. Can be left empty.
    /// - Parameter maxFramesPerArchive: Maximum number of frames per archive file.
    /// - Parameter exportAsVideo: If true, the RGB frames in the scan will be exported as an
    ///                            .mp4 video. If false, they will be individual image files.
    /// - Returns: An array of paths to the archive files, if the export was successful, `nil` if otherwise.
    ///     Export failure indicates something was wrong with the saved scan.
    /// - Throws:
    ///   - `NSDKError.invalidOperation` if the scanning session did not have a saved scan to export.
    public func exportSplitArchive(
        metadata: [String: Any]? = nil,
        maxFramesPerArchive: Int,
        exportAsVideo: Bool = true,
        exportResolution: ExportResolution = .high
    ) throws -> [String]? {
        var cSplitExport = ARDK_Scanning_Split_Export()
        defer {
            if cSplitExport.handle != nil {
                api.releaseResource(handle: cSplitExport.handle)
            }
        }

        let cStatus = try withMetadataJsonString(metadata) { ardk_str in
            api.exportSplitArchive(
                nsdkHandle: nsdkHandle,
                metadataJson: ardk_str,
                maxFramesPerArchive: Int32(maxFramesPerArchive),
                exportAsVideo: exportAsVideo,
                exportResolution: exportResolution.toC,
                exportOut: &cSplitExport
            )
        }

        if cStatus == ARDK_Status_InvalidOperation {
            throw NSDKError.invalidOperation
        } else if cStatus.isError {
            throw nsdkUnexpectedError(cStatus)
        }

        guard cSplitExport.handle != nil, cSplitExport.export_paths_size > 0 else { return nil }

        return (0..<Int(cSplitExport.export_paths_size)).compactMap { i in
            let nsdkString = cSplitExport.export_paths![i]
            return String(ptr: nsdkString.data, len: nsdkString.data_size)
        }
    }

    // MARK: - Voxels

    /// Triggers asynchronous voxel computation. Subscribe to `$latestVoxelBuffer` to receive
    /// the result once processing completes.
    ///
    /// - Precondition: Voxel visualization must have been enabled in the configuration.
    public func computeVoxels() {
        let cStatus = api.computeVoxels(nsdkHandle: nsdkHandle)
        if cStatus == ARDK_Status_InvalidOperation {
            return nsdkUnexpected(
                "session must have been successfully configured with voxel visualization enabled",
                returning: ()
            )
        } else if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    // MARK: - Private Helpers

    // Start the save process. May throw `SaveError.noFrames`
    private func saveRecording() throws {
        let saveCode = api.saveRecording(nsdkHandle: nsdkHandle)
        if saveCode.isInvalidOperation {
            throw NSDKScanningSession.SaveError.noFrames
        } else if saveCode.isError {
            throw nsdkUnexpectedError(saveCode)
        }
    }

    // Helper method to get saving state. It returns nil for any situation other than a
    // successfully saved scan.
    // NOTE: The discarded state is ignored because this is a helper method for getting
    // the state of saved, not discarded, scans.
    internal func currentSaveInfo() -> NSDKScanningSession.SaveInfo? {
        var cSave = ARDK_Scanning_SaveInfo()
        defer {
            if cSave.handle != nil {
                api.releaseResource(handle: cSave.handle)
            }
        }
        let cStatus = api.getSaveInfo(nsdkHandle: nsdkHandle, saveOut: &cSave)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: nil)
        }
        guard cSave.state == ARDK_Scanning_SaveState_Saved else { return nil }
        return NSDKScanningSession.SaveInfo(fromC: cSave)
    }

    // Get the most recently computed raycast buffers.
    // Once the session has been started and all the requested data has been sent through the
    // NSDKSession, a buffer should become available after a brief computation period.
    private func pollRaycastBuffer() -> RaycastBuffer? {
        var cBuffer = ARDK_Scanning_RaycastBuffer()
        let cStatus = api.getRaycastBuffer(nsdkHandle: nsdkHandle, raycastBufferOut: &cBuffer)
        if cStatus == ARDK_Status_InvalidOperation {
            return nsdkUnexpected(
                "session must have been successfully configured with raycast visualization enabled",
                returning: nil
            )
        } else if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: nil)
        }
        guard cBuffer.handle != nil else { return nil }
        let owner = api.createResourceOwner(handle: cBuffer.handle!)
        return RaycastBuffer(fromC: cBuffer, owner: owner)
    }

    // Get the most recently computed voxel data.
    // Once the session has been started and all the requested data has been sent through the
    // NSDKSession, a new buffer should become available after a brief computation period after
    // ``computeVoxels()`` has been called.
    private func pollVoxelBuffer() -> VoxelBuffer? {
        var cBuffer = ARDK_Scanning_VoxelBuffer()
        let cStatus = api.getVoxelBuffer(nsdkHandle: nsdkHandle, voxelBufferOut: &cBuffer)
        if cStatus == ARDK_Status_InvalidOperation {
            return nsdkUnexpected(
                "session must have been successfully configured with voxel visualization enabled",
                returning: nil
            )
        } else if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: nil)
        }
        guard cBuffer.handle != nil else { return nil }
        let owner = api.createResourceOwner(handle: cBuffer.handle!)
        return VoxelBuffer(fromC: cBuffer, owner: owner)
    }

    private func withMetadataJsonString<T>(
        _ metadata: [String: Any]?,
        _ body: (ARDK_String) throws -> T
    ) rethrows -> T {
        var jsonString = ""
        if let metadata {
            if let jsonData = try? JSONSerialization.data(withJSONObject: metadata, options: []),
               let str = String(data: jsonData, encoding: .utf8) {
                jsonString = str
            } else {
                // Continue with empty metadata rather than failing the whole export.
                nsdkUnexpected(
                    "a non-nil `metadata` argument must be serializable into a JSON string",
                    returning: ()
                )
            }
        }
        return try jsonString.withCString { cStr in
            let ardk_str = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return try body(ardk_str)
        }
    }
}
