import CArdk

public extension MeshDownloaderResults {
    /// Possible errors from Mesh Downloader network operations.
    enum Error: Swift.Error {
        /// The total download size exceeds the limit specified in the request.
        case sizeExceedsLimit

        /// There was a network error on the device.
        case curlClientError

        /// There was an error in the HTTP response.
        ///
        /// - Note: See logs for the specific HTTP response code.
        case httpResponseError

        /// Downloaded data could not be decompressed or parsed.
        case unexpectedResponse

        /// An unexpected error occurred.
        case internalError

        /// The payload used to request the mesh download was invalid
        case invalidPayload

        init(fromC cValue: ARDK_MeshDownloader_Error) {
            switch cValue {
            case ARDK_MeshDownloader_Error_SizeExceedsLimit:
                self = .sizeExceedsLimit
            case ARDK_MeshDownloader_Error_CurlClientError:
                self = .curlClientError
            case ARDK_MeshDownloader_Error_HttpResponseError:
                self = .httpResponseError
            case ARDK_MeshDownloader_Error_CorruptedResponse:
                self = .unexpectedResponse
            case ARDK_MeshDownloader_Error_InternalError:
                self = .internalError
            default:
                self = .internalError
            }
        }
    }
}
