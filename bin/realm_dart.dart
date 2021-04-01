import 'dart:io';
import 'dart:convert';

String _platformPath(String name, {String path = ""}) {
  if (path != "" && !path.endsWith(Platform.pathSeparator)) {
    path += Platform.pathSeparator;
  }

  if (Platform.isLinux || Platform.isAndroid) return path + "lib" + name + ".so";
  if (Platform.isMacOS) return path + "lib" + name + ".dylib";
  if (Platform.isWindows) return path + name + ".dll";
  throw Exception("Realm Dart supports Windows, Linx and MacOS only");
}

Future<void> main(List<String> args) {
  if (args.length != 1 || args[0] != "install") {
    print("Run this script with `dart run realm_dart install` to install Realm Dart into your application");
    exit(-1);
  }

  if (!Platform.isWindows && !Platform.isMacOS) {
    print("Unsupported platform ${Platform.operatingSystem}");
    exit(-1);
  }

  if (Platform.isMacOS) {
    print("realm_dart installed");
    exit(0);
  }

  Directory sourceDir = new File.fromUri(Platform.script).parent;

  String packageConfigFilePath = Directory.current.path + "/.dart_tool/package_config.json";
  File packageConfigFile = new File(packageConfigFilePath);
  if (!packageConfigFile.existsSync()) {
    throw Exception("pakcage_config not foundin $packageConfigFilePath. Start `realm_dart install` from the root directory of your application");
  }

  var json = jsonDecode(packageConfigFile.readAsStringSync());
  var packages = json['packages'];
  var realmDartPackage = packages.firstWhere((p) => p['name'] == "realm_dart");

  if (realmDartPackage == null) {
    throw Exception("realm_dart package not found in dependencies. Add `realm_dart` package to the pubspec.yaml");
  }

  var realmDartPackagePath = realmDartPackage['rootUri'].toString();
  if (realmDartPackagePath.startsWith("file://")) {
    //remove `file://`
    realmDartPackagePath = realmDartPackagePath.substring(8);
  }
  else if (realmDartPackagePath.startsWith("../")) {
    //relative paths start relative from .dart_tool dir. remove the first ../
    realmDartPackagePath = realmDartPackagePath.substring(3);

    realmDartPackagePath = File.fromUri(Uri.file(realmDartPackagePath, windows: true)).absolute.path;
    
    //remove trailing '\'
    realmDartPackagePath = realmDartPackagePath.substring(0, realmDartPackagePath.length - 1);
  }
  else {
    throw Exception("realm_dart package uri $realmDartPackagePath is not supported. It should start with file://");
  }

  File sourceFile = new File(realmDartPackagePath + Platform.pathSeparator + "bin" + Platform.pathSeparator + _platformPath("realm_dart_extension"));
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
    throw new Exception("Unsupported platform ${Platform.operatingSystem}");
  }

  print("Copying ${sourceFile} to ${targetFile}");
  sourceFile.copySync(targetFile);
}