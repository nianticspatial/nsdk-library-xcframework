import CArdk
import simd

/// Spatial mapping between the device's AR coordinate space and real-world
/// geolocation, as determined by VPS2.
public struct Vps2Localization: CustomDebugStringConvertible {
    /// The state of VPS2 tracking. The other fields in this struct are
    /// only valid if the tracking state is **not** .unavailable.
    public var trackingState: Vps2TrackingState
    
    /// Estimated latitude of the camera in degrees
    internal var referenceLatitudeDegrees: Double

    /// Estimated longitude of the camera in degrees
    internal var referenceLongitudeDegrees: Double

    /// Estimated altitude of the camera in metres
    internal var referenceAltitudeMetres: Double

    /// Transform from tracking to lat/lon/alt in metres relative to
    /// reference point.
    internal var trackingToRelativeLonNegAltLat: simd_float4x4

    /// Horizontal accuracy in metres of reference latitude and longitude
    internal var horizontalAccuracyMetres: Float

    /// Vertical accuracy in metres of reference altitude
    internal var verticalAccuracyMetres: Float

    /// Rotation accuracy in degrees of tracking to relative lon/neg/alt/lat transform.
    internal var rotationAccuracyDeg: Float
    
    internal init(
            trackingState: Vps2TrackingState,
            referenceLatitudeDegrees: Double,
            referenceLongitudeDegrees: Double,
            referenceAltitudeMetres: Double,
            trackingToRelativeLonNegAltLat: simd_float4x4,
            horizontalAccuracyMetres: Float,
            verticalAccuracyMetres: Float,
            rotationAccuracyDeg: Float
    ) {
        self.trackingState = trackingState
        self.referenceLatitudeDegrees = referenceLatitudeDegrees
        self.referenceLongitudeDegrees = referenceLongitudeDegrees
        self.referenceAltitudeMetres = referenceAltitudeMetres
        self.trackingToRelativeLonNegAltLat = trackingToRelativeLonNegAltLat
        self.horizontalAccuracyMetres = horizontalAccuracyMetres
        self.verticalAccuracyMetres = verticalAccuracyMetres
        self.rotationAccuracyDeg = rotationAccuracyDeg
    }
    
    internal init(fromC cValue: ARDK_VPS2_Localization) {
        self.trackingState = Vps2TrackingState(fromC: cValue.trackingState)
        self.referenceLatitudeDegrees = Double(cValue.referenceLatitudeDegrees)
        self.referenceLongitudeDegrees = Double(cValue.referenceLongitudeDegrees)
        self.referenceAltitudeMetres = Double(cValue.referenceAltitudeMetres)
        self.horizontalAccuracyMetres = Float(cValue.horizontal_accuracy_metres)
        self.verticalAccuracyMetres = Float(cValue.vertical_accuracy_metres)
        self.rotationAccuracyDeg = Float(cValue.rotation_accuracy_deg)
        
        let t = cValue.trackingToRelativeLonNegAltLat
        let ardkTransform = simd_float4x4(
            SIMD4<Float>(Float(t.0),  Float(t.1),  Float(t.2),  Float(t.3)),
            SIMD4<Float>(Float(t.4),  Float(t.5),  Float(t.6),  Float(t.7)),
            SIMD4<Float>(Float(t.8),  Float(t.9),  Float(t.10), Float(t.11)),
            SIMD4<Float>(Float(t.12), Float(t.13), Float(t.14), Float(t.15))
        )
        self.trackingToRelativeLonNegAltLat = ardkTransform.fromNSDKToARKit()
    }
    
    internal func convertToC() -> ARDK_VPS2_Localization {
        var cValue = ARDK_VPS2_Localization()
        cValue.trackingState = self.trackingState.convertToC()
        cValue.referenceLatitudeDegrees = self.referenceLatitudeDegrees
        cValue.referenceLongitudeDegrees = self.referenceLongitudeDegrees
        cValue.referenceAltitudeMetres = self.referenceAltitudeMetres
        cValue.horizontal_accuracy_metres = self.horizontalAccuracyMetres
        cValue.vertical_accuracy_metres = self.verticalAccuracyMetres
        cValue.rotation_accuracy_deg = self.rotationAccuracyDeg
        
        let ardkMatrix = trackingToRelativeLonNegAltLat.fromARKitToNSDK()
        let array = ardkMatrix.flatten()
        
        withUnsafeMutablePointer(to: &cValue.trackingToRelativeLonNegAltLat) { tuplePtr in
            tuplePtr.withMemoryRebound(to: Double.self, capacity: 16) { p in
                for i in 0..<16 {
                    p[i] = Double(array[i])
                }
            }
        }
        
        return cValue
    }
    
    public var debugDescription: String {
        "Vps2Localization(trackingState: \(trackingState), lat: \(referenceLatitudeDegrees), lon: \(referenceLongitudeDegrees), alt: \(referenceAltitudeMetres))"
    }
}
