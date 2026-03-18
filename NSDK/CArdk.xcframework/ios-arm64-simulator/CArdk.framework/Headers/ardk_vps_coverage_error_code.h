// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief   Possible errors from VPS Coverage network operations.
typedef enum ARDK_VPSCoverage_Error {
    /// @brief    Code returned when no error has occurred.
    ARDK_VPSCoverage_Error_None,

    /// @brief    Code returned when the device cannot connect to the server.
    ARDK_VPSCoverage_Error_CurlClientError,

    /// @brief    Code returned when the API key (specified when the \c ARDK
    ///           object was initialized) could not be authenticated (403).
    /// @details  This could happen if the API key is invalid or missing, or
    ///           if authorization features are not online.
    ARDK_VPSCoverage_Error_HttpForbidden,

    /// @brief    Code returned when the request was made to an invalid URL (404).
    ARDK_VPSCoverage_Error_HttpNotFound,

    /// @brief    Code returned when the client has triggered rate limiting (429).
    ARDK_VPSCoverage_Error_HttpTooManyRequests,

    /// @brief    Code returned by the server when the client request is invalid.
    /// @note     One of the possible reasons for this error is if the request
    ///           contains a query radius larger than a server-defined maximum
    ///           value. The current max radius is 2000 meters.
    ARDK_VPSCoverage_Error_InvalidRequest,

    /// @brief    Code returned when the request would have resulted in too many 
    ///           entities being returned.
    /// @details  The current max number of entities returned is 100.
    ///           - To reduce the number of entities in a request for coverage areas
    ///             or area targets, reduce the query radius.
    ///           - To reduce the number of entities in a request for localization
    ///             targets, reduce the number of target identifiers.
    ARDK_VPSCoverage_Error_TooManyEntitiesRequested,

    /// @brief    Code returned when there was an unexpected server issue.
    ARDK_VPSCoverage_Error_InternalServerError,

    /// @brief    Code returned when something went wrong internally trying to process the response.
    ARDK_VPSCoverage_Error_UnexpectedResponse
} ARDK_VPSCoverage_Error;

#ifdef __cplusplus
}
#endif
