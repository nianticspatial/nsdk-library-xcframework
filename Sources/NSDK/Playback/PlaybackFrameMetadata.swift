// Copyright 2026 Niantic Spatial.

import CArdk
import simd

/// One frame's recorded data, without its image or depth buffers. Mirrors the frame native playback
/// returns from `ARDK_PlaybackDataset_GetFrameMetadata`; ``transform`` is in the recorded (ARKit)
/// convention.
public struct PlaybackFrameMetadata: Equatable {
    /// Recorded frame sequence number.
    public let sequence: Int
    /// Camera timestamp in milliseconds, on the recording's clock.
    public let timestampMs: UInt64
    public let trackingState: NsdkTrackingState
    /// Camera-to-world.
    public let transform: simd_float4x4
    public let intrinsics: NSDKFrameData.CameraIntrinsics
    /// Image (width, height) in pixels.
    public let imageResolution: SIMD2<UInt32>
    /// Screen orientation the frame was recorded in; `.unknown` when not recorded.
    public let orientation: NSDKScreenOrientation
    /// Recorded GPS fix; nil when the frame has none.
    public let gpsData: NSDKFrameData.GpsData?
    /// Recorded compass sample, stamped with its clock base; nil when the frame has none.
    public let compassData: NSDKFrameData.CompassData?
    /// Depth buffer (width, height) in pixels; nil when the frame has no depth.
    public let depthResolution: SIMD2<UInt32>?
}

extension PlaybackFrameMetadata {
    /// Requires at least one camera frame in `cFrame`.
    internal init(fromC cFrame: ARDK_FrameData) {
        let camera = cFrame.camera_frames[0]
        sequence = Int(cFrame.frame_id)
        timestampMs = camera.camera_timestamp_ms
        trackingState = NsdkTrackingState(fromC: cFrame.tracking_state)
        transform = simd_float4x4(fromNSDKTransform: camera.camera_pose)
        intrinsics = NSDKFrameData.CameraIntrinsics(fromC: camera.camera_instrinsics)
        imageResolution = SIMD2(camera.camera_image_width, camera.camera_image_height)
        orientation = NSDKScreenOrientation(fromC: camera.camera_orientation)

        let gps = cFrame.gps_data
        gpsData = gps.latitude == 0 && gps.longitude == 0 ? nil : NSDKFrameData.GpsData(
            timestampMs: gps.timestamp_ms,
            latitude: gps.latitude,
            longitude: gps.longitude,
            altitude: gps.altitude,
            verticalAccuracy: gps.vertical_accuracy,
            horizontalAccuracy: gps.horizontal_accuracy)

        let compass = cFrame.compass_data
        compassData = compass.timestamp_ms == 0 ? nil : NSDKFrameData.CompassData(
            timestampMs: compass.timestamp_ms,
            headingAccuracy: compass.heading_accuracy,
            trueHeading: compass.true_heading,
            base: compass.base == ARDK_ClockBase_Monotonic ? .monotonic : .epoch)

        if cFrame.depth_frames_count > 0, let depth = cFrame.depth_frames?.pointee,
           depth.depth_image_data_width > 0, depth.depth_image_data_height > 0 {
            depthResolution = SIMD2(depth.depth_image_data_width, depth.depth_image_data_height)
        } else {
            depthResolution = nil
        }
    }
}

extension PlaybackFrameMetadata {
    /// This frame with its camera, GPS and compass timestamps `offsetMs` later. A zero GPS or
    /// compass timestamp means the reading was not recorded, so it stays zero.
    internal func shiftingTimestamps(byMs offsetMs: UInt64) -> PlaybackFrameMetadata {
        if offsetMs == 0 {
            return self
        }
        var gps = gpsData
        if let timestamp = gps?.timestampMs, timestamp != 0 {
            gps?.timestampMs = timestamp + offsetMs
        }
        var compass = compassData
        if let timestamp = compass?.timestampMs, timestamp != 0 {
            compass?.timestampMs = timestamp + offsetMs
        }
        return PlaybackFrameMetadata(
            sequence: sequence,
            timestampMs: timestampMs + offsetMs,
            trackingState: trackingState,
            transform: transform,
            intrinsics: intrinsics,
            imageResolution: imageResolution,
            orientation: orientation,
            gpsData: gps,
            compassData: compass,
            depthResolution: depthResolution)
    }
}

private extension NsdkTrackingState {
    init(fromC cValue: ARDK_TrackingState) {
        switch cValue {
        case ARDK_TrackingState_Failed: self = .failed
        case ARDK_TrackingState_Poor: self = .poor
        case ARDK_TrackingState_Normal: self = .normal
        default: self = .unknown
        }
    }
}

private extension NSDKScreenOrientation {
    // ARDK_Orientation orders LandscapeRight before LandscapeLeft, so raw values do not match.
    init(fromC cValue: ARDK_Orientation) {
        switch cValue {
        case ARDK_Orientation_Portrait: self = .portrait
        case ARDK_Orientation_PortraitUpsideDown: self = .portraitUpsideDown
        case ARDK_Orientation_LandscapeLeft: self = .landscapeLeft
        case ARDK_Orientation_LandscapeRight: self = .landscapeRight
        default: self = .unknown
        }
    }
}

private extension NSDKFrameData.CameraIntrinsics {
    init(fromC cValue: ARDK_CameraIntrinsics) {
        let matrix = simd_float3x3(columns: (
            SIMD3<Float>(cValue.focal_length_x, 0, 0),
            SIMD3<Float>(0, cValue.focal_length_y, 0),
            SIMD3<Float>(cValue.principal_point_x, cValue.principal_point_y, 1)
        ))
        self.init(intrinsics: matrix, width: cValue.resolution_x, height: cValue.resolution_y)
    }
}
