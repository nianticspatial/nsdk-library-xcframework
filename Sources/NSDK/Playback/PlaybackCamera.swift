//
//  PlaybackCamera.swift
//  NSDK
//
//  Camera representation for playback; stands in for ARCamera.
//

import Foundation
import UIKit
import ARKit
import simd
import CoreGraphics

/// Camera representation built from frame **metadata** (pose4x4, intrinsics, resolution). Exposes the same
/// concepts as **ARCamera**: transform, viewMatrix, projectionMatrix, viewportRect, displayOrientedTransform.
/// Relation to Apple AR: **Stands in for** ARCamera during playback. No Apple camera; we synthesize
/// view/projection from recorded intrinsics and pose. Use `PlaybackFrame.camera` to obtain an instance.
public final class PlaybackCamera {
    private let metadata: PlaybackDataset.FrameMetadata

    /// The 4×4 camera-to-world transformation matrix from the frame metadata (pose4x4).
    public var transform: simd_float4x4 {
        metadata.cameraTransform
    }

    /// Euler angles (pitch, yaw, roll) in radians, extracted from the transform; order matches ARKit.
    public var eulerAngles: simd_float3 {
        Self.eulerAngles(from: metadata.cameraTransform)
    }

    /// The camera's intrinsic matrix (fx, fy, cx, cy layout).
    public var intrinsics: simd_float3x3 {
        metadata.cameraIntrinsics
    }

    /// The camera's image resolution in pixels.
    public var imageResolution: CGSize {
        CGSize(width: Int(metadata.cameraImageWidth), height: Int(metadata.cameraImageHeight))
    }

    /// Camera tracking state (from metadata.tracking).
    public var trackingState: ARCamera.TrackingState {
        metadata.trackingState
    }

    /// Exposure duration in seconds. Playback has no exposure data; returns a default.
    @available(iOS 13.0, *)
    public var exposureDuration: TimeInterval {
        1.0 / 60.0
    }

    /// Exposure offset in EV. Playback has no exposure data; returns 0.
    @available(iOS 13.0, *)
    public var exposureOffset: Float {
        0
    }

    /// Default projection matrix (infinite far plane). Uses `metadata.projection` when available; otherwise built from intrinsics using orientation from metadata (`screenOrientation`), or inferred from image resolution (portrait if height > width, else landscape-right), or landscape-right as last resort.
    /// For display-time orientation or custom near/far, use `projectionMatrix(for:viewportSize:zNear:zFar:)`.
    public var projectionMatrix: simd_float4x4 {
        if let proj = metadata.projection, proj.count == 16 {
            return Self.matrix4x4(from: proj)
        }
        let orientation = inferredRecordedOrientation
        return projectionMatrixFromIntrinsics(displayOrientation: orientation, zNear: 0.001, zFar: 0)
    }

    /// Best-effort orientation: uses `metadata.orientation` (from `screenOrientation`) when set and not unknown; else inferred from resolution. Resolution alone gives only portrait vs landscape: height > width → portrait; width >= height → landscape. We cannot distinguish landscape-left from landscape-right (or portrait from portrait-upside-down) from resolution, so inferred landscape uses **landscape-right** and inferred portrait uses **portrait**. Landscape-left and portrait-upside-down come only from metadata.
    private var inferredRecordedOrientation: UIInterfaceOrientation {
        if let o = metadata.orientation, o != .unknown {
            return o
        }
        guard metadata.resolution.count >= 2 else {
            return .landscapeRight
        }
        let w = metadata.resolution[0], h = metadata.resolution[1]
        if h > w {
            return .portrait
        }
        return .landscapeRight
    }

    internal init(metadata: PlaybackDataset.FrameMetadata) {
        self.metadata = metadata
    }

    /// The interface orientation the frame was recorded in. Uses metadata `screenOrientation` when set; else inferred from image resolution (height > width → portrait, else landscape-right); else landscape-right.
    public var recordedOrientation: UIInterfaceOrientation {
        inferredRecordedOrientation
    }

    /// Returns the view matrix (world-to-camera) for the given interface orientation.
    /// Implemented as the inverse of the display-oriented transform so rendering matches the on-screen camera.
    public func viewMatrix(for orientation: UIInterfaceOrientation) -> simd_float4x4 {
        displayOrientedTransform(orientation: orientation).inverse
    }

