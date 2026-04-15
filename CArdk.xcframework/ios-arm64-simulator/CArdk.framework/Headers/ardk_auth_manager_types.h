// Copyright Niantic Spatial.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_string.h"

#ifdef __cplusplus
#include <cstdint>
extern "C" {
#else
#include <stdint.h>
#include <stdbool.h>
#endif

/// @brief        Authentication information containing token claims.
/// @details      Contains parsed JWT claims including token string, expiration,
///               user information, and other standard JWT fields.
///               The returned struct contains string data that must be copied immediately as
///               it may be invalidated on the next API call. The allocated memory must be freed
///               using \c ARDK_Release_Resource.
typedef struct ARDK_AuthManager_AuthInfo {
  /// @brief   Raw JWT token string; may be empty.
  ARDK_String token;
  /// @brief   Expiration time (seconds since epoch).
  int32_t expiration_time;
  /// @brief   Issued at time (seconds since epoch).
  int32_t issued_at_time;
  /// @brief   User ID claim.
  ARDK_String user_id;
  /// @brief   Subject claim.
  ARDK_String subject;
  /// @brief   Name claim.
  ARDK_String name;
  /// @brief   Email claim.
  ARDK_String email;
  /// @brief   Issuer claim.
  ARDK_String issuer;
  /// @brief   Audience claim.
  ARDK_String audience;
  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_AuthManager_AuthInfo;

#ifdef __cplusplus
}
#endif
