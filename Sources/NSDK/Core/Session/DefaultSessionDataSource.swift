import Foundation
import CoreLocation
import CoreVideo
import ARKit
import NSDK

// Proxy for acquiring the UI orientation
public protocol UIOrientationReporter: AnyObject {
    var currentOrientation: NSDKScreenOrientation { get }
}

/// Default iOS implementation of `NSDKSessionDataSource` backed by
/// `ARSession` and `CLLocationManager`.
public final class DefaultSessionDataSource: NSObject {
    
    // Location services for gps and compass
    private let locationManager = CLLocationManager()
    
    // ARSession for the camera image and pose
    private weak var arSession: ARSession?
    
    // Component that supplies the current latest UI orientation
    private weak var orientationReporter: UIOrientationReporter?
    
    // Protect shared state
    private let lock = NSLock()
    
    // Cached location updates
    private var _latestLocation: CLLocation?
    private var _latestHeading: CLHeading?
    
    /// Creates a data source that reads camera frames from the provided AR session.
    ///
    /// The AR session is not owned by this object and must be configured and run
    /// by the caller.
    public init(session: ARSession, orientationReporter: UIOrientationReporter) {
        super.init()
        
        self.arSession = session
        self.orientationReporter = orientationReporter
        self.startLocationServices()
    }
    
    deinit {
        // Stop location services
        locationManager.stopUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.stopUpdatingHeading()
        }
    }
    
    /// Configures and starts Core Location services.
    private func startLocationServices() {
        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request permission first
        locationManager.requestWhenInUseAuthorization()
        
        // If already authorized, start right away
        startUpdatesIfAuthorized()
    }
    
    /// Starts location and heading updates if authorization permits.
    private func startUpdatesIfAuthorized() {
        let status = locationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
        
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    /// Helper to get a snapshot of the latest location reading
    private func getLatestLocation() -> CLLocation? {
        lock.lock()
        defer { lock.unlock() }
        return _latestLocation
    }
    
    /// Helper to get a snaphot of the latest heading reading
    private func getLatestHeading() -> CLHeading? {
        lock.lock()
        defer { lock.unlock() }
        return _latestHeading
    }
}

// MARK: - NSDKSessionDataSource

extension DefaultSessionDataSource : NSDKSessionDataSource {
    public var isReady: Bool {
        guard let frame = arSession?.currentFrame else {
            return false
        }
        
        switch frame.camera.trackingState {
        case .notAvailable:
            return false
        default:
            return true
        }
    }
    
    public func latestTrackingStateSample() -> NsdkTrackingState {
        guard let frame = arSession?.currentFrame else {
            return .unknown
        }
        
        return frame.camera.trackingState.nsdkTrackingState
    }
    
    public func latestCameraSample() -> (image: CVPixelBuffer,
                                         intrinsics: NSDKCameraIntrinsics,
                                         pose: NSDKCameraExtrinsics,
                                         orientation: NSDKScreenOrientation,
                                         timestamp: UInt64)? {
        guard let frame = arSession?.currentFrame else { return nil }
        
        let timestampMs = UInt64(frame.timestamp * 1000)
        let intrinsics = NSDKFrameData.CameraIntrinsics(
            intrinsics: frame.camera.intrinsics,
            resolution: frame.camera.imageResolution
        )
        
        return (
            image: frame.capturedImage,
            intrinsics: intrinsics,
            pose: frame.camera.transform,
            orientation: orientationReporter?.currentOrientation ?? .unknown,
            timestamp: timestampMs
        )
    }
    
    public func latestDepthMapSample() -> (image: CVPixelBuffer,
                                           confidence: CVPixelBuffer?,
                                           intrinsics: NSDKCameraIntrinsics,
                                           pose: NSDKCameraExtrinsics,
                                           orientation: NSDKScreenOrientation,
                                           timestamp: UInt64)? {
        
        guard let frame = arSession?.currentFrame,
              let depthMap = frame.sceneDepth?.depthMap else { return nil }
        
        let timestampMs = UInt64(frame.timestamp * 1000)
        let intrinsics = NSDKFrameData.CameraIntrinsics(
            intrinsics: frame.camera.intrinsics,
            resolution: frame.camera.imageResolution
        )
        
        return (
            image: depthMap,
            confidence: frame.sceneDepth?.confidenceMap,
            intrinsics: intrinsics,
            pose: frame.camera.transform,
            orientation: orientationReporter?.currentOrientation ?? .unknown,
            timestamp: timestampMs
        )
    }
    
    public func latestGpsSample() -> NSDKFrameData.GpsData? {
        guard let location = getLatestLocation() else { return nil }
        
        var altitude = location.altitude
        if #available(iOS 16.0, *) {
            altitude = location.ellipsoidalAltitude
        }
        
        return NSDKFrameData.GpsData(
            timestampMs: UInt64(location.timestamp.timeIntervalSince1970 * 1000),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: altitude,
            verticalAccuracy: Float(location.verticalAccuracy),
            horizontalAccuracy: Float(location.horizontalAccuracy)
        )
    }
    
    public func latestCompassSample() -> NSDKFrameData.CompassData? {
        guard let heading = getLatestHeading() else { return nil }
        
        return NSDKFrameData.CompassData(
            timestampMs: UInt64(heading.timestamp.timeIntervalSince1970 * 1000),
            headingAccuracy: Float(heading.headingAccuracy),
            trueHeading: Float(heading.trueHeading)
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension DefaultSessionDataSource : CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        startUpdatesIfAuthorized()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        
        lock.lock()
        _latestLocation = last
        lock.unlock()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        lock.lock()
        _latestHeading = newHeading
        lock.unlock()
    }
}
