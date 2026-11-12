import CArdk
import simd

/// Spatial mapping between the device's AR tracking space and real-world
/// geolocation, as determined by VPS2.
///
/// This relates two origins: the AR tracking space origin (the ARKit world
/// origin) and a geographic reference point. It is not relative to the
/// current camera pose, and does not change as the device moves; it changes
/// only when VPS2 refines or replaces its localization. To convert a specific
/// geolocation, use ``NSDKVps2Session/getPose(localization:location:)``; to
/// convert a pose, use ``NSDKVps2Session/getGeolocation(pose:)``. All
/// distances are in meters.
public struct Vps2Localization: CustomDebugStringConvertible {
    /// The state of VPS2 tracking. The geolocation fields in this struct are
    /// only valid if the tracking state is **not** .unavailable.
    public var trackingState: Vps2TrackingState
    
    /// WGS84 latitude of the reference point, in degrees. The reference point
    /// is not the camera: it is the georeference origin of the localized map
    /// (precise), or a fixed origin chosen by the coarse localizer (coarse).
    internal var referenceLatitudeDegrees: Double

    /// WGS84 longitude of the reference point, in degrees.
    internal var referenceLongitudeDegrees: Double

    /// Altitude of the reference point, in meters above the WGS84 ellipsoid.
    internal var referenceAltitudeMetres: Double

    /// Transform from AR tracking space to a local East-Down-North frame
    /// centered on the reference point, in meters. Stored with both sides
    /// conjugated into ARKit axes by `fromNSDKToARKit()`, so it is only
    /// meaningful after converting back with `fromARKitToNSDK()`.
    internal var trackingToRelativeLonNegAltLat: simd_float4x4

    /// Horizontal accuracy in metres of reference latitude and longitude
    internal var horizontalAccuracyMetres: Float

    /// Vertical accuracy in metres of reference altitude
    internal var verticalAccuracyMetres: Float

    /// Rotation (heading) accuracy in degrees of `trackingToRelativeLonNegAltLat`.
    internal var rotationAccuracyDeg: Float

    /// The VPS asset the device is localized to, independent of the tracking
    /// state. `nil` until a visual localization succeeds against a submitted
    /// asset. Place the asset's content with
    /// ``NSDKVps2Session/assetTrackingData(assetId:)``.
    public var localizedAsset: Vps2LocalizedAsset?

    internal init(
            trackingState: Vps2TrackingState,
            referenceLatitudeDegrees: Double,
            referenceLongitudeDegrees: Double,
            referenceAltitudeMetres: Double,
            trackingToRelativeLonNegAltLat: simd_float4x4,
            horizontalAccuracyMetres: Float,
            verticalAccuracyMetres: Float,
            rotationAccuracyDeg: Float,
            localizedAsset: Vps2LocalizedAsset? = nil
    ) {
        self.trackingState = trackingState
        self.referenceLatitudeDegrees = referenceLatitudeDegrees
        self.referenceLongitudeDegrees = referenceLongitudeDegrees
        self.referenceAltitudeMetres = referenceAltitudeMetres
        self.trackingToRelativeLonNegAltLat = trackingToRelativeLonNegAltLat
        self.horizontalAccuracyMetres = horizontalAccuracyMetres
        self.verticalAccuracyMetres = verticalAccuracyMetres
        self.rotationAccuracyDeg = rotationAccuracyDeg
        self.localizedAsset = localizedAsset
    }

    /// A localization that carries no usable spatial mapping.
    ///
    /// Used when VPS2 cannot produce a localization at all. Only ``trackingState`` is
    /// meaningful, and it is always `.unavailable`, which callers already have to handle.
    internal static var unavailable: Vps2Localization {
        Vps2Localization(
            trackingState: .unavailable,
            referenceLatitudeDegrees: 0,
            referenceLongitudeDegrees: 0,
            referenceAltitudeMetres: 0,
            trackingToRelativeLonNegAltLat: matrix_identity_float4x4,
            horizontalAccuracyMetres: 0,
            verticalAccuracyMetres: 0,
            rotationAccuracyDeg: 0
        )
    }

    internal init(fromC cValue: ARDK_VPS2_Localization) {
        self.trackingState = Vps2TrackingState(fromC: cValue.trackingState)
        self.localizedAsset = Vps2LocalizedAsset(fromC: cValue.localized_asset)
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
        // localized_asset stays zeroed: the only consumer of this conversion
        // (GetPose) does not read it.
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