    /// Returns a projection matrix for the given orientation and viewport, with the requested near/far planes.
    /// Built from intrinsics with orientation applied: portrait swaps fx/fy and dimensions; landscape-left flips principal point.
    public func projectionMatrix(
        for orientation: UIInterfaceOrientation,
        viewportSize: CGSize,
        zNear: CGFloat,
        zFar: CGFloat
    ) -> simd_float4x4 {
        let zF: Float = zFar > 0 ? Float(zFar) : 0
        return projectionMatrixFromIntrinsics(displayOrientation: orientation, zNear: Float(zNear), zFar: zF)
    }

    /// Projects a 3D world-space point into 2D viewport pixel coordinates (origin top-left).
    /// Returns (-1, -1) if the point is behind the camera. Uses intrinsics and view for the given orientation.
    public func projectPoint(
        _ point: simd_float3,
        orientation: UIInterfaceOrientation,
        viewportSize: CGSize
    ) -> CGPoint {
        let view = viewMatrix(for: orientation)
        let viewPoint = view * simd_float4(point.x, point.y, point.z, 1)
        guard viewPoint.z > 0 else {
            return CGPoint(x: -1, y: -1)
        }
        let invZ = 1.0 / Float(viewPoint.z)
        let K = intrinsics
        let px = K[0, 0] * viewPoint.x * invZ + K[2, 0]
        let py = K[1, 1] * viewPoint.y * invZ + K[2, 1]
        return CGPoint(x: CGFloat(px), y: CGFloat(py))
    }

    /// Returns the camera transform with a Z-axis rotation applied so it matches the given screen orientation.
    /// Sensor frame is landscape-right; portrait adds π/2, portrait-upside-down adds -π/2, landscape-left adds π.
    public func displayOrientedTransform(orientation: UIInterfaceOrientation) -> simd_float4x4 {
        let angle: Float
        switch orientation {
        case .portrait:             angle = .pi / 2
        case .portraitUpsideDown:   angle = -.pi / 2
        case .landscapeLeft:        angle = .pi
        default:                    angle = 0  // .landscapeRight: no correction needed
        }
        guard angle != 0 else { return transform }
        return transform * simd_float4x4(simd_quatf(angle: angle, axis: [0, 0, 1]))
    }

    /// Viewport rect that covers the drawable via aspect-fill, matching how NSDKView renders the camera background.
    /// ARKit sensor images are always in landscape orientation.
    /// - Parameters:
    ///   - drawableSize: The drawable size (e.g. MTKView drawable size).
    ///   - displayOrientation: The current device interface orientation. When provided, the content aspect is computed for that orientation so the viewport fits the drawable when the device is in portrait or landscape. When nil, uses the frame's recorded orientation (backward compatibility).
    public func viewportRect(fittingIn drawableSize: CGSize, displayOrientation: UIInterfaceOrientation? = nil) -> CGRect {
        let rawW = CGFloat(metadata.cameraImageWidth)
        let rawH = CGFloat(metadata.cameraImageHeight)
        guard rawW > 0, rawH > 0 else {
            return CGRect(origin: .zero, size: drawableSize)
        }

        // Content aspect as displayed on screen: use current display orientation when provided,
        // so the viewport fits the drawable in any device orientation (portrait or landscape).
        let orientation = displayOrientation ?? metadata.orientation ?? .portrait
        let isDisplayPortrait = orientation == .portrait || orientation == .portraitUpsideDown
        let displayW = isDisplayPortrait ? rawH : rawW
        let displayH = isDisplayPortrait ? rawW : rawH

        let displayAspect = displayW / displayH
        let drawableAspect = drawableSize.width / drawableSize.height

        // Aspect-fill: scale to cover the entire drawable, cropping if necessary,
        // to match how NSDKView renders the camera background.
        let width: CGFloat
        let height: CGFloat
        if drawableAspect > displayAspect {
            width = drawableSize.width
            height = width / displayAspect
        } else {
            height = drawableSize.height
            width = height * displayAspect
        }
        let x = (drawableSize.width - width) * 0.5
        let y = (drawableSize.height - height) * 0.5
        return CGRect(x: x, y: y, width: width, height: height)
    }

