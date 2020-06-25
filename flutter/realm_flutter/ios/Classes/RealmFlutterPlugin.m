#import "RealmFlutterPlugin.h"
#if __has_include(<realm_flutter/realm_flutter-Swift.h>)
#import <realm_flutter/realm_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "realm_flutter-Swift.h"
#endif

@implementation RealmFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRealmFlutterPlugin registerWithRegistrar:registrar];
}
@end
