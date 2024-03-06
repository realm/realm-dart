// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// This is a simple command-line tool to build native assets for realm_dart
// It is a precursor to the upcoming `native_assets` feature.
import 'dart:async';
import 'dart:io' as io;
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

extension<T extends Enum> on Iterable<T> {
  T? firstEqualIgnoreCase(String? value) => value == null ? null : where((e) => equalsIgnoreAsciiCase(e.name, value)).firstOrNull;
  Iterable<String> get names => map((e) => e.name);
}

// This enum is based on `Architecture` class from the upcoming `native_assets_cli` package
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

  static Architecture? from(String name) => Architecture.values.firstEqualIgnoreCase(name);
}

// This enum is based on `iOSSdk` class from the upcoming `native_assets_cli` package
// ignore: camel_case_types
enum iOSSdk {
  iPhoneOS('device'),
  iPhoneSimulator('simulator'),
  ; // flutter doesn't support maccatalyst (yet?)

  final String? _cmakeName;
  String get cmakeName => _cmakeName ?? name;

  const iOSSdk([this._cmakeName]);

  static iOSSdk? from(String? name) => iOSSdk.values.firstEqualIgnoreCase(name);
}

// This enum is based on `OS` class from the upcoming `native_assets_cli` package
enum OS {
  android,
  iOS,
  macOS,
  windows,
  linux,
  ;

  String get cmakeName => name.toLowerCase();

  static OS? from(String? name) => OS.values.firstEqualIgnoreCase(name);
  static OS get current => from(io.Platform.operatingSystem) ?? (throw UnsupportedError('Unsupported OS: ${io.Platform.operatingSystem}'));
}

// Currently supported targets
// This enum is based on `Target` class from the upcoming `native_assets_cli` package
enum Target {
  androidArm(Architecture.arm, OS.android),
  androidArm64(Architecture.arm64, OS.android),
  androidIA32(Architecture.ia32, OS.android),
  androidX64(Architecture.x64, OS.android), // only for emulator
  // androidRiscv64, // not supported by realm currently
  // fuchsiaArm64, // -"- etc.
  // fuchsiaX64,
  // iOSArm(Architecture.arm, OS.iOS), // <-- pre ios11, not even supported by flutter?!?
  iOSArm64(Architecture.arm64, OS.iOS),
  iOSX64(Architecture.x64, OS.iOS), // only for simulator
  // linuxArm,
  // linuxArm64,
  // linuxIA32,
  // linuxRiscv32,
  // linuxRiscv64,
  linuxX64(Architecture.x64, OS.linux),
  macOSArm64(Architecture.arm64, OS.macOS),
  macOSX64(Architecture.x64, OS.macOS),
  // windowsArm64,
  // windowsIA32,
  windowsX64(Architecture.x64, OS.windows),
  ;

  final Architecture architecture;
  final OS os;

  const Target(this.architecture, this.os);

  static Target? from(String? name) => Target.values.firstEqualIgnoreCase(name);
}

enum BuildMode {
  debug('Debug'),
  release('Release'),
  ;

  final String cmakeName;

  const BuildMode(this.cmakeName);

  static BuildMode? from(String? name) => BuildMode.values.firstEqualIgnoreCase(name);
}

abstract class _BaseCommand extends Command<int> {
  @override
  final String name;
  @override
  final String description;

  _BaseCommand(this.name, this.description);

  late final verbose = globalResults!['verbose'] as bool; // don't access before run

  OS get os;
  // currently target must match the host OS, or be an android platform
  Iterable<Target> get possibleTargets => Target.values.where((t) => t.os == os || t.os == OS.android || (os == OS.macOS && t.os == OS.iOS));
}

class _BuildNativeCommand extends _BaseCommand {
  _BuildNativeCommand()
      : super(
          'native',
          'Build native assets for realm_dart',
        ) {
    argParser
      ..addMultiOption(
        'target',
        abbr: 't',
        help: 'The target platform to build for. Defaults to all possible targets',
        allowed: [...possibleTargets.names, 'all'],
        defaultsTo: ['all'],
      )
      ..addOption(
        'build-mode',
        abbr: 'm',
        allowed: BuildMode.values.names,
        defaultsTo: BuildMode.release.name,
      )
      ..addMultiOption(
        'ios-sdk',
        abbr: 's',
        help: 'The iOS SDK to build for. Ignored for non-iOS platforms. Defaults to all available SDKs.',
        allowed: [...iOSSdk.values.names, 'all'],
        defaultsTo: ['all'],
      );
  }

