Build Realm Dart
```
mkdir build
cd build
realm-dart\build>cmake --build .
```

Build Realm Flutter
```
mkdir build-android
cd build-android
realm-dart\build-android>..\scripts\build-android.bat all
```

Run dart tests
```
realm-dart>dart test test\realm_test.dart --name "Realm version"
```

Run flutter tests
```
realm-dart\flutter\realm_flutter\tests>flutter drive -t test_driver/app.dart --dart-define=testName="Realm version"
```