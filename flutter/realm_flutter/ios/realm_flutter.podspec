
current_dir = File.expand_path(__dir__)
puts "realm_flutter current directory: #{current_dir}"

application_dir = File.expand_path("../../../../", current_dir)
puts "Application directory: #{application_dir}"

project_file = File.expand_path("Runner.xcodeproj/project.pbxproj", application_dir)
puts "Project file: #{project_file}"

if File.exist?(project_file)
  puts "project file exists"
else
  puts "project file DOES NOT exists"
end

script_file = File.expand_path(".symlinks/plugins/realm_flutter/ios/scripts/xcode_backend.sh", application_dir)
puts "Scripts file: #{script_file}"

if File.exist?(script_file)
  puts "Scripts file exists"
else
  puts "Scripts file DOES NOT exists"
end

application_pod_file = File.expand_path("Podfile", application_dir)
puts "Application Podfile: #{application_pod_file}"
if File.exist?(application_pod_file)
  puts "application_pod_file file exists"
else
  puts "application_pod_file file DOES NOT exists"
end




# system("echo 123 | tr '3' '4'")

# system("sed -i.bak \"s~flutter_additional_ios_build_settings(target)~mytarget=target#flutter_additional_ios_build_settings(target)#system(\'./.symlinks/plugins/realm_flutter/ios/scripts/prepare.sh #{project_file}\')~\" #{application_pod_file} | tr \'#\' \'\n\'")

# system("sed -i.bak \"s~flutter_additional_ios_build_settings(target)~mytarget=target#flutter_additional_ios_build_settings(target)#system('./.symlinks/plugins/realm_flutter/ios/scripts/prepare.sh #{project_file}')~\" #{application_pod_file} | tr '#' '\n'")

# system("sed -i.bak \"s~flutter_additional_ios_build_settings(target)~puts 'BLAGOEV'~\" #{application_pod_file}")

# puts "PROJECT FILE CONTAINS====================================================================================================================="
# system('cat', "#{project_file}")
# puts "PROJECT FILE CONTAINS====================================================================================================================="

system('sed', '-i.bak', "s~FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh~PROJECT_DIR/.symlinks/plugins/realm_flutter/ios/scripts/xcode_backend.sh~", project_file)
system('sed', '-i.bak', "s~(PROJECT_DIR)/Flutter~(PROJECT_DIR)/.symlinks/plugins/realm_flutter/ios/Frameworks/Flutter~", project_file)

# puts "PROJECT FILE AFTER---------------------------------------------------------------------------------------------------------------------"
# system('cat', "#{project_file}")
# puts "PROJECT FILE AFTER---------------------------------------------------------------------------------------------------------------------"

realm_dart_src_path = "realm-dart-src/src/"
realm_dart_extension_path = "#{realm_dart_src_path}/realm-dart-extension"
object_store_path = "#{realm_dart_src_path}/object-store"


# Create symlinks to every single source code file. Cocoapods can't use symlinks to directories

