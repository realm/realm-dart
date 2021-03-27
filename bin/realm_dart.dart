import 'dart:io';


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

  Directory sourceDir = new File.fromUri(Platform.script).parent;
  String sourceFile = _platformPath("realm_dart_extension", path: sourceDir.path);

  String targetFile;
  if (Platform.isWindows) {
    String targetDir = Directory.current.path;
    targetFile = targetDir + Platform.pathSeparator + _platformPath("realm_dart_extension");
  }
  else if (Platform.isMacOS) {
    String targetDir = sourceDir.parent.path + Platform.pathSeparator + "lib" + Platform.pathSeparator + "src";
    targetFile = targetDir + Platform.pathSeparator + _platformPath("realm_dart_extension");
  }
  else {
    throw new Exception("Unsupported platform ${Platform.operatingSystem}");
  }

  print("Copying ${sourceFile} to ${targetFile}");
  new File(sourceFile).copySync(targetFile);
}