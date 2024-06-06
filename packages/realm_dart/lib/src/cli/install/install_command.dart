// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:args/command_runner.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;

import '../common/target_os_type.dart';
import '../common/archive.dart';
import 'options.dart';

class InstallCommand extends Command<void> {
  static const versionFileName = 'realm_version.txt';

  @override
  final description = 'Download & install Realm native binaries into a Flutter or Dart project';

  @override
  final name = 'install';

  late Options options;

  bool get debug => options.debug;

  InstallCommand() {
    populateOptionsParser(argParser);
  }

  Directory getBinaryPath(Directory realmPackagePath, {required bool isFlutter}) {
    if (isFlutter) {
      final root = realmPackagePath.path;
      return Directory(switch (options.targetOsType) {
        TargetOsType.android => path.join(root, 'android', 'src', 'main', 'cpp', 'lib'),
        TargetOsType.ios => path.join(root, 'ios'),
        TargetOsType.macos => path.join(root, 'macos'),
        TargetOsType.linux => path.join(root, 'linux', 'binary', 'linux'),
        TargetOsType.windows => path.join(root, 'windows', 'binary', 'windows'),
        _ => throw Exception('Unsupported target OS type for Flutter: ${options.targetOsType}')
      });
    }
    // TODO: Should binaries not go into package also for Dart?
    return Directory(path.join(Directory.current.absolute.path, 'binary', options.targetOsType!.name));
  }

  Future<bool> shouldSkipDownload(String binariesPath, String expectedVersion) async {
    final versionsFile = File(path.join(binariesPath, versionFileName));
    if (await versionsFile.exists()) {
      final existingVersion = await versionsFile.readAsString();
      if (expectedVersion == existingVersion) {
        print('Realm binaries for $expectedVersion already downloaded');
        return true;
      }
    }
    return false;
  }

  Future<void> downloadAndExtractBinaries(Directory destinationDir, Version version, String archiveName, bool force) async {
    if (await shouldSkipDownload(destinationDir.absolute.path, version.toString())) {
      if (!force) {
        return;
      }

      print('Deleting existing binaries because --force was supplied.');
      await destinationDir.delete(recursive: true);
    }

    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    final destinationFile = File(path.join(Directory.systemTemp.createTempSync('realm-binary-').absolute.path, archiveName));
    if (!await destinationFile.parent.exists()) {
      await destinationFile.parent.create(recursive: true);
    }

    print('Downloading Realm binaries for $version to ${destinationFile.absolute.path}');
    final client = HttpClient();
    var url = 'https://static.realm.io/downloads/dart/${Uri.encodeComponent(version.toString())}/$archiveName';
    if (debug) {
      url = 'http://localhost:8000/$archiveName';
    }
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw Exception('Error downloading Realm binaries from $url. Error code: ${response.statusCode}');
      }
      await response.pipe(destinationFile.openWrite());
    }
    // TODO: Handle download errors in Install command catch https://github.com/realm/realm-dart/issues/696.
    finally {
      client.close(force: true);
    }

    print('Extracting Realm binaries to ${destinationDir.absolute.path}');
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);

    final versionFile = File(path.join(destinationDir.absolute.path, versionFileName));
    await versionFile.writeAsString(version.toString());
  }

  Future<Directory> getPackagePath(String name) async {
    final packageConfig = await findPackageConfig(Directory.current);
    if (packageConfig == null) {
      abort('Run `dart pub get`');
    }
    final package = packageConfig.packages.where((p) => p.name == name).singleOrNull;
    if (package == null) {
      abort('$name package not found in dependencies. Add $name package to your pubspec.yaml');
    }
    return Directory.fromUri(package.root);
  }

  Future<Pubspec> parsePubspec(File file) async {
    try {
      return Pubspec.parse(await file.readAsString(), sourceUrl: file.uri);
    } on Exception catch (e) {
      throw Exception('Error parsing package pubspec at ${file.parent}. Error $e');
    }
  }

  @override
  FutureOr<void> run() async {
    final pubspec = await parsePubspec(File('pubspec.yaml'));
    final flavor = pubspec.dependencies['flutter'] == null ? Flavor.dart : Flavor.flutter;

    options = parseOptionsResult(argResults!);
    validateOptions(flavor);

    final flavorName = flavor.packageName;
    final realmDependency = pubspec.dependencyOverrides[flavorName] ?? pubspec.dependencies[flavorName];
    if (realmDependency is PathDependency && !options.force) {
      print(
          'Path dependency for $flavorName found. Skipping install of native lib (assuming local development). If you want to force install, add --force to the command invocation.');
      return;
    }
    if (realmDependency == null) {
      abort('Package $flavorName not found in dependencies. Add $flavorName package to your pubspec.yaml');
      // TODO: Should we just add it for them? What about the version?
    }

    final realmPackagePath = await getPackagePath(flavorName);
    final realmPubspec = await parsePubspec(File(path.join(realmPackagePath.path, "pubspec.yaml")));

    final binaryPath = getBinaryPath(realmPackagePath, isFlutter: flavor == Flavor.flutter);
    print(binaryPath);
    final archiveName = '${options.targetOsType!.name}.tar.gz';
    await downloadAndExtractBinaries(binaryPath, realmPubspec.version!, archiveName, options.force);

    print('Realm install command finished.');
  }

  void validateOptions(Flavor flavor) {
    final targetOs = flavor == Flavor.dart ? getTargetOS() : options.targetOsType;
    if (targetOs == null) {
      abort('Target OS not specified');
    }
    options.targetOsType = targetOs;
  }

  TargetOsType getTargetOS() => Platform.operatingSystem.asTargetOsType ?? (throw UnsupportedError('Unsupported platform ${Platform.operatingSystem}'));

  Never abort(String error) {
    print(error);
    print(usage);
    exit(64); //usage error
  }
}
