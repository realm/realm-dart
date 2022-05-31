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

#include <realm/object-store/sync/sync_session.hpp>
#include <realm/sync/config.hpp>
#include "sync_session.h"
#include "realm_dart.hpp"

struct realm_dart_sync_error_code : realm_sync_error_code
{
    realm_dart_sync_error_code(const realm_sync_error_code& error)
    : realm_sync_error_code(error)
    , message_buffer(error.message)
    {
        message = message_buffer.c_str();
    }

    const std::string message_buffer;
};

RLM_API void realm_dart_sync_wait_for_completion_callback(realm_userdata_t userdata, realm_sync_error_code_t* error)
{
    std::unique_ptr<realm_dart_sync_error_code> error_copy;
    if (error != nullptr) {
        error_copy = std::make_unique<realm_dart_sync_error_code>(*error);
    }

    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, error=std::move(error_copy)]() {
        (reinterpret_cast<realm_sync_download_completion_func_t>(ud->dart_callback))(ud->handle, error.get());
    });
}

RLM_API void realm_dart_sync_progress_callback(realm_userdata_t userdata, uint64_t transferred_bytes, uint64_t total_bytes)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, transferred_bytes, total_bytes]() {
        (reinterpret_cast<realm_sync_progress_func_t>(ud->dart_callback))(ud->handle, transferred_bytes, total_bytes);
    });
}

RLM_API void realm_dart_sync_connection_state_changed_callback(realm_userdata_t userdata,
                                                               realm_sync_connection_state_e old_state,
                                                               realm_sync_connection_state_e new_state)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, old_state, new_state]() {
        (reinterpret_cast<realm_sync_connection_state_changed_func_t>(ud->dart_callback))(ud->handle, old_state, new_state);
    });
}

RLM_API void realm_dart_sync_session_report_error_for_testing(realm_sync_session_t* session, uint32_t category, int errorCode, bool isFatal) noexcept
{
    std::error_code error_code;
    std::string msg;
    bool throwError = false;
    if (category == RLM_SYNC_ERROR_CATEGORY_CLIENT) {
        error_code = std::error_code(errorCode, realm::sync::client_error_category());
        msg = "Simulated client error";
        throwError = true;
    } else if (category == RLM_SYNC_ERROR_CATEGORY_SESSION) {
        error_code = std::error_code(errorCode, realm::sync::protocol_error_category());
        msg = "Simulated session error";
        throwError = true;
    }
    if (throwError) {
        realm::SyncSession::OnlyForTesting::handle_error(*(*session), realm::SyncError{ error_code, msg, isFatal });
    }
}
