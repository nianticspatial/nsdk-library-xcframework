import CArdk

public extension VpsAnchorUpdate {
    /// Provides additional context about why an anchor is in either the `NotTracked`
    /// or `Limited` tracking states.
    enum AnchorTrackingStateReason {
        /// No specific reason for the current tracking state is available. 
        case none

        /// The anchor is still being initialized.
        case initializing

        /// Tracking has been stopped for this anchor.
        case removed

        /// An unexpected internal error has occured.
        case internalError

        /// The anchor is part of a private VPS location that this application does not have
        /// authorization to access.
        case permissionDenied

        /// An unrecoverable network error has occured. Check the session's `featureStatus` for
        /// more information.
        case fatalNetworkError
        
        /// The device is not localized to the VPS location/map that this anchor belongs to, but
        /// coarse localization has been achieved through some other method(s).
        case noVisualLocalization

        init(fromC cValue: ARDK_VPS_AnchorTrackingStateReason) {
            switch cValue {
            case ARDK_VPS_AnchorTrackingStateReason_None:
                self = .none
            case ARDK_VPS_AnchorTrackingStateReason_Initializing:
                self = .initializing
            case ARDK_VPS_AnchorTrackingStateReason_Removed:
                self = .removed
            case ARDK_VPS_AnchorTrackingStateReason_InternalError:
                self = .internalError
            case ARDK_VPS_AnchorTrackingStateReason_PermissionDenied:
                self = .permissionDenied
            case ARDK_VPS_AnchorTrackingStateReason_FatalNetworkError:
                self = .fatalNetworkError
            case ARDK_VPS_AnchorTrackingStateReason_NoVisualLocalization:
                self = .noVisualLocalization
            default:
                self = .internalError
            }
        }

        public var isError: Bool {
            return self == .internalError || self == .permissionDenied || self == .fatalNetworkError
        }
    }
}
