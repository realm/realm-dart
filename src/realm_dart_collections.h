////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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

#ifndef REALM_DART_COLLECTIONS_H
#define REALM_DART_COLLECTIONS_H

#include "realm.h"
#include "dart_api_dl.h"

typedef void (*realm_dart_on_collection_change_func_t)(Dart_Handle notification_controller, const realm_collection_changes_t*);

/**
 * Subscribe for notifications of changes to a realm results collection.
 *
 * @param results The realm results to subscribe to.
 * @param userdata A handle to dart object that will be passed to the callback.
 * @param on_change The callback to invoke, if the realm results changes.
 * @return A notification token that can be released to unsubscribe.
 *
 * This is a dart specific wrapper for realm_results_add_notification_callback.
 */
RLM_API realm_notification_token_t *
realm_dart_results_add_notification_callback(realm_results_t *results,
                                             Dart_Handle notification_controller,
                                             realm_dart_on_collection_change_func_t callback,
                                             realm_scheduler_t *scheduler);

#endif // REALM_DART_COLLECTIONS_H