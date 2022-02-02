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
#include "dart_api_dl.h"
#include "realm_dart_collections.h"

struct Scope
{
    Scope()
    {
        Dart_EnterScope_DL();
    }
    ~Scope()
    {
        Dart_ExitScope_DL();
    }
};

class Callback
{
    Dart_WeakPersistentHandle handle_;
    realm_dart_on_collection_change_func_t callback_;

    static void finalize_(void *isolate_callback_data, void *peer)
    {
        auto &callback = *reinterpret_cast<Callback *>(peer);
        callback.drop_handle();
    }

    void drop_handle()
    {
        if (handle_ != nullptr)
        {
            Dart_DeleteWeakPersistentHandle_DL(handle_);
            handle_ = nullptr;
        }
    }

public:
    Callback(Dart_Handle handle, realm_dart_on_collection_change_func_t callback)
        : handle_(Dart_NewWeakPersistentHandle_DL(handle, this, 1 << 24, finalize_)), callback_(callback) {}

    ~Callback()
    {
        drop_handle();
    }

    void operator()(const realm_collection_changes_t *changes)
    {
        if (handle_ != nullptr)
        {
            Scope s; // ensure we can create handles
            auto h = Dart_HandleFromWeakPersistent_DL(handle_);
            // Note Dart_IsNull(h) is not exposed in DL, so we cannot check.
            // Hence the callback has to be prepared for this eventuality.
            callback_(h, changes);
        }
    }
};

void on_change_(void *userdata, const realm_collection_changes_t *changes)
{
    auto &callback = *reinterpret_cast<Callback *>(userdata);
    callback(changes);
}

void free_(void *userdata)
{
    auto callback = reinterpret_cast<Callback *>(userdata);
    delete callback;
}

RLM_API realm_notification_token_t *
realm_dart_results_add_notification_callback(realm_results_t *results,
                                             Dart_Handle userdata,
                                             realm_dart_on_collection_change_func_t on_change,
                                             realm_scheduler_t *scheduler)
{
    auto callback = new Callback{userdata, on_change};
    return realm_results_add_notification_callback(results,
                                                   callback,
                                                   free_,
                                                   on_change_,
                                                   nullptr, // on_error never called by realm core 6+
                                                   scheduler);
}