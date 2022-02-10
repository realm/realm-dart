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
#include <stdio.h>

struct HandleScope {
    HandleScope() {
        Dart_EnterScope_DL();
    }

    ~HandleScope() {
        Dart_ExitScope_DL();
    }
};

class CallbackData {
    //This is no op and does not need to call delete_handle since ~CallbackData is always called by the RealmNotificationTokenHandle finalizer
    static void finalize_handle(void* isolate_callback_data, void* peer) {}

    void delete_handle() {
        if (m_handle) {
            //TODO: uncomment when the HACK is removed.
            //Dart_DeleteWeakPersistentHandle_DL(m_handle);
            m_handle = nullptr;
        }
    }

public:
    CallbackData(Dart_Handle handle, realm_dart_on_collection_change_func_t callback)
        : m_handle(Dart_NewFinalizableHandle_DL(handle, nullptr, 1, finalize_handle)), m_callback(callback) 
    {}

    ~CallbackData() {
        delete_handle();
    }

    void callback(const realm_collection_changes_t* changes) {
        if (m_handle) {
            HandleScope scope;
            //TODO: HACK. We can not release Dart persitent handles in delete_handle on Isolate teardown since the IsolateGroup is destroyed before it.
            //This works since Dart_WeakPersistentHandle is equivalent to Dart_FinalizableHandle. They both are FinalizablePersistentHandle internally.
            Dart_WeakPersistentHandle weakHnd = reinterpret_cast<Dart_WeakPersistentHandle>(m_handle);
            auto handle = Dart_HandleFromWeakPersistent_DL(weakHnd);
            
            //clone changes object since the Dart callback is async and changes object is valid for the duration of this method only
            //clone failures are handled in the Dart callback
            const realm_collection_changes_t* cloned = static_cast<realm_collection_changes_t*>(realm_clone(changes));
            m_callback(handle, cloned);
        }
    }

private:
    //TODO: We use FinalizableHandle since it is auto-deleting. Switch to Dart_WeakPersistentHandle when the HACK is removed
    Dart_FinalizableHandle m_handle;
    realm_dart_on_collection_change_func_t m_callback;
};

void on_change_callback(void* userdata, const realm_collection_changes_t* changes) {
    auto& callbackData = *reinterpret_cast<CallbackData*>(userdata);
    callbackData.callback(changes);
}

void free_callback(void* userdata) {
    auto callback = reinterpret_cast<CallbackData*>(userdata);
    delete callback;
}

RLM_API realm_notification_token_t* realm_dart_results_add_notification_callback(
    realm_results_t* results, 
    Dart_Handle notification_controller,
    realm_dart_on_collection_change_func_t callback, 
    realm_scheduler_t* scheduler) 
{
    CallbackData* callback_data = new CallbackData(notification_controller, callback);

    return realm_results_add_notification_callback(results,
        callback_data,
        free_callback,
        on_change_callback,
        nullptr,
        scheduler);
}