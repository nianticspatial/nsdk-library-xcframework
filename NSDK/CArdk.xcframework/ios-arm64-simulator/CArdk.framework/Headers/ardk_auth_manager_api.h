// Copyright Niantic Spatial.

#pragma once

#include "capi_common.h"
#include "ardk_auth_manager_types.h"
#include "ardk_status.h"

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

typedef void *ARDK_Handle;

/// @brief        Set the access token for the ARDK object via AuthManager.
/// @param        handle        Handle to the ARDK object.
/// @param        access_token  The access token to set. Empty strings (null data or data_size 0) are allowed and will be persisted.
/// @return       ARDK_Status_OK if the token was forwarded successfully.
/// @return       ARDK_Status_NullArdkHandle if \p handle was null.
/// @return       ARDK_Status_NullArgument if \p access_token data was null but data_size > 0 (invalid state).
ARDK_CAPI_VISIBLE ARDK_Status ARDK_AuthManager_SetAccessToken(ARDK_Handle handle, ARDK_String access_token);

/// @brief        Set the refresh token for the ARDK object via AuthManager.
/// @param        handle         Handle to the ARDK object.
/// @param        refresh_token  The refresh token to set. Empty strings (null data or data_size 0) are allowed and will be persisted.
/// @return       ARDK_Status_OK if the token was forwarded successfully.
/// @return       ARDK_Status_NullArdkHandle if \p handle was null.
/// @return       ARDK_Status_NullArgument if \p refresh_token data was null but data_size > 0 (invalid state).
ARDK_CAPI_VISIBLE ARDK_Status ARDK_AuthManager_SetRefreshToken(ARDK_Handle handle, ARDK_String refresh_token);

/// @brief        Check if auth tokens are valid and ready for use.
/// @details      Returns true if a valid, non-expired access token is available.
/// @param        handle              Handle to the ARDK object.
/// @param[out]   is_authorized_out   Output parameter set to true if authorized, false otherwise.
/// @return       ARDK_Status_OK if the operation was successful.
/// @return       ARDK_Status_NullArdkHandle if \p handle was null.
/// @return       ARDK_Status_NullArgument if \p is_authorized_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_AuthManager_IsAuthorized(
    ARDK_Handle handle, bool* is_authorized_out);

/// @brief        Get access token authentication information.
/// @details      Returns authentication information containing information about the current access token.
///               The returned struct contains string data that must be copied immediately as
///               it may be invalidated on the next API call. The allocated memory must be freed
///               using \c ARDK_Release_Resource.
/// @param        handle              Handle to the ARDK object.
/// @param[out]   auth_info_out       Output parameter for the access token claims.
/// @return       ARDK_Status_OK if the operation was successful.
/// @return       ARDK_Status_NullArdkHandle if \p handle was null.
/// @return       ARDK_Status_NullArgument if \p auth_info_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_AuthManager_GetAccessAuthInfo(
    ARDK_Handle handle, ARDK_AuthManager_AuthInfo* auth_info_out);

/// @brief        Get refresh token authentication information.
/// @details      Returns authentication information containing information about the current refresh token.
///               The returned struct contains string data that must be copied immediately as
///               it may be invalidated on the next API call. The allocated memory must be freed
///               using \c ARDK_Release_Resource.
/// @param        handle              Handle to the ARDK object.
/// @param[out]   auth_info_out       Output parameter for the refresh token claims.
/// @return       ARDK_Status_OK if the operation was successful.
/// @return       ARDK_Status_NullArdkHandle if \p handle was null.
/// @return       ARDK_Status_NullArgument if \p auth_info_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_AuthManager_GetRefreshAuthInfo(
    ARDK_Handle handle, ARDK_AuthManager_AuthInfo* auth_info_out);

#ifdef __cplusplus
}
#endif
