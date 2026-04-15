import ARKit

/// Utility functions for AR and device capability detection.
///
/// `ARUtils` provides helper methods for detecting device capabilities
/// and AR features that are relevant to NSDK functionality.
public struct ARUtils {
    /// Checks if LiDAR depth is available on the current device.
    /// 
    /// LiDAR depth data significantly improves the accuracy of NSDK features 
    /// such as device mapping, scanning, and localization.
    ///
    /// - Returns: `true` if LiDAR is available and supported, `false` otherwise
    ///
    /// ## Example
    ///
    /// ```swift
    /// if ARUtils.isLidarAvailable() {
    ///     print("LiDAR is available - enhanced depth sensing enabled")
    ///     // Configure NSDK to use LiDAR data
    ///     let session = NSDKSession(apiKey: "your-key", useLidar: true)
    /// } else {
    ///     print("LiDAR not available - using alternative depth methods")
    ///     let session = NSDKSession(apiKey: "your-key", useLidar: false)
    /// }
    /// ```
    ///
    /// ## Device Support
    ///
    /// LiDAR is available on:
    /// - iPad Pro (4th generation and later)
    /// - iPhone 12 Pro and iPhone 12 Pro Max
    /// - iPhone 13 Pro and iPhone 13 Pro Max
    /// - iPhone 14 Pro and iPhone 14 Pro Max
    /// - iPhone 15 Pro and iPhone 15 Pro Max
    public static func isLidarAvailable() -> Bool {
        if #available(iOS 14.0, *) {
            return ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
        } else {
            // LiDAR was first introduced with iOS 14
            return false
        }
    }
}

public extension ARCamera {
    /// Returns the camera pose in world space corresponding to the current frame, with its basis
    /// vectors reoriented to match the specified UI interface orientation.
    /// - Parameter orientation: The current logical interface orientation of the app’s UI.
    /// - Returns: A camera-to-world transform in world coordinates.
    public func displayOrientedTransform(orientation: UIInterfaceOrientation) -> simd_float4x4 {
        return viewMatrix(for: orientation).inverse
    }
}

