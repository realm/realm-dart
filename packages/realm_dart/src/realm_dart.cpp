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

#include "realm_dart.h"
#include "realm_dart.hpp"

#if REALM_ARCHITECTURE_ARM32 || REALM_ARCHITECTURE_ARM64 || REALM_ARCHITECTURE_X86_32 || REALM_ARCHITECTURE_X86_64
#if REALM_ARCHITECTURE_ARM32
std::string cpuArch = "armeabi-v7a";
#pragma message("Building arm32")
#endif

#if REALM_ARCHITECTURE_ARM64
std::string cpuArch = "arm64";
#pragma message("Building arm64")
#endif

#if REALM_ARCHITECTURE_X86_64
std::string cpuArch = "x86_64";
#pragma message("Building x64")
#endif
#elif
std::string cpuArch = "Unknown";
#endif

RLM_API void realm_dart_initializeDartApiDL(void* data) {
    Dart_InitializeApiDL(data);
}

RLM_API void* realm_dart_object_to_persistent_handle(Dart_Handle handle) {
    return reinterpret_cast<void*>(Dart_NewPersistentHandle_DL(handle));
}

RLM_API Dart_Handle realm_dart_persistent_handle_to_object(void* handle) {
    Dart_PersistentHandle persistentHandle = reinterpret_cast<Dart_PersistentHandle>(handle);
    return Dart_HandleFromPersistent_DL(persistentHandle);
}

RLM_API void realm_dart_delete_persistent_handle(void* handle) {
    Dart_PersistentHandle persistentHandle = reinterpret_cast<Dart_PersistentHandle>(handle);
    Dart_DeletePersistentHandle_DL(persistentHandle);
}

RLM_API realm_dart_userdata_async_t realm_dart_userdata_async_new(Dart_Handle handle, void* callback, realm_scheduler_t* scheduler) {
    return new realm_dart_userdata_async(handle, callback, scheduler);
}

RLM_API void realm_dart_userdata_async_free(void* userdata) {
    auto async_userdata = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    async_userdata->scheduler->invoke([async_userdata]() {
        delete async_userdata;
    });
}

RLM_API void realm_dart_invoke_unlock_callback(realm_userdata_t error, void* unlockFunc) {
    auto castFunc = (reinterpret_cast<realm::util::UniqueFunction<void(realm_userdata_t)>*>(unlockFunc));
    (*castFunc)(error);
}

// Stamped into the library by the build system (see prepare-release.yml)
// Keep this method as it is written and do not format it.
// We have a github workflow that looks for and replaces this string as it is written here.
RLM_API const char* realm_dart_library_version() { return "20.1.1"; }

//for debugging only
// RLM_API void realm_dart_gc() {
//     Dart_ExecuteInternalCommand_DL("gc-now", nullptr);
// }

void handle_finalizer(void* isolate_callback_data, void* realmPtr) {
    realm_release(realmPtr);
}

RLM_API void* realm_attach_finalizer(Dart_Handle handle, void* realmPtr, int size) {
    return Dart_NewFinalizableHandle_DL(handle, realmPtr, size, handle_finalizer);
}

RLM_API void realm_detach_finalizer(void* finalizableHandle, Dart_Handle handle) {
    Dart_FinalizableHandle finalHandle = reinterpret_cast<Dart_FinalizableHandle>(finalizableHandle);
    return Dart_DeleteFinalizableHandle_DL(finalHandle, handle);
}

RLM_API void realm_set_auto_refresh(realm_t* realm, bool enable) {
    (*realm)->set_auto_refresh(enable);
}

RLM_API const char* realm_get_library_cpu_arch() {
    return cpuArch.c_str();
}