    // MARK: - Private helpers

    /// Extracts pitch, yaw, roll (in radians) from a 4×4 transform using the same convention as ARKit.
    private static func eulerAngles(from t: simd_float4x4) -> simd_float3 {
        let r00 = t.columns.0.x, r10 = t.columns.0.y, r20 = t.columns.0.z
        let r01 = t.columns.1.x, r11 = t.columns.1.y, r21 = t.columns.1.z
        let r02 = t.columns.2.x, r12 = t.columns.2.y, r22 = t.columns.2.z
        var pitch: Float = 0, yaw: Float = 0, roll: Float = 0
        let sy = sqrt(r00 * r00 + r10 * r10)
        if sy > 1e-6 {
            pitch = atan2(-r20, sy)
            yaw = atan2(r10, r00)
            roll = atan2(r21, r22)
        } else {
            pitch = atan2(-r20, sy)
            yaw = atan2(-r01, r11)
            roll = 0
        }
        return SIMD3<Float>(pitch, yaw, roll)
    }

    /// Builds a 4×4 projection matrix from intrinsics for the given display orientation and near/far planes.
    /// Portrait swaps fx/fy and width/height; landscape-left negates principal-point terms so the image is flipped correctly.
    private func projectionMatrixFromIntrinsics(displayOrientation: UIInterfaceOrientation, zNear: Float, zFar: Float) -> simd_float4x4 {
        let K = intrinsics
        let fx_raw = K[0, 0], fy_raw = K[1, 1], cx_raw = K[2, 0], cy_raw = K[2, 1]
        let w_raw = Float(metadata.cameraImageWidth), h_raw = Float(metadata.cameraImageHeight)

        // ARKit sensor images are always landscape. Swap intrinsics for portrait display to match
        // the π/2 rotation applied by displayOrientedTransform. For landscape-left (π rotation),
        // the sensor axes are both negated so the principal-point offset terms C and D are flipped.
        let isPortrait = displayOrientation == .portrait || displayOrientation == .portraitUpsideDown
        let isLandscapeLeft = displayOrientation == .landscapeLeft
        let fx = isPortrait ? fy_raw : fx_raw
        let fy = isPortrait ? fx_raw : fy_raw
        let cx = isPortrait ? cy_raw : cx_raw
        let cy = isPortrait ? cx_raw : cy_raw
        let w  = isPortrait ? h_raw  : w_raw
        let h  = isPortrait ? w_raw  : h_raw
        let A = (2.0 * fx) / w
        let B = (2.0 * fy) / h
        let C = isLandscapeLeft ? (2.0 * cx - w) / w : (w - 2.0 * cx) / w
        let D = isLandscapeLeft ? (h - 2.0 * cy) / h : (2.0 * cy - h) / h
        var E: Float = 0, F: Float = 0
        if zFar > 0 {
            E = -(zFar + zNear) / (zFar - zNear)
            F = -(2.0 * zFar * zNear) / (zFar - zNear)
        } else {
            E = -1
            F = -2.0 * zNear
        }
        return simd_float4x4(
            SIMD4<Float>(A, 0, 0, 0),
            SIMD4<Float>(0, B, 0, 0),
            SIMD4<Float>(C, D, E, -1),
            SIMD4<Float>(0, 0, F, 0)
        )
    }

    /// Converts a 16-element double array (column-major) from metadata into simd_float4x4.
    private static func matrix4x4(from proj: [Double]) -> simd_float4x4 {
        guard proj.count >= 16 else { return matrix_identity_float4x4 }
        return simd_float4x4(
            SIMD4<Float>(Float(proj[0]), Float(proj[1]), Float(proj[2]), Float(proj[3])),
            SIMD4<Float>(Float(proj[4]), Float(proj[5]), Float(proj[6]), Float(proj[7])),
            SIMD4<Float>(Float(proj[8]), Float(proj[9]), Float(proj[10]), Float(proj[11])),
            SIMD4<Float>(Float(proj[12]), Float(proj[13]), Float(proj[14]), Float(proj[15]))
        )
    }
}
