// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// This is a simple command-line tool to build native assets for realm_dart
// It is a precursor to the upcoming `native_assets` feature.
import 'dart:async';
import 'dart:io' as io;
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:async/async.dart';

extension IterableX<T extends Enum> on Iterable<T> {
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

abstract class BaseCommand extends Command<int> {
  @override
  final String name;
  @override
  final String description;

  BaseCommand(this.name, this.description);

  late final verbose = globalResults!['verbose'] as bool; // don't access before run

  OS get os;
  // currently target must match the host OS, or be an android platform
  Iterable<Target> get possibleTargets => Target.values.where((t) => t.os == os || t.os == OS.android || (os == OS.macOS && t.os == OS.iOS));
}

class BuildNativeCommand extends BaseCommand {
  BuildNativeCommand()
      : super(
          'build',
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
    final command = args.join(' ');
    message ??= command;
    if (verbose) {
      logger.info(message);
      await Future.wait([io.stdout.addStream(p.stdout), io.stderr.addStream(p.stderr)]);
    } else {
      // trim message to fit terminal width
      final width = io.stdout.hasTerminal ? io.stdout.terminalColumns - 12 : 80;
      message = message.padRight(width);
      if (message.length > width) {
        message = '${message.substring(0, width - 4)} ...';
      }

      progress = logger.progress(message);
      await for (final _ in StreamGroup.merge([p.stdout, p.stderr])) {
        // update progress when there's output in child process
        progress.update(message);
      }
    }
    final exitCode = await p.exitCode;
    assert(verbose ^ (progress != null)); // verbose <=> progress == null
    if (exitCode != 0) {
      progress?.fail(message);
      logger.err('Error: "$command" exited with code $exitCode');
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

    for (final target in targets) {
      logger.info('Building for ${target.name} in ${buildMode.name} mode');
      int? exitCode;
      switch (target.os) {
        case OS.iOS:
          for (final sdk in iosSdks) {
            exitCode ??= await runProc(['cmake', '--preset=ios'], logger: logger);
            exitCode ??= await runProc(['cmake', '--build', '--preset=ios-${sdk.cmakeName}', '--config=${buildMode.cmakeName}'], logger: logger);
          }
          final output = io.Directory('./binary/ios/realm_dart.xcframework');
          if (await output.exists()) {
            await output.delete(recursive: true);
          }
          exitCode ??= await runProc(
            [
              'xcodebuild',
              '-create-xcframework',
              for (final s in iosSdks) ...['-framework', './binary/ios/${buildMode.cmakeName}-${s.name.toLowerCase()}/realm_dart.framework'],
              ...['-output', output.path],
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
              if (target.os == OS.android && buildMode == BuildMode.release) '--target=strip',
            ],
            logger: logger,
          );
          break;
      }
      io.stdout.writeln();
      if (exitCode != null) return exitCode; // return first non-zero exit code
    }
    return 0; // success
  }
}

class PossibleTargets extends BaseCommand {
  PossibleTargets()
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
