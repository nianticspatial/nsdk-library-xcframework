import CArdk
import simd
import Foundation

/// Contains the latest tracking information for a VPS anchor.
///
/// Anchor updates are retrieved via `getAnchorUpdate(anchorId:)` and provide the
/// most current information about an anchor's position, orientation, and tracking status. This
/// is a snapshot of the anchor, and the latest anchor update should be used every frame.
public struct VpsAnchorUpdate: CustomDebugStringConvertible {
    /// The unique identifier of the anchor.
    public var anchorId: NSDKVpsAnchorId

    /// The 4x4 transformation matrix from anchor space to local tracking space.
    ///
    /// This matrix represents the anchor's position and orientation relative to the
    /// device's current local coordinate system. Use this for placing AR content
    /// relative to the anchor.
    public var anchorToLocalTransform: simd_float4x4?

    /// The current tracking state of the anchor.
    ///
    /// Indicates whether the anchor is being tracked and how reliable the pose data is.
    /// See ``AnchorTrackingState`` for detailed information about each state.
    public var trackingState: AnchorTrackingState

    /// Additional context about the tracking state.
    public var trackingStateReason: AnchorTrackingStateReason

    /// Confidence score for the current tracking estimate.
    ///
    /// A value between 0.0 and 1.0 indicating the reliability of the pose estimate.
    /// Higher values indicate more reliable tracking.
    public var trackingConfidence: Float?

    /// Timestamp when this update was generated (in milliseconds since epoch).
    public var timestampMs: UInt64?

    init(fromC cUpdate: ARDK_VPS_AnchorUpdate) {
        trackingState = AnchorTrackingState(fromC: cUpdate.tracking_state)
        trackingStateReason = AnchorTrackingStateReason(fromC: cUpdate.tracking_state_reason)

        let cAnchorId = cUpdate.anchor_identifier

        // This is safe to do because fixed-size C arrays imported
        // into Swift as part of a C struct are kept in contiguous
        // memory even as a tuple.
        anchorId = withUnsafeBytes(of: cAnchorId) { ptr in
            let data = Data(ptr)
            return String(bytes: data, encoding: .utf8) ?? ""
        }

        if (trackingState == .notTracked) {
            // leave other fields nil
            return
        }

        let t = cUpdate.anchor_to_local_tracking_transform
        let nsdkTransform = simd_float4x4(
            SIMD4<Float>(t.0,  t.1,  t.2,  t.3),
            SIMD4<Float>(t.4,  t.5,  t.6,  t.7),
            SIMD4<Float>(t.8,  t.9,  t.10, t.11),
            SIMD4<Float>(t.12, t.13, t.14, t.15)
        )


        anchorToLocalTransform = nsdkTransform.fromNSDKToARKit()
        trackingConfidence = cUpdate.tracking_confidence
        timestampMs = cUpdate.timestamp_ms
    }

    public var debugDescription: String {
        if (trackingState == .notTracked) {
            return """
VpsAnchorUpdate:
    anchorId: \(anchorId)
    trackingState: \(trackingState)
    trackingStateReason: \(trackingStateReason)
"""
        }

        let matrixRows = (0..<4).map { row in
            (0..<4).map { col in
                String(format: "%.3f", anchorToLocalTransform![row, col])
            }.joined(separator: " ")
        }.joined(separator: "\n    ")

        return """
VpsAnchorUpdate:
    anchorId: \(anchorId)
    anchorToLocalTransform:
      \(matrixRows)
    trackingState: \(trackingState)
    trackingStateReason: \(trackingStateReason)
    trackingConfidence: \(trackingConfidence)
    timestampMs: \(timestampMs)
"""
    }
}
