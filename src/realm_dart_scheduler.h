#ifndef REALM_DART_SCHEDULER_H
#define REALM_DART_SCHEDULER_H

#include "realm.h"
#include "dart_api_dl.h"

RLM_API realm_scheduler_t* realm_dart_create_scheduler(Dart_Port port);

RLM_API void realm_dart_scheduler_invoke(void* userData);

#endif // REALM_DART_SCHEDULER_H