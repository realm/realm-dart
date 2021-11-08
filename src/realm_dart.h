#ifndef REALM_DART_H
#define REALM_DART_H

#include "realm.h"
#include "dart_api_dl.h"

RLM_API void realm_initializeDartApiDL(void* data);

RLM_API bool realm_attach_finalizer(Dart_Handle handle, void* realmPtr, int size);

#endif // REALM_DART_H