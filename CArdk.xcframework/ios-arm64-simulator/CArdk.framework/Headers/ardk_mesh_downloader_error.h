// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief   Possible errors from Mesh Downloader network operations.
typedef enum ARDK_MeshDownloader_Error {
    /// @brief    Code returned when no error has occurred.
    ARDK_MeshDownloader_Error_None,

    /// @brief    Code returned when the total download size exceeds the limit
    ///           specified in the request.
    ARDK_MeshDownloader_Error_SizeExceedsLimit,

    /// @brief    Code returned when the there was a network error on the device.
    ARDK_MeshDownloader_Error_CurlClientError,

    /// @brief    Code returned when there was an error in the HTTP response.
    /// @note     See logs for the specific HTTP response code.
    ARDK_MeshDownloader_Error_HttpResponseError,

    /// @brief    Code returned when downloaded data could not be decompressed
    ///           or parsed.
    ARDK_MeshDownloader_Error_CorruptedResponse,

    /// @brief    Code returned when an unexpected error occurs.
    ARDK_MeshDownloader_Error_InternalError,
} ARDK_MeshDownloader_Error;

#ifdef __cplusplus
}
#endif
