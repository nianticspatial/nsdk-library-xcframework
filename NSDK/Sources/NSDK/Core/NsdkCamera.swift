//
//  NSDKCamera.swift
//  NSDK
//
//  Unified camera API for both live and playback.
//

import Foundation
import UIKit
import ARKit
import simd
import CoreGraphics

/// Single camera API for both modes. Holds either **ARCamera** (live) or **PlaybackCamera** (playback)
/// and exposes transform, viewMatrix, projectionMatrix, viewportRect, etc.
/// Relation to Apple AR: **Wraps** Apple's ARCamera in live mode; wraps our PlaybackCamera in playback.
/// Callers use NSDKCamera and don't branch. Create via `NSDKCamera(arCamera:)` or `NSDKCamera(playbackCamera:)`.
public final class NSDKCamera {

    /// The underlying camera: either a live ARCamera or a playback PlaybackCamera.
    /// Switch on this when you need to call APIs that are specific to one type (e.g. `recordedOrientation` on PlaybackCamera).
    ///
    /// Example:
    /// ```swift
    /// switch camera.backing {
    /// case .ar(let arCamera):
    ///     // ARCamera-specific APIs
    /// case .playback(let playbackCamera):
    ///     let orientation = playbackCamera.recordedOrientation
    /// }
    /// ```
    public enum Backing {
        case ar(ARCamera)
        case playback(PlaybackCamera)
    }

    private let internalBacking: Backing

    /// The underlying camera (live or playback). Use this to call ARCamera- or PlaybackCamera-specific APIs.
    public var backing: Backing { internalBacking }

    /// Creates an NSDKCamera that delegates to Apple's ARCamera (live session).
    /// Use when the app is using a live ARSession and you have a current ARFrame's camera.
    public init(arCamera: ARCamera) {
        self.internalBacking = .ar(arCamera)
    }

    /// Creates an NSDKCamera that delegates to PlaybackCamera (playback session).
    /// Use when playing back a recorded dataset; pass the frame's camera from `PlaybackFrame.camera`.
    public init(playbackCamera: PlaybackCamera) {
        self.internalBacking = .playback(playbackCamera)
    }

    /// The 4×4 transformation matrix of the camera in world coordinates (camera-to-world).
    /// Same convention as ARCamera.transform; use for placing virtual content relative to the camera.
    public var transform: simd_float4x4 {
        switch internalBacking {
        case .ar(let c): return c.transform
        case .playback(let c): return c.transform
        }
    }

    /// The camera's orientation as Euler angles (pitch, yaw, roll) in radians.
    public var eulerAngles: simd_float3 {
        switch internalBacking {
        case .ar(let c): return c.eulerAngles
        case .playback(let c): return c.eulerAngles
        }
    }

    /// The camera intrinsics matrix (3×3) in row-major layout: [fx, 0, 0; 0, fy, 0; cx, cy, 1].
    /// Use for unprojecting image coordinates to camera rays or building projection matrices.
    public var intrinsics: simd_float3x3 {
        switch internalBacking {
        case .ar(let c): return c.intrinsics
        case .playback(let c): return c.intrinsics
        }
    }

    /// The camera image resolution in pixels.
    public var imageResolution: CGSize {
        switch internalBacking {
        case .ar(let c): return c.imageResolution
        case .playback(let c): return c.imageResolution
        }
    }

    /// The camera's tracking state.
    public var trackingState: ARCamera.TrackingState {
        switch internalBacking {
        case .ar(let c): return c.trackingState
        case .playback(let c): return c.trackingState
        }
    }

    /// Camera exposure duration in seconds.
    @available(iOS 13.0, *)
    public var exposureDuration: TimeInterval {
        switch internalBacking {
        case .ar(let c): return c.exposureDuration
        case .playback(let c): return c.exposureDuration
        }
    }

