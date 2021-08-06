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

#include <jni.h>
#include <string>

#include "dart_api.h"
#include "dart_native_api.h"

#include "dart_io_extensions.h"
#include "dart_init.hpp"
#include "dart_api_dl.h"

#include "realm_flutter.h"

#include <android/log.h>
bool initialized = false;
std::string filesDir;
void flutterNativeExtensionDoWork(Dart_NativeArguments arguments) {
    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "flutterNativeExtensionDoWork called");
}

Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool* auto_setup_scope) {
    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "ResolveName called");
    if (!Dart_IsString(name)) {
        return NULL;
    }

    Dart_NativeFunction result = NULL;
    if (auto_setup_scope == NULL) {
        return NULL;
    }

    const char* cname;
    Dart_StringToCString(name, &cname);
    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "ResolveName name: %s", cname);
    return flutterNativeExtensionDoWork;
    //return NULL;
}

void init() {
    if (initialized) {
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "init called again. exitting");
        return;
    }

    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "init function called");

    void* p = (void*)Dart_CurrentIsolate();
    if (p != nullptr) {
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Isoleate non null");
    }
    else {
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Isoleate is null");
    };


    //__android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "calling Dart_NewStringFromCString");
//    Dart_Handle res = Dart_NewStringFromCString("package:FlutterNativeExtension");
//
//    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_NewStringFromCString finsihed");
//
//    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "calling  Dart_IsError");
//    if (Dart_IsError(res)) {
//        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_NewStringFromCString returned error");
//    } else {
//        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_NewStringFromCString returned success");
//    }


    Dart_Handle realmLibStr = Dart_NewStringFromCString("package:realm/realm.dart");
    auto realmLib = Dart_LookupLibrary(realmLibStr);
    if (Dart_IsError(realmLib)) {
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary extension returned error");
    } else {
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary extension returned success. realm.dart library found");


        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "calling realm::dartvm::dart_init");
        realm::dartvm::dart_init(Dart_CurrentIsolate(), realmLib, filesDir);
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "realm::dartvm::dart_init completed");
    }


//    print loaded libs
//    auto libs = Dart_GetLoadedLibraries();
//    intptr_t len;
//    Dart_ListLength(libs, &len);
//    for (size_t i = 0; i < len; i++)
//    {
//        auto lib = Dart_ListGetAt(libs, i);
//        auto name = Dart_LibraryResolvedUrl(lib);
//        const char* nameStr;
//        Dart_StringToCString(name, &nameStr);
//        //printf("%s \n", nameStr);
//        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary num:%d  name: %s", i, nameStr);
//    }



//    Dart_Handle lib = Dart_LookupLibrary(res);
//    if (Dart_IsError(lib)) {
//        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", " Dart_LookupLibrary returned error");
//        auto error =  Dart_GetError(lib);
//        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary failed: %s", error);
//    } else {
//        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", " Dart_LookupLibrary returned success");
//    }


    //auto rootLib = Dart_RootLibrary();

    // Dart_Handle result_code = Dart_SetNativeResolver(extensionLib, ResolveName, NULL);
    // if (Dart_IsError(result_code)) {
    //     __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_SetNativeResolver returned error");
    //     auto error =  Dart_GetError(result_code);
    //     __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary failed: %s", error);
    // } else {
    //     __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_SetNativeResolver returned success");
    // }

    initialized = true;
}

extern "C" JNIEXPORT jstring JNICALL Java_com_blagoev_FlutterNativeExtension_MainActivity_stringFromJNI(JNIEnv* env, jobject /* this */) {

    void* p = (void*)Dart_CurrentIsolate();

    //bool result = Dart_SetInitCallback(init);
    bool result = p != nullptr;
    std::string hello = "Hello from C++. Dart_CurrentIsolate returns: " + std::to_string((long long)p);
    if (!result) {
        hello += " Dart_SetInitCallback SUCCESS";
    } else {
        hello += " Dart_SetInitCallback FAIL";
    }


    return env->NewStringUTF(hello.c_str());
}

extern "C" JNIEXPORT void JNICALL Java_io_realm_realm_1flutter_RealmFlutter_native_1initRealm(JNIEnv *env, jobject thiz, jstring fileDir) {
    __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "getting filesDir");
    const char* strFileDir = env->GetStringUTFChars(fileDir, NULL);
    filesDir = strFileDir;
    env->ReleaseStringUTFChars(fileDir, strFileDir);
    __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "filesDir: %s", filesDir.c_str());

    //__android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "calling Dart_SetInitCallback");
    //bool result = Dart_SetInitCallback(init);
    //  __android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "Dart_SetInitCallback success");
}