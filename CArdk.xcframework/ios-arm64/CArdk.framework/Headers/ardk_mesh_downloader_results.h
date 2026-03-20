// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_mesh_downloader_error.h"
#include "ardk_resource_handle.h"
#include "ardk_mesh_data.h"
#include "ardk_mesh_downloader_request_status.h"
#include "ardk_buffer.h"
#include "ardk_matrix4f.h"

#ifdef __cplusplus

extern "C" {
#endif

// Struct containing the data of a mesh download.
typedef struct ARDK_MeshDownloader_Data {
  ARDK_MeshData mesh_data;
  ARDK_Buffer image_data;
  ARDK_Matrix4f transform;
} ARDK_MeshDownloader_Data;

// Struct pointing to an array of mesh download results.
typedef struct ARDK_MeshDownloader_Results {
  ARDK_ResourceHandle handle;
  ARDK_MeshDownloader_RequestStatus status;
  ARDK_MeshDownloader_Error error;
  ARDK_MeshDownloader_Data* results;
  int num_results;
} ARDK_MeshDownloader_Results;

#ifdef __cplusplus
}
#endif
