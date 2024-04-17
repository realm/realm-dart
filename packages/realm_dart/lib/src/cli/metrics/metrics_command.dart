// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'flutter_info.dart';
import 'metrics.dart';
import 'options.dart';
import '../common/utils.dart';

// stamped into the library by the build system (see prepare-release.yml)
const realmCoreVersion = '14.5.2';

class MetricsCommand extends Command<void> {
  @override
  final String description = 'Report anonymized builder metrics to Realm';

  @override
  final String name = 'metrics';

  MetricsCommand() {
    populateOptionsParser(argParser);
  }

  @override
  FutureOr<void>? run() async {
    await safe(() async {
      final options = parseOptionsResult(argResults!);
      await uploadMetrics(options);
    });
  }
}

Future<void> uploadMetrics(Options options) async {
  final pubspecPath = options.pubspecPath;
  final pubspecFile = File(pubspecPath);

  if (!pubspecFile.existsSync()) {
    // Curently the pubspec file is a hard requirement for metrics to work. Skip metrics run if the file does not exists at the expected location.
    // TODO: remove the pubspec file hard requirement and allow metrics to run with the neededdata gathered by other means.
    // https://jira.mongodb.org/browse/RDART-815
    return;
  }

  final pubspec = Pubspec.parse(await pubspecFile.readAsString());

  hierarchicalLoggingEnabled = true;
  log.level = options.verbose ? Level.INFO : Level.WARNING;

  var skipUpload = (isRealmCI ||
          Platform.environment['CI'] != null ||
          Platform.environment['REALM_DISABLE_ANALYTICS'] != null ||
          Directory.current.absolute.path.contains("realm-dart")) &&
      Platform.environment['REALM_DEBUG_ANALYTICS'] == null;
  if (skipUpload) {
    // skip early and don't do any work
    log.info('Skipping metrics upload.');
    return;
  }

  FlutterInfo? flutterInfo;
  try {
    flutterInfo = await getInfo(options);
  } catch (e) {
    flutterInfo = null;
  }

  final distinctId = await generateDistinctId();

  final builderId = await generateBuilderId();

  var frameworkName = flutterInfo != null ? 'Flutter' : null;

  Dependency? realmDep;
  if (pubspec.dependencies.containsKey('realm')) {
    realmDep = pubspec.dependencies["realm"];
    frameworkName = frameworkName ?? "Flutter";
  } else if (pubspec.dependencies.containsKey('realm_dart')) {
    realmDep = pubspec.dependencies["realm_dart"];
    frameworkName = frameworkName ?? "Dart";
  }

  final realmVersion = realmDep is HostedDependency ? '${realmDep.version}' : '?';

  final metrics = await generateMetrics(
      distinctId: distinctId,
      builderId: builderId,
      targetOsType: options.targetOsType,
      targetOsVersion: options.targetOsVersion,
      anonymizedMacAddress: distinctId,
      anonymizedBundleId: pubspec.name.strongHash(),
      framework: frameworkName ?? "Unknown",
      frameworkVersion: flutterInfo != null
          ? [
              '${flutterInfo.frameworkVersion}',
              if (flutterInfo.channel != null) '(${flutterInfo.channel})', // to mimic Platform.version
              if (flutterInfo.frameworkCommitDate != null) '(${flutterInfo.frameworkCommitDate})', // -"-
            ].join(' ')
          : Platform.version,
      realmVersion: realmVersion,
      realmCoreVersion: realmCoreVersion);

  const encoder = JsonEncoder.withIndent('  ');
  final payload = encoder.convert(metrics.toJson());
  log.info('Uploading metrics for ${pubspec.name}...\n$payload');
  final base64Payload = base64Encode(utf8.encode(payload));

  if (Platform.environment['REALM_DEBUG_ANALYTICS'] != null) {
    skipUpload = true;
  }

  if (skipUpload) {
    // skip late
    log.info('Skipping metrics upload.');
    return;
  }

  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse(
        'https://data.mongodb-api.com'
        '/app/realmsdkmetrics-zmhtm/endpoint/metric_webhook/metric'
        '?data=$base64Payload',
      ),
    );
    await request.close();
  } finally {
    client.close(force: true);
  }
}

