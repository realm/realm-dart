////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

#ifndef REALM_DART_LOGGER_H
#define REALM_DART_LOGGER_H

#include <realm.h>
#include <dart_api_dl.h>

RLM_API void realm_dart_init_default_logger();

RLM_API void realm_dart_set_logger(Dart_Handle logger, realm_log_level_e level, realm_log_func_t callback,
    realm_scheduler_t* scheduler, uint64_t isolateId);

RLM_API void realm_dart_set_log_level(realm_log_level_e level, uint64_t isolateId);

RLM_API void realm_dart_release_logger(uint64_t isolateId);

void unblock_default_logger();

#endif // REALM_DART_LOGGER_H