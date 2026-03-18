import Foundation
import ARKit
import CoreGraphics
import CoreImage
import CoreVideo

// MARK: - FrameMetadata conversion (PlaybackDataset utility)
//
// Extensions convert **PlaybackDataset.FrameMetadata** (arrays, strings) into Swift/ARKit types:
// cameraTransform (simd_float4x4), cameraIntrinsics (simd_float3x3), trackingState (ARCamera.TrackingState),
// orientation (UIInterfaceOrientation), etc. Also CGImage → CVPixelBuffer.
// Relation to Apple AR: **Bridges** recorded data into the types the rest of the stack expects (e.g. so
// PlaybackCamera and delegates see ARCamera-like data). Does not replace or drive Apple components.

extension PlaybackDataset.FrameMetadata {

    /// Converts the frame's tracking state integer from the dataset into ARCamera.TrackingState.
    /// Allows playback code to use the same tracking API as live AR. Mapping matches Unity ARFoundation:
    /// 0 → notAvailable, 1 → limited(insufficientFeatures), 2 (or other) → normal.
    public var trackingState: ARCamera.TrackingState {
        switch tracking {
        case 0:
            return .notAvailable
        case 1:
            return .limited(.insufficientFeatures)
        default:
            return .normal
        }
    }
    
    /// Converts the frame's pose4x4 array (16 floats, column-major) into a simd_float4x4 camera-to-world transform.
    /// Returns zero matrix if the array does not have exactly 16 elements.
    public var cameraTransform: simd_float4x4 {
        guard pose4x4.count == 16 else {
            return simd_float4x4(0)
        }
        return simd_float4x4(
            SIMD4<Float>(Float(pose4x4[0]), Float(pose4x4[1]), Float(pose4x4[2]), Float(pose4x4[3])),
            SIMD4<Float>(Float(pose4x4[4]), Float(pose4x4[5]), Float(pose4x4[6]), Float(pose4x4[7])),
            SIMD4<Float>(Float(pose4x4[8]), Float(pose4x4[9]), Float(pose4x4[10]), Float(pose4x4[11])),
            SIMD4<Float>(Float(pose4x4[12]), Float(pose4x4[13]), Float(pose4x4[14]), Float(pose4x4[15]))
        )
    }
    
    /// Converts the frame's intrinsics array (at least 5 elements: fx, fy, cx, cy, s) into a 3×3 pinhole intrinsics matrix.
    /// Layout is [fx, 0, 0; 0, fy, 0; cx, cy, 1]. The 5th parameter (skew/distortion) is not used in the matrix.
    /// Returns zero matrix if the array has fewer than 5 elements.
    public var cameraIntrinsics: simd_float3x3 {
        guard intrinsics.count >= 5 else {
            return simd_float3x3(0)
        }
        let fx = Float(intrinsics[0])
        let fy = Float(intrinsics[1])
        let cx = Float(intrinsics[2])
        let cy = Float(intrinsics[3])
        return simd_float3x3(
            SIMD3<Float>(fx, 0, 0),
            SIMD3<Float>(0, fy, 0),
            SIMD3<Float>(cx, cy, 1)
        )
    }
    
    /// Converts the frame's screen orientation string (e.g. "portrait", "landscapeleft") to UIInterfaceOrientation.
    /// Used to know how the recording was held so viewport and projection can match. Returns nil if metadata has no orientation.
    public var orientation: UIInterfaceOrientation? {
        guard let orientationString = screenOrientation else {
            return nil
        }
        
        switch orientationString.lowercased() {
        case "portrait":
            return .portrait
        case "portraitupsidedown":
            return .portraitUpsideDown
        case "landscapeleft":
            return .landscapeLeft
        case "landscaperight":
            return .landscapeRight
        default:
            return .unknown
        }
    }
    
    /// Builds NsdkFrameData.CompassData from the frame's location metadata when heading data is present; otherwise nil.
    public var compassData: NSDKFrameData.CompassData? {
        guard let location = location,
              let heading = location.heading,
              let headingAccuracy = location.headingAccuracy,
              let headingTimestamp = location.headingTimestamp else { return nil }
        return NSDKFrameData.CompassData(
            timestampMs: UInt64(headingTimestamp * 1000),
            headingAccuracy: Float(headingAccuracy),
            trueHeading: Float(heading)
        )
    }
    
    /// Builds NsdkFrameData.GpsData when location and latitude/longitude are present; otherwise nil. Uses 0 for other missing fields.
    public var gpsData: NSDKFrameData.GpsData? {
        guard let location = location,
              let latitude = location.latitude,
              let longitude = location.longitude else { return nil }
        return NSDKFrameData.GpsData(
            timestampMs: UInt64((location.positionTimestamp ?? 0) * 1000),
            latitude: latitude,
            longitude: longitude,
            altitude: location.altitude ?? 0,
            verticalAccuracy: Float(location.altitudeAccuracy ?? 0),
            horizontalAccuracy: Float(location.positionAccuracy ?? 0)
        )
    }
    
    /// Frame timestamp in milliseconds (from metadata timestamp × 1000).
    public var cameraTimestampMs: UInt64 {
        UInt64(timestamp * 1000)
    }
    
    /// Camera image width in pixels (first element of resolution array).
    public var cameraImageWidth: UInt32 {
        guard resolution.count >= 1 else { return 0 }
        return UInt32(resolution[0])
    }
    
    /// Camera image height in pixels (second element of resolution array).
    public var cameraImageHeight: UInt32 {
        guard resolution.count >= 2 else { return 0 }
        return UInt32(resolution[1])
    }
    
    /// Builds NSDKFrameData.CameraIntrinsics (intrinsics matrix plus width/height) for passing to the native SDK.
    public var nsdkCameraIntrinsics: NSDKFrameData.CameraIntrinsics {
        NSDKFrameData.CameraIntrinsics(
            intrinsics: cameraIntrinsics,
            width: cameraImageWidth,
            height: cameraImageHeight
        )
    }
}

// MARK: - CGImage Extension for CVPixelBuffer Conversion

extension CGImage {
    
    /// Converts the CGImage to a CVPixelBuffer in YUV420NV12 (bi-planar) format for use as a camera feed.
    /// Uses Core Image to perform the color conversion. Returns nil if buffer creation or render fails.
    /// - Parameters:
    ///   - width: Target width for the pixel buffer (typically the image width).
    ///   - height: Target height for the pixel buffer (typically the image height).
    public func toYUV420PixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, // YUV420NV12 format
            attributes as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("Failed to create CVPixelBuffer: \(status)")
            return nil
        }
        
        let ciContext = CIContext()
        let ciImage = CIImage(cgImage: self)
        ciContext.render(ciImage, to: buffer)
        
        return buffer
    }
}
