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

class InstallCommand extends Command<void> {
  static const versionFileName = "realm_version.txt";

  @override
  final String description = 'Download & install Realm native binaries into a Flutter or Dart project';

  @override
  final String name = 'install';

  late Options options;

  String get packageName => options.packageName!;

  bool get isFlutter => options.packageName == "realm";
  bool get isDart => options.packageName == "realm_dart";
  bool get isTargetAndroid => options.targetOsType == TargetOsType.android;
  bool get isTargetiOS => options.targetOsType == TargetOsType.ios;
  bool get isTargetMacOS => options.targetOsType == TargetOsType.macos;
  bool get isTargetWindows => options.targetOsType == TargetOsType.windows;
  bool get debug => options.debug ?? false;

  InstallCommand() {
    populateOptionsParser(argParser);
  }

  Future<bool> skipInstall() async {
    if (debug) {
      print("Debug flag set. Continuing Realm install command execution");
      return false;
    }

    var pubspecFile = await File("pubspec.yaml").readAsString();
    final projectPubspec = Pubspec.parse(pubspecFile);
    if (projectPubspec.name == "realm" || projectPubspec.name == "realm_dart" || projectPubspec.name == packageName) {
      return true;
    }

    const realmPackages = <String>{"realm", "realm_dart", "realm_common", "realm_generator"};
    isPathDependency(MapEntry<String, Dependency> entry) => (realmPackages.contains(entry.key) && entry.value is PathDependency);

    bool hasPathDependency = projectPubspec.dependencies.entries.any(isPathDependency);
    hasPathDependency = hasPathDependency || projectPubspec.dependencyOverrides.entries.any(isPathDependency);
    return hasPathDependency;
  }

  Future<bool> skipDownload(String binariesPath, String expectedVersion) async {
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

  Future<void> downloadAndExtractAndroidBinaries(String realmPackagePath, Pubspec realmPubspec) async {
    var destinationDir = Directory(path.join(path.dirname(realmPackagePath), "android", "src", "main", "cpp", "lib"));
    if (await skipDownload(destinationDir.absolute.path, realmPubspec.version.toString())) {
      return;
    }

    var archiveName = "android.tar.gz";
    final destinationFile = File(path.join(destinationDir.absolute.path, archiveName));
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    print("Downloading Realm binaries for $packageName@${realmPubspec.version} to ${destinationFile.absolute.path}");
    final client = HttpClient();
    var url = 'https://github.com/realm/realm-dart/releases/download/${realmPubspec.version}/$archiveName';
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
    //TODO: This does not handle download errors.
     finally {
      client.close(force: true);
    }

    print("Extracting Realm binaries to ${destinationDir.absolute.path}");
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);

    await saveVersionFile(destinationDir, realmPubspec);
  }

  Future<void> downloadAndExtractiOSBinaries(String realmPackagePath, Pubspec realmPubspec) async {
    var destinationDir = Directory(path.join(path.dirname(realmPackagePath), "ios"));
    if (await skipDownload(destinationDir.absolute.path, realmPubspec.version.toString())) {
      return;
    }

    var archiveName = "ios.tar.gz";
    final destinationFile = File(path.join(destinationDir.absolute.path, archiveName));
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    print("Downloading Realm binaries for $packageName@${realmPubspec.version} to ${destinationFile.absolute.path}");
    final client = HttpClient();
    try {
      var url = 'https://github.com/realm/realm-dart/releases/download/${realmPubspec.version}/$archiveName';
      if (debug) {
        url = 'http://localhost:8000/$archiveName';
      }
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw Exception("Error downloading Realm binaries from $url. Error code: ${response.statusCode}");
      }
      await response.pipe(destinationFile.openWrite());
    }
    //TODO: This does not handle download errors.
     finally {
      client.close(force: true);
    }

