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

RLM_API void realm_dart_sync_client_log_callback(realm_userdata_t userdata, realm_log_level_e level, const char* message);

RLM_API void realm_dart_sync_error_handler_callback(realm_userdata_t userdata, realm_sync_session_t* session, realm_sync_error_t error);

RLM_API void realm_dart_sync_wait_for_completion_callback(realm_userdata_t userdata, realm_sync_error_code_t* error);

RLM_API void realm_dart_sync_progress_callback(realm_userdata_t userdata, uint64_t transferred_bytes, uint64_t total_bytes);

RLM_API void realm_dart_sync_connection_state_changed_callback(realm_userdata_t userdata,
                                                               realm_sync_connection_state_e old_state,
                                                               realm_sync_connection_state_e new_state);

RLM_API void realm_dart_sync_on_subscription_state_changed_callback(realm_userdata_t userdata, realm_flx_sync_subscription_set_state_e state);

/**
 * Simulates a session error.
 *
 *  @param session The session where the simulated error will occur.
 *  @param category The category of the error that to be simulated (client=0, connection=1, session=2, system=3, unknown=4)
 *  @param errorCode Error code of the error that to be simulated.
 *  @param isFatal >If set to `true` the error will be marked as fatal.
 *
 *  Use this method to test your error handling code without connecting to a MongoDB Realm Server.
 */
RLM_API void realm_dart_sync_session_report_error_for_testing(realm_sync_session_t* session, uint32_t category, int errorCode, bool isFatal) RLM_API_NOEXCEPT;
