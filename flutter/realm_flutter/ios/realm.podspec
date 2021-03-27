#
# To learn more about a Podspec see http:/guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name                      = 'realm'
  s.version                   = '0.1.0-preview'
  s.summary                   = 'The official Realm SDK for Flutter'
  s.description               = <<-DESC
                                    Realm is a mobile database - an alternative to SQLite and key-value stores.
                                 DESC
  s.homepage                  = 'https://realm.io'
  s.license                   = { :file => '../LICENSE' }
  s.author                    = { 'Your Company' => 'help@realm.io' }
  s.source                    = { :path => '.' }
  s.source_files               = 'Classes/RealmFlutterPlugin.m',
  s.public_header_files        = 'Classes/RealmFlutterPlugin.h'
  s.dependency                  'Flutter'
  s.platform                  = :ios, '8.0'
  
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.swift_version             = '5.0'
  s.compiler_flags             = '-DFLUTTER'
  s.pod_target_xcconfig        = { 'DEFINES_MODULE' => 'YES', 
                                  'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
                                  'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'No',
                                  'CLANG_WARN_STRICT_PROTOTYPES' => 'No',
                                  'CLANG_WARN_INT_CONVERSION' => 'No',
                                  'FRAMEWORK_SEARCH_PATHS' => [
                                    '"$(PROJECT_DIR)/lubo"',
                                    '"$(PROJECT_DIR)/../.symlinks/plugins/realm/ios/Frameworks/Flutter.framework"'                                     
                                   ].join(' '),
                                  'LIBRARY_SEARCH_PATHS' => [
                                   '"$(PROJECT_DIR)/lubo-libs"',
                                    '"$(PROJECT_DIR)/../.symlinks/plugins/realm/ios/Frameworks/Flutter.framework"'
                                   ].join(' '),
                                  'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
                                  'CLANG_CXX_LIBRARY' => 'libc++',
                                }
    s.user_target_xcconfig     = { 'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'No',
                                  'CLANG_WARN_STRICT_PROTOTYPES' => 'No',
                                  'CLANG_WARN_INT_CONVERSION' => 'No' }
end