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

#ifndef REALM_DART_H
#define REALM_DART_H

#include <realm.h>
#include <dart_api_dl.h>

RLM_API void realm_dart_initializeDartApiDL(void* data);

RLM_API void* realm_dart_object_to_weak_handle(Dart_Handle handle);
RLM_API Dart_Handle realm_dart_weak_handle_to_object(void* handle);

RLM_API void* realm_dart_object_to_persistent_handle(Dart_Handle handle);
RLM_API Dart_Handle realm_dart_persistent_handle_to_object(void* handle);
RLM_API void realm_dart_delete_persistent_handle(void* handle);

// implemented for iOS and Android only
RLM_API const char* realm_dart_get_files_path();

typedef struct realm_dart_userdata_async* realm_dart_userdata_async_t;

RLM_API realm_dart_userdata_async_t realm_dart_userdata_async_new(Dart_Handle handle, void* callback, realm_scheduler_t* scheduler);
RLM_API void realm_dart_userdata_async_free(void* userdata);

RLM_API void realm_dart_invoke_unlock_callback(bool success, void* unlockFunc);

RLM_API const char* realm_dart_library_version();

#endif // REALM_DART_H