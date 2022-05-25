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
#include <dart_api_dl.h>

#include "realm_dart.h"

RLM_API void realm_dart_initializeDartApiDL(void* data) {
    Dart_InitializeApiDL(data);
}

static void handle_finalizer(void* isolate_callback_data, void* realmPtr) {
    realm_release(realmPtr);
}

RLM_API Dart_FinalizableHandle realm_dart_attach_finalizer(Dart_Handle handle, void* realmPtr, int size) {
    return Dart_NewFinalizableHandle_DL(handle, realmPtr, size, handle_finalizer);
}

RLM_API void realm_dart_delete_finalizable(Dart_FinalizableHandle finalizable_handle, Dart_Handle handle) {
    Dart_DeleteFinalizableHandle_DL(finalizable_handle, handle);
}

class WeakHandle {
public:
    WeakHandle(Dart_Handle handle) : m_weakHandle(Dart_NewWeakPersistentHandle_DL(handle, this, 1, finalize_handle)) {
    }

    Dart_Handle value() {
        return Dart_HandleFromWeakPersistent_DL(m_weakHandle);
    }

private:
    ~WeakHandle() {
        if (m_weakHandle) {
            Dart_DeleteWeakPersistentHandle_DL(m_weakHandle);
            m_weakHandle = nullptr;
        }
    }

    static void finalize_handle(void* isolate_callback_data, void* peer) {
        delete reinterpret_cast<WeakHandle*>(peer);
    }

    Dart_WeakPersistentHandle m_weakHandle;
};

RLM_API void* realm_dart_object_to_weak_handle(Dart_Handle handle) {
    return new WeakHandle(handle);
}

RLM_API Dart_Handle realm_dart_weak_handle_to_object(void* handle) {
    return reinterpret_cast<WeakHandle*>(handle)->value();
}

RLM_API void* realm_dart_object_to_persistent_handle(Dart_Handle handle) {
    return reinterpret_cast<void*>(Dart_NewPersistentHandle_DL(handle));
}

RLM_API Dart_Handle realm_dart_persistent_handle_to_object(void* handle) {
    Dart_PersistentHandle persistentHandle = reinterpret_cast<Dart_PersistentHandle>(handle);
    return Dart_HandleFromPersistent_DL(persistentHandle);
}

RLM_API void realm_dart_delete_persistent_handle(void* handle) {
    Dart_PersistentHandle persistentHandle = reinterpret_cast<Dart_PersistentHandle>(handle);
    Dart_DeletePersistentHandle_DL(persistentHandle);
}
