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

#include "realm_dart.h"
#include <realm/object-store/c_api/types.hpp>
#include <realm/util/functional.hpp>

struct realm_dart_userdata_async {
    realm_dart_userdata_async(Dart_Handle handle, void* callback, realm_scheduler_t* scheduler)
    : handle(Dart_NewPersistentHandle_DL(handle))
    , dart_callback(callback)
    , scheduler(*scheduler)
    { }

    ~realm_dart_userdata_async() {
        Dart_DeletePersistentHandle_DL(handle);
    }

    Dart_PersistentHandle handle;
    void* dart_callback;
    std::shared_ptr<realm::util::Scheduler> scheduler;
};