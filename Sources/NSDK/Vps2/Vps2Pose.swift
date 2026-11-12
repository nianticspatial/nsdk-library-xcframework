import CArdk
import Foundation
import simd

/// Pose in AR tracking space calculated by VPS2 from a geolocation. This is
/// the pose of the geolocation that was passed in, not of the device.
public struct Vps2Pose: CustomDebugStringConvertible {

    /// Pose in the device's AR (ARKit) tracking space, with translation in
    /// meters from the tracking space origin.
    public var transform: simd_float4x4

    /// Horizontal accuracy in metres.
    public var horizontalAccuracyMetres: Float

    /// Vertical accuracy in metres.
    public var verticalAccuracyMetres: Float

    /// Rotation accuracy in degrees.
    public var rotationAccuracyDeg: Float

    /// Tracking state of the localization this pose was computed from. Always
    /// `.coarse` or `.precise` when a pose is returned (never `.unavailable`).
    public var trackingState: Vps2TrackingState

    // MARK: - Initializers

    /// Creates a `Vps2Pose` with explicit field values.
    ///
    /// - Parameters:
    ///   - transform: The pose transform in AR coordinate space.
    ///   - horizontalAccuracyMetres: Horizontal accuracy in metres.
    ///   - verticalAccuracyMetres: Vertical accuracy in metres.
    ///   - rotationAccuracyDeg: Rotation accuracy in degrees.
    ///   - trackingState: Tracking state of the localization this pose was computed from.
    public init(
        transform: simd_float4x4,
        horizontalAccuracyMetres: Float,
        verticalAccuracyMetres: Float,
        rotationAccuracyDeg: Float,
        trackingState: Vps2TrackingState = .unavailable
    ) {
        self.transform = transform
        self.horizontalAccuracyMetres = horizontalAccuracyMetres
        self.verticalAccuracyMetres = verticalAccuracyMetres
        self.rotationAccuracyDeg = rotationAccuracyDeg
        self.trackingState = trackingState
    }

    internal init(fromC cValue: ARDK_VPS2_Pose) {
        self.transform = simd_float4x4(fromNSDKTransform: cValue.pose)
        self.horizontalAccuracyMetres = cValue.horizontal_accuracy_metres
        self.verticalAccuracyMetres = cValue.vertical_accuracy_metres
        self.rotationAccuracyDeg = cValue.rotation_accuracy_deg
        self.trackingState = Vps2TrackingState(fromC: cValue.tracking_state)
    }

    // MARK: - CustomDebugStringConvertible

    public var debugDescription: String {
        """
        Vps2Pose(
          transform: \(transform),
          horizontalAccuracyMetres: \(horizontalAccuracyMetres),
          verticalAccuracyMetres: \(verticalAccuracyMetres),
          rotationAccuracyDeg: \(rotationAccuracyDeg),
          trackingState: \(trackingState)
        )
        """
    }
}
