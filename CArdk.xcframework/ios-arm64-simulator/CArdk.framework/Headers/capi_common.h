// Copyright 2022-2025 Niantic.

#pragma once

// Declare C-API should be exported.
// Add this macro to top of the C-API and add "PIN_SYMBOL(FuncName)" in
// pin_symbol.cc
#if !defined(_MSC_VER)
#define ARDK_CAPI_VISIBLE __attribute__((visibility("default")))
#else
#define ARDK_CAPI_VISIBLE __declspec(dllexport)
#endif