    /// Camera exposure offset in EV.
    @available(iOS 13.0, *)
    public var exposureOffset: Float {
        switch internalBacking {
        case .ar(let c): return c.exposureOffset
        case .playback(let c): return c.exposureOffset
        }
    }

    /// Default projection matrix (no far clipping).
    public var projectionMatrix: simd_float4x4 {
        switch internalBacking {
        case .ar(let c): return c.projectionMatrix
        case .playback(let c): return c.projectionMatrix
        }
    }

    /// Returns the view matrix (world-to-camera) for the given interface orientation.
    /// Pass the current device orientation (e.g. from the window scene) so that rendering follows the device when rotated.
    /// For both live and playback, the returned matrix matches the display-oriented camera transform.
    public func viewMatrix(for orientation: UIInterfaceOrientation) -> simd_float4x4 {
        switch internalBacking {
        case .ar(let c): return c.viewMatrix(for: orientation)
        case .playback(let c): return c.viewMatrix(for: orientation)
        }
    }

    /// Returns a projection matrix for the given orientation and viewport size, with optional near/far clipping.
    /// Pass the same orientation and viewport size used for the view matrix so that 3D content projects correctly.
    /// zFar > 0 uses a finite far plane; zFar <= 0 yields an infinite far plane (e.g. for skyboxes).
    public func projectionMatrix(
        for orientation: UIInterfaceOrientation,
        viewportSize: CGSize,
        zNear: CGFloat,
        zFar: CGFloat
    ) -> simd_float4x4 {
        switch internalBacking {
        case .ar(let c): return c.projectionMatrix(for: orientation, viewportSize: viewportSize, zNear: zNear, zFar: zFar)
        case .playback(let c): return c.projectionMatrix(for: orientation, viewportSize: viewportSize, zNear: zNear, zFar: zFar)
        }
    }

    /// Projects a 3D point in world space into 2D viewport coordinates (origin top-left, in pixels).
    /// Returns (-1, -1) if the point is behind the camera. Use with the same orientation and viewport size as rendering.
    public func projectPoint(
        _ point: simd_float3,
        orientation: UIInterfaceOrientation,
        viewportSize: CGSize
    ) -> CGPoint {
        switch internalBacking {
        case .ar(let c): return c.projectPoint(point, orientation: orientation, viewportSize: viewportSize)
        case .playback(let c): return c.projectPoint(point, orientation: orientation, viewportSize: viewportSize)
        }
    }

    /// Returns the camera transform adjusted for the given display orientation (Z-axis rotation applied).
    /// Use when you need the camera pose in the same coordinate frame as the on-screen image (e.g. for overlay alignment).
    public func displayOrientedTransform(orientation: UIInterfaceOrientation) -> simd_float4x4 {
        switch internalBacking {
        case .ar(let c): return c.displayOrientedTransform(orientation: orientation)
        case .playback(let c): return c.displayOrientedTransform(orientation: orientation)
        }
    }

    /// When in playback, the orientation the frame was recorded in. When in live, returns nil.
    /// View and projection matrices use the orientation passed by the caller so rendering can follow the device.
    public var effectiveRenderingOrientation: UIInterfaceOrientation? {
        switch internalBacking {
        case .ar: return nil
        case .playback(let c): return c.recordedOrientation
        }
    }

    /// Returns the viewport rect to use when rendering into the given drawable size.
    /// - Live: returns the full drawable (origin zero, size = drawableSize).
    /// - Playback: returns an aspect-fill rect so the camera image aligns with the rendered content; pass `displayOrientation` (current device orientation) so the viewport fits correctly in portrait and landscape.
    public func viewportRect(fittingIn drawableSize: CGSize, displayOrientation: UIInterfaceOrientation? = nil) -> CGRect {
        switch internalBacking {
        case .ar: return CGRect(origin: .zero, size: drawableSize)
        case .playback(let c): return c.viewportRect(fittingIn: drawableSize, displayOrientation: displayOrientation)
        }
    }
}
