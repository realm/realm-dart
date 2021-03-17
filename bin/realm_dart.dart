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
    print("Run this script with `pub run realm_dart install` to install Realm Dart into your application");
    exit(-1);
  }

  if (!Platform.isWindows) {
    print("The command `pub run realm_dart install` is only needed on Windows");
    exit(0);
  }

  String targetDir = Directory.current.path;
  String targetFile = targetDir + Platform.pathSeparator + _platformPath("realm_dart_extension");

  Directory sourceDir = new File.fromUri(Platform.script).parent;
  String sourceFile = _platformPath("realm_dart_extension", path: sourceDir.path);
  print("Copying ${sourceFile} to ${targetFile}");
  new File(sourceFile).copySync(targetFile);
}