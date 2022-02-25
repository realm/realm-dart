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

template<typename Type, typename Func>
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
    CallbackData(Dart_Handle handle, Func callback)
        : m_handle(Dart_NewFinalizableHandle_DL(handle, nullptr, 1, finalize_handle)), m_callback(callback)
    {}

    ~CallbackData() {
        delete_handle();
    }

    void callback(const Type* changes) {
        if (m_handle) {
            HandleScope scope;
            //TODO: HACK. We can not release Dart persitent handles in delete_handle on Isolate teardown since the IsolateGroup is destroyed before it.
            //This works since Dart_WeakPersistentHandle is equivalent to Dart_FinalizableHandle. They both are FinalizablePersistentHandle internally.
            Dart_WeakPersistentHandle weakHnd = reinterpret_cast<Dart_WeakPersistentHandle>(m_handle);
            auto handle = Dart_HandleFromWeakPersistent_DL(weakHnd);

            //clone changes object since the Dart callback is async and changes object is valid for the duration of this method only
            //clone failures are handled in the Dart callback
            const Type* cloned = static_cast<Type*>(realm_clone(changes));
            m_callback(handle, cloned);
        }
    }
   
private:
    //TODO: We use FinalizableHandle since it is auto-deleting. Switch to Dart_WeakPersistentHandle when the HACK is removed
    Dart_FinalizableHandle m_handle;
    Func m_callback;
};

typedef CallbackData<realm_collection_changes_t, realm_dart_on_collection_change_func_t> CollectionCallbackData;
typedef CallbackData<realm_object_changes_t, realm_dart_on_object_change_func_t> ObjectCallbackData;

void on_collection_change_callback(void* userdata, const realm_collection_changes_t* changes) {
    auto& callbackData = *reinterpret_cast<CollectionCallbackData*>(userdata);
    callbackData.callback(changes);
}

template<typename Type>
void on_collection_change_callback_type(void* userdata, const realm_collection_changes_t* changes) {
    auto& callbackData = *reinterpret_cast<Type*>(userdata);
    callbackData.callback(changes);
}

void free_collection_callback_data(void* userdata) {
    auto callback = reinterpret_cast<CollectionCallbackData*>(userdata);
    delete callback;
}

void on_object_change_callback(void* userdata, const realm_object_changes* changes) {
    auto& callbackData = *reinterpret_cast<ObjectCallbackData*>(userdata);
    callbackData.callback(changes);
}

void free_object_callback_data(void* userdata) {
    auto callback = reinterpret_cast<ObjectCallbackData*>(userdata);
    delete callback;
}

RLM_API realm_notification_token_t* realm_dart_results_add_notification_callback(
    realm_results_t* results,
    Dart_Handle notification_controller,
    realm_dart_on_collection_change_func_t callback,
    realm_scheduler_t* scheduler)
{
    auto callback_data = new CollectionCallbackData(notification_controller, callback);

    return realm_results_add_notification_callback(results,
        callback_data,
        free_collection_callback_data,
        on_collection_change_callback,
        nullptr,
        scheduler);
}

RLM_API realm_notification_token_t* realm_dart_list_add_notification_callback(
    realm_list_t* list,
    Dart_Handle notification_controller,
    realm_dart_on_collection_change_func_t callback,
    realm_scheduler_t* scheduler)
{
    auto callback_data = new CollectionCallbackData(notification_controller, callback);

    return realm_list_add_notification_callback(list,
        callback_data,
        free_collection_callback_data,
        on_collection_change_callback,
        nullptr,
        scheduler);
}

RLM_API realm_notification_token_t* realm_dart_object_add_notification_callback(
    realm_object_t* realm_object,
    Dart_Handle notification_controller,
    realm_dart_on_object_change_func_t callback,
    realm_scheduler_t* scheduler)
{
    auto callback_data = new ObjectCallbackData(notification_controller, callback);

    return realm_object_add_notification_callback(realm_object,
        callback_data,
        free_object_callback_data,
        on_object_change_callback,
        nullptr,
        scheduler);
}
