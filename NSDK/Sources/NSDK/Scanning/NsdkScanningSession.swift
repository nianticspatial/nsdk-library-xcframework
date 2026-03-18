import CArdk
import Foundation

extension NSDKSession {
    /// Creates a new Scanning session.
    ///
    /// - Returns: A new Scanning session attached to this NSDK session
    public func createScanningSession() -> NSDKScanningSession {
        let key = ObjectIdentifier(NSDKScanningSession.self)
        if let existing = disposables[key] as? NSDKScanningSession {
            return existing
        }
        let session = NSDKScanningSession(nsdkHandle: nativeHandle, api: CScanningApi())
        disposables[key] = session
        return session
    }
}

/// A session for 3D scanning and visualization functionality.
///
/// The scanning feature provides capabilities for capturing, processing, and exporting
/// 3D scan data from AR sessions. Scans of a location can be processed by the Visual
/// Positioning System's (VPS's) cloud services to enable VPS localization.
public final class NSDKScanningSession: NSDKSession.IDisposable, NSDKFeatureSession {
    private let nsdkHandle: NSDKHandle
    private let api: ScanningApi

    init(nsdkHandle: NSDKHandle, api: ScanningApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        let cStatus = api.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    internal func destroy() {
        let cStatus = api.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

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
                unexpectedNSDKStatus(cStatus)
            }
        }
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
        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Stops scanning and discards any unsaved scan data.
    ///
    /// Halts any active scanning while keeping the scanner instance alive.
    /// You can restart scanning later by calling `start()`.
    ///
    /// - SeeAlso: `start()`
    public func stop() {
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Returns information about the current recording.
    ///
    /// Call this method **before** `saveCurrentScan()` to ensure that the recording
    /// contains frames to save. Otherwise, the save operation may fail.
    ///
    /// - Returns: A `RecordingInfo` object containing details about the current recording.
    /// - Throws: An error if the underlying NSDK call fails.
    /// - Note: Make sure to call this method before `saveCurrentScan()` if you plan to
    ///         save the current scan; otherwise, the save may fail.
    public func recordingInfo() -> RecordingInfo {
        var cRecordingInfo = ARDK_Scanning_RecordingInfo()
        let cStatus = api.getRecordingInfo(nsdkHandle: nsdkHandle, recordingOut: &cRecordingInfo)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        return RecordingInfo(fromC: cRecordingInfo)
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
    public func saveCurrentScan(
        timeout: Double = 10.0,
        pollingInterval: TimeInterval = 0.1
    ) async throws -> SaveInfo {
        try saveRecording()

        let deadline = Date(timeIntervalSinceNow: timeout)
        while (true) {
            // Check for time-out
            if (Date() > deadline) {
                throw TimeoutError()
            }

            // Sleep before next poll. Will throw CancellationError if running Task is cancelled.
            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))

            // Poll the state of the save
            if let saveInfo = currentSaveInfo() {
                return saveInfo
            }
        }
    }

    // Start the save process. May throw `SaveError.noFrames`
    private func saveRecording() throws {
        let saveCode = api.saveRecording(nsdkHandle: nsdkHandle)
        if saveCode.isInvalidOperation {
            throw NSDKScanningSession.SaveError.noFrames
        } else if saveCode.isError {
            unexpectedNSDKStatus(saveCode)
        }
    }

