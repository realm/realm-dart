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

#include "sync_client_config.h"
#include "realm_dart.hpp"

RLM_API void realm_dart_sync_client_log_callback(realm_userdata_t userdata, realm_log_level_e level, const char* message)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, level, message=std::string(message)]() {
        (reinterpret_cast<realm_log_func_t>(ud->dart_callback))(ud->handle, level, message.c_str());
    });
}
