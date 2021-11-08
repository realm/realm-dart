This package configures the ffigen to generate bindings to realm-core library. 

Usage: 

On Windows: dart run ffigen --config windows.yaml
On MacOS: dart run ffigen --config macos.yaml
On Linux: dart run ffigen --config linux.yaml

Note: Dart ffigen tool generated platform dependent bindings which are tailored for the host platform the ffigen is executed. Currently all of platforms generate similar output with a configuration workaround here: https://github.com/dart-lang/ffigen/pull/119. 

Dart has an issues to generate platform independent bindings here: 
https://github.com/dart-lang/sdk/issues/42563
https://github.com/dart-lang/ffigen/issues/7
