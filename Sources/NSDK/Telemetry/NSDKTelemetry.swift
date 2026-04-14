// Copyright 2022-2026 Niantic.

import CArdk

/// Namespace for NSDK telemetry controls.
public enum NSDKTelemetry {
    /// Disables telemetry for the current process.
    ///
    /// Clears any buffered events and stops the telemetry sink from accepting new ones.
    /// Call this before initializing ARDK if you want to opt out of telemetry entirely.
    public static func disable() {
        Lightship_ARDK_TelemetrySink_Disable()
    }
}
