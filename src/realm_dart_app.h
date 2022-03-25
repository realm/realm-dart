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

#ifndef REALM_DART_APP_H
#define REALM_DART_APP_H

#include "realm.h"
#include "dart_api_dl.h"

/**
 * Completion callback for asynchronous Realm App operations that yield a user object.
 *
 * @param userdata The userdata the asynchronous operation was started with.
 * @param user User object produced by the operation, or null if it failed.
 *             The pointer is alive only for the duration of the callback,
 *             if you wish to use it further make a copy with realm_clone().
 * @param error Pointer to an error object if the operation failed, otherwise null if it completed successfully.
 * 
 * This is a dart specific version of the completion callback for asynchronous Realm operations.
 */
typedef void (*realm_dart_app_user_completion_func_t)(Dart_Handle userdata, realm_user_t* user, const realm_app_error_t* error);

/**
 * @brief 
 * 
 * @param completion 
 * @param userdata 
 * @return true if operation started successfully, false if an error occurred.
 */
RLM_API bool realm_dart_app_log_in_with_credentials(realm_app_t*, realm_app_credentials_t*,
                                                    realm_dart_app_user_completion_func_t completion, Dart_Handle userdata);

#endif