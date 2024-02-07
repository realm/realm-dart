#import "realm_plugin.h"

#include <string>
#include <sstream>


#ifndef BUNDLE_ID
#define BUNDLE_ID "realm_bundle_id"
#endif

static std::string bundleId = BUNDLE_ID;

RLM_API const char* realm_dart_get_bundle_id() {
    return bundleId.c_str();
}