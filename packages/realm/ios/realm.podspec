#
# To learn more about a Podspec see http:/guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm.podspec' to validate before publishing.
#

#On iOS we need the xcframework available early so we download on prepare as well.
realmPackageDir = File.expand_path(__dir__)
# This works cause realm plugin is always accessed through the .symlinks directory.
# For example the tests app refers to the realm plugin using this path .../realm-dart/flutter/realm_flutter/tests/ios/.symlinks/plugins/realm/ios
project_dir = File.expand_path("../../../../", realmPackageDir)
puts "project dir is #{project_dir}"
app_dir = File.expand_path("../", project_dir)
puts "app dir is #{app_dir}"
contents = IO.read("#{app_dir}/pubspec.yaml")
match = contents.match("name:[ \r\n\t]*([a-z0-9_]*)")
bundleId = match[1]
puts "bundleId is #{bundleId}"


Pod::Spec.new do |s|
  s.name                      = 'realm'
  s.version                   = '20.1.1'
  s.summary                   = 'The official Realm SDK for Flutter'
  s.description               = <<-DESC
                                    Realm is a mobile database - an alternative to SQLite and key-value stores.
                                 DESC
  s.homepage                  = 'https://realm.io'
  s.license                   = { :file => '../LICENSE' }
  s.author                    = { 'Realm' => 'help@realm.io' }
  s.source                    = { :path => '.' }
  s.source_files              = 'Classes/**/*'
  s.public_header_files       = 'Classes/**/*.h'
  s.vendored_frameworks       = 'realm_dart.xcframework'
  s.dependency                  'Flutter'
  s.platform                  = :ios, '8.0'
  s.compiler_flags            = "-DBUNDLE_ID='\"#{bundleId}\"'"
  s.library                   = 'c++', 'z', 'compression'

  s.swift_version             = '5.0'
  s.pod_target_xcconfig       = { 'DEFINES_MODULE' => 'YES' }
                                #Use --debug to debug the install command on both prepare_command and script_phase below
  s.prepare_command           = "source \"#{project_dir}/Flutter/flutter_export_environment.sh\" && cd \"$FLUTTER_APPLICATION_PATH\" && \"$FLUTTER_ROOT/bin/dart\" run realm install --target-os-type ios"
  s.script_phases             = [
                                  { :name => 'Download Realm Flutter iOS Binaries',
                                  #Use --debug to debug the install command
                                  :script => 'source "$PROJECT_DIR/../Flutter/flutter_export_environment.sh" && cd "$FLUTTER_APPLICATION_PATH" && "$FLUTTER_ROOT/bin/dart" run realm install --target-os-type ios',
                                    :execution_position => :before_headers
                                  }
                                ]
  s.resource_bundles          = { 'realm_privacy' => [ 'Resources/PrivacyInfo.xcprivacy' ] }
end