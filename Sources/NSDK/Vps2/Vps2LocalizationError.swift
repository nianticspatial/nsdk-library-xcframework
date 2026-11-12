import CArdk

/// Possible errors from VPS localization operations.
public enum Vps2LocalizationError {
    /// An unknown error occurred.
    case unknown

    /// No error has occurred.
    case none

    /// The device cannot connect to the server.
    case badNetworkConnection

    /// The API gateway rejected the request due to an authentication or authorization failure.
    case authFailure

    /// The server denied permission for the request.
    case permissionDenied

    /// The request rate limit has been exceeded.
    case requestsLimitExceeded

    /// The server encountered an internal error while processing the request.
    case internalServer

    /// The server response could not be parsed by the client.
    case internalClient

    /// The server could not find a map near the request GPS location.
    case noMapFound

    /// The server processed the request but localization failed.
    case localizationFailed

    /// The API gateway rejected the request because the account or project quota was exceeded (HTTP 429).
    case quotaExceeded

    /// The frame was rejected because tracking state is not normal.
    case badTracking

    /// The frame was rejected because the camera is pointing at the ground or sky (no horizon crossing).
    case badCameraAngle

    /// The frame was rejected before dispatch because no valid geolocation prior was available
    /// (the GPS reading was NaN or a placeholder and no other valid prior could be substituted).
    case noValidPrior

    /// The frame was rejected because the device was held upside down.
    case deviceUpsideDown

    /// The frame was flagged because the image was too blurry or featureless to localize well.
    /// Advisory: the frame is still sent; use this to coach the user, not to explain a drop.
    case imageTooBlurry

    /// The requested site does not exist or is not accessible to this caller.
    case siteNotFound

    /// The site was found but has no assets to localize against: either none of the
    /// requested asset ids are in it, or the matching assets were not localizable.
    case assetsNotFound

    internal init(fromC cValue: ARDK_VPS2_LocalizationError) {
        switch cValue {
        case ARDK_VPS2_LocalizationError_None:
            self = .none
        case ARDK_VPS2_LocalizationError_BadNetworkConnection:
            self = .badNetworkConnection
        case ARDK_VPS2_LocalizationError_AuthFailure:
            self = .authFailure
        case ARDK_VPS2_LocalizationError_PermissionDenied:
            self = .permissionDenied
        case ARDK_VPS2_LocalizationError_RequestsLimitExceeded:
            self = .requestsLimitExceeded
        case ARDK_VPS2_LocalizationError_InternalServer:
            self = .internalServer
        case ARDK_VPS2_LocalizationError_InternalClient:
            self = .internalClient
        case ARDK_VPS2_LocalizationError_NoMapFound:
            self = .noMapFound
        case ARDK_VPS2_LocalizationError_LocalizationFailed:
            self = .localizationFailed
        case ARDK_VPS2_LocalizationError_QuotaExceeded:
            self = .quotaExceeded
        case ARDK_VPS2_LocalizationError_BadTracking:
            self = .badTracking
        case ARDK_VPS2_LocalizationError_BadCameraAngle:
            self = .badCameraAngle
        case ARDK_VPS2_LocalizationError_NoValidPrior:
            self = .noValidPrior
        case ARDK_VPS2_LocalizationError_DeviceUpsideDown:
            self = .deviceUpsideDown
        case ARDK_VPS2_LocalizationError_ImageTooBlurry:
            self = .imageTooBlurry
        case ARDK_VPS2_LocalizationError_SiteNotFound:
            self = .siteNotFound
        case ARDK_VPS2_LocalizationError_VpsAssetsNotFound:
            self = .assetsNotFound
        case ARDK_VPS2_LocalizationError_Unknown:
            fallthrough
        default:
            self = .unknown
        }
    }
}
