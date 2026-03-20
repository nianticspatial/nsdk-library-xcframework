import RealityKit
import UIKit

/// Renders each playback frame: (1) draws the recorded camera image as the background, (2) **moves the
/// RealityKit camera** (pose + FOV) to match the playback frame. **PlaybackSession** holds an optional
/// reference and calls `renderFrame(_:)` on the main queue for every new frame.
/// Relation to Apple AR: **Manipulates** RealityKit—sets `arView.environment.background = .color(.clear)`,
/// adds a **PerspectiveCamera** and **AnchorEntity**, and updates their transform and `fieldOfViewInDegrees`
/// every frame from PlaybackCamera. In playback, ARView's default camera is off; we drive the virtual camera.
@MainActor
public class PlaybackRenderer {
    private var camera: PerspectiveCamera
    private var cameraAnchor: AnchorEntity
    private var backgroundRenderer: PlaybackBackgroundRenderer

    /// Creates the renderer: a background view (camera image) in the given container and a RealityKit camera in the ARView.
    /// The ARView's environment background is set to clear so the playback image is visible behind RealityKit content.
    public init(in view: UIView, arView: ARView) {
        backgroundRenderer = PlaybackBackgroundRenderer(frame: view.frame)
        backgroundRenderer.setup(in: view)
        arView.environment.background = .color(.clear)

        let camera = PerspectiveCamera()
        self.camera = camera

        let cameraAnchor = AnchorEntity(world: .zero)
        self.cameraAnchor = cameraAnchor
        cameraAnchor.addChild(camera)

        arView.scene.addAnchor(cameraAnchor)
    }

    /// Called on the main queue for each new playback frame. Updates the background image and the virtual camera pose/FOV to match the frame.
    public func renderFrame(_ frame: PlaybackFrame) {
        updateCameraPosition(frame.camera)
        backgroundRenderer.updateBackgroundImage(image: frame.image)
    }

    /// Sets the RealityKit camera anchor transform from the playback camera's display-oriented pose and updates the camera FOV from intrinsics.
    private func updateCameraPosition(_ playbackCamera: PlaybackCamera) {
        let orientation = currentInterfaceOrientation()
        let matrix = playbackCamera.displayOrientedTransform(orientation: orientation)
        cameraAnchor.transform = Transform(matrix: matrix)

        // Set the FOV to match the recorded camera's intrinsics.
        // In portrait the screen vertical = landscape horizontal (fx, image width).
        // In landscape the screen vertical = landscape vertical (fy, image height).
        let K = playbackCamera.intrinsics
        let res = playbackCamera.imageResolution
        let isPortrait = orientation == .portrait || orientation == .portraitUpsideDown
        let fovRad: Float = isPortrait
            ? 2 * atan(Float(res.width) / (2 * K[0, 0]))
            : 2 * atan(Float(res.height) / (2 * K[1, 1]))
        camera.camera.fieldOfViewInDegrees = fovRad * 180 / .pi
    }

    /// Returns the current device interface orientation from the first window scene, or .portrait if none is available.
    private func currentInterfaceOrientation() -> UIInterfaceOrientation {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        return scene?.interfaceOrientation ?? .portrait
    }
}
