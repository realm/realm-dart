#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint realm.podspec` to validate before publishing.
#
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
  s.source_files               = 'Classes/**/*'
  s.dependency                  'FlutterMacOS'

  s.platform                  = :osx, '10.11'
  s.pod_target_xcconfig        = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version             = '5.0'
  s.resources                 = 'librealm_dart.dylib.txt'
end
