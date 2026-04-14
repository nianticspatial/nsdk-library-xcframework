// Copyright Niantic Spatial.

#pragma once

#include "capi_common.h"

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

/// Starts process-wide telemetry publishing (periodic drain of \ref TelemetrySinkRegistry).
/// \p environment selects the telemetry ingest URL (UTF-8, null-terminated). Recognized values
/// (case-insensitive): "dev"/"development", "staging"/"stg", "prod"/"production"; null or empty
/// defaults to production. Unknown strings default to production.
/// \p platform identifies the originating SDK/platform (UTF-8, null-terminated). Recognized values
/// (case-insensitive, leading/trailing whitespace ignored): "swift", "kotlin", "unity android",
/// "unity ios", "unity editor". Null, empty, or unknown strings are treated as an unknown platform
/// and omitted from telemetry id fields.
/// At most one publisher may be active; returns false if already started.
ARDK_CAPI_VISIBLE bool Lightship_ARDK_TelemetryPublishing_Start(const char* environment,
                                                                const char* platform);

/// Stops telemetry publishing and destroys the publisher. Idempotent if not started.
ARDK_CAPI_VISIBLE void Lightship_ARDK_TelemetryPublishing_Stop(void);

#ifdef __cplusplus
}
#endif
