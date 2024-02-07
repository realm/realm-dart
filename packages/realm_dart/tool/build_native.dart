import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:collection/collection.dart';

extension<T extends Enum> on Iterable<T> {
  T firstEqualIgnoreCase(String value) => firstWhere((e) => compareAsciiLowerCase(e.name, value) == 0);
  Iterable<String> get names => map((e) => e.name);
}

enum Architecture {
  arm('armeabi-v7a'),
  arm64('arm64-v8a'),
  ia32('x86'),
  riscv32,
  riscv64,
  x64('x86_64'),
  ;

  final String? _cmakeName;
  String get cmakeName => _cmakeName ?? name;

  const Architecture([this._cmakeName]);

  static Architecture from(String name) => Architecture.values.firstEqualIgnoreCase(name);
}

enum OS {
  android,
  ios,
  macos,
  windows,
  linux,
  ;

  static OS from(String name) => OS.values.firstEqualIgnoreCase(name);
}

// Currently supported targets
enum Target {
  androidArm,
  androidArm64,
  androidIA32,
  androidX64,
  // androidRiscv64, // not supported by realm currently
  // fuchsiaArm64, // -"- etc.
  // fuchsiaX64,
  iOSArm,
  iOSArm64,
  // iOSX64,
  // linuxArm,
  // linuxArm64,
  // linuxIA32,
  // linuxRiscv32,
  // linuxRiscv64,
  linuxX64,
  macOSArm64,
  macOSX64,
  // windowsArm64,
  // windowsIA32,
  windowsX64,
  ;

  static Target from(String name) => Target.values.firstEqualIgnoreCase(name);
}

enum BuildMode {
  debug,
  release,
  ;

  static BuildMode from(String name) => BuildMode.values.firstWhere((e) => e.name == name);
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('target', abbr: 't', allowed: Target.values.names)
    ..addOption('mode', abbr: 'm', allowed: BuildMode.values.names)
    ..addOption('arch', abbr: 'a', allowed: Architecture.values.names);

  final argResults = parser.parse(arguments);

  final hostOS = OS.from(io.Platform.operatingSystem);
  final targetOs = OS.from(argResults['target']);
  final buildMode = BuildMode.from(argResults['mode']);

  print(io.Platform.operatingSystem);
}
