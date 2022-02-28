////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <exception>

#include <realm.h>
#include "dart_api_dl.h"
#include "realm_dart.h"

#if defined(_WIN32)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

BOOL APIENTRY DllMain(HMODULE module,
                      DWORD  reason,
                      LPVOID reserved) {
  return true;
}

#endif  // defined(_WIN32)

RLM_API void realm_initializeDartApiDL(void* data) {
  Dart_InitializeApiDL(data);
}

void handle_finalizer(void* isolate_callback_data, void* realmPtr) {
  realm_release(realmPtr);
}

RLM_API Dart_FinalizableHandle realm_attach_finalizer(Dart_Handle handle, void* realmPtr, int size) {
  return Dart_NewFinalizableHandle_DL(handle, realmPtr, size, handle_finalizer);
}

RLM_API void realm_delete_finalizable(Dart_FinalizableHandle finalizable_handle, Dart_Handle handle) {
  Dart_DeleteFinalizableHandle_DL(finalizable_handle, handle);
}

#if (ANDROID)
void realm_android_dummy();
#endif

// Force the linker to link all exports from realm-core C API
void dummy(void) {
  realm_scheduler_make_default();
  realm_config_new();
  realm_schema_new(nullptr, 0, nullptr);
  realm_get_library_version();
  realm_object_create(nullptr, 0);
  realm_results_get_object(nullptr, 0);
  realm_list_size(nullptr, 0);
  realm_results_add_notification_callback(nullptr, nullptr, nullptr, nullptr, nullptr, nullptr);
  realm_results_snapshot(nullptr);
#if (ANDROID)
  realm_android_dummy();
#endif
}