// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

extern "C" {
#endif

/// @brief        Image format enumeration
/// @internal     // TODO(mng): merge with ardk_image_type.h
typedef enum ARDK_ImageFormat {
  ARDK_ImageFormat_Unknown = 0,

  /// @brief      Bi-planar Y'CbCr 4:2:0 format, where the NV12 and UV channels are interleaved
  ///             into one plane.
  ARDK_ImageFormat_Yuv420Nv12 = 1,

  /// @brief      Bi-planar Y'CbCr 4:2:0 format, where the NV21 and VU channels are interleaved
  ///             into one plane.
  ARDK_ImageFormat_Yuv420Nv21 = 2,

  /// @brief      Tri-planar YUV 8-bit 4:2:0 format, with each channel in a separate plane.
  ARDK_ImageFormat_Yuv420888 = 3,

  /// @brief      Single channel format with 8 bits per pixel.
  ARDK_ImageFormat_OneComponent8 = 4,

  /// @brief      Single channel format with a 16-bit unsigned integer per pixel,
  ///             describing the distance to an object in millimeters.
  ARDK_ImageFormat_DepthUint16 = 5,

  /// @brief      IEEE754-2008 binary32 float, describing the distance to an object in meters.
  ARDK_ImageFormat_DepthFloat32 = 6,

  /// @brief      Single channel format with 32 bits per pixel.
  ARDK_ImageFormat_OneComponent32 = 7,

  /// @brief      Color with alpha format with 4 8-bit channels interleaved into one plane.
  ///             The channels are ordered in A, R, G, B order.
  ARDK_ImageFormat_ARGB32 = 8,

  /// @brief      Color with alpha format with 4 8-bit channels interleaved into one plane.
  ///             The channels are ordered in R, G, B, A order.
  ARDK_ImageFormat_RGBA32 = 9,

  /// @brief      Color with alpha format with 4 8-bit channels interleaved into one plane.
  ///             The channels are ordered in B, G, R, A order.
  ARDK_ImageFormat_BGRA32 = 10,

  /// @brief      Color with alpha format with 3 8-bit channels interleaved into one plane.
  ///             The channels are ordered in R, G, B order.
  ARDK_ImageFormat_RGB24 = 11,

  /// @brief      Pre-encoded JPEG image data
  /// @details    When this format is used, camera_image_plane0 contains the complete
  ///             JPEG file data. Use camera_image_plane0.data_size to specify the
  ///             compressed data size in bytes. SAL will automatically decode and
  ///             resize as needed to satisfy module requirements.
  /// @note       Platform should encode at quality 85-95 for best results.
  ///             Any resolution is supported (SAL will resize if needed).
  /// @example    Bandwidth-constrained IPC: Compress on CV processor, decompress in SAL
  ARDK_ImageFormat_Jpeg = 12,
} ARDK_ImageFormat;

#ifdef __cplusplus
}
#endif
