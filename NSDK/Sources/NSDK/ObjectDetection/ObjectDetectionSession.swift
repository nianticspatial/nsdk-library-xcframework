import CArdk
import UIKit
import Foundation

extension NSDKSession {
    public func createObjectDetectionSession() -> NSDKObjectDetectionSession {
        let key = ObjectIdentifier(NSDKObjectDetectionSession.self)
        if let existing = disposables[key] as? NSDKObjectDetectionSession {
            return existing
        }
        let session = NSDKObjectDetectionSession(nsdkHandle: nativeHandle, api: CObjectDetectionApi())
        disposables[key] = (session)
        return session
    }
}

public final class NSDKObjectDetectionSession: NSDKSession.IDisposable, NSDKFeatureSession {
    private let nsdkHandle: NSDKHandle
    private let api: ObjectDetectionApi

    // Backing variables
    private var _sourceFrameSize: CGSize?
    private var _modelFrameSize: CGSize?
    private var _classNames: ObjectDetectionClassNamesBuffer?

    /// Returns the list of possible object detection classifications, if available.
    /// Reads from the currently loaded native model and returns its data.
    ///
    /// - Returns: The list of possible object detection classifications, or `nil` if not available.
    public var classNames: ObjectDetectionClassNamesBuffer? {
        if let cachedNames = _classNames { return cachedNames }

        var buffer = ARDK_ObjectDetectionClassNamesBuffer()
        let cStatus = api.getClassNames(nsdkHandle: nsdkHandle, bufferOut: &buffer)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }

        if buffer.status == ARDK_Awareness_Status_Available {
            let resourceOwner = ResourceHandleOwner(handle: buffer.handle)
            _classNames = ObjectDetectionClassNamesBuffer.init(fromC: buffer, resourceOwner: resourceOwner)
        }

        return _classNames
    }

    /// Gets the size of the image submitted to the object detection predictor (input) and
    /// the coordinate frame that the model outputs are defined in (output). Caches these values
    /// to be returned on subsequent calls
    ///
    /// - Returns: The input and output frame sizes of the object detection models, or `nil` if not available.
    private func getFrameSizes() -> (input: CGSize, output: CGSize)? {
        // Return cached values if available
        if let inputSize = _sourceFrameSize, let outputSize = _modelFrameSize {
            return (input: inputSize, output: outputSize)
        }

        let metadataResult = metadata()

        guard case .success(let objectDetectionMetadata) = metadataResult else {
            switch metadataResult {
            case .inProgress(nil):
                print("Object detection metadata not ready to get frame sizes")
            case .failure(let error):
                print("Object detection metadata returned with error: \(error)")
            default:
                break
            }
            return nil
        }

        let inputSize = CGSize(
            width: CGFloat(objectDetectionMetadata.imageParams.sourceFrameWidth),
            height: CGFloat(objectDetectionMetadata.imageParams.sourceFrameHeight)
        )

        let outputSize = CGSize(
            width: CGFloat(objectDetectionMetadata.imageParams.modelFrameWidth),
            height: CGFloat(objectDetectionMetadata.imageParams.modelFrameHeight)
        )

        // Cache the values
        _sourceFrameSize = inputSize
        _modelFrameSize = outputSize

        return (input: inputSize, output: outputSize)
    }

    /// Returns an affine transform that maps coordinates from the model's frame to the image frame,
    /// accounting for the model image being rotated to align with gravity, while the source image
    /// is always oriented in landscape.
    ///
    /// - Parameter orientation: The gravity aligned interface orientation.
    /// - Returns: A `CGAffineTransform` to convert model coordinates to image coordinates,
    ///            or `nil` if the model frame size, source frame size, or orientation is unavailable.
    public func modelToImageTransform(forPhysicalOrientation orientation: UIInterfaceOrientation) -> CGAffineTransform? {
        guard let (sourceFrame, modelFrame) = getFrameSizes() else {
            return nil
        }

        return ImageMath.viewRotation(fromOrientation: .landscapeLeft, toOrientation: orientation)
            .concatenating(ImageMath.affineCrop(source: sourceFrame, target: modelFrame))
    }

    /// Creates and initializes a new object detection feature instance in the NSDK runtime.
    ///
    /// - Parameters:
    ///   - nsdkHandle: The handle to the initialized NSDK instance.
    ///   - api: The C API interface for object detection.
    internal init(nsdkHandle: NSDKHandle, api: ObjectDetectionApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        let cStatus = api.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    /// Destroys the native object detection feature instance.
    internal func destroy() {
        let cStatus = api.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    /// Reports the current status of the object detection feature.
    ///
    /// This method can be used to detect errors that have occurred within the feature’s
    /// internal processes. Once an error is flagged, it will remain flagged until the
    /// relevant process has been rerun and completed successfully.
    ///
    /// Typical usage is to call this at the beginning of a session to check whether
    /// object detection is still initializing or if a previous failure has occurred.
    ///
    /// - Returns: An `NSDKFeatureStatus` value
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

        if cStatus.isError { throw NSDKError(fromC: cStatus) }
    }

    /// Starts the object detection session.
    public func start() {
        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    /// Stops the object detection session.
    /// After stopping, the session can be reconfigured and restarted.
    public func stop() {
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    /// Retrieves the latest object detection results from the object detection session.
    ///
    /// - Returns: An `NSDKAsyncState` containing either the latest `ObjectDetectionResult`,
    ///  or an `AwarenessError`.
    public func latestDetections() -> NSDKAsyncState<ObjectDetectionResult, AwarenessError> {
        var cResult = ARDK_ObjectDetectionResult()
        let cStatus = api.getLatestObjectDetection(nsdkHandle: nsdkHandle, resultOut: &cResult)

        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            return .success(ObjectDetectionResult(fromC: cResult, owner: api.createResourceOwner(handle: cResult.handle!)))
        } else if cResult.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cResult.status))
        }
    }

    /// Retrieves the metadata for object detection.
    ///
    /// - Returns: An `NSDKAsyncState` containing either the latest `ObjectDetectionMetadata`,
    ///  or an `AwarenessError`.
    public func metadata() -> NSDKAsyncState<ObjectDetectionMetadata, AwarenessError> {
        var cMetadata = ARDK_ObjectDetection_Metadata()
        let cStatus = api.getMetadata(nsdkHandle: nsdkHandle, metadataOut: &cMetadata)

        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }

        if cMetadata.status == ARDK_Awareness_Status_Available {
            return .success(ObjectDetectionMetadata(fromC: cMetadata))
        } else if cMetadata.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cMetadata.status))
        }
    }
}
