import CArdk
import Foundation

/// GPS and heading data calculated by VPS2.
public struct Vps2GeolocationData: CustomDebugStringConvertible {
    /// Contains the GPS and heading data.
    public var geolocationData: GeolocationData
    
    /// Horizontal accuracy in metres.
    public var horizontalAccuracyMetres: Float

    /// Vertical accuracy in metres.
    public var verticalAccuracyMetres: Float
    
    /// Rotation accuracy in degrees.
    public var rotationAccuracyDeg: Float
    
    // MARK: - Initializers

    /// Creates a `Vps2GeolocationData` value with explicit field values.
    ///
    /// - Parameters:
    ///   - geolocationData: The GPS and heading data.
    ///   - horizontalAccuracyMetres: Horizontal accuracy in metres.
    ///   - verticalAccuracyMetres: Vertical accuracy in metres.
    ///   - rotationAccuracyDeg: Rotation accuracy in degrees.
    public init(
        geolocationData: GeolocationData,
        horizontalAccuracyMetres: Float,
        verticalAccuracyMetres: Float,
        rotationAccuracyDeg: Float
    ) {
        self.geolocationData = geolocationData
        self.horizontalAccuracyMetres = horizontalAccuracyMetres
        self.verticalAccuracyMetres = verticalAccuracyMetres
        self.rotationAccuracyDeg = rotationAccuracyDeg
    }

    internal init(fromC cValue: ARDK_VPS2_GeolocationData) {
        self.geolocationData = GeolocationData(fromC: cValue.geolocation_data)
        self.horizontalAccuracyMetres = cValue.horizontal_accuracy_metres
        self.verticalAccuracyMetres = cValue.vertical_accuracy_metres
        self.rotationAccuracyDeg = cValue.rotation_accuracy_deg
    }
    
    // MARK: - CustomDebugStringConvertible

    public var debugDescription: String {
        """
        Vps2GeolocationData(
          geolocation: \(geolocationData),
          horizontalAccuracyMetres: \(horizontalAccuracyMetres),
          verticalAccuracyMetres: \(verticalAccuracyMetres),
          rotationAccuracyDeg: \(rotationAccuracyDeg)
        )
        """
    }
}
