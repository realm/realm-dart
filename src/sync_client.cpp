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

#include "sync_client.h"

#include <realm/object-store/c_api/types.hpp>
#include <realm/object-store/c_api/util.hpp>

#include "event_loop_dispatcher.hpp"

namespace realm::c_api {
namespace {

using FreeT = std::function<void()>;
using CallbackT = std::function<void(realm_sync_session_t*, const realm_sync_error_t)>; // Differs per callback
using UserdataT = std::tuple<CallbackT, FreeT>;

void _callback(void* userdata, realm_sync_session_t* session, const realm_sync_error_t error) {
    auto error_copy = error; // copy struct

    // we need to copy the detailed_message
    auto message = duplicate_string(std::string(error.detailed_message));
    error_copy.detailed_message = message;

    // other strings are not read, so we skip those
    error_copy.c_original_file_path_key = nullptr;
    error_copy.c_recovery_file_path_key = nullptr;

    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<0>(*u)(session, error_copy);
}

void _userdata_free(void* userdata) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<1>(*u)();
    delete u;
}

RLM_API void realm_dart_sync_config_set_error_handler(
    realm_sync_config_t* config,
    realm_sync_error_handler_func_t handler,
    realm_userdata_t userdata,
    realm_free_userdata_func_t userdata_free,
    realm_scheduler_t* scheduler) noexcept
{
    auto u = new UserdataT(std::bind(util::EventLoopDispatcher{ *scheduler, handler }, userdata, std::placeholders::_1, std::placeholders::_2),
                           std::bind(util::EventLoopDispatcher{ *scheduler, userdata_free }, userdata));
    return realm_sync_config_set_error_handler(config, _callback, u, _userdata_free);
}

}
}
