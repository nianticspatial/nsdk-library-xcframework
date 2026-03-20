// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_coverage_area.h"
#include "ardk_localization_target.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     Container tying a single localization target to its parent
///            coverage area.
typedef struct ARDK_VPSCoverage_AreaTarget {
  /// @brief   A localization target.
  ARDK_VPSCoverage_LocalizationTarget localization_target;

  /// @brief   The coverage area that is localizeable via the
  ///          \c localization target paired in this struct.
  ARDK_VPSCoverage_CoverageArea coverage_area;
} ARDK_VPSCoverage_AreaTarget;

#ifdef __cplusplus
}
#endif
