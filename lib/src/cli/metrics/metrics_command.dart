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
  final pubspec = Pubspec.parse(await File(pubspecPath).readAsString());

  hierarchicalLoggingEnabled = true;
  log.level = options.verbose ? Level.INFO : Level.WARNING;

  final skipUpload = isRealmCI || Platform.environment['CI'] != null || Platform.environment['REALM_DISABLE_ANALYTICS'] != null;
  if (skipUpload && !isRealmCI) {
    // skip early
    log.info('Skipping metrics upload');
    return;
  }

  FlutterInfo? flutterInfo;
  try {
    flutterInfo = await getInfo(options);
  } catch (e) {
    flutterInfo = null;
  }

  final hostId = await machineId();
  
  var frameworkName = flutterInfo != null ? 'Flutter' : null;

  Dependency? realmDep;
  if (pubspec.dependencies.containsKey('realm')) {
    realmDep = pubspec.dependencies["realm"];
    frameworkName = frameworkName ?? "Flutter";
  }
  else if (pubspec.dependencies.containsKey('realm_dart')) {
    realmDep = pubspec.dependencies["realm_dart"];
    frameworkName = frameworkName ?? "Dart";
  }

  final realmVersion = realmDep is HostedDependency ? '${realmDep.version}' : '?';

  final metrics = await generateMetrics(
    distinctId: hostId,
    targetOsType: options.targetOsType,
    targetOsVersion: options.targetOsVersion,
    anonymizedMacAddress: hostId,
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
  );

  const encoder = JsonEncoder.withIndent('  ');
  final payload = encoder.convert(metrics.toJson());
  log.info('Uploading metrics for ${pubspec.name}...\n$payload');
  final base64Payload = base64Encode(utf8.encode(payload));

  if (skipUpload) {
    // skip late
    log.info('Skipping metrics upload (late)');
    return;
  }

  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse(
        'https://data.mongodb-api.com'
        '/app/realmsdkmetrics-zmhtm/endpoint/metric_webhook/metric_stage'
        '?data=$base64Payload}',
      ),
    );
    await request.close();
  } finally {
    client.close(force: true);
  }
}

Future<Digest> machineId() async {
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
      final r = RegExp('"IOPlatformUUID" = "([^"]*)"', dotAll: true);
      return r.firstMatch(id)?.group(1); // extract IOPlatformUUID
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
  return id.strongHash(); // strong hash for privacy
}

extension _StringEx on String {
  static const _defaultSalt = <int>[75, 97, 115, 112, 101, 114, 32, 119, 97, 115, 32, 104, 101, 114];
  Digest strongHash({List<int> salt = _defaultSalt}) => sha256.convert([...salt, ...utf8.encode(this)]);
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
    final flutterPath = flutterRoot == null ? flutterExecutableName : path.join(flutterRoot, path.basename(flutterRoot) != "bin" ? 'bin' : "", flutterExecutableName);
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
