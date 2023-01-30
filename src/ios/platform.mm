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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <string>
#include "../realm_dart.h"
#import <sys/utsname.h>

static std::string filesDir;
static std::string deviceModel;
static std::string deviceVersion;

std::string default_realm_file_directory()
{
    std::string ret;
    @autoreleasepool {
        // On iOS the Documents directory isn't user-visible, so put files there
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        ret = path.UTF8String;
        return ret;
    }
}

std::string current_device_model()
{
    std::string ret;
    @autoreleasepool {
        NSString *model = [[UIDevice currentDevice] model];
        ret = model.UTF8String;
        return ret;
    }
}


RLM_API const char* realm_dart_get_files_path() {
    if (filesDir == "") {
        filesDir = default_realm_file_directory();
    }

    return filesDir.c_str();
}

RLM_API const char* realm_dart_get_device_name() {
    if (deviceModel == "") {
        deviceModel = current_device_model();
    }

    return deviceModel.c_str();
}

RLM_API const char* realm_dart_get_device_version() {
    if (deviceVersion == "") {
        struct utsname systemInfo;
        uname(&systemInfo);
        deviceVersion = systemInfo.machine;
    }

    return deviceVersion.c_str();
}
