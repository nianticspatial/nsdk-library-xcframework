// Copyright 2022-2025 Niantic.

#pragma once

#include "capi_common.h"
#include "ardk_mapping_configuration.h"
#include "ardk_mapping_configuration_deprecated.h"
#include "ardk_buffer.h"
#include "ardk_feature_status.h"
#include "ardk_status.h"
#include "ardk_api.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Reports errors that have occurred within processes running inside this
///               feature.
/// @details      Check this periodically to see if any errors have occurred with
///               processes running inside this feature. Once an error has been flagged,
///               it will remain flagged until the culprit process has been run again
///               and completed successfully.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_FeatureStatus enum value that indicates the current state of the
///               mapping feature
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_DeviceMapping_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initialize the mapping feature. Call this before calling any other
///               mapping functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK object was
///               created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the mapping feature, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_Destroy(ARDK_Handle ardk_handle);

/// @brief        Start the mapping session.
/// @details      This starts some underlying processes that need to be running before actual
///               mapping can begin, downloading the model containing the mapping algorithm.
///               It does not actually start the map building process, which needs to be
///               invoked separately with StartMapping.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_Start(ARDK_Handle ardk_handle);

/// @brief        Stop all mapping processes.
/// @note         If mapping is in progress, this will stop mapping.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_Stop(ARDK_Handle ardk_handle);

/// @brief        Begin a mapping sequence.
/// @details      This begins building an on-device map that can be used for VPS.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_StartMapping(ARDK_Handle ardk_handle);

/// @brief        Stop the current mapping sequence.
/// @details      This stops adding new frames to the current on-device VPS Map.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_StopMapping(ARDK_Handle ardk_handle);

/// @brief        Configures the session with the specified settings.
/// @details      Only settings that differ from the defaults will be applied.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        config         An object that defines this session's behavior.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called while the mapping session is stopped.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_Configure(ARDK_Handle ardk_handle,
                                                           const ARDK_DeviceMapping_Config* config);

ARDK_CAPI_VISIBLE ARDK_Status ARDK_DeviceMapping_Configure_Deprecated(
    ARDK_Handle ardk_handle, const ARDK_MappingConfiguration_Deprecated* config);
#ifdef __cplusplus
}
#endif
