import CArdk
import simd

/// Struct representing geolocation data including latitude, longitude, altitude,
/// heading, and orientation.
public struct GeolocationData {
    /// Geographical device location latitude.
    public let latitude: Double
    
    /// Geographical device location longitude.
    public let longitude: Double
    
    /// Geographical device location altitude in meters.
    public let altitude: Double
    
    /// Heading in degrees relative to true north.
    public let heading: Double
    
    /// Orientation in East-Down-North (EDN) frame.
    private let orientationEDN: simd_quatf
    
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
