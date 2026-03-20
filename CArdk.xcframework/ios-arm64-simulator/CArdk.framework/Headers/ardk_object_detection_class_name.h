// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_resource_handle.h"
#include "ardk_awareness_status.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// Struct used to store object detection class name and length of name
typedef struct ARDK_ObjectDetectionClassNameInfo {
  const char *class_name;
  uint32_t class_name_size;
} ARDK_ObjectDetectionClassNameInfo;

// ObjectDetection buffer holds a pointer to an array of class name structs and its size.
// Release the buffer data after use by freeing the ARDK_ResourceHandle.
typedef struct ARDK_ObjectDetectionClassNamesBuffer {
  enum ARDK_Awareness_Status status;
  ARDK_ResourceHandle handle;
  ARDK_ObjectDetectionClassNameInfo *names_array;
  uint32_t names_array_size;
} ARDK_ObjectDetectionClassNamesBuffer;

#ifdef __cplusplus
}
#endif
