#
# To learn more about a Podspec see http:/guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm.podspec' to validate before publishing.
#

# //TODO read the version from pubspec.yaml
Pod::Spec.new do |s|
  s.name                      = 'realm'
  s.version                   = '0.2.0-alpha'
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
  s.public_header_files       = 'Classes/**/*.h',
  s.vendored_frameworks       = 'realm_flutter_ios.xcframework'
  s.dependency                  'Flutter'
  s.platform                  = :ios, '8.0'
  s.library                   = 'c++', 'z'
    
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported. Using EXCLUDED_ARCHS to exclude i386 arch.
  s.swift_version             = '5.0'
  s.pod_target_xcconfig       = { 'DEFINES_MODULE' => 'YES',
                                  'CURRENT_PROJECT_VERSION' => s.version,
                                  'VERSIONING_SYSTEM' => 'apple-generic',
                                  'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
                                  'CLANG_CXX_LIBRARY' => 'libc++',
                                  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
                                  'HEADER_SEARCH_PATHS' => [
                                    '"$(PODS_TARGET_SRCROOT)/src/realm-core/src/"',
                                    '"$(PODS_TARGET_SRCROOT)/Classes"',
                                  ],
                                  'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_TARGET_SRCROOT)/**"'
                                }
  s.script_phase              = { :name => 'Report Metrics', 
                                  
                                  :script => 'cd "$PROJECT_DIR/../.." && dart run realm metrics --verbose --target-os-type ios --target-os-version "$IPHONEOS_DEPLOYMENT_TARGET"', 
                                  :execution_position => :before_compile 
                                }
end