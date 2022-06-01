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

#include <realm/object-store/c_api/util.hpp>
#include <realm/sync/client_base.hpp>
#include <realm/object-store/sync/sync_session.hpp>
#include <realm/sync/config.hpp>
#include "sync_session.h"
#include "event_loop_dispatcher.hpp"

#include <iostream>

namespace realm::c_api {
namespace _1 {

using FreeT = std::function<void()>;
using CallbackT = std::function<void(realm_sync_error_code_t*)>;
using UserdataT = std::tuple<CallbackT, FreeT>;

void _callback(void* userdata, realm_sync_error_code_t* error) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    if (error != nullptr) {
        auto error_copy = (realm_sync_error_code_t*)malloc(sizeof(realm_sync_error_code_t));
        *error_copy = *error; // copy struct

        // we need to copy the message 
        auto message = duplicate_string(std::string(error->message));
        error_copy->message = message;

        std::get<0>(*u)(error_copy);
    }
    else {
        std::get<0>(*u)(nullptr);
    }
}

void _userdata_free(void* userdata) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<1>(*u)();
    delete u;
}

RLM_API void realm_dart_sync_session_wait_for_download_completion(realm_sync_session_t* session,
                                                                  realm_sync_download_completion_func_t callback,
                                                                  void* userdata,
                                                                  realm_free_userdata_func_t userdata_free,
                                                                  realm_scheduler_t* scheduler) noexcept
{
    auto u = new UserdataT(std::bind(util::EventLoopDispatcher{ *scheduler, callback }, userdata, std::placeholders::_1),
                           std::bind(util::EventLoopDispatcher{ *scheduler, userdata_free }, userdata));
    realm_sync_session_wait_for_download_completion(session, _callback, u, _userdata_free);
}

RLM_API void realm_dart_sync_session_wait_for_upload_completion(realm_sync_session_t* session,
                                                                realm_sync_upload_completion_func_t callback,
                                                                void* userdata,
                                                                realm_free_userdata_func_t userdata_free,
                                                                realm_scheduler_t* scheduler) noexcept
{
    auto u = new UserdataT(std::bind(util::EventLoopDispatcher{ *scheduler, callback }, userdata, std::placeholders::_1),
                           std::bind(util::EventLoopDispatcher{ *scheduler, userdata_free }, userdata));
    realm_sync_session_wait_for_upload_completion(session, _callback, u, _userdata_free);
}

} // anonymous namespace

namespace _2 {

using FreeT = std::function<void()>;
using CallbackT = std::function<void(uint64_t, uint64_t)>;
using UserdataT = std::tuple<CallbackT, FreeT>;

void _callback(void* userdata, uint64_t transferred_bytes, uint64_t total_bytes) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<0>(*u)(transferred_bytes, total_bytes);
}

void _userdata_free(void* userdata) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<1>(*u)();
    delete u;
}

RLM_API uint64_t realm_dart_sync_session_register_progress_notifier(realm_sync_session_t* session,
                                                                    realm_sync_progress_func_t callback,
                                                                    realm_sync_progress_direction_e direction,
                                                                    bool is_streaming,
                                                                    void* userdata,
                                                                    realm_free_userdata_func_t userdata_free,
                                                                    realm_scheduler_t* scheduler) noexcept
{
    auto u = new UserdataT(std::bind(util::EventLoopDispatcher{ *scheduler, callback }, userdata, std::placeholders::_1, std::placeholders::_2),
                           std::bind(util::EventLoopDispatcher{ *scheduler, userdata_free }, userdata));
    return realm_sync_session_register_progress_notifier(session, _callback, direction, is_streaming, u, _userdata_free);
}

} // anonymous namespace

namespace _3 {

using FreeT = std::function<void()>;
using CallbackT = std::function<void(realm_sync_connection_state_e, realm_sync_connection_state_e)>;
using UserdataT = std::tuple<CallbackT, FreeT>;

void _callback(void* userdata, realm_sync_connection_state_e old_state, realm_sync_connection_state_e new_state) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<0>(*u)(old_state, new_state);
}

void _userdata_free(void* userdata) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<1>(*u)();
    delete u;
}

RLM_API uint64_t realm_dart_sync_session_register_connection_state_change_callback(realm_sync_session_t* session,
                                                                              realm_sync_connection_state_changed_func_t callback,
                                                                              void* userdata,
                                                                              realm_free_userdata_func_t userdata_free,
                                                                              realm_scheduler_t* scheduler) noexcept
{
    auto u = new UserdataT(std::bind(util::EventLoopDispatcher{ *scheduler, callback }, userdata, std::placeholders::_1, std::placeholders::_2),
                           std::bind(util::EventLoopDispatcher{ *scheduler, userdata_free }, userdata));
    return realm_sync_session_register_connection_state_change_callback(session, _callback, u, _userdata_free);
}

} // anonymous namespace

RLM_API void realm_dart_sync_session_report_error_for_testing(realm_sync_session_t* session, uint32_t category, int errorCode, bool isFatal) noexcept
{
    std::error_code error_code;
    std::string msg;
    bool throwError = false;
    if (category == realm_sync_error_category::RLM_SYNC_ERROR_CATEGORY_CLIENT) {
        error_code = std::error_code(errorCode, realm::sync::client_error_category());
        msg = "Simulated client error";
        throwError = true;
    }
    else if (category == realm_sync_error_category::RLM_SYNC_ERROR_CATEGORY_SESSION) {
        error_code = std::error_code(errorCode, realm::sync::protocol_error_category());
        msg = "Simulated session error";
        throwError = true;
    }
    if (throwError) {
        SyncSession::OnlyForTesting::handle_error(*(*session), SyncError{ error_code, msg, isFatal });
    }
}
} // namespace realm::c_api
