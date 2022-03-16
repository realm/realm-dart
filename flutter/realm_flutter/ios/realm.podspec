#
# To learn more about a Podspec see http:/guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm.podspec' to validate before publishing.
#

#On iOS we need the xcframework available early so we download on prepare as well.
realmPackageDir = File.expand_path(__dir__)
# This works cause realm plugin is always accessed through the .symlinks directory.
# For example the tests app refers to the realm plugin using this path .../realm-dart/flutter/realm_flutter/tests/ios/.symlinks/plugins/realm/ios
project_dir = File.expand_path("../../../../", realmPackageDir)

# //TODO read the version from pubspec.yaml
Pod::Spec.new do |s|
  s.name                      = 'realm'
  s.version                   = '0.2.1+alpha'
  s.summary                   = 'The official Realm SDK for Flutter'
  s.description               = <<-DESC
                                    Realm is a mobile database - an alternative to SQLite and key-value stores.
                                 DESC
  s.homepage                  = 'https://realm.io'
  s.license                   = { :file => '../LICENSE' }
  s.author                    = { 'Realm' => 'help@realm.io' }
  s.source                    = { :path => '.' }
  s.source_files              = 'Classes/**/*', 
                                'src/realm_dart.cpp'
                                'src/realm_dart_scheduler.cpp'
                                'src/realm_dart_collections.cpp'
                                'src/realm_dart_http_transport.cpp'
  s.public_header_files       = 'Classes/**/*.h',
  s.vendored_frameworks       = 'realm_flutter_ios.xcframework'
  s.dependency                  'Flutter'
  s.platform                  = :ios, '8.0'
  s.library                   = 'c++', 'z'
    
  s.swift_version             = '5.0'
  s.pod_target_xcconfig       = { 'DEFINES_MODULE' => 'YES',
                                  'CURRENT_PROJECT_VERSION' => s.version,
                                  'VERSIONING_SYSTEM' => 'apple-generic',
                                  'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
                                  'CLANG_CXX_LIBRARY' => 'libc++',
                                  # Flutter.framework does not contain a i386 slice. 
                                  # Only x86_64 simulators are supported. Using EXCLUDED_ARCHS to exclude i386 arch.
                                  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
                                  'HEADER_SEARCH_PATHS' => [
                                    '"$(PODS_TARGET_SRCROOT)/Classes"',
                                    '"$(PODS_TARGET_SRCROOT)/src"',
                                    '"$(PODS_TARGET_SRCROOT)/src/ios"',
                                    '"$(PODS_TARGET_SRCROOT)/src/dart-include"',
                                    '"$(PODS_TARGET_SRCROOT)/src/realm-core/src"',
                                  ],
                                  'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_TARGET_SRCROOT)/**"'
                                }
                                #Use --debug to debug the install command on both prepare_command and script_phase below
  s.prepare_command           = "source \"#{project_dir}/Flutter/flutter_export_environment.sh\" && cd \"$FLUTTER_APPLICATION_PATH\" && \"$FLUTTER_ROOT/bin/flutter\" pub run realm install --target-os-type ios --package-name realm"
  s.script_phases             = [ 
                                  { :name => 'Download Realm Flutter iOS Binaries', 
                                  #Use --debug to debug the install command  
                                  :script => 'source "$PROJECT_DIR/../Flutter/flutter_export_environment.sh" && cd "$FLUTTER_APPLICATION_PATH" && "$FLUTTER_ROOT/bin/flutter" pub run realm install --target-os-type ios --package-name realm', 
                                    :execution_position => :before_headers
                                  },                                
                                  { :name => 'Report Metrics', 
                                    :script => 'source "$PROJECT_DIR/../Flutter/flutter_export_environment.sh" && cd "$FLUTTER_APPLICATION_PATH" && "$FLUTTER_ROOT/bin/flutter" pub run realm metrics --flutter-root "$FLUTTER_ROOT" --target-os-type ios --target-os-version "$IPHONEOS_DEPLOYMENT_TARGET"', 
                                    :execution_position => :before_compile
                                  }
                                ]
end                           