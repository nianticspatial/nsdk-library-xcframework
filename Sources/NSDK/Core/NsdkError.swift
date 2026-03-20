import CArdk

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

@inline(__always)
func unexpectedNSDKStatus(_ cStatus: ARDK_Status) -> Never {
    fatalError("Unexpected NSDK Status: \(cStatus)")
}
