import CArdk
import CoreLocation

//
///// Struct representing a geographical coordinate with latitude and longitude in degrees.
//public struct LatLng: CustomDebugStringConvertible, Sendable {
//    /// Latitude in degrees.
//    public let latDegrees: Double
//    
//    /// Longitude in degrees.
//    public let lngDegrees: Double
//    
//    public init(latDegrees: Double, lngDegrees: Double) {
//        self.latDegrees = latDegrees
//        self.lngDegrees = lngDegrees
//    }
//  
//    init(fromC cValue: ARDK_VPSCoverage_LatLng) {
//        self.latDegrees = cValue.lat_degrees
//        self.lngDegrees = cValue.lng_degrees
//    }
//
//    func convertToC() -> ARDK_VPSCoverage_LatLng {
//        return ARDK_VPSCoverage_LatLng(
//            lat_degrees: self.latDegrees,
//            lng_degrees: self.lngDegrees
//        )
//    }
//    
//    public var debugDescription: String {
//        return "Lat: \(latDegrees), Lng: \(lngDegrees)"
//    }
//}

extension CLLocationCoordinate2D {
    internal init(fromC cValue: ARDK_VPSCoverage_LatLng) {
        self.init(latitude: cValue.lat_degrees, longitude: cValue.lng_degrees)
    }
    
    internal func convertToC() -> ARDK_VPSCoverage_LatLng {
        return ARDK_VPSCoverage_LatLng(
            lat_degrees: self.latitude,
            lng_degrees: self.longitude
        )
    }
}
