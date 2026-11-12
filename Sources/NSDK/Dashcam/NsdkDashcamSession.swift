// Copyright 2022-2026 Niantic.

import CArdk
import Foundation

extension NSDKSession {
    /// Creates a new dashcam session.
    ///
    /// - Returns: A new dashcam session attached to this NSDK session.
    public func createDashcamSession() -> NSDKDashcamSession {
        let key = ObjectIdentifier(NSDKDashcamSession.self)
        if let existing = disposables[key] as? NSDKDashcamSession {
            return existing
        }
        let session = NSDKDashcamSession(nsdkHandle: nativeHandle, api: CDashcamApi())
        disposables[key] = session
        return session
    }
}

/// A session for continuous frame buffering and on-demand save functionality.
///
/// The dashcam feature captures frames into a circular buffer while running.
/// At any point, the buffer contents can be saved to disk as a V2 sequence
/// for later playback or upload. This is useful for capturing context around
/// events of interest without requiring the user to explicitly start recording
/// in advance.
public final class NSDKDashcamSession: NSDKSession.IDisposable, NSDKFeatureSession {
    private let nsdkHandle: NSDKHandle
    private let api: DashcamApi

    /// Whether buffering is running, so a second `start()` can be refused.
    private var isActive = false

    init(nsdkHandle: NSDKHandle, api: DashcamApi) {
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

    /// Reports errors that have occurred within the dashcam feature.
    ///
    /// Check this periodically to monitor the health of the dashcam.
    /// Once an error has been flagged, it remains until the process
    /// runs again and completes successfully.
    ///
    /// - Returns: Feature status flags for any issues that have occurred.
    public func featureStatus() -> NSDKFeatureStatus {
        let flags = api.getFeatureStatus(nsdkHandle: nsdkHandle)
        return NSDKFeatureStatus(rawValue: flags.rawValue)
    }

    /// Configures the dashcam with the specified settings.
    ///
    /// - Attention: Must be called while the dashcam is stopped.
    /// - Parameter config: Configuration defining buffer limits, framerate, and output path.
    /// - Throws: ``NSDKError.invalidArgument`` if the configuration is invalid.
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
    }

    /// Starts buffering frames.
    ///
    /// The dashcam will continuously capture and buffer sensor data
    /// from the frame pipeline.
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

    /// Stops buffering frames.
    ///
    /// The buffer is cleared. Saving is not allowed while stopped.
    public func stop() {
        // Reset state first, so a failed stop cannot leave the session permanently
        // unable to start again.
        isActive = false

        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    /// Returns information about the current buffer state.
    ///
    /// - Returns: A ``BufferInfo`` with frame count, memory usage, and duration.
    public func bufferInfo() -> BufferInfo {
        var cInfo = ARDK_Dashcam_BufferInfo()
        let cStatus = api.getBufferInfo(nsdkHandle: nsdkHandle, infoOut: &cInfo)

        if cStatus.isError {
            // `cInfo` was never written, so do not convert it.
            return nsdkUnexpected(cStatus, returning: .empty)
        }

        return BufferInfo(fromC: cInfo)
    }

    /// Triggers a save of the current buffer contents to disk as a V2 sequence.
    ///
    /// This is an asynchronous operation. The dashcam continues buffering
    /// new frames during the save. Use ``saveBuffer(timeout:pollingInterval:)``
    /// for an async/await wrapper that polls to completion.
    ///
    /// - Throws: ``NSDKError.invalidOperation`` if no frames are in the buffer.
    private func triggerSave() throws {
        let cStatus = api.triggerSave(nsdkHandle: nsdkHandle)
        if cStatus.isInvalidOperation {
            throw NSDKError.invalidOperation
        } else if cStatus.isError {
            throw nsdkUnexpectedError(cStatus)
        }
    }

    /// Polls the result of the most recent save operation.
    ///
    /// - Returns: The current ``SaveResult``, or `nil` if no result is available yet.
    private func currentSaveResult() -> SaveResult? {
        var cResult = ARDK_Dashcam_SaveResult()
        defer {
            if cResult.handle != nil {
                api.releaseResource(handle: cResult.handle)
            }
        }

        let cStatus = api.getSaveResult(nsdkHandle: nsdkHandle, resultOut: &cResult)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: nil)
        }

        let result = SaveResult(fromC: cResult)
        switch result.state {
        case .notAvailable:
            return nil
        default:
            return result
        }
    }

    /// Saves the current buffer contents and waits for completion.
    ///
    /// - Parameters:
    ///   - timeout: Maximum duration in seconds to wait (default 30 seconds).
    ///   - pollingInterval: Interval in seconds between progress checks (default 0.5 seconds).
    /// - Returns: The ``SaveResult`` containing the save path on success.
    /// - Throws:
    ///   - ``NSDKError.invalidOperation`` if the buffer is empty.
    ///   - ``TimeoutError`` if the save does not complete within the timeout.
    ///   - ``CancellationError`` if the running Task is cancelled.
    ///   - ``SaveError.saveFailed`` if the native save operation failed.
    /// - Important: Runs on the main actor, where the session is created and started.
    @MainActor
    public func saveBuffer(
        timeout: Double = 30.0,
        pollingInterval: TimeInterval = 0.5
    ) async throws -> SaveResult {
        try triggerSave()

        let deadline = Date(timeIntervalSinceNow: timeout)
        while true {
            if Date() > deadline {
                throw TimeoutError()
            }

            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))

            if let result = currentSaveResult() {
                if result.state == .failed {
                    throw SaveError.saveFailed
                }
                return result
            }
        }
    }

    /// Errors specific to dashcam save operations.
    public enum SaveError: Error {
        /// The native save operation reported a failure.
        case saveFailed
    }
}
