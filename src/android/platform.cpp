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
#include "../realm_dart.h"

static std::string mFilesDir;
static std::string mDeviceName;
static std::string mDeviceVersion;
static std::string mBundleId;

extern "C" JNIEXPORT void Java_io_realm_RealmPlugin_native_1initRealm(JNIEnv * env, jobject thiz, jstring filesDir, jstring deviceName, jstring deviceVersion, jstring bundleId) {
    const char* strFilesDir = env->GetStringUTFChars(filesDir, NULL);
    mFilesDir = std::string(strFilesDir);
    env->ReleaseStringUTFChars(filesDir, strFilesDir);

    const char* strDeviceName = env->GetStringUTFChars(deviceName, NULL);
    mDeviceName = std::string(strDeviceName);
    env->ReleaseStringUTFChars(deviceName, strDeviceName);

    const char* strDeviceVersion = env->GetStringUTFChars(deviceVersion, NULL);
    mDeviceVersion = std::string(strDeviceVersion);
    env->ReleaseStringUTFChars(deviceVersion, strDeviceVersion);

    const char* strBundleId = env->GetStringUTFChars(bundleId, NULL);
    mBundleId = std::string(strBundleId);
    env->ReleaseStringUTFChars(bundleId, strBundleId);
}

extern "C" JNIEXPORT const char* realm_dart_get_files_path() {
    return mFilesDir.c_str();
}

extern "C" JNIEXPORT const char* realm_dart_get_device_name() {
    return mDeviceName.c_str();
}

extern "C" JNIEXPORT const char* realm_dart_get_device_version() {
    return mDeviceVersion.c_str();
}

extern "C" JNIEXPORT const char* realm_dart_get_bundle_id() {
    return mBundleId.c_str();
}
