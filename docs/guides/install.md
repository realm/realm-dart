# Install the Flutter SDK
You can use the Realm SDK for Flutter in a Flutter project or in a
standalone Dart project. This guide provides instructions for installing the
SDK in both types of projects.

## Prerequisites
To get started with the Realm SDK for Flutter, you need to install
the following, depending on the type of app you are developing:

- For Flutter or Dart apps, install Flutter with Dart in your development environment.
The Flutter installation includes Dart. To learn how, refer to the official
[Flutter Installation Guide](https://docs.flutter.dev/get-started/install).
- For standalone Dart apps, you can install Dart in your development
environment without Flutter. To learn how, refer to the official
[Dart Installation Guide](https://dart.dev/get-dart).

See the [Flutter SDK README](/README.md) for the minimum versions required.

### Supported Platforms
The Flutter SDK supports the following platforms:

- iOS
- Android
- macOS
- Windows running on 64-bit architecture
- Linux running on 64-bit architecture

> **IMPORTANT:**
> The Flutter SDK does *not* support the following platforms:
>
> - Web
> - Windows running on ARM64 or 32-bit architectures
> - Linux running on ARM64 or 32-bit architectures
>

## Install the SDK
The Realm SDK for Flutter has two packages available to install,
depending on whether you are developing a Flutter or Dart standalone app:

- `realm`: The Flutter SDK package for use in Flutter applications.
- `realm_dart`: The standalone Dart SDK package for use in Dart applications,
such as CLI apps or running Dart in a server environment.

The standalone Dart package has the same usage as the Flutter package except
where otherwise noted.

> **TIP**:
> The Flutter SDK uses Realm Core database for device data persistence. When you install the Flutter SDK, the package names reflect Realm naming.
>

### Create a Project
#### Flutter
To create a Flutter project, run the following commands:

```shell
flutter create <app_name>
cd <app_name>
```

For more information, refer to Flutter's official [Get Started Guide](https://docs.flutter.dev/get-started/test-drive?tab=terminal).

#### Dart
To create a Dart project, run the following commands:

```shell
dart create <app_name>
cd <app_name>
```

For more information, refer to Dart's official [Get Started Guide](https://dart.dev/tutorials/server/get-started) for standalone
Dart command-line and server applications.

### Add the SDK to the Project
#### Flutter
To add the Flutter SDK to your project, run the following command:

```bash
flutter pub add realm
```

This downloads the [realm](https://pub.dev/packages/realm) package, and adds it to your project.

In your `pubspec.yaml` file, you should see:

```yaml
dependencies:
   realm: <latest_version>
```

> **NOTE:**
> If you are developing with the Flutter SDK in the macOS App
Sandbox and require network access, you must enable network
entitlements in your app. By default, network requests are
not allowed due to built-in macOS security settings.
>
> To use networking in your macOS app, you must change your app's
macOS network entitlements. To learn how, refer to
Use Realm with the macOS App Sandbox.
>

#### Dart
To add the SDK to your project, run the following command:

```shell
dart pub add realm_dart
```

This downloads the [realm_dart](https://pub.dev/packages/realm_dart)
package, and adds it to your project.

In your `pubspec.yaml` file, you should see:

```yaml
dependencies:
   realm_dart: <latest_version>
```

After the package is added, run the following command to install it:

```shell
dart run realm_dart install
```

This downloads and copies the required native binaries to the app
directory.

#### Import the Package into Files
To use the SDK in your app, import the package into any files where you
will use it:

#### Flutter
```dart
import 'package:realm/realm.dart';
```

#### Dart
```dart
import 'package:realm_dart/realm.dart';
```

## Update the Package Version
To change the version of the SDK in your project, perform the following steps,
depending on whether you are using the `realm` or `realm_dart` package:

### Update the `pubspec.yaml` File
Update the package version in your `pubspec.yaml` file dependencies.

#### Flutter
```yaml
dependencies:
   realm: <updated_version>
```

#### Dart
```yaml
dependencies:
   realm_dart: <updated_version>
```

### Install the Updated Package
#### Flutter
Run the following command to install the updated version:

```yaml
dependencies:
   realm: <updated_version>
```

#### Dart
Run the following command to install the updated version:
```shell
dart pub upgrade realm_dart
```

Then, run the following command to install the updated SDK's native
binaries:
```shell
dart run realm_dart install
```

### Regenerate Object Models
#### Flutter
```shell
dart run realm generate
```

#### Dart
```shell
dart run realm_dart generate
```

> **IMPORTANT:**
> Flutter SDK version 2.0.0 introduces an update to the
> builder, which impacts how files generate. In v2.0.0 and later, all
> generated files use the `.realm.dart` naming convention instead of `.g.dart`.
>
> This is a breaking change for existing apps. For information on how to upgrade an existing app from an earlier SDK version to v2.0.0 or later,
> refer to Upgrade to Flutter SDK v2.0.0.
>

## Troubleshooting
If you have issues using the updated SDK version in your application, you can
delete the `.realm` database file created by the SDK, and restart the
application. Note that deleting the `.realm` file also deletes all
data stored in the database on that client.

For more information, refer to Delete a Realm File - Flutter SDK.

## Apple Privacy Manifest
> Version added: 2.2.0

Apple requires any apps or third-party SDKs that use *required reasons APIs* to
provide a privacy manifest. The manifest contains details about the app's or SDK's
data collection and use practices, and it must be included when submitting new
apps or app updates to the Apple App Store. For more details about these
requirements, refer to
[Upcoming third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/)
on the Apple Developer website.

Starting in Flutter SDK version 2.2.0, the SDK ships with a privacy manifest for
`iOS` and `macOS` environments, contained in the `realm` package. Both
privacy manifests contain Apple's required API disclosures and the reasons for
using those APIs.

You can view these privacy manifests in the SDK package or directly in the
`realm-dart` GitHub repository:

- `iOS`:
[https://github.com/realm/realm-dart/blob/main/packages/realm/ios/Resources/PrivacyInfo.xcprivacy](https://github.com/realm/realm-dart/blob/main/packages/realm/ios/Resources/PrivacyInfo.xcprivacy)
- `macOS`:
[https://github.com/realm/realm-dart/blob/main/packages/realm/macos/Resources/PrivacyInfo.xcprivacy](https://github.com/realm/realm-dart/blob/main/packages/realm/macos/Resources/PrivacyInfo.xcprivacy)

The Flutter SDK does *not*:

- Include analytics code in builds for the App Store.

> **IMPORTANT:**
> The Flutter SDK privacy manifest does *not* include disclosures for
> App Services APIs.
>

For more information, refer to Apple's
[Privacy Manifest Files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
documentation.
