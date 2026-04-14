import CArdk
import simd
import Foundation

/// Contains the latest tracking information for a VPS anchor.
///
/// Anchor updates are retrieved via `anchorUpdate(anchorId:)` and provide the
/// most current information about an anchor's position, orientation, and tracking status. This
/// is a snapshot of the anchor, and the latest anchor update should be used every frame.
public struct VpsAnchorUpdate: CustomDebugStringConvertible {
    public struct TrackingData: Equatable {
        /// The 4x4 transformation matrix of the anchor in local ARKit space.
        public let targetAnchorTransform: simd_float4x4

        /// Timestamp when this update was generated (in milliseconds since epoch).
        public let timestampMs: UInt64

        /// Reliability of the pose estimate, between 0.0 (unreliable) and 1.0 (highly reliable).
        public let confidence: Float

        /// Geolocation data of the anchor, if available.
        /// TODO: Does this need to be optional?
        public let geolocation: GeolocationData?
    }
    
    /// The unique identifier of the anchor.
    public let anchorId: NSDKVpsAnchorId

    /// The current tracking state of the anchor, and associated data.
    ///
    /// Anchors in `.notTracked` and `.limited` states have an associated
    /// value of type `AnchorTrackingState.Reason` which explains why the anchor
    /// is in its current state.
    public let trackingState: AnchorTrackingState
    
    /// Pose, confidence, and timestamp data available when an anchor is in `.limited` or
    /// `.tracked` states,
    public let trackingData: TrackingData?

    init(fromC cUpdate: ARDK_VPS_AnchorUpdate) {
        let cAnchorId = cUpdate.anchor_identifier

        // This is safe to do because fixed-size C arrays imported
        // into Swift as part of a C struct are kept in contiguous
        // memory even as a tuple.
        anchorId = withUnsafeBytes(of: cAnchorId) { ptr in
            let data = Data(ptr)
            return String(bytes: data, encoding: .utf8) ?? ""
        }

        let t = cUpdate.anchor_to_local_tracking_transform
        let nsdkTransform = simd_float4x4(
            SIMD4<Float>(t.0,  t.1,  t.2,  t.3),
            SIMD4<Float>(t.4,  t.5,  t.6,  t.7),
            SIMD4<Float>(t.8,  t.9,  t.10, t.11),
            SIMD4<Float>(t.12, t.13, t.14, t.15)
        )

        trackingState = AnchorTrackingState(
            cState: cUpdate.tracking_state,
            cReason: cUpdate.tracking_state_reason
        )
        
        if case .notTracked(_) = trackingState {
            trackingData = nil
        } else {
            let geolocation: GeolocationData? = cUpdate.has_geolocation != 0
                ? GeolocationData(fromC: cUpdate.geolocation_data)
                : nil
            trackingData = VpsAnchorUpdate.TrackingData(
                targetAnchorTransform: nsdkTransform.fromNSDKToARKit(),
                timestampMs: cUpdate.timestamp_ms,
                confidence: cUpdate.tracking_confidence,
                geolocation: geolocation
            )
        }
    }

    public var debugDescription: String {
        var str =
"""
VpsAnchorUpdate:
    anchorId: \(anchorId)
    trackingState: \(trackingState)
""";
        guard let trackingData = trackingData else { return str }
        let matrixRows = (0..<4).map { row in
            (0..<4).map { col in
                String(format: "%.3f", trackingData.targetAnchorTransform[row, col])
            }.joined(separator: " ")}.joined(separator: "\n    ")

        var geoStr = "nil"
        if let geo = trackingData.geolocation {
            geoStr = "(lat: \(geo.latitude), lon: \(geo.longitude), alt: \(geo.altitude), heading: \(geo.heading))"
        }

        return
"""
VpsAnchorUpdate:
    anchorId: \(anchorId)
    anchorToLocalTransform:
      \(matrixRows)
    trackingState: \(trackingState)
    timestampMs: \(trackingData.timestampMs)
    geolocation: \(geoStr)
"""
    }
}
