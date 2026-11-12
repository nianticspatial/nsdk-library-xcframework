// Copyright Niantic Spatial.

#pragma once

#include "capi_common.h"

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

/// Starts process-wide telemetry publishing (periodic drain of \ref TelemetrySinkRegistry).
/// The telemetry ingest environment (dev/staging/prod) is sourced from \ref
/// ITelemetrySink::GetEnvironment() and is set automatically by AuthManager from the JWT issuer
/// claim. \p dev_platform identifies the originating SDK/dev platform (UTF-8, null-terminated).
/// Recognized values (case-insensitive, leading/trailing whitespace ignored): "swift", "kotlin",
/// "unity android", "unity ios", "unity editor", "ros2". Null, empty, or unknown strings are
/// treated as an unknown dev platform and omitted from telemetry id fields (no row with \c idType
/// "dev_platform").
/// At most one publisher may be active; returns false if already started.
ARDK_CAPI_VISIBLE bool Lightship_ARDK_TelemetryPublishing_Start(const char* dev_platform);

/// Stops telemetry publishing and destroys the publisher. Idempotent if not started.
ARDK_CAPI_VISIBLE void Lightship_ARDK_TelemetryPublishing_Stop(void);

#ifdef __cplusplus
}
#endif
