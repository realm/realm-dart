//
//  realm_flutter.c
//  Pods-Runner
//
//  Created by lubo on 2.11.20.
//
#include <stdio.h>

#include "dart_init.hpp"

#include "realm_flutter.h"
void init_realm() {
    Dart_Handle realmLibStr = Dart_NewStringFromCString("package:realm_flutter/realm.dart");
    Dart_Handle realmLib = Dart_LookupLibrary(realmLibStr);
    if (Dart_IsError(realmLib)) {
        fprintf(stderr, "Dart_LookupLibrary extension returned error");
    } else {
        fprintf(stderr, "Dart_LookupLibrary extension returned success. realm.dart library found");

        fprintf(stderr, "calling realm::dartvm::dart_init");
        realm::dartvm::dart_init(Dart_CurrentIsolate(), realmLib, "");
        fprintf(stderr, "realm::dartvm::dart_init completed");
    }
}
