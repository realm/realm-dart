Dart packages should distribute their prebuilt native extension binaries (if any) in the lib directory of the package.
This is where Dart VM looks for the binary when an application loads the Dart package.
On Windows Dart VM have a bug which looks for the package with incorrect path.
For Realm Dart this is something like C:\C:\<DART_PACKAGES_CACHE_PATH>\realm_dart\lib\src\realm_dart.dartrealm_dart_extension.dll.
The name of the native extension binary and the device letter is incorrect path on Windows.

To workaround this bug Realm Dart package has a script in its binary directory which copies the native extension to the correct place on Windows
When the Dart VM bug is fixed Realm Dart package should move the native extension dll to its lib directory and this script will not be needed.

In order to use the Realm Dart package application developers should execute `pub run realm_dart install` from the root directory of their Dart application.