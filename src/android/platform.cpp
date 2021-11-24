#include <string>
#include <android/log.h>

#include "platform.h"

static std::string filesDir;

extern "C" JNIEXPORT void Java_io_realm_RealmPlugin_native_1initRealm(JNIEnv *env, jobject thiz, jstring fileDir) {
    const char* strFileDir = env->GetStringUTFChars(fileDir, NULL);
    filesDir = std::string(strFileDir);
    env->ReleaseStringUTFChars(fileDir, strFileDir);
}

extern "C" JNIEXPORT const char* realm_dart_get_files_path() {
    return filesDir.c_str();
}

// Force the linker to link all exports from this file
void realm_android_dummy() {
    Java_io_realm_RealmPlugin_native_1initRealm(nullptr, nullptr, nullptr);
    realm_dart_get_files_path();
}