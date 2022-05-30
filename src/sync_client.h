////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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

#ifndef REALM_DART_SYNC_CLIENT_H
#define REALM_DART_SYNC_CLIENT_H

#include "realm.h"

RLM_API void realm_dart_sync_config_set_error_handler(realm_sync_config_t* config, 
                                                      realm_sync_error_handler_func_t handler,
                                                      realm_userdata_t userdata,
                                                      realm_free_userdata_func_t userdata_free,
                                                      realm_scheduler_t* scheduler) RLM_API_NOEXCEPT;

#endif // REALM_DART_SYNC_CLIENT_H