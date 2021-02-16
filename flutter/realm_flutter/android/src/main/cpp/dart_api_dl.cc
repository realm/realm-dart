/*
 * Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#include "dart_api_dl.h"
#include "dart_version.h"
#include "dart_api_dl_impl.h"

#include <string.h>

#include <android/log.h>

void init(Dart_Handle realmClass);

#define DART_API_DL_DEFINITIONS(name)                                          \
  using name##_Type = decltype(&name);                                          \
  name##_Type name##_DL = nullptr;
DART_API_ALL_DL_SYMBOLS(DART_API_DL_DEFINITIONS)
#undef DART_API_DL_DEFINITIONS

typedef void (*DartApiEntry_function)();

DartApiEntry_function FindFunctionPointer(const DartApiEntry* entries,
                                          const char* name) {
  while (entries->name != nullptr) {
    if (strcmp(entries->name, name) == 0) return entries->function;
    entries++;
  }
  return nullptr;
}

//dummy function which enables looking for a type from native code when the AOT dart compiler is used.
//If types are not passed from dart to native code using this functiont then Dart_GetType will fail to find the type
void EnableType(Dart_Handle type) {
    bool isType = Dart_IsType_DL(type);
    if (!isType) {
        __android_log_print(ANDROID_LOG_ERROR, "RealmFlutter", "EnableType failed");
    }
}


void InitRealm(Dart_Handle realmClass) {
    __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "Dart_InitializeApiDL checking RealmClass is a class");
    //DART_EXPORT Dart_Handle Dart_ClassLibrary(Dart_Handle cls_type);
    bool isType = false;
    isType = Dart_IsType_DL(realmClass);
    if (isType) {
        __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "realmClass argument is a class");
    }

    __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "Dart_InitializeApiDL calling init()");
    init(realmClass);
    __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "Dart_InitializeApiDL done");
}


intptr_t Dart_InitializeApiDL(void* data) {
  __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "Dart_InitializeApiDL called");
  DartApi* dart_api_data = reinterpret_cast<DartApi*>(data);

  if (dart_api_data->major != DART_API_DL_MAJOR_VERSION) {
    // If the DartVM we're running on does not have the same version as this
    // file was compiled against, refuse to initialize. The symbols are not
    // compatible.
    __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "Dart_InitializeApiDL: ERROR: incompatible versions");
    return -1;
  }
  // Minor versions are allowed to be different.
  // If the DartVM has a higher minor version, it will provide more symbols
  // than we initialize here.
  // If the DartVM has a lower minor version, it will not provide all symbols.
  // In that case, we leave the missing symbols un-initialized. Those symbols
  // should not be used by the Dart and native code. The client is responsible
  // for checking the minor version number himself based on which symbols it
  // is using.
  // (If we would error out on this case, recompiling native code against a
  // newer SDK would break all uses on older SDKs, which is too strict.)

  const DartApiEntry* dart_api_function_pointers = dart_api_data->functions;

#define DART_API_DL_INIT(name)                                                 \
  name##_DL = reinterpret_cast<name##_Type>(                                    \
      FindFunctionPointer(dart_api_function_pointers, #name));
  DART_API_ALL_DL_SYMBOLS(DART_API_DL_INIT)
#undef DART_API_DL_INIT

  return 0;
}
