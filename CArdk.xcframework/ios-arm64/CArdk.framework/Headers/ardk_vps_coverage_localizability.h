// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief   Description of the quality of VPS coverage area.
typedef enum ARDK_VPSCoverage_Localizability {
    /// @brief    Has not been assigned a value yet.
    ARDK_VPSCoverage_Localizablity_Unset,

    /// @brief    Testing quality, suitable for experimental use.
    ARDK_VPSCoverage_Localizability_Experimental,

    /// @brief    Highest quality, suitable for production use.
    ARDK_VPSCoverage_Localizability_Production,
} ARDK_VPSCoverage_Localizability;

#ifdef __cplusplus
}
#endif
