import CArdk

/// Defines the available logging levels for NSDK.
///
/// `NSDKLogLevel` controls the verbosity of logging output from the NSDK system.
/// Logging can be configured separately for stdout, files, and callback functions.
///
/// ## Overview
///
/// Log levels follow a hierarchical structure where higher levels include all messages
/// from lower levels. For example, setting the level to `.warn` will include warning,
/// error, and fatal messages, but exclude debug and info messages.
public enum NSDKLogLevel {
    /// Logs all messages regardless of level.
    ///
    /// This is the most verbose logging level and should only be used for debugging.
    case all

    /// Logs debug messages and all higher priority messages.
    ///
    /// Debug messages provide detailed information useful for development and troubleshooting.
    case debug

    /// Logs informational messages and all higher priority messages.
    ///
    /// Info messages provide general information about system operation and state changes.
    case info

    /// Logs warning messages and all higher priority messages.
    ///
    /// Warning messages indicate potential issues that don't prevent operation but may
    /// affect performance or reliability.
    case warn

    /// Logs error messages and fatal messages.
    ///
    /// Error messages indicate problems that prevent normal operation or may cause
    /// unexpected behavior.
    case error

    /// Disables all logging output.
    ///
    /// This level completely suppresses all log messages for maximum performance.
    case off

    // Convert Swift → C enum
    var cValue: ARDK_LogLevel {
        switch self {
        case .all:   return ARDK_LogLevel_All
        case .debug: return ARDK_LogLevel_Debug
        case .info:  return ARDK_LogLevel_Info
        case .warn:  return ARDK_LogLevel_Warn
        case .error: return ARDK_LogLevel_Error
        case .off:   return ARDK_LogLevel_Off
        }
    }

    // Convert C enum → Swift
    init(fromC cLevel: ARDK_LogLevel) {
        switch cLevel {
        case ARDK_LogLevel_All:   self = .all
        case ARDK_LogLevel_Debug: self = .debug
        case ARDK_LogLevel_Info:  self = .info
        case ARDK_LogLevel_Warn:  self = .warn
        case ARDK_LogLevel_Error: self = .error
        case ARDK_LogLevel_Off:   self = .off
        default:                  self = .info
        }
    }
}

/// Provides logging configuration functionality for NSDK.
///
/// `LoggingApi` contains static methods for configuring different logging outputs
/// in the NSDK system. Each method allows setting a specific log level for a particular
/// output destination.
///
/// ## Overview
///
/// NSDK supports three types of logging outputs:
/// - **Stdout**: Console output for development and debugging
/// - **File**: Persistent log files for analysis and troubleshooting
/// - **Callback**: Custom logging functions for integration with existing systems
internal class LoggingApi {
    /// Sets the logging level for stdout output.
    ///
    /// This method controls the verbosity of log messages sent to the console.
    /// Useful for development and debugging sessions.
    ///
    /// - Parameters:
    ///   - nsdkHandle: The NSDK session handle
    ///   - logLevel: The desired logging level for stdout
    static public func setStdoutLogLevel(
        nsdkHandle: ARDK_Handle,
        logLevel: NSDKLogLevel
    ) {
        let cStatus = ARDK_Logging_SetStdoutLogLevel(nsdkHandle, logLevel.cValue)
        if cStatus.isError { return nsdkUnexpected(cStatus, returning: ()) }
    }

    /// Sets the logging level for file output.
    ///
    /// This method controls the verbosity of log messages written to log files.
    /// File logging provides persistent records for analysis and troubleshooting.
    ///
    /// - Parameters:
    ///   - nsdkHandle: The NSDK session handle
    ///   - logLevel: The desired logging level for file output
    static public func setFileLogLevel(
        nsdkHandle: ARDK_Handle,
        logLevel: NSDKLogLevel
    ) {
        let cStatus = ARDK_Logging_SetFileLogLevel(nsdkHandle, logLevel.cValue)
        if cStatus.isError { return nsdkUnexpected(cStatus, returning: ()) }
    }

    /// Sets the logging level for callback functions.
    ///
    /// This method controls the verbosity of log messages sent to custom callback
    /// functions. Useful for integrating NSDK logging with existing logging systems.
    ///
    /// - Parameters:
    ///   - nsdkHandle: The NSDK session handle
    ///   - logLevel: The desired logging level for callback functions
    static public func setCallbackLogLevel(
        nsdkHandle: ARDK_Handle,
        logLevel: NSDKLogLevel
    ) {
        let cStatus = ARDK_Logging_SetCallbackLogLevel(nsdkHandle, logLevel.cValue)
        if cStatus.isError { return nsdkUnexpected(cStatus, returning: ()) }
    }

    /// Enables or disables log throttling globally.
    ///
    /// When disabled, all throttled log callsites log unconditionally regardless of their
    /// configured interval. Useful for debugging noisy per-frame logs. Throttling is enabled
    /// by default.
    ///
    /// - Parameters:
    ///   - enabled: Pass `true` to enable throttling (default), `false` to disable.
    static public func setThrottleEnabled(enabled: Bool) {
        ARDK_Logging_SetThrottleEnabled(enabled)
    }
}
