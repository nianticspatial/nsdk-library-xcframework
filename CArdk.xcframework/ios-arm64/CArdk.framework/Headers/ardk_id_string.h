// Copyright 2026 Niantic Spatial.

#pragma once

#ifdef __cplusplus

extern "C" {
#endif

/// @brief  Size in bytes of an \c ARDK_IdString, including the NUL terminator. Ids are
///         canonical 36-character UUID strings; the headroom absorbs format changes without
///         an ABI break. Must stay equal to \c ARDK_VPS2_ASSET_ID_BUFFER_SIZE so that ids
///         from different APIs can be compared and stored interchangeably.
#define ARDK_ID_STRING_SIZE 64

/// @brief    An identifier carried by value: a NUL-terminated UTF-8 string in a fixed buffer.
///
/// @details  Unlike \c ARDK_String, which borrows a pointer into memory a resource handle
///           owns, an \c ARDK_IdString is copied into the caller's struct. It needs no
///           handle to stay alive, so it remains readable after the resource it arrived with
///           has been released, and no caller has to copy it out defensively.
///
///           This is the representation for short identifiers in structs the C API fills in.
///           Use \c ARDK_String for string inputs, and for outputs whose length has no small
///           upper bound. An id too long for the buffer is truncated, with a warning logged.
///           An unknown or inapplicable id is the empty string, never a garbage buffer.
typedef char ARDK_IdString[ARDK_ID_STRING_SIZE];

#ifdef __cplusplus
}
#endif
