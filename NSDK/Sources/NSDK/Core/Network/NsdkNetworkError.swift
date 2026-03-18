import CArdk

/// Possible errors from network operations.
public enum NSDKNetworkError {
    /// An unknown network error occurred.
    case unknown

    /// No error has occurred.
    case none

    /// The device cannot connect to the server.
    case badNetworkConnection

    /// The API key specified when initializing ARDK is invalid.
    case badApiKey

    /// Deprecated: permission denied (kept for backwards compatibility).
    case permissionDenied

    /// Deprecated: request limit exceeded (kept for backwards compatibility).
    case requestsLimitExceeded

    /// The server encountered an internal error while processing the request.
    case internalServer

    /// The server response could not be parsed by the client.
    case internalClient

    internal init(fromC cValue: ARDK_NetworkError) {
        switch cValue {
        case kNetworkError_None:
            self = .none
        case kNetworkError_BadNetworkConnection:
            self = .badNetworkConnection
        case kNetworkError_BadApiKey:
            self = .badApiKey
        case kNetworkError_PermissionDenied:
            self = .permissionDenied
        case kNetworkError_RequestsLimitExceeded:
            self = .requestsLimitExceeded
        case kNetworkError_InternalServer:
            self = .internalServer
        case kNetworkError_InternalClient:
            self = .internalClient
        case kNetworkError_Unknown:
            fallthrough
        default:
            self = .unknown
        }
    }

    internal func convertToC() -> ARDK_NetworkError {
        switch self {
        case .unknown:
            return kNetworkError_Unknown
        case .none:
            return kNetworkError_None
        case .badNetworkConnection:
            return kNetworkError_BadNetworkConnection
        case .badApiKey:
            return kNetworkError_BadApiKey
        case .permissionDenied:
            return kNetworkError_PermissionDenied
        case .requestsLimitExceeded:
            return kNetworkError_RequestsLimitExceeded
        case .internalServer:
            return kNetworkError_InternalServer
        case .internalClient:
            return kNetworkError_InternalClient
        }
    }
}
