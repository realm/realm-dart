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

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <exception>

#include <realm.h>
#include "dart_api_dl.h"
#include "realm_dart.h"

#if defined(_WIN32)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

BOOL APIENTRY DllMain(HMODULE module,
                      DWORD  reason,
                      LPVOID reserved) {
    return true;
}

#endif  // defined(_WIN32)

RLM_API void realm_initializeDartApiDL(void* data) {
    Dart_InitializeApiDL(data);
}

void handle_finalizer(void* isolate_callback_data, void* realmPtr) {
    realm_release(realmPtr);
}

RLM_API Dart_FinalizableHandle realm_attach_finalizer(Dart_Handle handle, void* realmPtr, int size) {
    return Dart_NewFinalizableHandle_DL(handle, realmPtr, size, handle_finalizer);
}

RLM_API void realm_delete_finalizable(Dart_FinalizableHandle finalizable_handle, Dart_Handle handle) {
    Dart_DeleteFinalizableHandle_DL(finalizable_handle, handle);
}

class WeakHandle {
public:
    // TODO: HACK. Should be able to use the weak handle to get the handle.
    // When hack removed, replace with:
    // GCHandle(Dart_Handle handle) : m_weakHandle(Dart_NewWeakPersistentHandle_DL(handle, this, 1, finalize_handle)) {}
    WeakHandle(Dart_Handle handle) : m_weakHandle(Dart_NewFinalizableHandle_DL(handle, this, 1, finalize_handle)) {
    }

    Dart_Handle value() {
        // TODO: HACK. We can not release Dart weak persistent handles in on Isolate teardown until
        // https://github.com/dart-lang/sdk/issues/48321 is fixed and released, since the IsolateGroup
        // is destroyed before it happens.
        //
        // This works since Dart_WeakPersistentHandle is equivalent to Dart_FinalizableHandle.
        // They both are FinalizablePersistentHandle internally.
        Dart_WeakPersistentHandle weakHnd = reinterpret_cast<Dart_WeakPersistentHandle>(m_weakHandle);
        return Dart_HandleFromWeakPersistent_DL(weakHnd);
        // When hack removed, replace with:
        // return Dart_HandleFromFinalizable_DL(m_weakHandle);
    }

private:
    // destructor is private, only called by finalize_handle, when corresponding dart object is GCed
    /* TODO: HACK. Uncomment when hack removed
    ~GCHandle() {
        if (m_weakHandle) {
            Dart_DeleteWeakPersistentHandle_DL(m_weakHandle);
            m_weakHandle = nullptr;
        }
    }
    */

    static void finalize_handle(void* isolate_callback_data, void* peer) {
        delete reinterpret_cast<WeakHandle*>(peer);
    }

    // TODO: HACK. Should be Dart_WeakPersistentHandle when hack removed
    Dart_FinalizableHandle m_weakHandle;
};

RLM_API void* object_to_weak_handle(Dart_Handle handle) {
    return new WeakHandle(handle);
}

RLM_API Dart_Handle weak_handle_to_object(void* handle) {
    return reinterpret_cast<WeakHandle*>(handle)->value();
}

RLM_API void* object_to_persistent_handle(Dart_Handle handle) {
    return reinterpret_cast<void*>(Dart_NewPersistentHandle_DL(handle));
}

RLM_API Dart_Handle persistent_handle_to_object(void* handle) {
    Dart_PersistentHandle persistentHandle = reinterpret_cast<Dart_PersistentHandle>(handle);
    return Dart_HandleFromPersistent_DL(persistentHandle);
}

RLM_API void delete_persistent_handle(void* handle) {
    Dart_PersistentHandle persistentHandle = reinterpret_cast<Dart_PersistentHandle>(handle);
    Dart_DeletePersistentHandle_DL(persistentHandle);
}
