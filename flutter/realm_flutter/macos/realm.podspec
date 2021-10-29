#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'realm'
  s.version          = '0.2.0-alpha'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  s.script_phase = { 
    :name => 'Report Metrics', 
    # Cannot use $FLUTTER_APPLICATION_PATH (it is not exported), so use $PROJECT_DIR/../.. instead
    :script => 'cd "$PROJECT_DIR/../.." && dart run metrics --target-os-type macos --target-os-version "$MACOSX_DEPLOYMENT_TARGET" --application-identifier foobar', 
    :execution_position => :before_compile 
  }
end
