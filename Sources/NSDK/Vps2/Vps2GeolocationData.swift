import CArdk
import CoreLocation
import Foundation

/// Location and heading data calculated by VPS2.
public struct Vps2GeolocationData: CustomDebugStringConvertible {
    /// The state of VPS2 tracking. The other fields in this struct are
    /// only valid if the tracking state is **not** .unavailable.
    public var trackingState: Vps2TrackingState
    
    /// Contains the GPS and heading data.
    public var geolocationData: GeolocationData

    /// Horizontal accuracy in metres.
    public var horizontalAccuracyMetres: Float

    /// Vertical accuracy in metres.
    public var verticalAccuracyMetres: Float

    /// Rotation accuracy in degrees.
    public var rotationAccuracyDeg: Float

    /// The time at which this geolocation was acquired.
    public let timestamp: Date

    // MARK: - Initializers
    internal init(fromC cValue: ARDK_VPS2_GeolocationData) {
        self.trackingState = Vps2TrackingState(fromC: cValue.tracking_state)
        self.geolocationData = GeolocationData(fromC: cValue.geolocation_data)
        self.horizontalAccuracyMetres = cValue.horizontal_accuracy_metres
        self.verticalAccuracyMetres = cValue.vertical_accuracy_metres
        self.rotationAccuracyDeg = cValue.rotation_accuracy_deg
        self.timestamp = Date()
    }

    // MARK: - CoreLocation conversion

    /// The position represented as a `CLLocation` (`Vps2Location`).
    ///
    /// `coordinate` and `horizontalAccuracy` carry the VPS2-computed values.
    /// `ellipsoidalAltitude` holds the WGS84 height from VPS2; `verticalAccuracy` is its precision.
    ///
    /// - Note: `altitude` (MSL/orthometric) always returns `-1` because converting WGS84
    ///   ellipsoidal height to MSL requires a geoid model (e.g. EGM96) that is not currently
    ///   available. Use `ellipsoidalAltitude` instead.
    public var clLocation: CLLocation {
        Vps2Location(
            coordinate: CLLocationCoordinate2D(
                latitude: geolocationData.latitude,
                longitude: geolocationData.longitude
            ),
            ellipsoidalAltitude: geolocationData.altitude,
            horizontalAccuracy: Double(horizontalAccuracyMetres),
            verticalAccuracy: Double(verticalAccuracyMetres),
            timestamp: timestamp
        )
    }

    /// The heading represented as a `CLHeading` (via `Vps2Heading`).
    ///
    /// `trueHeading` is the VPS2-computed heading in degrees clockwise from true north.
    /// `headingAccuracy` is derived from `rotationAccuracyDeg`. The magnetometer component
    /// values (`x`, `y`, `z`) are zero because VPS2 does not use a magnetometer.
    public var clHeading: CLHeading {
        Vps2Heading(
            trueHeading: geolocationData.heading,
            headingAccuracy: Double(rotationAccuracyDeg),
            timestamp: timestamp
        )
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
