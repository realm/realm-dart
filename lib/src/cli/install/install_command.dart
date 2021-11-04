import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:package_config/package_config.dart';
import '../metrics/utils.dart';

class InstallCommand extends Command<void> {
  @override
  final String description = 'Install shared library when using dart native';

  @override
  final String name = 'install';

  @override
  FutureOr<void>? run() async {
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
        throw Exception(
            "packcage_config.json not found. Start `realm_dart install` from the root directory of your application");
      }

      final realmDartPackage = packageConfig.packages
          .where((p) => p.name == 'realm_dart')
          .firstOrNull;
      if (realmDartPackage == null) {
        throw Exception(
            "realm_dart package not found in dependencies. Add `realm_dart` package to the pubspec.yaml");
      }

      if (realmDartPackage.root.scheme != 'file') {
        throw Exception(
            "realm_dart package uri ${realmDartPackage.root} is not supported. Scheme must be file");
      }

      final realmDartPackagePath = realmDartPackage.root.path;
      final sourceFile = File(path.joinAll([
        realmDartPackagePath,
        "bin",
        _platformPath("realm_dart_extension"),
      ]));
      if (!sourceFile.existsSync()) {
        throw Exception("realm_dart binary not found in ${sourceFile.path}");
      }

      String targetFile;
      if (Platform.isWindows) {
        String targetDir = Directory.current.path;
        targetFile = targetDir +
            Platform.pathSeparator +
            _platformPath("realm_dart_extension");
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
    }
    else {

    }
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
}
