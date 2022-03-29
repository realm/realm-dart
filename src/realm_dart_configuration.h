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

#include "realm.h"

typedef struct realm_callback_struct realm_callback_struct_t;
typedef bool (*realm_dart_should_compact_on_launch_func_t)(uint64_t total_bytes, uint64_t used_bytes);
/**
 * Set the should-compact-on-launch callback.
 *
 * The callback is invoked the first time a realm file is opened in this process
 * to decide whether the realm file should be compacted.
 *
 * Note: If another process has the realm file open, it will not be compacted.
 *
 * This function cannot fail.
 */
RLM_API void realm_dart_config_set_should_compact_on_launch_function(realm_config_t*,
                                                                realm_dart_should_compact_on_launch_func_t);