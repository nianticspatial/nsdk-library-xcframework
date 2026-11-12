import CArdk
import simd

/// Struct representing geolocation data including latitude, longitude, altitude,
/// heading, and orientation.
///
/// Coordinates use the WGS84 datum. Depending on the API, this describes the
/// device, a VPS asset's origin, an anchor, or an arbitrary location passed in.
public struct GeolocationData: Equatable, Sendable {
    /// WGS84 latitude, in degrees.
    public let latitude: Double
    
    /// WGS84 longitude, in degrees.
    public let longitude: Double
    
    /// Altitude in meters above the WGS84 ellipsoid (not mean sea level), as
    /// in `CLLocation.ellipsoidalAltitude`.
    public let altitude: Double
    
    /// Heading in degrees relative to true north.
    public let heading: Double
    
    /// Orientation in East-Down-North (EDN) frame.
    private let orientationEDN: simd_quatf
    
    /// Creates geolocation data from a latitude, longitude, and altitude.
    ///
    /// - Parameters:
    ///   - latitude: WGS84 latitude, in degrees.
    ///   - longitude: WGS84 longitude, in degrees.
    ///   - altitude: Altitude in meters above the WGS84 ellipsoid. When taking it from a
    ///     `CLLocation`, use `ellipsoidalAltitude`, not `altitude` (mean sea level).
    public init(latitude: Double, longitude: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.heading = 0
        self.orientationEDN = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    }

    internal init(fromC: ARDK_GeolocationData) {
        latitude = fromC.latitude
        longitude = fromC.longitude
        altitude = fromC.altitude
        heading = fromC.heading_edn
        
        orientationEDN = simd_quatf(
            ix: fromC.orientation_edn_x,
            iy: fromC.orientation_edn_y,
            iz: fromC.orientation_edn_z,
            r: fromC.orientation_edn_w
        )
    }
    
    internal func convertToC() -> ARDK_GeolocationData {
        var cValue = ARDK_GeolocationData()
        cValue.latitude = latitude
        cValue.longitude = longitude
        cValue.altitude = altitude
        cValue.heading_edn = heading
        
        cValue.orientation_edn_x = orientationEDN.imag.x
        cValue.orientation_edn_y = orientationEDN.imag.y
        cValue.orientation_edn_z = orientationEDN.imag.z
        cValue.orientation_edn_w = orientationEDN.real
        
        return cValue
    }
}

extension GeolocationData {
    public static func == (lhs: GeolocationData, rhs: GeolocationData) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.altitude == rhs.altitude
            && lhs.heading == rhs.heading
            && lhs.orientationEDN.vector == rhs.orientationEDN.vector
    }

    /// Returns the orientation in East-Down-North (EDN) frame.
    public func getEastDownNorthQuaternion() -> simd_quatf {
        return orientationEDN
    }
    
    /// Returns the orientation converted to East–Up–South (EUS) frame.
    public func getEastUpSouthQuaternion() -> simd_quatf {
        // Flip Y and Z axes to convert EDN to EUS
        let flip = float3x3([
            simd_float3( 1,  0,  0),
            simd_float3( 0, -1,  0),
            simd_float3( 0,  0, -1)
        ])
        
        let qFlip = simd_quatf(flip)
        let qEus = qFlip * orientationEDN * qFlip
        return qEus
    }
}