    // Helper method to get saving state. It returns nil for any situation other than a
    // successfully saved scan.
    // NOTE: The discarded state is ignored because this is a helper method for getting
    // the state of saved, not discarded, scans.
    internal func currentSaveInfo() -> SaveInfo? {
        var cSave = ARDK_Scanning_SaveInfo()
        defer {
            if (cSave.handle != nil) {
                api.releaseResource(handle: cSave.handle)
            }
        }

        let cStatus = api.getSaveInfo(nsdkHandle: nsdkHandle, saveOut: &cSave)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        switch cSave.state {
        case ARDK_Scanning_SaveState_Saved:
            return SaveInfo(fromC: cSave)
        default:
            return nil
        }
    }

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
    public func exportArchive(metadata: [String: Any]? = nil, exportAsVideo: Bool = true) throws -> String? {
        var cArchive = ARDK_Scanning_Export()
        defer {
            if (cArchive.handle != nil) {
                api.releaseResource(handle: cArchive.handle)
            }
        }

        var jsonString = ""
        if let metadata = metadata {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: metadata, options: [])
                jsonString = String(data: jsonData, encoding: .utf8)!
            } catch {
                preconditionFailure("Non-nil value of argument `metadata` must be serializable into a JSON string.")
            }
        }

        let cStatus = jsonString.withCString { cStr in
            let ardk_str = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return api.exportArchive(nsdkHandle: nsdkHandle, metadataJson: ardk_str, exportAsVideo: exportAsVideo, exportOut: &cArchive)
        }

        if cStatus == ARDK_Status_InvalidOperation {
            throw NSDKError.invalidOperation
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if cArchive.handle != nil {
            // Assume C to gives us valid data for String constructor here
            let archivePath = String(ptr: cArchive.export_path, len: cArchive.export_path_len)
            return archivePath!
        }

        return nil
    }

    /// Exports the scan data as multiple archive files.
    ///
    /// This method processes the saved scan data and exports it to multiple archive files
    /// based on the maxFramesPerArchive parameter. Each archive will contain at most
    /// maxFramesPerArchive frames.
    ///
    /// - Note: This function is blocking and may take a while to execute.
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
    public func exportSplitArchive(metadata: [String: Any]? = nil, maxFramesPerArchive: Int, exportAsVideo: Bool = true) throws -> [String]? {
        var cSplitExport = ARDK_Scanning_Split_Export()
        defer {
            if (cSplitExport.handle != nil) {
                api.releaseResource(handle: cSplitExport.handle)
            }
        }

        var jsonString = ""
        if let metadata = metadata {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: metadata, options: [])
                jsonString = String(data: jsonData, encoding: .utf8)!
            } catch {
                preconditionFailure("Non-nil value of argument `metadata` must be serializable into a JSON string.")
            }
        }

        let cStatus = jsonString.withCString { cStr in
            let ardk_str = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return api.exportSplitArchive(nsdkHandle: nsdkHandle, metadataJson: ardk_str, maxFramesPerArchive: Int32(maxFramesPerArchive), exportAsVideo: exportAsVideo, exportOut: &cSplitExport)
        }

        if cStatus == ARDK_Status_InvalidOperation {
            throw NSDKError.invalidOperation
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if cSplitExport.handle != nil && cSplitExport.export_paths_size > 0 {
            // Convert the C ARDK_String array to Swift strings
            var archivePaths: [String] = []
            for i in 0..<Int(cSplitExport.export_paths_size) {
                let nsdkString = cSplitExport.export_paths![i]
                let path = String(ptr: nsdkString.data, len: nsdkString.data_size)
                archivePaths.append(path!)
            }
            return archivePaths
        }

        return nil
    }

    /// Get the most recently computed raycast buffers.
    ///
    /// Once the session has been started and all the requested data has been sent through the
    /// NSDKSession, a buffer should become available after a brief computation period.
    ///
    /// - Precondition: Raycast visualization must have been enabled in the configuration.
    /// - Returns: The most recently computed raycast buffers if available, nil if not.
    ///
    public func raycastBuffer() ->  RaycastBuffer? {
        var cBuffer = ARDK_Scanning_RaycastBuffer()
        let cStatus = api.getRaycastBuffer(nsdkHandle: nsdkHandle, raycastBufferOut: &cBuffer)

        if cStatus == ARDK_Status_InvalidOperation {
            preconditionFailure("Session was not successfully configured with raycast visualization enabled.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if cBuffer.handle != nil {
            let owner = api.createResourceOwner(handle: cBuffer.handle!)
            return RaycastBuffer(fromC: cBuffer, owner: owner)
        }

        return nil
    }

    /// Compute the voxelization of the scanned scene.
    ///
    /// Processing is asynchronous. Call this function and then call ``getVoxelBuffer()``
    /// to retrieve voxel data.
    ///
    /// - Precondition: Voxel visualization must have been enabled in the configuration.
    public func computeVoxels() {
        let cStatus = api.computeVoxels(nsdkHandle: nsdkHandle)
        if cStatus == ARDK_Status_InvalidOperation {
            preconditionFailure("Session was not successfully configured with voxel visualization enabled.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Get the most recently computed voxel data.
    ///
    /// Once the session has been started and all the requested data has been sent through the
    /// NSDKSession, a new buffer should become available after a brief computation period after
    /// ``computeVoxels()`` has been called.
    ///
    /// - Precondition: Voxel visualization must have been enabled in the configuration.
    /// - Returns: The most recently computed voxel data if available, nil if not.
    public func voxelBuffer() -> VoxelBuffer? {
        var cBuffer = ARDK_Scanning_VoxelBuffer()
        let cStatus = api.getVoxelBuffer(nsdkHandle: nsdkHandle, voxelBufferOut: &cBuffer)

        if cStatus == ARDK_Status_InvalidOperation {
            preconditionFailure(
                "Session must have been successfully configured with voxel visualization enabled."
            )
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if cBuffer.handle != nil {
            let owner = api.createResourceOwner(handle: cBuffer.handle!)
            return VoxelBuffer(fromC: cBuffer, owner: owner)
        }

        return nil
    }
}
