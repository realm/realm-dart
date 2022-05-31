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

#include <realm.h>

RLM_API void realm_dart_sync_on_subscription_state_changed_callback(realm_userdata_t userdata, realm_flx_sync_subscription_set_state_e state);

#endif // REALM_DART_SUBSCRIPTION_SET_H
