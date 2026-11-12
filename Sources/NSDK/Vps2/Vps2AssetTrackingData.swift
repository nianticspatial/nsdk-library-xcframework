// Copyright 2026 Niantic Spatial.

import CArdk
import simd

/// Pose of a VPS asset's origin in the device's AR tracking space.
///
/// Content authored in the asset's coordinate space is placed with
/// ``assetToTrackingTransform``. This relates two origins (the asset's and
/// the AR session's) and is independent of the current camera pose. The
/// asset's coordinate space is the same space downloaded mesh chunks are
/// placed in (see ``MeshDownloaderChunk/transform``). Only served while the
/// asset is fully tracked; see ``NSDKVps2Session/assetTrackingData(assetId:)``.
public struct Vps2AssetTrackingData: CustomDebugStringConvertible, Sendable {
    /// The identifier of the site the asset belongs to.
    public let siteId: String

    /// The identifier of the asset.
    public let assetId: String

    /// Identifier of subarea in the site localized, or `nil` when the asset
    /// has no subareas.
    public let areaId: String?

    /// Transform from the asset's coordinate space to the device's AR
    /// tracking space (`p_tracking = assetToTrackingTransform * p_asset`).
    /// Equivalently, the pose of the asset's origin in tracking space.
    /// Translation is in meters; both spaces use ARKit axes (x right, y up,
    /// z backward).
    public let assetToTrackingTransform: simd_float4x4

    /// Confidence in the transform, from 0 (none) to 1 (full).
    public let confidence: Float

    /// Timestamp of the camera frame the transform was last updated from,
    /// in monotonic milliseconds.
    public let timestampMs: UInt64

    /// Geolocation of the asset's origin, or `nil` while the asset has no
    /// georeference.
    public let geolocation: GeolocationData?

    internal init?(fromC cValue: ARDK_VPS2_AssetTrackingData) {
        guard let siteId = String(fixedCString: cValue.asset.site_id),
              let assetId = String(fixedCString: cValue.asset.asset_id)
        else {
            return nil
        }
        self.siteId = siteId
        self.assetId = assetId
        self.areaId = String(fixedCString: cValue.asset.area_id)

        let t = cValue.asset_to_local_tracking_transform
        let nsdkTransform = simd_float4x4(
            SIMD4<Float>(t.0,  t.1,  t.2,  t.3),
            SIMD4<Float>(t.4,  t.5,  t.6,  t.7),
            SIMD4<Float>(t.8,  t.9,  t.10, t.11),
            SIMD4<Float>(t.12, t.13, t.14, t.15)
        )
        self.assetToTrackingTransform = nsdkTransform.fromNSDKToARKit()
        self.confidence = cValue.tracking_confidence
        self.timestampMs = cValue.timestamp_ms
        self.geolocation = cValue.has_geolocation != 0
            ? GeolocationData(fromC: cValue.geolocation_data)
            : nil
    }

    public var debugDescription: String {
        var geolocationDescription = "nil"
        if let geolocation {
            geolocationDescription = "(lat: \(geolocation.latitude), lon: \(geolocation.longitude), "
                + "alt: \(geolocation.altitude), heading: \(geolocation.heading))"
        }
        return "Vps2AssetTrackingData(siteId: \(siteId), assetId: \(assetId), "
            + "areaId: \(areaId ?? "nil"), "
            + "confidence: \(confidence), timestampMs: \(timestampMs), "
            + "geolocation: \(geolocationDescription))"
    }
}
