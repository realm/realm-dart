////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'dart:async';
import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:args/command_runner.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;

import '../common/target_os_type.dart';
import '../common/archive.dart';
import '../common/utils.dart';
import 'options.dart';

class PackageNames {
  static const String flutter = 'realm';
  static const String dart = 'realm_dart';

  static const List<String> all = [flutter, dart];
}

class InstallCommand extends Command<void> {
  static const versionFileName = "realm_version.txt";

  @override
  final String description = 'Download & install Realm native binaries into a Flutter or Dart project';

  @override
  final String name = 'install';

  late Options options;

  String get packageName => options.packageName!;

  bool get isFlutter => options.packageName == PackageNames.flutter;
  bool get isDart => options.packageName == PackageNames.dart;
  bool get debug => options.debug ?? false;

  InstallCommand() {
    populateOptionsParser(argParser);
  }

  String getBinaryPath(String realmPackagePath) {
    if (isFlutter) {
      switch (options.targetOsType) {
        case TargetOsType.android:
          return path.join(realmPackagePath, "android", "src", "main", "cpp", "lib");
        case TargetOsType.ios:
          return path.join(realmPackagePath, "ios");
        case TargetOsType.macos:
          return path.join(realmPackagePath, "macos");
        case TargetOsType.linux:
          return path.join(realmPackagePath, "linux", "binary", "linux");
        case TargetOsType.windows:
          return path.join(realmPackagePath, "windows", "binary", "windows");
        default:
          throw Exception("Unsupported target OS type for Flutter: ${options.targetOsType}");
      }
    }

    if (isDart) {
      return path.join(Directory.current.absolute.path, 'binary', options.targetOsType!.name);
    }

    throw Exception("Unsupported package name: $packageName");
  }

  Future<bool> shouldSkipInstall(Pubspec realmPubspec) async {
    final pubspecFile = await File("pubspec.yaml").readAsString();
    final projectPubspec = Pubspec.parse(pubspecFile);
    if (PackageNames.all.contains(projectPubspec.name)) {
      print('Running install command inside ${projectPubspec.name} package which is the development package for Realm. '
          'Skipping download as it is expected that you build the packages manually.');
      return true;
    }

    if (realmPubspec.publishTo == 'none') {
      print("Referencing $packageName@${realmPubspec.version} which hasn't been published (publish_to: none). Skipping download.");
      return true;
    }

    return false;
  }

  Future<bool> shouldSkipDownload(String binariesPath, String expectedVersion) async {
    final versionsFile = File(path.join(binariesPath, versionFileName));

    if (!await versionsFile.exists()) {
      return false;
    }

    final existingVersion = await versionsFile.readAsString();
    if (expectedVersion == existingVersion) {
      print("Realm binaries for $packageName@$expectedVersion already downloaded");
    }
    return expectedVersion == existingVersion;
  }

  Future<void> downloadAndExtractBinaries(Directory destinationDir, Pubspec realmPubspec, String archiveName) async {
    if (await shouldSkipDownload(destinationDir.absolute.path, realmPubspec.version.toString())) {
      return;
    }

    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    final destinationFile = File(path.join(Directory.systemTemp.absolute.path, "realm-binary", archiveName));
    if (!await destinationFile.parent.exists()) {
      await destinationFile.parent.create(recursive: true);
    }

    print("Downloading Realm binaries for $packageName@${realmPubspec.version} to ${destinationFile.absolute.path}");
    final client = HttpClient();
    var url = 'https://static.realm.io/downloads/dart/${Uri.encodeComponent(realmPubspec.version.toString())}/$archiveName';
    if (debug) {
      url = 'http://localhost:8000/$archiveName';
    }
    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw Exception("Error downloading Realm binaries from $url. Error code: ${response.statusCode}");
      }
      await response.pipe(destinationFile.openWrite());
    }
    // TODO: Handle download errors in Install command catch https://github.com/realm/realm-dart/issues/696.
     finally {
      client.close(force: true);
    }

    print("Extracting Realm binaries to ${destinationDir.absolute.path}");
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);

    final versionFile = File(path.join(destinationDir.absolute.path, versionFileName));
    await versionFile.writeAsString("${realmPubspec.version}");
  }

  Future<String> getRealmPackagePath() async {
    final packageConfig = await findPackageConfig(Directory.current);
    if (packageConfig == null) {
      throw Exception("Package configuration not found. "
          "Run the 'dart run $packageName install` command from the root directory of your application");
    }

    final realmDartPackage = packageConfig.packages.where((p) => p.name == packageName).firstOrNull;
    if (realmDartPackage == null) {
      throw Exception("$packageName package not found in dependencies. Add $packageName package to your pubspec.yaml");
    }

    if (realmDartPackage.root.scheme != 'file') {
      throw Exception("$packageName package uri ${realmDartPackage.root} is not supported. Uri should start with file://");
    }

    final realmPackagePath = path.join(realmDartPackage.root.toFilePath(), "pubspec.yaml");
    return realmPackagePath;
  }

  Future<Pubspec> parseRealmPubspec(String path) async {
    try {
      var realmPubspecFile = await File(path).readAsString();
      final pubspec = Pubspec.parse(realmPubspecFile);
      if (pubspec.name != packageName) {
        throw Exception("Unexpected package name `${pubspec.name}` at $path. Realm install command expected package `$packageName`");
      }

      return pubspec;
    } on Exception catch (e) {
      throw Exception("Error parsing package `$packageName` pubspec at $path. Error $e");
    }
  }

  @override
  FutureOr<void>? run() async {
    options = parseOptionsResult(argResults!);
    validateOptions();

    final realmPackagePath = await getRealmPackagePath();
    final realmPubspec = await parseRealmPubspec(realmPackagePath);

    if (await shouldSkipInstall(realmPubspec)) {
      return;
    }

    final binaryPath = Directory(getBinaryPath(path.dirname(realmPackagePath)));
    final archiveName = "${options.targetOsType!.name}.tar.gz";
    await downloadAndExtractBinaries(binaryPath, realmPubspec, archiveName);

    print("Realm install command finished.");
  }

  void validateOptions() {
    if (options.targetOsType == null && options.packageName == PackageNames.flutter) {
      abort("Invalid target OS: null.");
    } else if (options.targetOsType == null && options.packageName == PackageNames.dart) {
      options.targetOsType = getTargetOS();
    }

    if (!PackageNames.all.contains(options.packageName)) {
      abort("Invalid package name: ${options.packageName}");
    }

    if ((options.targetOsType == TargetOsType.ios || options.targetOsType == TargetOsType.android) && packageName != PackageNames.flutter) {
      throw Exception("Invalid package name $packageName for target OS ${TargetOsType.values.elementAt(options.targetOsType!.index).name}");
    }
  }

  TargetOsType getTargetOS() {
    if (Platform.isWindows) {
      return TargetOsType.windows;
    } else if (Platform.isLinux) {
      return TargetOsType.linux;
    } else if (Platform.isMacOS) {
      return TargetOsType.macos;
    } else {
      throw Exception("Unsuported platform ${Platform.operatingSystem}");
    }
  }

  void abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
