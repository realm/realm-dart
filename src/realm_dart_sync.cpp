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
#include "realm_dart.hpp"
#include "realm_dart_sync.h"

RLM_API void realm_dart_http_request_callback(realm_userdata_t userdata, const realm_http_request_t request, void* request_context) {
    // the pointers in error are to stack values, we need to make copies and move them into the scheduler invocation
    struct request_copy_buf {
        std::string url;
        std::string body;
        std::map<std::string, std::string> headers;
        std::vector<realm_http_header_t> headers_vector;
    } buf;

    realm_http_request_t request_copy = request; // copy struct

    buf.url = request.url;
    request_copy.url = buf.url.c_str();
    buf.body = std::string(request.body, request.body_size);
    request_copy.body = buf.body.data();

    buf.headers_vector.reserve(request.num_headers);
    for (size_t i = 0; i < request.num_headers; i++) {
        auto [it, _] = buf.headers.emplace(request.headers[i].name, request.headers[i].value);
        buf.headers_vector.push_back({ it->first.c_str(), it->second.c_str() });
    }
    request_copy.headers = buf.headers_vector.data();

    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, request_copy = std::move(request_copy), buf = std::move(buf), request_context]() {
        (reinterpret_cast<realm_http_request_func_t>(ud->dart_callback)(ud->handle, request_copy, request_context));
    });
}

RLM_API void realm_dart_sync_client_log_callback(realm_userdata_t userdata, realm_log_level_e level, const char* message)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, level, message = std::string(message)]() {
        (reinterpret_cast<realm_log_func_t>(ud->dart_callback))(ud->handle, level, message.c_str());
    });
}

RLM_API void realm_dart_sync_error_handler_callback(realm_userdata_t userdata, realm_sync_session_t* session, realm_sync_error_t error)
{
    // the pointers in error are to stack values, we need to make copies and move them into the scheduler invocation
    struct error_copy {
        std::string message;
        std::string detailed_message;
        std::map<std::string, std::string> user_info_map;
        std::vector<realm_sync_error_user_info_t> user_info_vector;
    } buf;

    buf.message = error.error_code.message;
    error.error_code.message = buf.message.c_str();

    buf.detailed_message = error.detailed_message;
    error.detailed_message = buf.detailed_message.c_str();

    buf.user_info_vector.reserve(error.user_info_length);
    for (size_t i = 0; i < error.user_info_length; i++) {
        auto [it, _] = buf.user_info_map.emplace(error.user_info_map[i].key, error.user_info_map[i].value);
        buf.user_info_vector.push_back({ it->first.c_str(), it->second.c_str() });
    }
    error.user_info_map = buf.user_info_vector.data();

    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, session = *session, error = std::move(error), buf = std::move(buf)]() {
        (reinterpret_cast<realm_sync_error_handler_func_t>(ud->dart_callback))(ud->handle, const_cast<realm_sync_session_t*>(&session), error);
    });
}

RLM_API void realm_dart_sync_wait_for_completion_callback(realm_userdata_t userdata, realm_sync_error_code_t* error)
{
    // we need to make a deep copy of error, because the message pointer points to stack memory
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

    std::unique_ptr<realm_dart_sync_error_code> error_copy;
    if (error != nullptr) {
        error_copy = std::make_unique<realm_dart_sync_error_code>(*error);
    }

    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, error = std::move(error_copy)]() {
        (reinterpret_cast<realm_sync_wait_for_completion_func_t>(ud->dart_callback))(ud->handle, error.get());
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

RLM_API void realm_dart_sync_on_subscription_state_changed_callback(realm_userdata_t userdata, realm_flx_sync_subscription_set_state_e state)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, state]() {
        (reinterpret_cast<realm_sync_on_subscription_state_changed_t>(ud->dart_callback))(ud->handle, state);
    });
}
