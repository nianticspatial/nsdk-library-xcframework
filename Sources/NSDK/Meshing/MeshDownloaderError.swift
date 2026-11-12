import CArdk

public extension MeshDownloaderResults {
    /// Possible errors from Mesh Downloader network operations.
    enum Error: Swift.Error {
        /// A single mesh's size exceeds the per-mesh limit in a oneshot location mesh request;
        /// no data was fetched for that mesh.
        ///
        /// - Note: This is distinct from ``sizeLimitReached``, which is the cumulative cap for
        ///   streaming portal mesh requests.
        case sizeExceedsLimit

        /// There was a network error on the device.
        case curlClientError

        /// There was an error in the HTTP response.
        ///
        /// - Note: See logs for the specific HTTP response code.
        case httpResponseError

        /// Downloaded data could not be decompressed or parsed.
        case unexpectedResponse

        /// The cumulative download size cap was hit. All chunks downloaded before the cap was
        /// reached were delivered; no further chunks will arrive.
        case sizeLimitReached

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
