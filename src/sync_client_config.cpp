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

#include <realm/object-store/c_api/types.hpp>
#include <realm/object-store/c_api/util.hpp>

#include "event_loop_dispatcher.hpp"

namespace realm::c_api {
namespace {

using namespace realm::sync;

using FreeT = std::function<void()>;
using CallbackT = std::function<void(realm_log_level_e level, const char* message)>; // Differs per callback
using UserdataT = std::tuple<CallbackT, FreeT>;

void _callback(void* userdata, realm_log_level_e level, const char* message ) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    // we need to copy the message 
    auto len = strlen(message) + 1;
    auto buffer = (char*)malloc(len);
    strncpy(buffer, message, len);
    std::get<0>(*u)(level, buffer);
}

void _userdata_free(void* userdata) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<1>(*u)();
    delete u;
}

RLM_API void realm_dart_sync_client_config_set_log_callback(
    realm_sync_client_config_t* config, 
    realm_log_func_t callback, 
    void* userdata,
    realm_free_userdata_func_t userdata_free,
    realm_scheduler_t* scheduler) noexcept
{
    auto u = new UserdataT(std::bind(util::EventLoopDispatcher{ *scheduler, callback }, userdata, std::placeholders::_1, std::placeholders::_2),
                           std::bind(util::EventLoopDispatcher{ *scheduler, userdata_free }, userdata));
    return realm_sync_client_config_set_log_callback(config, _callback, u, _userdata_free);
}

} // anonymous namespace
} // namespace realm::c_api 
