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

#ifndef REALM_DART_SYNC_SESSION_H
#define REALM_DART_SYNC_SESSION_H

#include "realm.h"

/**
 * Register a callback that will be invoked when all pending downloads have completed.
 */
RLM_API void realm_dart_sync_session_wait_for_download_completion(realm_sync_session_t* session,
                                                                  realm_sync_download_completion_func_t callback,
                                                                  void* userdata,
                                                                  realm_free_userdata_func_t userdata_free,
                                                                  realm_scheduler_t* scheduler) RLM_API_NOEXCEPT;

/**
 * Register a callback that will be invoked when all pending uploads have completed.
 */
RLM_API void realm_dart_sync_session_wait_for_upload_completion(realm_sync_session_t* session,
                                                                realm_sync_upload_completion_func_t callback,
                                                                void* userdata,
                                                                realm_free_userdata_func_t userdata_free,
                                                                realm_scheduler_t* scheduler) RLM_API_NOEXCEPT;

/**
 * Register a callback that will be invoked every time the session reports progress.
 *
 * @param is_streaming If true, then the notifier will be called forever, and will
 *                     always contain the most up-to-date number of downloadable or uploadable bytes.
 *                     Otherwise, the number of downloaded or uploaded bytes will always be reported
 *                     relative to the number of downloadable or uploadable bytes at the point in time
 *                     when the notifier was registered.
 * @return A token value that can be used to unregister the notifier.
 */
RLM_API uint64_t realm_dart_sync_session_register_progress_notifier(realm_sync_session_t* session,
                                                                    realm_sync_progress_func_t callback,
                                                                    realm_sync_progress_direction_e direction,
                                                                    bool is_streaming,
                                                                    void* userdata,
                                                                    realm_free_userdata_func_t userdata_free,
                                                                    realm_scheduler_t* scheduler) RLM_API_NOEXCEPT;

/**
 * Register a callback that will be invoked every time the session's connection state changes.
 *
 * @return A token value that can be used to unregister the callback.
 */
RLM_API uint64_t realm_dart_sync_session_register_connection_state_change_callback(realm_sync_session_t* session,
                                                                                   realm_sync_connection_state_changed_func_t callback,
                                                                                   void* userdata,
                                                                                   realm_free_userdata_func_t userdata_free,
                                                                                   realm_scheduler_t* scheduler) RLM_API_NOEXCEPT;

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
#endif // REALM_DART_SYNC_SESSION_H