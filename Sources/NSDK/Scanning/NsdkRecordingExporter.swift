import CArdk
import Foundation

/// Resolution option for exported scan images.
///
/// When exporting a recording, this controls which image resolutions are included in the payload.
public enum ExportResolution: UInt32 {
    /// Export both 720p and high resolution images when available.
    case mixed = 0
    /// Export only the 720p resolution image.
    case res720_540 = 1
    /// Export only the high resolution image when available.
    /// This is the same resolution as the camera frame passed to NSDKSession.sendFrame
    case high = 2

    var toC: NSDK_ExportResolution {
        NSDK_ExportResolution(rawValue)
    }
}

extension NSDKSession {
    /// Creates a new Recording Exporter session.
    ///
    /// Recording Export enables the conversion and export of saved scan recordings
    /// to various formats for external processing or sharing. This session manages
    /// the export workflow from scan selection through format conversion and output.
    ///
    /// - Returns: A new Recording Exporter session attached to this NSDK session
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireRecordingExporter() -> NSDKRecordingExporter {
        let key = ObjectIdentifier(NSDKRecordingExporter.self)
        if let existing = disposables[key] as? NSDKRecordingExporter {
            return existing
        }
        let exporter = NSDKRecordingExporter(nsdkHandle: nativeHandle, api: CRecordingExportApi())
        disposables[key] = exporter
        return exporter
    }
}

/// A session for exporting scan recordings to various formats.
///
/// `NSDKRecordingExporter` provides capabilities for converting saved scan data
/// into recorderV2 format for use in Unity Playback or activating VPS.
///
public final class NSDKRecordingExporter: NSDKSession.IDisposable {

    private let nsdkHandle: NSDKHandle
    private let api: RecordingExportApi

    init(nsdkHandle: NSDKHandle, api: RecordingExportApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        _ = api.create(nsdkHandle: nsdkHandle)
    }

    func destroy() {
        _ = api.destroy(nsdkHandle: nsdkHandle)
    }