    print("Extracting Realm binaries to ${destinationDir.absolute.path}");
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);

    await saveVersionFile(destinationDir, realmPubspec);
  }

  Future<void> downloadAndExtractMacOSFlutterBinaries(String realmPackagePath, Pubspec realmPubspec) async {
    var destinationDir = Directory(path.join(path.dirname(realmPackagePath), "macos"));
    if (await skipDownload(destinationDir.absolute.path, realmPubspec.version.toString())) {
      return;
    }

    var archiveName = "macos.tar.gz";
    final destinationFile = File(path.join(destinationDir.absolute.path, archiveName));
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    print("Downloading Realm binaries for $packageName@${realmPubspec.version} to ${destinationFile.absolute.path}");
    final client = HttpClient();
    try {
      var url = 'https://github.com/realm/realm-dart/releases/download/${realmPubspec.version}/$archiveName';
      if (debug) {
        url = 'http://localhost:8000/$archiveName';
      }
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw Exception("Error downloading Realm binaries from $url. Error code: ${response.statusCode}");
      }
      await response.pipe(destinationFile.openWrite());
    }
    //TODO: This does not handle download errors.
     finally {
      client.close(force: true);
    }

    print("Extracting Realm binaries to ${destinationDir.absolute.path}");
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);
    await saveVersionFile(destinationDir, realmPubspec);

    //We create a symlink to the binary file to be included as a app resource on build which needs to have an txt extension
    var binaryName = "librealm_dart.dylib";
    final linkToBinaryFile = Link(path.join(destinationDir.absolute.path, "$binaryName.txt"));
    if (await linkToBinaryFile.exists()) {
      await linkToBinaryFile.delete();
    }
    await linkToBinaryFile.create("$binaryName");
  }

  Future<void> downloadAndExtractWindowsFlutterBinaries(String realmPackagePath, Pubspec realmPubspec) async {
    var destinationDir = Directory(path.join(path.dirname(realmPackagePath), "windows", "binary", "windows"));
    if (await skipDownload(destinationDir.absolute.path, realmPubspec.version.toString())) {
      return;
    }

    var archiveName = "windows.tar.gz";
    final destinationFile = File(path.join(destinationDir.absolute.path, archiveName));
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }

    print("Downloading Realm binaries for $packageName@${realmPubspec.version} to ${destinationFile.absolute.path}");
    final client = HttpClient();
    try {
      // debug url
      var url = 'https://github.com/realm/realm-dart/releases/download/${realmPubspec.version}/$archiveName';
      if (debug) {
        url = 'http://localhost:8000/$archiveName';
      }
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw Exception("Error downloading Realm binaries from $url. Error code: ${response.statusCode}");
      }
      await response.pipe(destinationFile.openWrite());
    }
    //TODO: This does not handle download errors.
     finally {
      client.close(force: true);
    }

    print("Extracting Realm binaries to ${destinationDir.absolute.path}");
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);
    await saveVersionFile(destinationDir, realmPubspec);
  }

  Future<void> downloadAndExtractWindowsBinaries(String realmPackagePath, Pubspec realmPubspec) async {
    final destinationDir = Directory(path.join(Directory.systemTemp.absolute.path, "realm-binary", "windows"));
    final archiveName = "windows.tar.gz";
    final destinationFile = File(path.join(destinationDir.absolute.path, archiveName));
    if (!await skipDownload(destinationDir.absolute.path, realmPubspec.version.toString())) {
      await download(destinationFile, realmPubspec, archiveName);
    }

    print("Extracting Realm binaries to ${destinationDir.absolute.path}");
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);
    await saveVersionFile(destinationDir, realmPubspec);

    final binaryName = "realm_dart.dll";
    final binaryFile = File(path.join(Directory.current.absolute.path, "binary", "windows", binaryName));
    //create parent dirs if needed
    await binaryFile.create(recursive: true);

    final dowloadedBinaryFile = File(path.join(destinationDir.absolute.path, binaryName));
    print("Copying realm binary ${dowloadedBinaryFile.absolute.path} to ${binaryFile.absolute.path}");
    await dowloadedBinaryFile.copy(binaryFile.absolute.path);
  }

  Future<void> downloadAndExtractMacOSBinaries(String realmPackagePath, Pubspec realmPubspec) async {
    final destinationDir = Directory(path.join(Directory.systemTemp.absolute.path, "realm-binary", "macos"));
    final archiveName = "macos.tar.gz";
    final destinationFile = File(path.join(destinationDir.absolute.path, archiveName));
    if (!await skipDownload(destinationDir.absolute.path, realmPubspec.version.toString())) {
      await download(destinationFile, realmPubspec, archiveName);
    }

    print("Extracting Realm binaries to ${destinationDir.absolute.path}");
    final archive = Archive();
    await archive.extract(destinationFile, destinationDir);
    await saveVersionFile(destinationDir, realmPubspec);

    final binaryName = "librealm_dart.dylib";
    final binaryFile = File(path.join(Directory.current.absolute.path, binaryName));

    final dowloadedBinaryFile = File(path.join(destinationDir.absolute.path, binaryName));
    print("Copying realm binary ${dowloadedBinaryFile.absolute.path} to ${binaryFile.absolute.path}");
    await dowloadedBinaryFile.copy(binaryFile.absolute.path);
  }

  Future<void> download(File destinationFile, Pubspec realmPubspec, String archiveName) async {
    if (!await destinationFile.exists()) {
      await destinationFile.create(recursive: true);
    }

    print("Downloading Realm binaries for $packageName@${realmPubspec.version} to ${destinationFile.absolute.path}");
    final client = HttpClient();
    try {
      var url = 'https://github.com/realm/realm-dart/releases/download/${realmPubspec.version}/$archiveName';
      if (debug) {
        url = 'http://localhost:8000/$archiveName';
      }
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw Exception("Error downloading Realm binaries from $url. Error code: ${response.statusCode}");
      }
      await response.pipe(destinationFile.openWrite());
    }
    //TODO: This does not handle download errors.
     finally {
      client.close(force: true);
    }
  }

  Future<void> saveVersionFile(Directory destinationDir, Pubspec realmPubspec) async {
    var versionFile = File(path.join(destinationDir.absolute.path, versionFileName));
    await versionFile.writeAsString("${realmPubspec.version}");
  }

  Future<String> getRealmPackagePath() async {
    final packageConfig = await findPackageConfig(Directory.current);
    if (packageConfig == null) {
      throw Exception("Package configuration ('package_config.json' or '.packages') not found. "
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
      throw Exception("Error parsing package `$packageName` pubspect at $path. Error $e");
    }
  }

  @override
  FutureOr<void>? run() async {
    await runInternal();
    print("Realm install comamnd finished.");
  }

  FutureOr<void>? runInternal() async {
    options = parseOptionsResult(argResults!);
    validateOptions();

    if (await skipInstall()) {
      print("Realm install command started from within the realm-dart repo or one of the realm packages is a path dependency or has a path dependency override."
          " Skipping install.");
      return;
    }

    String realmPackagePath = await getRealmPackagePath();
    Pubspec realmPubspec = await parseRealmPubspec(realmPackagePath);

    if (isTargetAndroid) {
      return await downloadAndExtractAndroidBinaries(realmPackagePath, realmPubspec);
    } else if (isTargetiOS) {
      return await downloadAndExtractiOSBinaries(realmPackagePath, realmPubspec);
    } else if (isTargetMacOS && isFlutter) {
      return await downloadAndExtractMacOSFlutterBinaries(realmPackagePath, realmPubspec);
    } else if (isTargetWindows && isFlutter) {
      return await downloadAndExtractWindowsFlutterBinaries(realmPackagePath, realmPubspec);
    } else if (isTargetWindows && isDart) {
      return await downloadAndExtractWindowsBinaries(realmPackagePath, realmPubspec);
    } else if (isTargetMacOS && isDart) {
      return await downloadAndExtractMacOSBinaries(realmPackagePath, realmPubspec);
    }

    print("Unsupported target OS ${options.targetOsType} or package $packageName");
    return;

    if (!Platform.isWindows && !Platform.isMacOS) {
      throw UsageException("Unsupported platform ${Platform.operatingSystem}", "??!");
    }

    if (Platform.isMacOS) {
      print("realm_dart installed succesfully."); // TODO?!
      return;
    }

    if (Platform.isWindows || true) {
      final packageConfig = await findPackageConfig(Directory.current);
      if (packageConfig == null) {
        throw Exception("package_config.json not found. Start `realm_dart install` from the root directory of your application");
      }

      final realmDartPackage = packageConfig.packages.where((p) => p.name == 'realm_dart').firstOrNull;
      if (realmDartPackage == null) {
        throw Exception("realm_dart package not found in dependencies. Add `realm_dart` package to the pubspec.yaml");
      }

      if (realmDartPackage.root.scheme != 'file') {
        throw Exception("realm_dart package uri ${realmDartPackage.root} is not supported. Scheme must be file");
      }

      final realmDartPackagePath = realmDartPackage.root.path;
      final sourceFile = File(path.join(realmDartPackagePath, "bin", _platformPath("realm_dart_extension")));
      if (!sourceFile.existsSync()) {
        throw Exception("realm_dart binary not found in ${sourceFile.path}");
      }

      String targetFile;
      if (Platform.isWindows) {
        String targetDir = Directory.current.path;
        targetFile = targetDir + Platform.pathSeparator + _platformPath("realm_dart_extension");
      }
      // else if (Platform.isMacOS) {
      //   String targetDir = sourceDir.parent.path + Platform.pathSeparator + "lib" + Platform.pathSeparator + "src";
      //   targetFile = targetDir + Platform.pathSeparator + _platformPath("realm_dart_extension");
      // }
      else {
        throw Exception("Unsupported platform ${Platform.operatingSystem}");
      }

      print("Copying $sourceFile to $targetFile");
      sourceFile.copySync(targetFile);

      print("realm_dart installed succesfully.");
    } else {}
  }

  String _platformPath(String name, {String path = ""}) {
    if (path != "" && !path.endsWith(Platform.pathSeparator)) {
      path += Platform.pathSeparator;
    }

    if (Platform.isLinux || Platform.isAndroid) {
      return path + "lib" + name + ".so";
    }
    if (Platform.isMacOS) return path + "lib" + name + ".dylib";
    if (Platform.isWindows) return path + name + ".dll";
    throw Exception("Realm Dart supports Windows, Linx and MacOS only");
  }

  void validateOptions() {
    if (options.targetOsType == null && options.packageName == "realm") {
      abort("Invalid target OS.");
    } else if (options.targetOsType == null && options.packageName == "realm_dart") {
      options.targetOsType = getTargetOS();
    }

    if (!["realm", "realm_dart"].contains(options.packageName)) {
      abort("Invalid package name.");
    }

    if ((options.targetOsType == TargetOsType.ios || options.targetOsType == TargetOsType.android) && packageName != "realm") {
      throw Exception("Invalid package name ${packageName} for target OS ${TargetOsType.values.elementAt(options.targetOsType!.index).name}");
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
