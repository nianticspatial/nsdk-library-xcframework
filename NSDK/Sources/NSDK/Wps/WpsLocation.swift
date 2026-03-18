import CArdk
import simd
import Foundation

/// Contains world positioning data from the WPS (World Positioning System).
///
/// `WpsLocation` provides global positioning information that combines GPS/GNSS
/// data with visual positioning for enhanced accuracy and reliability.
///
/// ## Overview
///
/// WPS location data includes:
/// - Reference GPS coordinates (latitude, longitude, altitude)
/// - Transformation matrix for coordinate conversions
/// - Status information about positioning quality
///
/// ## Example Usage
///
/// ```swift
/// let (status, location) = wpsSession.latestLocation()
/// if status.isOk() {
///     print("GPS Coordinates: \(location.referenceLatitudeDegrees), \(location.referenceLongitudeDegrees)")
///     print("Altitude: \(location.referenceAltitudeMetres) meters")
///     print("Status: \(location.status)")
///     
///     // Use the transformation matrix for coordinate conversions
///     let worldPosition = location.trackingToRelativeEdn
///     placeARContent(at: worldPosition)
/// }
/// ```
///

public struct WpsLocation: CustomDebugStringConvertible {
    /// Reference latitude in degrees (WGS84 coordinate system).
    ///
    /// This represents the GPS latitude of the reference point used for
    /// WPS positioning calculations.
    public let referenceLatitudeDegrees: Double;
    
    /// Reference longitude in degrees (WGS84 coordinate system).
    ///
    /// This represents the GPS longitude of the reference point used for
    /// WPS positioning calculations.
    public let referenceLongitudeDegrees: Double;
    
    /// Reference altitude in meters above sea level.
    ///
    /// This represents the GPS altitude of the reference point used for
    /// WPS positioning calculations.
    public let referenceAltitudeMetres: Double;
    
    /// Transformation matrix from tracking to relative coordinate system.
    ///
    /// This 4x4 transformation matrix converts between the tracking coordinate
    /// system and the relative coordinate system used for AR content placement.
    public let trackingToRelativeEdn: simd_float4x4;

    init(fromC location: ARDK_WPS_Location) {
        referenceLatitudeDegrees = location.reference_gps_location.latitude
        referenceLongitudeDegrees = location.reference_gps_location.longitude
        referenceAltitudeMetres = location.reference_gps_location.altitude

        let t = location.tracking_rdf_to_relative_edn
        let trackingRdfToRelativeEdn = simd_float4x4(
                SIMD4<Float>(t.0,  t.1,  t.2,  t.3),
                SIMD4<Float>(t.4,  t.5,  t.6,  t.7),
                SIMD4<Float>(t.8,  t.9,  t.10, t.11),
                SIMD4<Float>(t.12, t.13, t.14, t.15)
                )
        let conversion = simd_diagonal_matrix(simd_make_float4(1, -1, -1, 1))
        trackingToRelativeEdn = trackingRdfToRelativeEdn * conversion
    }

    public var debugDescription: String {
        return """
WPS Location:
referenceLatitudeDegrees: \(referenceLatitudeDegrees)
referenceLongitudeDegrees: \(referenceLongitudeDegrees)
referenceAltitudeMetres: \(referenceAltitudeMetres)
trackingToRelativeEdn: \(trackingToRelativeEdn)
"""
    }
}