    /// Exports a scan recording asynchronously.
    ///
    /// Starts the export process for a scan recording and suspends until the export
    /// completes successfully, fails, or times out.
    ///
    /// - Parameters:
    ///   - scanPath: The path to the directory containing the raw scan files to export. This
    ///     is obtained from the return value of``NSDKScanningSession/saveInfo()``.
    ///     The export will be written to a .tgz file inside this directory.
    ///   - scanId: The unique identifier of the scan to export.
    ///   - userData: Dictionary containing custom metadata to include in the export.
    ///   - exportAsVideo: If true, the RGB frames in the scan will be exported as an
    ///                    .mp4 video. If false, they will be individual image files.
    ///   - exportResolution: Resolution option for exported images (default: ``ExportResolution/high``).
    ///   - pollingInterval: Time between progress checks (default: 0.5s).
    ///   - timeout: Maximum duration to wait before failing (default: 5 minutes).
    /// - Returns: The file path to the exported recording.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    public func export(
        scanDirPath: String,
        scanId: String,
        userData: [String: Any] = [:],
        exportAsVideo: Bool = true,
        exportResolution: ExportResolution = .high,
        pollingInterval: TimeInterval = 0.1,
        timeout: TimeInterval = 300.0,
        progressCallback: ((Float) -> Void)? = nil
    ) async throws -> String {
        try startExport(scanDirPath: scanDirPath, scanId: scanId, userData: userData, exportAsVideo: exportAsVideo, maxFramesPerArchive: Int32.max, exportResolution: exportResolution)

        defer {
            _ = close(scanId: scanId)
        }

        let startTime = Date()
        var lastProgress: Float = 0.0

        while true {
            try Task.checkCancellation()

            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }

            // Only report progress updates when there's a meaningful change
            let currentProgress = try getExportProgress(scanId: scanId)
            if abs(currentProgress - lastProgress) > 0.01 {
                lastProgress = currentProgress
                progressCallback?(currentProgress)
            }

            if try isComplete(scanId: scanId) {
                break
            }

            try await Task.sleep(seconds: pollingInterval)
        }

        // Retrieve final path
        let paths = try getExportedPaths(scanId: scanId)
        guard let path = paths.first else {
            throw NSDKError.unknown(msg: "Export completed but no paths were returned.")
        }

        progressCallback?(1.0)
        return path
    }

    /// Exports a scan recording as multiple archive files asynchronously.
    ///
    /// Starts the export process for a scan recording and suspends until the export
    /// completes successfully, fails, or times out.
    ///
    /// - Parameters:
    ///   - scanPath: The path to the directory containing the raw scan files to export. This
    ///     is obtained from the return value of``NSDKScanningSession/saveInfo()``.
    ///     The export will be written to a .tgz file inside this directory.
    ///   - scanId: The unique identifier of the scan to export.
    ///   - maxFramesPerArchive: The maximum number of frames to include in each archive of the
    ///                        exported recording. Must be greater than 0.
    ///   - userData: Dictionary containing custom metadata to include in the export.
    ///   - exportAsVideo: If true, the RGB frames in the scan will be exported as an
    ///                    .mp4 video. If false, they will be individual image files.
    ///   - exportResolution: Resolution option for exported images (default: ``ExportResolution/high``).
    ///   - pollingInterval: Time between progress checks (default: 0.5s).
    ///   - timeout: Maximum duration to wait before failing (default: 5 minutes).
    /// - Returns: A list of file paths to the exported recording.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    public func exportSplitArchives(
        scanDirPath: String,
        scanId: String,
        maxFramesPerArchive: Int32,
        userData: [String: Any] = [:],
        exportAsVideo: Bool = true,
        exportResolution: ExportResolution = .high,
        pollingInterval: TimeInterval = 0.1,
        timeout: TimeInterval = 300.0,
        progressCallback: ((Float) -> Void)? = nil
    ) async throws -> [String] {
        try startExport(scanDirPath: scanDirPath, scanId: scanId, userData: userData, exportAsVideo: exportAsVideo, maxFramesPerArchive: maxFramesPerArchive, exportResolution: exportResolution)

        defer {
            _ = close(scanId: scanId)
        }

        let startTime = Date()
        var lastProgress: Float = 0.0

        while true {
            try Task.checkCancellation()

            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }

            // Only report progress updates when there's a meaningful change
            let currentProgress = try getExportProgress(scanId: scanId)
            if abs(currentProgress - lastProgress) > 0.01 {
                lastProgress = currentProgress
                progressCallback?(currentProgress)
            }

            if try isComplete(scanId: scanId) {
                break
            }

            try await Task.sleep(seconds: pollingInterval)
        }

        let paths = try getExportedPaths(scanId: scanId)

        progressCallback?(1.0)
        return paths
    }

    /// Starts the export process for a scan recording.
    ///
    /// This method begins the conversion of a saved scan recording to an exportable format.
    /// The export process runs asynchronously, and you should use `isComplete` to monitor
    /// progress and `getExportedPaths` to retrieve the result.
    ///
    /// - Parameters:
    ///   - scanDirPath: The path to the directory containing the raw scan files to export. This
    ///     is obtained from the return value of``NSDKScanningSession/saveInfo()``.
    ///     The export will be written to a .tgz file inside this directory.
    ///   - scanId: The unique identifier of the scan to export
    ///   - userData: Dictionary containing custom metadata to include in the export
    ///   - exportAsVideo: If true, the RGB frames in the scan will be exported as an
    ///                    .mp4 video. If false, they will be individual image files.
    ///   - maxFramesPerArchive: The maximum number of frames to include in each archive of the
    ///                        exported recording. Must be greater than 0.
    ///   - exportResolution: Resolution option for exported images (default: ``ExportResolution/high``).
    /// - Throws:
    ///   - ``NSDKError.invalidArgument`` if no scan with `scanId` exists
    ///   - ``NSDKError.nullArgument`` if `scanId` is empty
    internal func startExport(scanDirPath: String, scanId: String, userData: [String: Any], exportAsVideo: Bool = true, maxFramesPerArchive: Int32 = Int32.max, exportResolution: ExportResolution = .high) throws {
        if !JSONSerialization.isValidJSONObject(userData) {
            throw NSDKError.invalidArgument
        }

        let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!

        let cStatus = scanDirPath.withCString { basePathCStr in
            scanId.withCString { scanIdCStr in
                jsonString.withCString { userDataCStr in
                    let basePathArdk = ARDK_String(data: basePathCStr, data_size: UInt32(strlen(basePathCStr)))
                    let scanIdArdk = ARDK_String(data: scanIdCStr, data_size: UInt32(strlen(scanIdCStr)))
                    let userDataArdk = ARDK_String(data: userDataCStr, data_size: UInt32(strlen(userDataCStr)))

                    return api.startExport(
                        nsdkHandle: nsdkHandle,
                        scanDirPath: basePathArdk,
                        scanId: scanIdArdk,
                        userDataStr: userDataArdk,
                        exportAsVideo: exportAsVideo,
                        maxFramesPerArchive: maxFramesPerArchive,
                        exportResolution: exportResolution.toC
                    )
                }
            }
        }

        if cStatus.isArgumentError {
            throw NSDKError(fromC: cStatus)
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }


    /// Checks if the export for the specified scan is complete.
    ///
    /// This method polls the current status of an export operation. Use this to monitor
    /// progress of long-running exports and determine when results are ready.
    ///
    /// - Parameter scanId: The unique identifier of the scan being exported
    /// - Returns: A tuple containing the operation status and completion state if successful
    /// - Throws:
    ///   - ``NSDKError.invalidArgument`` if no scan with `scanId` exists
    ///   - ``NSDKError.nullArgument`` if `scanId` is empty
    internal func isComplete(scanId: String) throws -> Bool {
        var isComplete: Bool = false

        let cStatus = scanId.withCString { scanIdCStr in
            let scanIdArdk = ARDK_String(data: scanIdCStr, data_size: UInt32(strlen(scanIdCStr)))
            return api.isComplete(nsdkHandle: nsdkHandle, scanId: scanIdArdk, isComplete: &isComplete)
        }

        if cStatus.isArgumentError {
            throw NSDKError(fromC: cStatus)
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        return isComplete
    }

    /// Gets the current export progress for the specified scan.
    ///
    /// This method returns the progress of the export operation as a value between 0.0 and 1.0,
    /// where 0.0 represents the start of the export and 1.0 represents completion.
    /// Use this to provide progress feedback to users during long-running exports.
    ///
    /// - Parameter scanId: The unique identifier of the scan being exported
    /// - Returns: The progress value, ranging from 0.0 to 1.0
    /// - Throws:
    ///   - ``NSDKError.invalidArgument`` if no scan with `scanId` exists
    ///   - ``NSDKError.nullArgument`` if `scanId` is empty
    internal func getExportProgress(scanId: String) throws -> Float {
        var progress: Float = 0.0

        let cStatus = scanId.withCString { scanIdCStr in
            let scanIdArdk = ARDK_String(data: scanIdCStr, data_size: UInt32(strlen(scanIdCStr)))
            return api.getExportProgress(nsdkHandle: nsdkHandle, scanId: scanIdArdk, progress: &progress)
        }

        if cStatus.isArgumentError {
            throw NSDKError(fromC: cStatus)
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        return progress
    }

    /// Retrieves all file paths of the completed export.
    ///
    /// This method returns an array of paths to the exported archive files once the export
    /// operation has completed successfully. When an export is split across multiple archives
    /// (based on `maxFramesPerArchive`), this will contain multiple paths, one for each archive.
    /// Call this only after ``isComplete`` returns true.
    ///
    /// - Parameter scanId: The unique identifier of the scan that was exported
    /// - Returns: An array of export file paths
    /// - Throws:
    ///   - ``NSDKError.invalidArgument`` if no scan with `scanId` exists
    ///   - ``NSDKError.nullArgument`` if `scanId` is empty
    ///   - ``NSDKError.invalidOperation`` if the scan has not yet completed.
    ///   Before calling this method, check whether paths are available by calling
    ///   ``isComplete(scanId:)``.
    internal func getExportedPaths(scanId: String) throws -> [String] {
        var cPaths = ARDK_RecordingExportPaths()
        defer {
            if cPaths.handle != nil {
                api.releaseResource(handle: cPaths.handle)
            }
        }

        let cStatus = scanId.withCString { scanIdCStr in
            let scanIdArdk = ARDK_String(data: scanIdCStr, data_size: UInt32(strlen(scanIdCStr)))
            return api.getExportedPaths(nsdkHandle: nsdkHandle, scanId: scanIdArdk, exportedPaths: &cPaths)
        }

        if cStatus.isArgumentError || cStatus.isInvalidOperation {
            throw NSDKError(fromC: cStatus)
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        guard cPaths.paths != nil, cPaths.num_paths > 0 else {
            throw NSDKError.unknown(msg: "Native call in getExportedPaths unexpectedly returned no paths.")
        }

        var paths: [String] = []
        for i in 0..<Int(cPaths.num_paths) {
            let nsdkString = cPaths.paths[i]
            guard let path = String(nsdkStr: nsdkString) else {
                throw NSDKError.unknown(msg: "Native call in getExportedPaths returned an invalid path at index \(i).")
            }
            paths.append(path)
        }

        return paths
    }

    /// Closes and cleans up resources for the specified scan export.
    ///
    /// This method releases all resources associated with an export operation.
    /// You can use this method to cancel an ongoing export, or release the resources after
    /// the export is complete. After calling this method, other operations on the same scanId
    /// will become invalid.
    ///
    /// If the `scanId` is invalid, the function will no-op.
    ///
    /// - Parameter scanId: The unique identifier of the scan export to close
    internal func close(scanId: String) {
        let cStatus = scanId.withCString { scanIdCStr in
            let scanIdArdk = ARDK_String(data: scanIdCStr, data_size: UInt32(strlen(scanIdCStr)))
            return api.close(nsdkHandle: nsdkHandle, scanId: scanIdArdk)
        }

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }
}
