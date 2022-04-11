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

#import "RealmPlugin.h"
#if __has_include(<realm/realm-Swift.h>)
#import <realm/realm-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "realm-Swift.h"
#endif
#import "realm_dart.h"
#import "realm_dart_scheduler.h"
#import "platform.h"
@implementation RealmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRealmPlugin registerWithRegistrar:registrar];
}

void dummy(void) {
  realm_get_library_version();
  realm_initializeDartApiDL(NULL);
  realm_dart_create_scheduler(0,0);
  realm_object_create(NULL, 0);
  realm_dart_get_files_path();
  realm_results_get_object(NULL, 0);
  realm_list_size(NULL, 0);
  realm_results_snapshot(NULL);
  realm_app_credentials_new_anonymous();
}

@end
