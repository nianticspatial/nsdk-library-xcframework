import Foundation
import CoreGraphics
import CoreVideo

/// One "frame" of playback: metadata (pose, intrinsics, orientation, etc.), optional camera image, optional depth.
/// Exposes `.camera` → **PlaybackCamera**. Created by PlaybackSession and delivered to the delegate and PlaybackRenderer.
/// Relation to Apple AR: Not an Apple type. Delivered **instead of ARFrame** when in playback; the app gets
/// frame-like data (image, camera, etc.) from the delegate so app code can stay uniform.
public struct PlaybackFrame: @unchecked Sendable {
    /// Frame metadata from the dataset: pose4x4, intrinsics, resolution, tracking state, orientation, timestamps, location.
    public let metadata: PlaybackDataset.FrameMetadata

    /// Camera representation for this frame (view/projection/viewport). Created once when the frame is built; use without branching on session type.
    public let camera: PlaybackCamera

    /// The RGB camera image for this frame (e.g. for background display). Nil if the dataset has no image for this index.
    public let image: CGImage?

    /// Depth buffer (Float32, meters) for this frame if the dataset includes LiDAR depth; otherwise nil.
    public let depthData: CVPixelBuffer?

    /// Per-pixel depth confidence (UInt8) when available; nil if not present in the dataset.
    public let depthConfidence: CVPixelBuffer?

    /// Creates a playback frame with the given metadata and optional image/depth buffers.
    public init(
        metadata: PlaybackDataset.FrameMetadata,
        image: CGImage?,
        depthData: CVPixelBuffer? = nil,
        depthConfidence: CVPixelBuffer? = nil
    ) {
        self.metadata = metadata
        self.camera = PlaybackCamera(metadata: metadata)
        self.image = image
        self.depthData = depthData
        self.depthConfidence = depthConfidence
    }
}