  @override
  OS get os => OS.current;

  Future<int?> runProc(List<String> args, {required Logger logger, String? message}) async {
    final p = await io.Process.start(args.first, args.skip(1).toList());
    Progress? progress;
    if (verbose) {
      await io.stdout.addStream(p.stdout);
    } else {
      message ??= args.join(' ');
      final width = io.stdout.hasTerminal ? io.stdout.terminalColumns - 12 : 80;
      message = message.padRight(width).substring(0, width);
      progress = logger.progress(message);
      await for (final _ in p.stdout) {
        progress.update(message);
      }
    }
    final exitCode = await p.exitCode;
    if (exitCode < 0) {
      progress?.fail(message);
      logger.err('Error: "$message}" exited with code $exitCode');
      return exitCode;
    } else {
      progress?.complete(message);
      return null; // return null if successful
    }
  }

  @override
  Future<int> run() async {
    final argResults = this.argResults!;
    final targetOptions = argResults['target'] as List<String>;

    final targets = targetOptions.contains('all') // if 'all' is specified, build for all possible targets
        ? possibleTargets
        : targetOptions.map((o) => Target.from(o) ?? (throw ArgumentError.value(o, 'target', 'Invalid target')));

    final buildMode =
        BuildMode.from(argResults['build-mode'] as String?) ?? (throw ArgumentError.value(argResults['build-mode'], 'build-mode', 'Invalid build mode'));

    final iosSdkOptions = argResults['ios-sdk'] as List<String>;
    final iosSdks = iosSdkOptions.contains('all') // if 'all' is specified, build for all available SDKs
        ? iOSSdk.values
        : iosSdkOptions.map((o) => iOSSdk.from(o)).whereNotNull();

    int? exitCode;
    for (final target in targets) {
      logger.info('Building for ${target.name} in ${buildMode.name} mode');
      switch (target.os) {
        case OS.iOS:
          for (final sdk in iosSdks) {
            exitCode ??= await runProc(['cmake', '--preset=ios'], logger: logger);
            exitCode ??= await runProc(['cmake', '--build', '--preset=ios-${sdk.cmakeName}', '--config=${buildMode.cmakeName}'], logger: logger);
          }
          exitCode ??= await runProc(
            [
              'xcodebuild',
              '-create-xcframework',
              for (final s in iosSdks) '-framework ./binary/ios/${buildMode.cmakeName}-${s.name.toLowerCase()}/realm_dart.framework',
              '-output ./binary/ios/realm_dart.xcframework',
            ],
            logger: logger,
          );
          break;

        case OS.android:
        case OS.linux:
        case OS.macOS:
        case OS.windows:
          final preset = '${target.os.cmakeName}${target.os == OS.android ? "-${target.architecture.cmakeName}" : ""}';
          exitCode ??= await runProc(['cmake', '--preset=$preset'], logger: logger);
          exitCode ??= await runProc(
            [
              'cmake',
              '--build',
              '--preset=$preset',
              '--config=${buildMode.cmakeName}',
              if (target.os == OS.macOS) '-- -destination "generic/platform=macOS',
              if (target.os == OS.android) '--target=strip',
            ],
            logger: logger,
          );
          break;
      }
      io.stdout.writeln();
    }
    return exitCode ?? 0;
  }
}

class _PossibleTargets extends _BaseCommand {
  _PossibleTargets()
      : super(
          'targets',
          'List possible targets for building native assets',
        ) {
    argParser.addOption(
      'os',
      abbr: 'o',
      allowed: OS.values.names,
      defaultsTo: OS.current.name,
    );
  }

  late final _osOption = argResults?['os'] as String?;
  @override
  OS get os => OS.from(_osOption) ?? (throw ArgumentError.value(_osOption, 'os', 'Invalid OS'));

  @override
  int run() {
    print(possibleTargets.names.join('\n'));
    return 0;
  }
}

final logger = Logger(progressOptions: ProgressOptions(trailing: ''));

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<int>('build', 'Helper tool for building realm_dart')
    ..addCommand(_BuildNativeCommand())
    ..addCommand(_PossibleTargets())
    ..argParser.addFlag('verbose', abbr: 'v', help: 'Print verbose output', defaultsTo: false);
  try {
    final exitCode = await runner.run(arguments);
    io.exit(exitCode!);
  } on UsageException catch (error) {
    logger.err('$error');
    io.exit(64); // Exit code 64 indicates a usage error.
  }
}
