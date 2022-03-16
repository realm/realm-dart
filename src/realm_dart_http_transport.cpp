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

#include "realm_dart_http_transport.h"
#include "dart_api_dl.h"

struct HandleScope {
    HandleScope() {
        Dart_EnterScope_DL();
    }

    ~HandleScope() {
        Dart_ExitScope_DL();
    }
};

class RequestCallbackData {
    //This is no op and does not need to call delete_handle since ~CallbackData is always called by the RealmNotificationTokenHandle finalizer
    static void finalize_handle(void* isolate_callback_data, void* peer) {}

    void delete_handle() {
        if (m_handle) {
            Dart_DeleteWeakPersistentHandle_DL(m_handle);
            m_handle = nullptr;
        }
    }

public:
    RequestCallbackData(Dart_Handle handle, realm_dart_http_request_func_t callback)
        : m_handle(Dart_NewWeakPersistentHandle_DL(handle, nullptr, 1, finalize_handle)), m_callback(callback)
    {}

    ~RequestCallbackData() {
        delete_handle();
    }

    void callback(const realm_http_request_t request, void* request_context) {
        if (m_handle) {
            HandleScope scope;
            auto handle = Dart_HandleFromWeakPersistent_DL(m_handle);
            m_callback(handle, request, request_context);
        }
    }

private:
    Dart_WeakPersistentHandle m_handle;
    realm_dart_http_request_func_t m_callback;
};

void free_request_callback_data(void* userdata) {
    auto request_callback_data = static_cast<RequestCallbackData*>(userdata);
    delete request_callback_data;
}

void on_request_callback(
    void* userdata,
    const realm_http_request_t request,
    void* request_context)
{
    auto request_callback_data = static_cast<RequestCallbackData*>(userdata);
    request_callback_data->callback(request, request_context);
}

RLM_API realm_http_transport_t* realm_dart_http_transport_new(
    realm_dart_http_request_func_t request_callback,
    Dart_Handle userdata)
{
    auto request_callback_data = new RequestCallbackData(userdata, request_callback);
    return realm_http_transport_new(on_request_callback, request_callback_data, free_request_callback_data);
}
