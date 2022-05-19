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

#ifndef REALM_DART_SUBSCRIPTION_SET_H
#define REALM_DART_SUBSCRIPTION_SET_H

#include "realm.h"

typedef void (*realm_dart_sync_on_subscription_state_changed)(void* userdata,
                                                              realm_flx_sync_subscription_set_state_e state);

/**
 * Register a handler in order to be notified when subscription set is equal to the one passed as parameter
 * This is an asynchronous operation.
 * 
 * @return true/false if the handler was registered correctly
 * 
 * This is dart specific version of realm_dart_on_subscription_set_state_change_async.
 * Unlike the original method, this one uses event_loop_dispatcher to ensure the callback
 * is handled on the correct isolate thread.
 */
RLM_API bool
realm_dart_sync_on_subscription_set_state_change_async(const realm_flx_sync_subscription_set_t* subscription_set,
                                                       realm_flx_sync_subscription_set_state_e notify_when,
                                                       realm_dart_sync_on_subscription_state_changed callback,
                                                       void* userdata, 
                                                       realm_free_userdata_func_t userdata_free,
                                                       realm_scheduler_t* scheduler) RLM_API_NOEXCEPT;

#endif // REALM_DART_SUBSCRIPTION_SET_H