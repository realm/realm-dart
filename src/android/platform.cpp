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
