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

void init(Dart_Handle realmClass) {
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

//    //print loaded libs
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


    Dart_Handle realmLibStr = Dart_NewStringFromCString("package:realm_flutter/realm.dart");
    auto realmLib = Dart_LookupLibrary(realmLibStr);
    if (Dart_IsError(realmLib)) {
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary extension returned error");

        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Using realmClass argument");
        realmLib = Dart_ClassLibrary(realmClass);
        if (realmLib == nullptr || !Dart_IsLibrary(realmLib)) {
            __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Error: Dart_ClassLibrary returned a non library");
        }
    }

    if (realmLib != nullptr && Dart_IsLibrary(realmLib)) {
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Dart_LookupLibrary extension returned success. realm.dart library found");
        //---------------
        Dart_Handle url = Dart_LibraryUrl(realmLib);
        const char* resolvedUrl;
        Dart_StringToCString(url, &resolvedUrl);
        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "Realm Library resolved url %s", resolvedUrl);

        Dart_Handle coreLib = Dart_LookupLibrary(Dart_NewStringFromCString("dart:core"));
        Dart_Handle result = Dart_GetType(coreLib, Dart_NewStringFromCString("DateTime"), 0, nullptr);
        if (Dart_IsError(result)) {
            __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime GetType failed");
            result = Dart_GetNullableType(coreLib, Dart_NewStringFromCString("DateTime"), 0, nullptr);
            if (Dart_IsError(result)) {
                __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime Dart_GetNullableType failed");
                result = Dart_GetNonNullableType(coreLib, Dart_NewStringFromCString("DateTime"), 0, nullptr);
                if (Dart_IsError(result)) {
                    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime Dart_GetNonNullableType failed");
                    result = Dart_GetClass(coreLib, Dart_NewStringFromCString("DateTime"));
                    if (Dart_IsError(result)) {
                        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime Dart_GetClass failed");
                    }
                    else {
                        __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime Dart_GetClass SUCCESS");
                    }
                }
                else {
                    __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime Dart_GetNonNullableType SUCCESS");
                }
            }
            else {
                __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime Dart_GetNullableType SUCCESS");
            }
        }
        else {
            __android_log_print(ANDROID_LOG_DEBUG, "FlutterNativeExtension", "DateTime Dart_GetType SUCCESS");
        }


        //---------------

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

    //__android_log_print(/NDROID_LOG_DEBUG, "RealmFlutter", "calling Dart_SetInitCallback");
    //bool result = Dart_SetInitCallback(init);
    //__android_log_print(ANDROID_LOG_DEBUG, "RealmFlutter", "Dart_SetInitCallback success");
}