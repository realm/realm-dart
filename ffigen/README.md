This package configures the ffigen to generate bindings to realm-core library.
The is executed manually as needed and this package is never published.

Usage: 

dart run ffigen

On linux you may need to install clang 11 dev tools. If you are using apt-get you can do:
```
sudo apt-get install libclang-11-dev
``` 

Note: Dart ffigen tool generated platform dependent bindings which are tailored for the host platform the ffigen is executed. Currently all of platforms generate identical output with the configuration workaround here: https://github.com/dart-lang/ffigen/pull/119. 

Dart has an issues to generate platform independent bindings here: 
https://github.com/dart-lang/sdk/issues/42563
https://github.com/dart-lang/ffigen/issues/7
