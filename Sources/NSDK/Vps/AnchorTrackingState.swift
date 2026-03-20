import CArdk
import simd

public extension VpsAnchorUpdate {
    /// Represents the current tracking state of a VPS anchor.
    ///
    /// The tracking state indicates how well the system is able to track an anchor's position
    /// and orientation in the current environment.
    enum AnchorTrackingState: Equatable, CustomStringConvertible {
        /// Provides additional context about why an anchor is in either the `notTracked`
        /// or `limited` tracking states.
        public enum Reason: Equatable, CustomStringConvertible {
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

            public var description: String {
                switch self {
                case .initializing: return "initializing"
                case .removed: return "removed"
                case .internalError: return "internalError"
                case .permissionDenied: return "permissionDenied"
                case .fatalNetworkError: return "fatalNetworkError"
                case .noVisualLocalization: return "noVisualLocalization"
                }
            }

            public var isError: Bool {
                return self == .internalError || self == .permissionDenied || self == .fatalNetworkError
            }
        }

        /// The anchor is not currently being tracked.
        case notTracked(reason: Reason?)

        /// The anchor is being tracked with limited accuracy.
        ///
        /// Tracking information is available, but is of poor quality and should
        /// not be relied upon at close distances.
        case limited(reason: Reason?)

        /// The anchor is being tracked with full accuracy.
        case tracked

        public var description: String {
            switch self {
            case .notTracked(let reason):
                if let reason = reason {
                    return "notTracked (reason: \(reason))"
                }
                return "notTracked"
            case .limited(let reason):
                if let reason = reason {
                    return "limited (reason: \(reason))"
                }
                return "limited"
            case .tracked:
                return "tracked"
            }
        }

        init(cState: ARDK_VPS_AnchorTrackingState, cReason: ARDK_VPS_AnchorTrackingStateReason) {
            var reason: Reason?
            switch cReason {
            case ARDK_VPS_AnchorTrackingStateReason_Initializing:
                reason = .initializing
            case ARDK_VPS_AnchorTrackingStateReason_Removed:
                reason = .removed
            case ARDK_VPS_AnchorTrackingStateReason_InternalError:
                reason = .internalError
            case ARDK_VPS_AnchorTrackingStateReason_PermissionDenied:
                reason = .permissionDenied
            case ARDK_VPS_AnchorTrackingStateReason_FatalNetworkError:
                reason = .fatalNetworkError
            case ARDK_VPS_AnchorTrackingStateReason_NoVisualLocalization:
                reason = .noVisualLocalization
            default:
                reason = nil
            }

            switch cState {
            case ARDK_VPS_AnchorTrackingState_NotTracked:
                self = .notTracked(reason: reason)
            case ARDK_VPS_AnchorTrackingState_Limited:
                self = .limited(reason: reason)
            case ARDK_VPS_AnchorTrackingState_Tracked:
                self = .tracked
            default:
                self = .notTracked(reason: .internalError)
            }
        }
    }
}
