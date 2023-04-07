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

#ifndef REALM_DART_SCHEDULER_H
#define REALM_DART_SCHEDULER_H

#include <realm.h>
#include <dart_api_dl.h>

RLM_API realm_scheduler_t* realm_dart_create_scheduler(uint64_t isolateId, Dart_Port port);

RLM_API void realm_dart_scheduler_invoke(uint64_t isolateId, void* userData);

RLM_API uint64_t realm_dart_get_thread_id();

RLM_API void realm_dart_logger_callback(realm_userdata_t userData, realm_log_level_e level, const char* message);;

RLM_API void realm_dart_initialize_logger(Dart_Handle logger, realm_log_func_t arg0, realm_log_level_e arg1, realm_scheduler_t* scheduler);

RLM_API void realm_dart_userdata_free(realm_userdata_t userdata);
#endif // REALM_DART_SCHEDULER_H