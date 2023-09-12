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

RLM_API void realm_dart_http_request_callback(realm_userdata_t userdata, realm_http_request_t request, void* request_context) {
    // the pointers in request are to stack values, we need to make copies and move them into the scheduler invocation
    struct request_copy_buf {
        std::string url;
        std::string body;
        std::vector<std::pair<std::string, std::string>> headers_values;
        std::vector<realm_http_header_t> headers;
    } buf;

    buf.url = request.url;
    buf.body = std::string(request.body, request.body_size);
    buf.headers_values.reserve(request.num_headers);
    buf.headers.reserve(request.num_headers);
    for (size_t i = 0; i < request.num_headers; i++) {
        auto& [name, value] = buf.headers_values.emplace_back(request.headers[i].name, request.headers[i].value);
        buf.headers.push_back({ name.c_str(), value.c_str() });
    }

    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, request = std::move(request), buf = std::move(buf), request_context]() mutable {
        //we moved buf so we need to update the request pointers here.
        request.url = buf.url.c_str();
        request.body = buf.body.data();
        request.headers = buf.headers.data();
        (reinterpret_cast<realm_http_request_func_t>(ud->dart_callback)(ud->handle, request, request_context));
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
    struct compensating_write_copy {
        std::string reason;
        std::string object_name;
        realm_value_t primary_key;
    };

    struct error_copy {
        std::string message;
        realm_errno_e error;
        realm_error_categories categories;
        std::string original_file_path_key;
        std::string recovery_file_path_key;
        bool is_fatal;
        bool is_client_reset_requested;
        std::vector<std::pair<std::string, std::string>> user_info_values;
        std::vector<realm_sync_error_user_info_t> user_info;
        std::vector<compensating_write_copy> compensating_writes_errors_info_copy;
        std::vector<realm_sync_error_compensating_write_info_t> compensating_writes_errors_info;
    } buf;

    buf.message = std::string(error.status.message);
    buf.categories = error.status.categories;
    buf.error = error.status.error;
    // TODO: Map usercode_error and path when issue https://github.com/realm/realm-core/issues/6925 is fixed
    buf.original_file_path_key = std::string(error.c_original_file_path_key);
    buf.recovery_file_path_key = std::string(error.c_recovery_file_path_key);
    buf.is_fatal = error.is_fatal;
    buf.is_client_reset_requested = error.is_client_reset_requested;
    buf.user_info_values.reserve(error.user_info_length);
    buf.user_info.reserve(error.user_info_length);
    buf.compensating_writes_errors_info_copy.reserve(error.compensating_writes_length);
    buf.compensating_writes_errors_info.reserve(error.compensating_writes_length);

    for (size_t i = 0; i < error.user_info_length; i++) {
        auto& [key, value] = buf.user_info_values.emplace_back(error.user_info_map[i].key, error.user_info_map[i].value);
        buf.user_info.push_back({ key.c_str(), value.c_str() });
    }
    for (size_t i = 0; i < error.compensating_writes_length; i++) {
        const auto& cw = error.compensating_writes[i];
        const auto& cw_buf = buf.compensating_writes_errors_info_copy.emplace_back(compensating_write_copy{
            std::string(cw.reason),
            std::string(cw.object_name),
            cw.primary_key
        });
        buf.compensating_writes_errors_info.push_back(realm_sync_error_compensating_write_info_t{
            cw_buf.reason.c_str(),
            cw_buf.object_name.c_str(),
            cw_buf.primary_key
        });
    }

    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, session = *session, error = std::move(error), buf = std::move(buf)]() mutable {
        //we moved buf so we need to update the error pointers here.
        error.status.message = buf.message.c_str();
        error.status.error = buf.error;
        error.status.categories = buf.categories;
        error.c_original_file_path_key = buf.original_file_path_key.c_str();
        error.c_recovery_file_path_key = buf.recovery_file_path_key.c_str();
        error.is_fatal = buf.is_fatal;
        error.is_client_reset_requested = buf.is_client_reset_requested;
        error.user_info_map = buf.user_info.data();
        error.compensating_writes = buf.compensating_writes_errors_info.data();
        (reinterpret_cast<realm_sync_error_handler_func_t>(ud->dart_callback))(ud->handle, const_cast<realm_sync_session_t*>(&session), error);
    });
}

RLM_API void realm_dart_sync_wait_for_completion_callback(realm_userdata_t userdata, realm_error_t* error)
{
    // we need to make a deep copy of error, because the message pointer points to stack memory
    struct realm_dart_sync_error_code : realm_error_t
    {
        realm_dart_sync_error_code(const realm_error& error_input)
            : message_buffer(error_input.message)
        {
          error = error_input.error;
          categories = error_input.categories;
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

bool invoke_dart_and_await_result(realm::util::UniqueFunction<void(realm::util::UniqueFunction<void(bool)>*)>* userCallback)
{
    std::condition_variable condition;
    std::mutex mutex;
    bool success = false;
    bool completed = false;

    realm::util::UniqueFunction unlockFunc = [&](bool result) {
        std::unique_lock lock(mutex);
        success = result;
        completed = true;
        condition.notify_one();
    };
    
    std::unique_lock lock(mutex);
    (*userCallback)(&unlockFunc);
    condition.wait(lock, [&] (){ return completed; });

    return success;
}

RLM_API bool realm_dart_sync_before_reset_handler_callback(realm_userdata_t userdata, realm_t* realm)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    realm::util::UniqueFunction userCallback = [ud, realm](realm::util::UniqueFunction<void(bool)>* unlockFunc) {
        ud->scheduler->invoke([ud, realm, unlockFunc]() {
            (reinterpret_cast<realm_sync_before_client_reset_begin_func_t>(ud->dart_callback))(ud->handle, realm, unlockFunc);
        });
    };
    return invoke_dart_and_await_result(&userCallback);
}

RLM_API bool realm_dart_sync_after_reset_handler_callback(realm_userdata_t userdata, realm_t* before_realm, realm_thread_safe_reference_t* after_realm, bool did_recover)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    realm::util::UniqueFunction userCallback = [ud, before_realm, after_realm, did_recover](realm::util::UniqueFunction<void(bool)>* unlockFunc) {
        ud->scheduler->invoke([ud, before_realm, after_realm, did_recover, unlockFunc]() {
            (reinterpret_cast<realm_sync_after_client_reset_begin_func_t>(ud->dart_callback))(ud->handle, before_realm, after_realm, did_recover, unlockFunc);
        });
    };
    return invoke_dart_and_await_result(&userCallback);
}

RLM_API void realm_dart_async_open_task_callback(realm_userdata_t userdata, realm_thread_safe_reference_t* realm, const realm_async_error_t* error)
{
    auto ud = reinterpret_cast<realm_dart_userdata_async_t>(userdata);
    ud->scheduler->invoke([ud, realm, error]() {
        (reinterpret_cast<realm_async_open_task_completion_func_t>(ud->dart_callback))(ud->handle, realm, error);
    });
}
