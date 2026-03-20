import CArdk

/// Status of a network request.
public enum NSDKNetworkRequestStatus {
    /// Unknown request status.
    case unknown

    /// The request is pending.
    case pending

    /// The request completed successfully.
    case successful

    /// The request failed.
    case failed

    internal init(fromC cValue: ARDK_NetworkRequestStatus) {
        switch cValue {
        case kNetworkRequestStatus_Pending:
            self = .pending
        case kNetworkRequestStatus_Successful:
            self = .successful
        case kNetworkRequestStatus_Failed:
            self = .failed
        case kNetworkRequestStatus_Unknown:
            fallthrough
        default:
            self = .unknown
        }
    }

    internal func convertToC() -> ARDK_NetworkRequestStatus {
        switch self {
        case .unknown:
            return kNetworkRequestStatus_Unknown
        case .pending:
            return kNetworkRequestStatus_Pending
        case .successful:
            return kNetworkRequestStatus_Successful
        case .failed:
            return kNetworkRequestStatus_Failed
        }
    }
}
