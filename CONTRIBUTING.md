# Contributing

## Filing Issues

Whether you find a bug, typo or an API call that could be clarified, please [file an issue](https://github.com/realm/realm-dart/issues) on our GitHub repository.

When filing an issue, please provide as much of the following information as possible in order to help others fix it:

1. **Goals**
2. **Expected results**
3. **Actual results**
4. **Steps to reproduce**
5. **Code sample that highlights the issue** (full Flutter or Dart project that we can run ourselves are ideal)
6. **Version of Realm, Flutter and Dart**
7. **Version of desktop OS - Mac, Windows or Linux**
8. **Version of target mobile OS**

If you'd like to send us sensitive sample code to help troubleshoot your issue, you can email <help@realm.io> directly.

## Contributing Enhancements

We love contributions to Realm! If you'd like to contribute code, documentation, or any other improvements, please [file a Pull Request](https://github.com/realm/realm-dart/pulls) on our GitHub repository. Make sure to accept our [CLA](#CLA).

### CLA

Realm welcomes all contributions! The only requirement we have is that, like many other projects, we need to have a [Contributor License Agreement](https://en.wikipedia.org/wiki/Contributor_License_Agreement) (CLA) in place before we can accept any external code. Our own CLA is a modified version of the Apache Software Foundation’s CLA.

[Please submit your CLA electronically using our Google form](https://docs.google.com/forms/d/1ga5zIS9qnwwFPmbq-orSPsiBIXQjltKg7ytHd2NmDYo/viewform) so we can accept your submissions. The GitHub username you file there will need to match that of your Pull Requests. If you have any questions or cannot file the CLA electronically, you can email <help@realm.io>.

## Building the source

### Building Realm Flutter

* Clone the repo
    ```
    git clone https://github.com/realm/realm-dart
    git submodule update --init --recursive
    ```

#### Build Realm Flutter native binaries

* Android
    ```bash
    ./scripts/build-android.sh all
    scripts\build-android.bat all
    # Or for Android Emulator only
    ./scripts/build-android.sh x86
    scripts\build-android.bat x86
    ```

* iOS
    ```bash
    ./scripts/build-ios.sh
    # Or for iOS Simulator only
    ./scripts/build-ios.sh simulator
    ```

* Windows
    ```
    scripts\build.bat
    ```
* MacOS
    ```
    ./scripts/build-macos.sh
    ```

* Linux
    ```
    ./scripts/build-linux.sh
    ```

### Building Realm Dart

* Windows
    ```
    scripts\build.bat
    ```
* MacOS
    ```
    ./scripts/build-macos.sh
    ```
* Linux
    ```
    ./scripts/build-linux.sh
    ```

## Versioning

Realm Flutter and Dart SDK packages follow [Semantic Versioning](https://semver.org/).
During the initial development the packages will be versioned according the scheme `0.major.minor+release stage` until the first stable version is reached then packages will be versioned with `major.minor.patch` scheme.

The first versions will follow `0.1.0+preview`, `0.1.1+preview` etc.
Then next release stages will pick up the next minor version `0.1.2+beta`, `0.1.3+beta`. This will ensure dependencies are updated on `dart pub get` with the new `alpha`, `beta` versions.
If an `alpha` version is released before `beta` and it needs to not be considered for `pub get` then it should be marked as `prerelease` with `-alpha` so  `0.1.2-alpha` etc.
Updating the major version with every release stage is also possible - `0.2.0+alpha`, `0.3.0+beta`, `0.3.1+beta`.