Future<String> getMachineId() async {
  var id = await safe(() async {
    if (Platform.isLinux) {
      // For linux use /etc/machine-id
      // Can be changed by administrator but with unpredictable consequences!
      // (see https://man7.org/linux/man-pages/man5/machine-id.5.html)
      final process = await Process.start('cat', ['/etc/machine-id']);
      return await process.stdout.transform(utf8.decoder).join();
    } else if (Platform.isMacOS) {
      // For MacOS, use the IOPlatformUUID value from I/O Kit registry in
      // IOPlatformExpertDevice class
      final process = await Process.start('ioreg', [
        '-rd1',
        '-c',
        'IOPlatformExpertDevice',
      ]);
      final id = await process.stdout.transform(utf8.decoder).join();
      return id;
    } else if (Platform.isWindows) {
      // For Windows, use the key MachineGuid in registry:
      // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography
      // Can be changed by administrator but with unpredictable consequences!
      //
      // It is generated during OS installation and won't change unless you make
      // another OS update or re-install. Depending on the OS version it may
      // contain the network adapter MAC address embedded (plus some other numbers,
      // including random), or a pseudorandom number.
      //
      // Consider using System.Identity.UniqueID instead.
      // (see https://docs.microsoft.com/en-gb/windows/win32/properties/props-system-identity-uniqueid)
      final process = await Process.start(
        '${Platform.environment['WINDIR']}\\System32\\Reg.exe',
        [
          'QUERY',
          r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography',
          '/v',
          'MachineGuid',
        ],
      );
      return await process.stdout.transform(systemEncoding.decoder).join();
    }
  }, message: 'failed to get machine id');
  id ??= Platform.localHostname; // fallback
  return id;
}

const macOSMachineIdRegEx = r'.*\"IOPlatformUUID\"\s=\s\"(.+)\"';

Future<Digest> generateDistinctId() async {
  var id = await safe(() async {
    final machineId = await getMachineId();
    if (Platform.isLinux) {
      return machineId;
    } else if (Platform.isMacOS) {
      final regex = RegExp(macOSMachineIdRegEx, dotAll: true);
      return regex.firstMatch(machineId)?.group(1); // extract IOPlatformUUID
    } else if (Platform.isWindows) {
      return machineId;
    }
  }, message: 'failed to get machine id');

  id ??= Platform.localHostname; // fallback
  return id.strongHash(); // strong hash for privacy
}

Future<Digest> generateBuilderId() async {
  var id = await safe(() async {
    final machineId = await getMachineId();
    if (Platform.isLinux) {
      return machineId;
    } else if (Platform.isMacOS) {
      final regex = RegExp(macOSMachineIdRegEx, dotAll: true);
      return regex.firstMatch(machineId)?.group(1); // extract IOPlatformUUID
    } else if (Platform.isWindows) {
      final regex = RegExp(r'\s*MachineGuid\s*\w*\s*([A-Za-z0-9-]+)', dotAll: true);
      return regex.firstMatch(machineId)?.group(1); // extract MachineGuid
    }
  }, message: 'failed to get machine id');

  id ??= Platform.localHostname; // fallback

  const builderIdSalt = [82, 101, 97, 108, 109, 32, 105, 115, 32, 103, 114, 101, 97, 116];
  return id.strongHash(builderIdSalt); // strong hash for privacy
}

extension _StringEx on String {
  static const _defaultSalt = <int>[75, 97, 115, 112, 101, 114, 32, 119, 97, 115, 32, 104, 101, 114];
  Digest strongHash([List<int> salt = _defaultSalt]) => sha256.convert([...salt, ...utf8.encode(this)]);
}

Future<FlutterInfo?> getInfo(Options options) async {
  final pubspecPath = options.pubspecPath;
  final pubspec = Pubspec.parse(await File(pubspecPath).readAsString());

  const flutter = 'flutter';
  final flutterDep = pubspec.dependencies.values.whereType<SdkDependency>().where((dep) => dep.sdk == flutter).firstOrNull;
  if (flutterDep == null) {
    return null; // no flutter dependency, so not a flutter project
  }

  // Read constraints, if any
  var flutterVersionConstraints = flutterDep.version.intersect(pubspec.environment?[flutter] ?? VersionConstraint.any);

  // Try to read actual version from version file in .dart_tools.
  // This is updated when calling a flutter command on the project,
  // but not when calling a dart command..
  final version = await safe(() async {
    return Version.parse(await File(path.join(path.dirname(pubspecPath), '.dart_tool/version')).readAsString());
  });

  // Try to get full info by calling flutter executable
  final info = await safe(() async {
    final flutterRoot = options.flutterRoot;
    final flutterExecutableName = Platform.isWindows ? "flutter.bat" : "flutter";
    final flutterPath =
        flutterRoot == null ? flutterExecutableName : path.join(flutterRoot, path.basename(flutterRoot) != "bin" ? 'bin' : "", flutterExecutableName);
    final process = await Process.start(flutterPath, ['--version', '--machine']);
    final infoJson = await process.stdout.transform(utf8.decoder).join();
    return FlutterInfo.fromJson(json.decode(infoJson) as Map<String, dynamic>);
  });

  // Sanity check full info, if we have it
  if (info != null && (version == null || version == info.frameworkVersion) && flutterVersionConstraints.allows(info.frameworkVersion)) {
    // The returned info match both the projects constraints and the
    // flutter version of the latest flutter command run on the project
    return info;
  }

  // Fallback to simplified info build from the version read from .dart_tool/version,
  // secondly the min constraint of the flutter SDK used
  return FlutterInfo(
    frameworkVersion: version ?? (await safe(() => (flutterVersionConstraints as VersionRange).min!)) ?? Version.none,
    dartSdkVersion: Version.parse(Platform.version.takeUntil(' ')),
  );
}
