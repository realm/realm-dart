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

#ifndef REALM_DART_H
#define REALM_DART_H

#include "realm.h"
#include "dart_api_dl.h"

RLM_API void realm_initializeDartApiDL(void* data);

RLM_API Dart_FinalizableHandle realm_attach_finalizer(Dart_Handle handle, void* realmPtr, int size);

RLM_API void realm_delete_finalizable(Dart_FinalizableHandle finalizable_handle, Dart_Handle handle);

// GC Handle stuff
RLM_API void* gc_handle_new(Dart_Handle handle);
RLM_API void gc_handle_delete(void* handler);
RLM_API Dart_Handle gc_handle_deref(void* handler);

#endif // REALM_DART_H