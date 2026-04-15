// Copyright Niantic Spatial.

/// Telemetry backend environment passed to native on session start.
///
/// Use this type instead of a free `String` so only supported values (`dev`, `stg`, `prod`) compile.
public enum NSDKTelemetryEnvironment: String, Sendable {
    case dev
    case stg
    case prod
}
