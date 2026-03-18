import CArdk

    /// Network request errors that can occur during VPS coverage operations.
    ///
    /// `VpsCoverageNetworkRequestError` provides detailed error information for
    /// network-related issues when querying VPS coverage data from the server.
    ///
    /// ## Overview
    ///
    /// These errors help diagnose network connectivity issues, server problems,
    /// and request validation failures when accessing VPS coverage services.
enum VpsCoverageError: Swift.Error {
    /// Client-side network error (e.g., connection failure, timeout).
    ///
    /// This indicates a problem with the network connection or client-side
    /// networking stack, such as DNS resolution failure or connection timeout.
    case curlClientError
    
    /// HTTP 403 Forbidden - access denied.
    ///
    /// The API key lacks permission to access the requested resource
    /// or the request is not authorized.
    case httpForbidden
    
    /// HTTP 404 Not Found - requested resource not found.
    ///
    /// The requested VPS coverage data or area does not exist.
    case httpNotFound
    
    /// HTTP 429 Too Many Requests - rate limit exceeded.
    ///
    /// The request rate has exceeded the allowed limits.
    /// Implement exponential backoff and retry later.
    case httpTooManyRequests
    
    /// Invalid request format or parameters.
    ///
    /// The request was rejected due to invalid format or parameters
    /// before reaching the server.
    case invalidRequest
    
    /// Too many entities requested in a single query.
    ///
    /// The request attempted to query more entities than allowed
    /// in a single operation.
    case tooManyEntitiesRequested
    
    /// HTTP 500 Internal Server Error - server-side error.
    ///
    /// An unexpected error occurred on the server side.
    /// This is typically a temporary issue.
    case internalServerError
    
    /// Unexpected or unrecognized response from server.
    ///
    /// The server returned a response that could not be processed
    /// or was in an unexpected format.
    case unexpectedResponse
    
    /// An unexpected error occurred.
    case internalError
    
    init(fromC cValue: ARDK_VPSCoverage_Error) {
        switch cValue {
        case ARDK_VPSCoverage_Error_CurlClientError:
            self = .curlClientError
        case ARDK_VPSCoverage_Error_HttpForbidden:
            self = .httpForbidden
        case ARDK_VPSCoverage_Error_HttpNotFound:
            self = .httpNotFound
        case ARDK_VPSCoverage_Error_HttpTooManyRequests:
            self = .httpTooManyRequests
        case ARDK_VPSCoverage_Error_InvalidRequest:
            self = .invalidRequest
        case ARDK_VPSCoverage_Error_TooManyEntitiesRequested:
            self = .tooManyEntitiesRequested
        case ARDK_VPSCoverage_Error_InternalServerError:
            self = .internalServerError
        case ARDK_VPSCoverage_Error_UnexpectedResponse:
            self = .unexpectedResponse
        default:
            self = .unexpectedResponse
        }
    }
}
