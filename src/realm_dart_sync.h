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

#pragma once

#include <realm.h>
typedef void (*realm_sync_before_client_reset_begin_func_t)(realm_userdata_t userdata, realm_t* before_realm, void* unlockFunc);

typedef void (*realm_sync_after_client_reset_begin_func_t)(realm_userdata_t userdata, realm_t* before_realm, realm_thread_safe_reference_t* after_realm, bool did_recover, void* unlockFunc);

RLM_API void realm_dart_http_request_callback(realm_userdata_t userdata, realm_http_request_t request, void* request_context);

RLM_API void realm_dart_sync_client_log_callback(realm_userdata_t userdata, realm_log_level_e level, const char* message);

RLM_API void realm_dart_sync_error_handler_callback(realm_userdata_t userdata, realm_sync_session_t* session, realm_sync_error_t error);

RLM_API void realm_dart_sync_wait_for_completion_callback(realm_userdata_t userdata, realm_sync_error_code_t* error);

RLM_API void realm_dart_sync_progress_callback(realm_userdata_t userdata, uint64_t transferred_bytes, uint64_t total_bytes);

RLM_API void realm_dart_sync_connection_state_changed_callback(realm_userdata_t userdata,
                                                               realm_sync_connection_state_e old_state,
                                                               realm_sync_connection_state_e new_state);

RLM_API void realm_dart_sync_on_subscription_state_changed_callback(realm_userdata_t userdata, realm_flx_sync_subscription_set_state_e state);

RLM_API bool realm_dart_sync_before_reset_handler_callback(realm_userdata_t userdata, realm_t* realm);

RLM_API bool realm_dart_sync_after_reset_handler_callback(realm_userdata_t userdata, realm_t* before_realm, realm_thread_safe_reference_t* after_realm, bool did_recover);

RLM_API void realm_dart_async_open_task_callback(realm_userdata_t userdata, realm_thread_safe_reference_t* realm, const realm_async_error_t* error);
