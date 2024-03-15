#include <string>
#include <sstream>
#import <Foundation/Foundation.h>

#import "realm_plugin.h"

#ifndef BUNDLE_ID
#define BUNDLE_ID "realm_bundle_id"
#endif

static std::string filesDir;
static std::string bundleId = BUNDLE_ID;

std::string default_realm_file_directory()
{
    std::string ret;
    std::string bundle;
    @autoreleasepool {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
        ret = path.UTF8String;
        return ret;
    }
}

// Returns the app directory on the current machine or null if getting the default directory fails
// On macOS this is the /Users/username/Library/Containers/app_name/Data/Library/Application Support
RLM_API const char* realm_dart_get_app_directory() {
    if (!filesDir.empty()) {
        return filesDir.c_str();
    }

    std::stringstream ss;
    ss << default_realm_file_directory();
    filesDir = ss.str();

    return filesDir.c_str();
}
 
RLM_API const char* realm_dart_get_bundle_id() {
    return bundleId.c_str();
}