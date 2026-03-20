import Foundation
import CoreVideo
import simd

public typealias NSDKCameraIntrinsics = NSDKFrameData.CameraIntrinsics
public typealias NSDKCameraExtrinsics = simd_float4x4

/// Provides synchronous, pull-based access to the latest available sensor data
/// required by `NSDKSession`.
///
/// All methods must be non-blocking and thread-safe. Returned values represent
/// the most recent samples already captured by the underlying services.
public protocol NSDKSessionDataSource: AnyObject {

    /// Indicates whether the data source is currently able to provide
    /// meaningful sensor data.
    var isReady: Bool { get }

    /// Returns the most recent camera sample, if available.
    ///
    /// - Returns: A tuple containing:
    ///   - image: A retained `CVPixelBuffer` representing the captured image.
    ///   - intrinsics: Camera intrinsic parameters for the image.
    ///   - pose: The pose (extrinsics) of the camera associated with the image.
    ///   - orientation: The device orientation of the camera associated with the image.
    ///   - timestamp: Camera timestamp in milliseconds.
    func latestCameraSample()
    -> (image: CVPixelBuffer,
        intrinsics: NSDKCameraIntrinsics,
        pose: NSDKCameraExtrinsics,
        orientation: NSDKScreenOrientation,
        timestamp: UInt64)?

    /// Returns the most recent platform depth sample, if available.
    ///
    /// - Returns: A tuple containing:
    ///   - image: A retained `CVPixelBuffer` representing the captured image.
    ///   - confidence: A pixel buffer containing the confidence level for each depth value in the `image`.
    ///   - intrinsics: Camera intrinsic parameters for the image.
    ///   - pose: The pose (extrinsics) of the camera associated with the image.
    ///   - orientation: The device orientation of the camera associated with the image.
    ///   - timestamp: Camera timestamp in milliseconds.
    func latestDepthMapSample()
    -> (image: CVPixelBuffer,
        confidence: CVPixelBuffer?,
        intrinsics: NSDKCameraIntrinsics,
        pose: NSDKCameraExtrinsics,
        orientation: NSDKScreenOrientation,
        timestamp: UInt64)?

    /// Returns the most recent GPS sample, if available.
    func latestGpsSample() -> NSDKFrameData.GpsData?

    /// Returns the most recent compass (heading) sample, if available.
    func latestCompassSample() -> NSDKFrameData.CompassData?

    /// Returns the most recent VIO tracking state report
    func latestTrackingStateSample() -> NsdkTrackingState
}

/// Type alias for API compatibility.
public typealias NsdkSessionDataSource = NSDKSessionDataSource
