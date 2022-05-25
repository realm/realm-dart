#include <stdint.h>

// In order to cheat ffigen and hide the dart-dl headers, we define the dart-api.h include guard here,
// which prevents libclang from processing the header file at all
#define RUNTIME_INCLUDE_DART_API_H_

// however we still need these types from dart-api.h in our headers
typedef struct _Dart_Handle* Dart_Handle;
typedef Dart_Handle Dart_PersistentHandle;
typedef struct _Dart_WeakPersistentHandle* Dart_WeakPersistentHandle;
typedef struct _Dart_FinalizableHandle* Dart_FinalizableHandle;
typedef int64_t Dart_Port;

// The C API header
#include <realm.h>

// List all the headers that should be processed by ffigen, relative to the src folder
#include <realm_dart_scheduler.h>
#include <realm_dart.h>
#include <subscription_set.h>
#include <sync_client_config.h>
#include <sync_session.h>
