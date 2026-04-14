// Copyright Niantic Spatial.

import CArdk

internal enum TelemetryPublishing {
    @discardableResult
    static func start(environment: NSDKTelemetryEnvironment) -> Bool {
        environment.rawValue.withCString { envC in
            Lightship_ARDK_TelemetryPublishing_Start(envC, "swift")
        }
    }
}
