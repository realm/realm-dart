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
#include "realm_dart_configuration.h"
#include <stdio.h>

struct realm_config_struct {
    realm_dart_should_compact_on_launch_func_t callback_func;
};

bool should_compact_on_launch(void* userdata_p, uint64_t total_size, uint64_t used_size)
{
    auto userdata = static_cast<realm_config_struct*>(userdata_p);
    return userdata->callback_func(total_size, used_size);
}


RLM_API void realm_dart_config_set_should_compact_on_launch_function(realm_config_t* config,
                                                       realm_dart_should_compact_on_launch_func_t func)
{
    realm_config_struct userdata;
    userdata.callback_func = func;

    return realm_config_set_should_compact_on_launch_function(config,
       should_compact_on_launch, &userdata);
}


