// Copyright Niantic Spatial.
import CArdk

/// Base class for results returned by queries to the Sites Manager service.
public class SitesResult {
}

public extension SitesResult {
    /// Network request errors that can occur during Sites Manager operations.
    enum Error: Swift.Error {
        case none
        case networkError
        case invalidRequest
        case httpForbidden
        case httpNotFound
        case httpTooManyRequests
        case httpServerError
        case parseError
        case unexpectedError
        
        init(fromC cValue: ARDK_SitesManager_Error) {
            switch cValue {
            case ARDK_SitesManager_Error_None:
                self = .none
            case ARDK_SitesManager_Error_NetworkError:
                self = .networkError
            case ARDK_SitesManager_Error_InvalidRequest:
                self = .invalidRequest
            case ARDK_SitesManager_Error_HttpForbidden:
                self = .httpForbidden
            case ARDK_SitesManager_Error_HttpNotFound:
                self = .httpNotFound
            case ARDK_SitesManager_Error_HttpTooManyRequests:
                self = .httpTooManyRequests
            case ARDK_SitesManager_Error_HttpServerError:
                self = .httpServerError
            case ARDK_SitesManager_Error_ParseError:
                self = .parseError
            case ARDK_SitesManager_Error_UnexpectedError:
                self = .unexpectedError
            default:
                self = .unexpectedError
            }
        }
    }
}

