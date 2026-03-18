import CArdk
import Foundation
import simd

/// Pose in AR coordinate space calculated by VPS2 from a geolocation.
public struct Vps2Pose: CustomDebugStringConvertible {

    /// Pose in the device's AR coordinate space, expressed in the OpenCV coordinate system.
    public var transform: simd_float4x4

    /// Horizontal accuracy in metres.
    public var horizontalAccuracyMetres: Float

    /// Vertical accuracy in metres.
    public var verticalAccuracyMetres: Float

    /// Rotation accuracy in degrees.
    public var rotationAccuracyDeg: Float

    // MARK: - Initializers

    /// Creates a `Vps2Pose` with explicit field values.
    ///
    /// - Parameters:
    ///   - transform: The pose transform in AR coordinate space.
    ///   - horizontalAccuracyMetres: Horizontal accuracy in metres.
    ///   - verticalAccuracyMetres: Vertical accuracy in metres.
    ///   - rotationAccuracyDeg: Rotation accuracy in degrees.
    public init(
        transform: simd_float4x4,
        horizontalAccuracyMetres: Float,
        verticalAccuracyMetres: Float,
        rotationAccuracyDeg: Float
    ) {
        self.transform = transform
        self.horizontalAccuracyMetres = horizontalAccuracyMetres
        self.verticalAccuracyMetres = verticalAccuracyMetres
        self.rotationAccuracyDeg = rotationAccuracyDeg
    }

    internal init(fromC cValue: ARDK_VPS2_Pose) {
        self.transform = simd_float4x4(fromNSDKTransform: cValue.pose)
        self.horizontalAccuracyMetres = cValue.horizontal_accuracy_metres
        self.verticalAccuracyMetres = cValue.vertical_accuracy_metres
        self.rotationAccuracyDeg = cValue.rotation_accuracy_deg
    }

    // MARK: - CustomDebugStringConvertible

    public var debugDescription: String {
        """
        Vps2Pose(
          transform: \(transform),
          horizontalAccuracyMetres: \(horizontalAccuracyMetres),
          verticalAccuracyMetres: \(verticalAccuracyMetres),
          rotationAccuracyDeg: \(rotationAccuracyDeg)
        )
        """
    }
}
