#ifndef FFI_GEN
#include <jni.h>
extern "C" JNIEXPORT void Java_io_realm_RealmPlugin_native_1initRealm(JNIEnv *env, jobject thiz, jstring fileDir);
#endif

#ifndef FFI_GEN
extern "C" JNIEXPORT 
#endif
const char* realm_dart_get_files_path();