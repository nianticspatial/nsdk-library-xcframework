// Copyright 2022-2025 Niantic.
#pragma once
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

typedef enum ARDK_VPS_GraphOperationError : uint32_t {
  /// @brief    Code returned when no error has occurred.
  ARDK_VPS_GraphOperationError_None,

  /// @brief    Code returned when VPS is not initialized.
  ARDK_VPS_GraphOperationError_NotInitialized,

  /// @brief    Code returned when the device is not localized to any
  ///           VPS location.
  ARDK_VPS_GraphOperationError_NotLocalized,

  /// @brief    Code returned when the device is not localized to a
  ///           VPS location that contains the target node specified
  ///           for the graph operation.
  ARDK_VPS_GraphOperationError_NoTransformToTrackingNode,

  /// @brief    Code returned when the VPS location that the device is
  ///           localized to does not contain the target node specified
  ///           for the graph operation.
  ARDK_VPS_GraphOperationError_TargetNodeNotFound,

  /// @brief    Code returned when the VPS location that the device is
  ///           localized to contains no nodes with georeference data.
  /// @details  Currently, only publicly available VPS locations have
  ///           georeference data.
  ARDK_VPS_GraphOperationError_NoGeoreferenceData,
} ARDK_VPS_GraphOperationError;

#ifdef __cplusplus
}
#endif
