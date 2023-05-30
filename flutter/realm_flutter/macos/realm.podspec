#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm.podspec` to validate before publishing.
#
realmPackageDir = File.expand_path(__dir__)
# puts "realmPackageDir: #{realmPackageDir}"

realmLibName = "librealm_dart.dylib"

# Check if the build is running in the realm-dart repo
# We need to create an absolute symlink to librealm_dart.dylib otherwises
# Cocoapods and Xcode build look for different files from different base directories while handling `vendored_libraries`
realmLibraryPath = "#{realmPackageDir}/#{realmLibName}";
if realmLibraryPath.include?("flutter/realm_flutter") && !File.exist?(realmLibraryPath)
  absoluteRealRealmLibPath = File.realpath("#{realmPackageDir}/../../../binary/macos/#{realmLibName}")

  if !File.exist?(absoluteRealRealmLibPath)
    raise "Realm macos library does not exists in realm-dart repo at path #{absoluteRealRealmLibPath}"
  end
    
  # create an absolute symlink to realm flutter macos lib librealm_dart.dylib
  File.symlink(absoluteRealRealmLibPath, realmLibraryPath); 
end

# This works cause realm plugin is always accessed through the .symlinks directory.
# For example the tests app refers to the realm plugin using this path .../realm-dart/flutter/realm_flutter/tests/macos/Flutter/ephemeral/.symlinks/plugins/realm/macos
#project_dir = File.expand_path("../../../../../../", realmPackageDir)
#puts "project dir is #{project_dir}"

Pod::Spec.new do |s|
  s.name                      = 'realm'
  s.version                   = '1.1.0'
  s.summary                   = 'The official Realm SDK for Flutter'
  s.description               = <<-DESC
                                    Realm is a mobile database - an alternative to SQLite and key-value stores.
                                 DESC
  s.homepage                  = 'https://realm.io'
  s.license                   = { :file => '../LICENSE' }
  s.author                    = { 'Realm' => 'help@realm.io' }
  s.source                    = { :path => '.' }
  s.source_files               = 'Classes/**/*'
  s.dependency                  'FlutterMacOS'

  s.platform                  = :osx, '10.11'
  s.pod_target_xcconfig        = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version             = '5.0'
  s.vendored_libraries        = "#{realmLibName}"
  s.prepare_command           = "touch #{realmPackageDir}/librealm_dart.dylib" #librealm_dart.dylib is needed before the build is started
  s.script_phases             = [
                                  { :name => 'Download Realm Flutter iOS Binaries',
                                    #Use --debug to debug the install command
                                    :script => 'source "$PROJECT_DIR/../Flutter/ephemeral/flutter_export_environment.sh" && cd "$FLUTTER_APPLICATION_PATH" && "$FLUTTER_ROOT/bin/flutter" pub run realm install --target-os-type macos --flavor flutter',
                                    :execution_position => :before_headers
                                  },
                                  { :name => 'Report Metrics',
                                    :script => 'source "$PROJECT_DIR/../Flutter/ephemeral/flutter_export_environment.sh" && cd "$FLUTTER_APPLICATION_PATH" && "$FLUTTER_ROOT/bin/flutter" pub run realm metrics --flutter-root "$FLUTTER_ROOT" --target-os-type macos --target-os-version "$MACOSX_DEPLOYMENT_TARGET"',
                                    :execution_position => :before_compile
                                  }
                                ]
end
