//
//  NSDKView.swift
//  NSDK
//
//  Single view for both live AR and playback. Subclasses ARView.
//

import ARKit
import RealityKit
import UIKit

public protocol NSDKViewDelegate: AnyObject, ARSessionDelegate, PlaybackSessionDelegate { }

/// Single view for both live and playback. Subclasses **ARView**; holds either an **ARSession** (live)
/// or **PlaybackSession** (playback) and exposes `sessionMode`, `getCamera()`, `setDelegate()`, `setup()`.
/// Relation to Apple AR: **Uses** ARView; assigns either Apple's ARSession or our PlaybackSession to
/// `self.session` so the view always has a "session." The app talks to NSDKView so it doesn't have to
/// branch on live vs. playback for view, projection, viewport, or delegate callbacks.
public class NSDKView : ARView {
    public enum SessionMode {
        case live(ARSession)
        case playback(PlaybackSession)
    }

    private let internalSessionMode: SessionMode

    /// The current session mode (live AR or playback). Switch on this to access the underlying ARSession or PlaybackSession.
    public var sessionMode: SessionMode { internalSessionMode }
    
    /// Unified session delegate (live or playback).
    /// Automatically forwards to the underlying ARSession or PlaybackSession.
    public weak var delegate: NSDKViewDelegate? {
        didSet {
            switch internalSessionMode { 
            case .live(let liveSession):
                liveSession.delegate = delegate
            case .playback(let playbackSession):
                playbackSession.playbackDelegate = delegate
            }
        }
    }

    /// Returns whether depth data is available for this session.
    /// In playback, true if the dataset has LiDAR depth; in live, true if the device has a LiDAR sensor.
    public var hasDepth: Bool {
        switch internalSessionMode {
        case .playback(let playbackSession):
            return playbackSession.hasDepth()
        case .live:
            return ARUtils.isLidarAvailable()
        }
    }
    
    /// Initializes the view in live AR mode with a new ARSession.
    /// The session is assigned to the underlying ARView so ARKit drives the camera and tracking.
    public init() {
        let liveSession = ARSession()
        internalSessionMode = .live(liveSession)
        super.init(frame: .zero)
        self.session = liveSession
    }

    /// Initializes the view in playback mode with a loaded dataset.
    /// Uses a PlaybackSession and disables ARKit's automatic session configuration so playback drives the camera.
    public init(dataset: PlaybackDataset) {
        let playbackSession = PlaybackSession(dataset: dataset)
        internalSessionMode = .playback(playbackSession)
        super.init(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        self.session = playbackSession
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    @available(*, unavailable)
    required init(frame: CGRect) {
        fatalError("init(frame:) is not supported. Use init() or init(dataset:) instead.")
    }
    
    /// Adds the NSDKView to the given container and sets up playback rendering when in playback mode.
    /// In playback, creates the PlaybackRenderer (background + camera) first so the camera image is drawn behind RealityKit content.
    /// Call this after creating the NSDKView; the view is constrained to fill the container.
    public func setup(in view: UIView) {
        // Setup playback objects first so the background renderer draws behind everything.
        if case .playback(let playbackSession) = internalSessionMode {
            playbackSession.playbackRenderer = PlaybackRenderer(in: view, arView: self)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    /// Returns a unified camera (NSDKCamera) for the current frame when one is available.
    /// In live mode uses the current ARFrame's camera; in playback uses the current playback frame's camera.
    /// Returns nil if no frame is ready. Use this so callers do not need to branch on session mode for view/projection/viewport.
    public func getCamera() -> NSDKCamera? {
        switch internalSessionMode {
        case .live(let liveSession):
            guard let frame = liveSession.currentFrame else { return nil }
            return NSDKCamera(arCamera: frame.camera)
        case .playback(let playbackSession):
            guard let frame = playbackSession.currentPlaybackFrame else { return nil }
            return NSDKCamera(playbackCamera: frame.camera)
        }
    }
}
