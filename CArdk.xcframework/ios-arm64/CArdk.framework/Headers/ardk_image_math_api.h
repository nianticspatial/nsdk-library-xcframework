// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#include "ardk_orientation.h"
#include "capi_common.h"
#include "ardk_matrix3f.h"

/// 4×4 view matrix
typedef float ARDK_ViewMatrix[16];

/// Returns a homography (3x3 matrix) that reprojects image coordinates
/// from the reference camera view into the target camera view.
ARDK_CAPI_VISIBLE void ARDK_ImageMath_Reprojection(float aspect, float fovRadians, float zNear,
                                                   float zFar, const ARDK_ViewMatrix referenceView,
                                                   const ARDK_ViewMatrix targetView,
                                                   float backProjectionDistance,
                                                   ARDK_Matrix3f outMatrix);

/// Returns an affine matrix to crop the source to match the aspect ratio of the target.
ARDK_CAPI_VISIBLE void ARDK_ImageMath_AffineCrop(uint32_t sourceWidth, uint32_t sourceHeight,
                                                 uint32_t targetWidth, uint32_t targetHeight,
                                                 ARDK_Matrix3f outMatrix);

/// Returns an affine matrix that fits the source into the target, aligning top and bottom edges.
ARDK_CAPI_VISIBLE void ARDK_ImageMath_AffineFit(uint32_t sourceWidth, uint32_t sourceHeight,
                                                ARDK_Orientation sourceOrientation,
                                                uint32_t targetWidth, uint32_t targetHeight,
                                                ARDK_Orientation targetOrientation,
                                                ARDK_Matrix3f outMatrix);

/// Returns an affine matrix for rotating from one orientation to another.
ARDK_CAPI_VISIBLE void ARDK_ImageMath_CalculateViewRotation(ARDK_Orientation from,
                                                            ARDK_Orientation to,
                                                            ARDK_Matrix3f outMatrix);

/// Returns an affine matrix for 2D rotation around origin.
ARDK_CAPI_VISIBLE void ARDK_ImageMath_AffineRotation(float radians, ARDK_Matrix3f outMatrix);

/// Returns an affine matrix for 2D translation.
ARDK_CAPI_VISIBLE void ARDK_ImageMath_AffineTranslation(float tx, float ty,
                                                        ARDK_Matrix3f outMatrix);

/// Returns an affine matrix for 2D scaling.
ARDK_CAPI_VISIBLE void ARDK_ImageMath_AffineScaling(float sx, float sy, ARDK_Matrix3f outMatrix);

/// Horizontal mirroring: (u, v) -> (1 - u, v)
ARDK_CAPI_VISIBLE void ARDK_ImageMath_AffineInvertHorizontal(ARDK_Matrix3f outMatrix);

/// Vertical mirroring: (u, v) -> (u, 1 - v)
ARDK_CAPI_VISIBLE void ARDK_ImageMath_AffineInvertVertical(ARDK_Matrix3f outMatrix);

#ifdef __cplusplus
}
#endif
