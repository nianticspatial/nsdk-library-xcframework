// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_string.h"
#include "ardk_awareness_status.h"

#ifdef __cplusplus
#include <cstdint>
extern "C" {
#else
#include <stdint.h>
#endif

/// @brief Defines the available semantic segmentation channel names.
///
/// Each value represents a specific real-world category that the semantics
/// feature can detect and classify within a scene.
typedef enum ARDK_Semantics_Channel : uint8_t {
  ARDK_Semantics_Channel_Sky = 0,
  ARDK_Semantics_Channel_Ground,
  ARDK_Semantics_Channel_NaturalGround,
  ARDK_Semantics_Channel_ArtificialGround,
  ARDK_Semantics_Channel_Water,
  ARDK_Semantics_Channel_Person,
  ARDK_Semantics_Channel_Building,
  ARDK_Semantics_Channel_Foliage,
  ARDK_Semantics_Channel_Grass,

  // Experimental channels
  ARDK_Semantics_Channel_FlowerExperimental = 100,
  ARDK_Semantics_Channel_TreeTrunkExperimental,
  ARDK_Semantics_Channel_PetExperimental,
  ARDK_Semantics_Channel_SandExperimental,
  ARDK_Semantics_Channel_TvExperimental,
  ARDK_Semantics_Channel_DirtExperimental,
  ARDK_Semantics_Channel_VehicleExperimental,
  ARDK_Semantics_Channel_FoodExperimental,
  ARDK_Semantics_Channel_LoungeableExperimental,
  ARDK_Semantics_Channel_SnowExperimental
} ARDK_Semantics_Channel;

#ifdef __cplusplus
}
#endif
