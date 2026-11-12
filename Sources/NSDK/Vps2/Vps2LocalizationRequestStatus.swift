import CArdk

/// Status of a network request.
public enum Vps2LocalizationRequestStatus {
    /// Unknown request status.
    case unknown

    /// The request has been sent and is awaiting a response.
    case pending

    /// The request completed and a response was received.
    ///
    /// - Note: The localization itself may still have failed — check the localization error for details.
    case completed

    /// The request failed (e.g. network error, HTTP error, or unparseable response). A site
    /// request cancelled by ``NSDKVps2Session/stopLocalize(siteId:)`` also ends failed, with
    /// ``Vps2LocalizationError/unknown``.
    case failed

    /// The request was not sent because the frame was rejected (e.g. camera pointed downward).
    case frameRejected

    /// The frame was flagged for a non-fatal quality issue (e.g. too blurry) but still sent;
    /// use this to warn the user.
    case frameFlagged

    internal init(fromC cValue: ARDK_VPS2_LocalizationRequestStatus) {
        switch cValue {
        case ARDK_VPS2_LocalizationRequestStatus_Pending:
            self = .pending
        case ARDK_VPS2_LocalizationRequestStatus_Completed:
            self = .completed
        case ARDK_VPS2_LocalizationRequestStatus_Failed:
            self = .failed
        case ARDK_VPS2_LocalizationRequestStatus_FrameRejected:
            self = .frameRejected
        case ARDK_VPS2_LocalizationRequestStatus_FrameFlagged:
            self = .frameFlagged
        case ARDK_VPS2_LocalizationRequestStatus_Unknown:
            fallthrough
        default:
            self = .unknown
        }
    }

    internal func convertToC() -> ARDK_VPS2_LocalizationRequestStatus {
        switch self {
        case .unknown:
            return ARDK_VPS2_LocalizationRequestStatus_Unknown
        case .pending:
            return ARDK_VPS2_LocalizationRequestStatus_Pending
        case .completed:
            return ARDK_VPS2_LocalizationRequestStatus_Completed
        case .failed:
            return ARDK_VPS2_LocalizationRequestStatus_Failed
        case .frameRejected:
            return ARDK_VPS2_LocalizationRequestStatus_FrameRejected
        case .frameFlagged:
            return ARDK_VPS2_LocalizationRequestStatus_FrameFlagged
        }
    }
}
