// Copyright 2022-2026 Niantic Spatial.

import Foundation

/// Internal utility that auto-detects device metadata for telemetry.
///
/// Used as default values for `NSDKSession.DeviceInfo` so that
/// `application_id`, `manufacturer`, `device_model`, and `platform` are
/// populated without requiring the developer to set them explicitly.
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
}
