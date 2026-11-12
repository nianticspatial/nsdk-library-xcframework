import CArdk
import os

/// Errors thrown by the NSDK API.
///
/// `NSDKError` a subset of all the `ARDK_Status`codes returned by the C API,
/// containing just those that can occur in the Swift environment.
public enum NSDKError: Error, Equatable {
    /// A null argument was passed where a valid value was required.
    ///
    /// This typically indicates an internal error, as the Swift wrapper
    /// should prevent null arguments from being passed to the C API.
    case nullArgument
    
    /// An invalid argument was provided to the operation.
    ///
    /// This occurs when arguments are technically valid (non-null) but
    /// contain invalid values, such as out-of-range numbers or malformed data.
    case invalidArgument
    
    /// The requested operation cannot be performed in the current state.
    ///
    /// For example, trying to start a feature that's already running,
    /// or attempting to get data before initialization is complete.
    case invalidOperation
    
    /// Indicates an internal malfunction. In a working version of NSDK,
    /// an application should never see this result code.
    case unknown(msg: String)
    
    init(fromC cValue: ARDK_Status) {
        switch cValue {
        case ARDK_Status_NullArgument:
            self = .nullArgument
        case ARDK_Status_InvalidArgument:
            self = .invalidArgument
        case ARDK_Status_InvalidOperation:
            self = .invalidOperation
        default:
            self = .unknown(msg: "Unexpected initialization from native \(cValue)")
        }
    }
    
    public static func ==(lhs: NSDKError, rhs: NSDKError) -> Bool {
        switch (lhs, rhs) {
        case (.nullArgument, .nullArgument),
             (.invalidArgument, .invalidArgument),
             (.invalidOperation, .invalidOperation):
            return true
        case let (.unknown(msg1), .unknown(msg2)):
            return msg1 == msg2
        default:
            return false
        }
    }
}

// MARK: - Failure funnels
//
// NSDK does not terminate the host application. When it reaches a condition it cannot
// handle, it reports the problem and carries on: `nsdkUnexpected` returns the neutral value
// the caller nominates, and `nsdkUnexpectedError` returns an error for a throwing caller to
// throw.

private let nsdkDiagnosticsLog = Logger(
    subsystem: "com.nianticspatial.nsdk",
    category: "diagnostics"
)

/// Single point at which every recoverable NSDK failure is reported.
///
/// Set a symbolic breakpoint here to stop at the moment of failure while debugging.
@inline(__always)
private func reportUnexpected(_ message: String) {
    let detail = message.hasSuffix(".") ? message : message + "."
    nsdkDiagnosticsLog.fault(
        "NSDK unexpected: \(detail, privacy: .public) NSDK may not work correctly until this is resolved."
    )
}

/// Describes a status the calling code does not handle, with the only guidance that applies
/// to every such call.
@inline(__always)
private func unhandledStatusMessage(_ cStatus: ARDK_Status) -> String {
    "unhandled ARDK_Status \(cStatus). Check the arguments and session state for this call."
}

/// Reports a condition NSDK does not expect to encounter, then returns `value`.
///
/// - Parameters:
///   - message: Description of the condition, for the log.
///   - value: The result the caller should produce instead. Choose the value that makes
///     the call a no-op for the caller, such as `nil`, `false`, or an empty collection.
/// - Returns: `value`, unchanged.
@inline(__always)
func nsdkUnexpected<T>(_ message: String, returning value: T) -> T {
    reportUnexpected(message)
    return value
}

/// Reports a non-ok `ARDK_Status` that the calling code does not handle explicitly,
/// then returns `value`.
@inline(__always)
func nsdkUnexpected<T>(_ cStatus: ARDK_Status, returning value: T) -> T {
    reportUnexpected(unhandledStatusMessage(cStatus))
    return value
}

/// Reports a status a `throws` function does not handle explicitly, and returns the error
/// it should throw.
///
/// Preferred over ``nsdkUnexpected(_:returning:)`` wherever the enclosing function already
/// throws: the caller has an error channel, so there is no reason to discard the failure.
@inline(__always)
func nsdkUnexpectedError(_ cStatus: ARDK_Status) -> NSDKError {
    reportUnexpected(unhandledStatusMessage(cStatus))
    return NSDKError(fromC: cStatus)
}

/// Reports a Swift-side conversion failure in a `throws` function, and returns the error
/// it should throw.
@inline(__always)
func nsdkUnexpectedError(_ message: String) -> NSDKError {
    reportUnexpected(message)
    return .unknown(msg: message)
}

