//
//  realm_flutter.c
//  Pods-Runner
//
//  Created by lubo on 2.11.20.
//
#include <stdio.h>
#include <string>
#include <syslog.h>

#include "dart_init.hpp"
#include "realm_flutter.h"

void init() {
    syslog(LOG_ERR, "Relm flutter init() called.");
    Dart_Handle realmLibStr = Dart_NewStringFromCString_DL("package:realm/realm.dart");
    Dart_Handle realmLib = Dart_LookupLibrary(realmLibStr);
    if (Dart_IsError(realmLib)) {
        syslog(LOG_ERR, "Dart_LookupLibrary returned error");
        exit(-1);
    } else {
        syslog(LOG_ERR, "Dart_LookupLibrary returned success. realm.dart library found");


        syslog(LOG_ERR, "calling realm::dartvm::dart_init");
        realm::dartvm::dart_init(Dart_CurrentIsolate(), realmLib, "");
        syslog(LOG_ERR, "realm::dartvm::dart_init completed");

// dynmaic framework loading not working
//         syslog(LOG_ERR, "Realm: calling dlopen");
//         void (*dart_init)(Dart_Isolate env, Dart_Handle realmLibrary, const std::string& filesDir);
//         void *handle = dlopen("Flutter.framework/realm", RTLD_LOCAL | RTLD_LAZY);
//         if (!handle) {
//            syslog(LOG_ERR, "Invalid handle on dlopen");
//            exit(-1);
//         }
        
//         syslog(LOG_ERR, "Realm: searching for dart_init");
//         //do not cast void* to function pointer. see Example https://linux.die.net/man/3/dlsym
//         *(void**) (&dart_init) = dlsym(handle, "dart_init");
//         if (!dart_init) {
//             syslog(LOG_ERR, "Can not find dart_init exported function");
//             exit(-1);
//         }

//         syslog(LOG_ERR, "calling realm::dartvm::dart_init function");
//         dart_init(Dart_CurrentIsolate(), realmLib, "");
//         syslog(LOG_ERR, "realm::dartvm::dart_init completed successfuly");
// #endif
    }
}
