import Foundation
import UIKit
import simd
import CoreGraphics
import CoreVideo
import ARKit

/// Drives playback. **Subclasses ARSession** so it can be assigned to `ARView.session` and the app can use
/// the same delegate pattern. Runs a loop on a background queue, builds **PlaybackFrame** per frame from
/// the PlaybackDataset, dispatches to the main queue, and notifies the delegate and **PlaybackRenderer**.
/// Relation to Apple AR: **Replaces** the behavior of ARSession (no real device frames); API-compatible so
/// ARView and delegate code don't need to know it's playback.
public class PlaybackSession : ARSession, @unchecked Sendable {
    private var currentFrameIndex: Int = 0
    private let playbackQueue = DispatchQueue(label: "com.nsdk.playback", qos: .userInitiated)
    private var isPlaying: Bool = false
    private var lastTrackingValue: Int? = nil
    private let playbackDataset: PlaybackDataset
    
    /// Delegate that receives frame updates during playback
    public weak var playbackDelegate: (any PlaybackSessionDelegate)?
    public var playbackRenderer: PlaybackRenderer?

    /// The most recently delivered playback frame. Set on the main queue when each frame is delivered.
    /// Use this to get camera or frame data outside the delegate (e.g. in a render loop).
    public private(set) var currentPlaybackFrame: PlaybackFrame?

    /// Initializes a new playback session with an existing dataset.
    /// 
    /// - Parameter dataset: The playback dataset to use
    public init(dataset: PlaybackDataset) {
        self.playbackDataset = dataset
    }
    
    /// Main playback loop: fetches the current frame from the dataset, builds a PlaybackFrame, and dispatches to the main queue.
    /// Runs on the playback queue. Between frames it sleeps for the dataset's frame interval. When the last frame is reached,
    /// the index wraps to 0 so playback loops indefinitely. On error it skips to the next frame and continues.
    private func playbackLoop() {
        while isPlaying {
            do {
                let metadata = try playbackDataset.getFrameDataAtIndex(index: currentFrameIndex)
                let image = try playbackDataset.getFrameImageAtIndex(index: currentFrameIndex)
                let depthData = try playbackDataset.getDepthDataAtIndex(index: currentFrameIndex)
                let depthConfidence = try playbackDataset.getDepthConfidenceAtIndex(index: currentFrameIndex)
                
                let frame = PlaybackFrame(
                    metadata: metadata,
                    image: image,
                    depthData: depthData,
                    depthConfidence: depthConfidence
                )
                
                // Capture delegate, renderer, and tracking state change before dispatching
                let delegate = self.playbackDelegate
                let renderer = self.playbackRenderer
                let trackingValue = metadata.tracking
                let trackingStateChanged = trackingValue != self.lastTrackingValue
                self.lastTrackingValue = trackingValue

                DispatchQueue.main.async {
                    self.currentPlaybackFrame = frame
                    if trackingStateChanged {
                        delegate?.playbackSession(self, cameraDidChangeTrackingState: frame.camera)
                    }
                    delegate?.playbackSession(self, didUpdate: frame)
                    renderer?.renderFrame(frame)
                }

                // Move to next frame, looping back to start if needed
                currentFrameIndex = (currentFrameIndex + 1) % playbackDataset.frameCount
                Thread.sleep(forTimeInterval: playbackDataset.frameInterval)
            } catch {
                print("PlaybackSession: Error retrieving frame at index \(currentFrameIndex): \(error.localizedDescription)")
                // Skip to next frame on error
                currentFrameIndex = (currentFrameIndex + 1) % playbackDataset.frameCount
                Thread.sleep(forTimeInterval: playbackDataset.frameInterval)
            }
        }
    }
    
    /// Starts playback. The playback loop runs asynchronously on a background queue; frames are delivered on the main queue.
    /// Configuration and options are ignored (playback uses the dataset's frame rate and content). Call `pause()` to stop.
    public override func run(_ configuration: ARConfiguration, options: ARSession.RunOptions = []) {
        isPlaying = true
        lastTrackingValue = nil
        playbackQueue.async { [weak self] in
            self?.playbackLoop()
        }
    }

    /// Stops playback. The loop exits on its next iteration; the current frame index is preserved so a later `run()` resumes from the same frame.
    public override func pause() {
        isPlaying = false
    }
    
    /// Returns whether the dataset contains LiDAR depth (depthSource == "lidar"). Used by NSDKView.hasDepth and feature checks.
    public func hasDepth() -> Bool {
        return playbackDataset.hasDepth()
    }
    
    deinit {
        isPlaying = false
    }
}

/// Delegate protocol for receiving frame updates during playback (mirrors ARSessionDelegate-style callbacks).
public protocol PlaybackSessionDelegate: AnyObject {
    /// Called on the main queue each time a new playback frame is ready. Use the frame's metadata, image, and optional depth for rendering or processing.
    func playbackSession(_ session: PlaybackSession, didUpdate frame: PlaybackFrame)

    /// Called on the main queue when the tracking state changes (e.g. at start of playback). For playback, state is typically .normal.
    func playbackSession(_ session: PlaybackSession, cameraDidChangeTrackingState camera: PlaybackCamera)
}

public extension PlaybackSessionDelegate {
    func playbackSession(_ session: PlaybackSession, cameraDidChangeTrackingState camera: PlaybackCamera) {}
}

