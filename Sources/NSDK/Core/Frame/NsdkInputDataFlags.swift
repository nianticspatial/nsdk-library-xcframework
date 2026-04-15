/// Flags indicating which types of input data are required by NSDK.
///
/// `NSDKInputDataFlags` is an option set that specifies which data types
/// should be included in frames sent to NSDK. Use `getRequestedDataInputs()`
/// to determine which data is currently needed, then include only the
/// requested data types in your frame data for optimal performance.
///
/// ## Overview
///
/// NSDK features dynamically request different types of input data based on:
/// - Which features are active (VPS2, scanning, mapping)
/// - Current processing state and requirements
/// - Device capabilities and available sensors
///
/// ## Example Usage
///
/// ```swift
/// let requiredInputs = nsdkSession.getRequestedDataInputs()
/// var frameData = NSDKFrameData()
///
/// if requiredInputs.contains(.pose) {
///     frameData.cameraTransform = currentPose
/// }
/// if requiredInputs.contains(.cameraImage) {
///     frameData.cameraPlane0 = cameraPlane
/// }
/// if requiredInputs.contains(.platformDepth) {
///     frameData.depthData = depthBuffer
/// }
///
/// nsdkSession.sendFrame(frameData)
/// ```
public struct NSDKInputDataFlags: OptionSet, CustomDebugStringConvertible, @unchecked Sendable {
    /// The raw value representing the input data flags.
    public let rawValue: UInt32
    
    /// Creates input data flags with the specified raw value.
    ///
    /// - Parameter rawValue: The raw flags value
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
        
    /// No input data is required.
    ///
    /// This indicates that NSDK doesn't currently need any input data,
    /// which may occur when all features are stopped or inactive.
    public static let none = NSDKInputDataFlags([])
    
    /// Device pose (position and orientation) is required.
    ///
    /// This includes the camera transform matrix that defines the device's
    /// position and orientation in world coordinate space.
    public static let pose = NSDKInputDataFlags(rawValue: 1 << 0)
    
    /// Device screen orientation is required.
    ///
    /// This indicates the physical orientation of the device screen,
    /// used for proper alignment of AR content.
    public static let deviceOrientation = NSDKInputDataFlags(rawValue: 1 << 1)
    
    /// ARKit tracking state is required.
    ///
    /// This provides information about the quality and reliability
    /// of the device's pose tracking system.
    public static let trackingState = NSDKInputDataFlags(rawValue: 1 << 2)
    
    /// Camera image data is required.
    ///
    /// This includes the color camera image planes and associated
    /// metadata like intrinsics and timestamps.
    public static let cameraImage = NSDKInputDataFlags(rawValue: 1 << 3)
    
    /// GPS location data is required.
    ///
    /// This includes latitude, longitude, altitude, and accuracy
    /// information from the device's location services.
    public static let gpsLocation = NSDKInputDataFlags(rawValue: 1 << 4)
    
    /// Compass heading data is required.
    ///
    /// This includes magnetic and true heading information
    /// from the device's magnetometer and compass.
    public static let compass = NSDKInputDataFlags(rawValue: 1 << 5)
    
    /// Platform depth data is required.
    ///
    /// This includes depth measurements and confidence data
    /// from LiDAR or structured light depth sensors.
    public static let platformDepth = NSDKInputDataFlags(rawValue: 1 << 6)
  
    private static let caseDescriptions: [(Self, String)] = [
        (.none, "none"),
        (.pose, "pose"),
        (.deviceOrientation, "deviceOrientation"),
        (.trackingState, "trackingState"),
        (.cameraImage, "cameraImage"),
        (.gpsLocation, "gpsLocation"),
        (.compass, "compass"),
        (.platformDepth, "platformDepth")
    ]

    public var debugDescription: String {
      let flagged = Self.caseDescriptions.filter { contains($0.0) && $0.0 != .none }.map { $0.1 }
      if (flagged.isEmpty) { return "none"}
      
      let s = flagged.joined(separator: ", ")
      return "\(s)"
    }
}
