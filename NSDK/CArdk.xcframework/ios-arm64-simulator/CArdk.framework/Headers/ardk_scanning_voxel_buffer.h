// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_buffer.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Data representing the voxel cloud representation of the scanned
///             scene.
/// @note       Make sure to release this object once it's no longer needed by
///             calling the \c ARDK_Release_Resource function for this struct's
///             \c handle.
typedef struct ARDK_Scanning_VoxelBuffer {
  /// @brief    Handle to the raycast buffer's underlying memory.
  ARDK_ResourceHandle handle;

  /// @brief    A buffer containing the world position of each voxel's center in
  ///           the OpenCV coordinate system.
  ///
  /// @remarks  The OpenCV coordinate system is right-handed with the positive x-axis
  ///           pointing right, the positive y-axis pointing down, and the positive
  ///           z-axis pointing forward.
  ARDK_Buffer position_buffer;

  /// @brief    A buffer containing the RGBA32 color of each voxel. Each entry in
  ///           this buffer corresponds to the entry in the \c position_buffer at
  ///           the same index.
  ARDK_Buffer color_buffer;

  /// @brief    A buffer containing the normal vector of each voxel. Each entry in this
  ///           buffer corresponds to the entry in the \c position_buffer at the same
  ///           index.
  ///
  /// @remarks  The OpenCV coordinate system is right-handed with the positive x-axis
  ///           pointing right, the positive y-axis pointing down, and the positive
  ///           z-axis pointing forward.
  ARDK_Buffer normal_buffer;

  /// @brief    The size of voxels in meters.
  float voxel_size;
} ARDK_Scanning_VoxelBuffer;

#ifdef __cplusplus
}
#endif
