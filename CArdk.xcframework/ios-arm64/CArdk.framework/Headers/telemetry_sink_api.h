// Copyright 2022-2026 Niantic.

#pragma once

#include "capi_common.h"

#ifdef __cplusplus
extern "C" {
#endif

/// Publishes an initialization telemetry event to the process-wide \ref TelemetrySinkRegistry.
/// \p install_mode and \p processor are UTF-8, null-terminated; null pointers are treated as empty.
ARDK_CAPI_VISIBLE void Lightship_ARDK_TelemetrySink_PublishInitializationEvent(
    const char* install_mode, const char* processor);

/// Publishes an AR session start telemetry event to the process-wide \ref TelemetrySinkRegistry.
ARDK_CAPI_VISIBLE void Lightship_ARDK_TelemetrySink_PublishArSessionStartEvent(void);

/// Clears buffered events on the process-wide \ref TelemetrySinkRegistry sink and stops accepting
/// new ones (same semantics as \ref ITelemetrySink::Disable).
ARDK_CAPI_VISIBLE void Lightship_ARDK_TelemetrySink_Disable(void);

#ifdef __cplusplus
}
#endif