#
# To learn more about a Podspec see http:/guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name                      = 'realm_flutter'
  s.version                   = '0.0.1'
  s.summary                   = 'A new flutter plugin project.'
  s.description               = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage                  = 'http:/example.com'
  s.license                   = { :file => '../LICENSE' }
  s.author                    = { 'Your Company' => 'email@example.com' }
  s.source                    = { :path => '.' }
  s.source_files               = 'Classes/**/*', 
                                'Classes/*.cpp', 
                                'Classes/*.mm', 
                                'realm-dart-src/src/realm-dart-extension/*.cpp',
                                'realm-dart-src/src/realm-dart-extension/*.hpp',
                                'realm-dart-src/src/realm-dart-extension/dart/dart_init.cpp',
                                'realm-dart-src/src/realm-dart-extension/dart/dart_types.cpp',
                                'realm-dart-src/src/realm-dart-extension/dart/*.hpp',
                                #  'realm-dart-src/src/realm-dart-extension/dart/dart_types.cpp',
                                #  'realm-dart-src/src/realm-dart-extension/dart/platform.cpp',
                                'realm-dart-src/src/realm-dart-extension/realm-js-common/*.cpp',
                                'realm-dart-src/src/realm-dart-extension/realm-js-common/*.hpp',
                                'realm-dart-src/src/object-store/src/impl/*.cpp',
                                'realm-dart-src/src/object-store/src/impl/*.hpp',
                                'realm-dart-src/src/object-store/src/impl/apple/*.cpp',
                                'realm-dart-src/src/object-store/src/impl/apple/*.hpp',
                                #  'realm-dart-src/src/object-store/src/impl/collection_notifier.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/list_notifier.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/object_notifier.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/realm_coordinator.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/results_notifier.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/transact_log_handler.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/weak_realm_notifier.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/apple/external_commit_helper.cpp',
                                #  'realm-dart-src/src/object-store/src/impl/apple/keychain_helper.cpp',
                                'realm-dart-src/src/object-store/src/util/*.cpp',
                                'realm-dart-src/src/object-store/src/util/*.hpp',
                                #  'realm-dart-src/src/object-store/src/util/scheduler.cpp',
                                'realm-dart-src/src/object-store/src/*.cpp',
                                'realm-dart-src/src/object-store/src/*.hpp',
                                #  'realm-dart-src/src/object-store/src/collection_notifications.cpp',
                                #  'realm-dart-src/src/object-store/src/index_set.cpp',
                                #  'realm-dart-src/src/object-store/src/list.cpp',
                                #  'realm-dart-src/src/object-store/src/object_schema.cpp',
                                #  'realm-dart-src/src/object-store/src/object_store.cpp',
                                #  'realm-dart-src/src/object-store/src/object.cpp',
                                #  'realm-dart-src/src/object-store/src/object_changeset.cpp',
                                #  'realm-dart-src/src/object-store/src/results.cpp',
                                #  'realm-dart-src/src/object-store/src/schema.cpp',
                                #  'realm-dart-src/src/object-store/src/shared_realm.cpp',
                                #  'realm-dart-src/src/object-store/src/thread_safe_reference.cpp'


  s.public_header_files         = 'Classes/RealmFlutterPlugin.h'
  s.ios.vendored_libraries     = 'realm-dart-src/src/vendor-include/realm-ios/librealm-ios.a', 
                                 'realm-dart-src/src/vendor-include/realm-ios/librealm-parser-ios.a'
  s.dependency                   'Flutter'
  s.platform                   = :ios, '8.0'
  s.prepare_command            = "./scripts/prepare.sh #{project_file}"
  
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.swift_version              = '5.0'
  s.compiler_flags              = '-DREALM_HAVE_CONFIG -DFLUTTER'
  s.pod_target_xcconfig         = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
                                   'FRAMEWORK_SEARCH_PATHS' => '$(PROJECT_DIR)/.symlinks/plugins/realm_flutter/ios/Frameworks/Flutter',
                                   'LIBRARY_SEARCH_PATHS' => '$(PROJECT_DIR)/.symlinks/plugins/realm_flutter/ios/Frameworks/Flutter',
                                   'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
                                   'CLANG_CXX_LIBRARY' => 'libc++',
                                   'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF' => 'NO',
                                   'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO',
                                   'CLANG_WARN_STRICT_PROTOTYPES' => 'No',
                                   'CLANG_WARN_INT_CONVERSION' => 'No',
                                   'OTHER_CPLUSPLUSFLAGS[arch=armv7]' => '-fno-aligned-new',
                                   'HEADER_SEARCH_PATHS' => [
                                       '"$(PODS_TARGET_SRCROOT)/src/"',
                                       '"$(PODS_TARGET_SRCROOT)/realm-dart-src/src/object-store/src/"',
                                       '"$(PODS_TARGET_SRCROOT)/realm-dart-src/src/object-store/external/json/"',
                                       '"$(PODS_TARGET_SRCROOT)/realm-dart-src/src/vendor-include/realm-ios/include"',
                                       '"$(PODS_TARGET_SRCROOT)/realm-dart-src/src/vendor-include/realm-ios/include/realm/"'
                                    ].join(' ')
                                 }
    s.user_target_xcconfig = { 'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'No',
                              'CLANG_WARN_STRICT_PROTOTYPES' => 'No',
                              'CLANG_WARN_INT_CONVERSION' => 'No',  }
end