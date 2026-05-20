// Copyright 2022-2026 Niantic Spatial.

import ARKit
import Foundation

/// Internal utility that auto-detects device metadata for telemetry.
///
/// Used as default values for `NSDKSession.DeviceInfo` so that
/// device metadata fields are populated without requiring the developer
/// to set them explicitly.
enum DeviceMetadata {
    /// The application's bundle identifier (e.g. `"com.niantic.myapp"`).
    static var applicationId: String? {
        Bundle.main.bundleIdentifier
    }

    /// Always `"Apple"` on iOS/macOS.
    static let manufacturer: String = "Apple"

    /// Hardware model identifier (e.g. `"iPhone14,5"`, `"iPad13,4"`).
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = systemInfo.machine
        return withUnsafeBytes(of: machine) { buf in
            guard let baseAddress = buf.baseAddress else { return "Unknown" }
            return String(cString: baseAddress.assumingMemoryBound(to: CChar.self))
        }
    }

    /// OS name and version (e.g. `"iOS 18.4"`).
    static var platform: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "iOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    /// Per-launch application instance identifier.
    ///
    /// A new UUID is generated once per process lifetime, matching the Unity
    /// SDK's `AppInstanceId = Guid.NewGuid().ToString()` pattern.
    static let appInstanceId: String = UUID().uuidString

    /// Whether the device has a LiDAR sensor.
    static var deviceLidarSupported: Bool {
        if #available(iOS 14.0, *) {
            return ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
        }
        return false
    }
}
