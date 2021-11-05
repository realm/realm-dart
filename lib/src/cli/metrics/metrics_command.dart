import 'dart:async';

import 'package:args/command_runner.dart';

import 'flutter_info.dart';
import 'metrics.dart';
import 'options.dart';

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

class MetricsCommand extends Command<void> {
  @override
  final String description =
      'Report anonymised metrics about build host to Realm';

  @override
  final String name = 'metrics';

  MetricsCommand() {
    populateOptionsParser(argParser);
  }

  @override
  FutureOr<void>? run() async {
    try {
      final options = parseOptionsResult(argResults!);
      await uploadMetrics(options);
    } catch (e, s) {
      _log.warning('Failed to upload metrics', e, s);
      // We squash on runtime errors!
      // This script is called during build (via gradle, podspec, etc.)
      // and we don't want to be the cause of a broken build!
    }
  }
}

Future<void> uploadMetrics(Options options) async {
  final pubspecPath = path.join(path.current, 'pubspec.yaml');
  final pubspec = Pubspec.parse(await File(pubspecPath).readAsString());

  hierarchicalLoggingEnabled = true;
  _log.level = options.verbose ? Level.INFO : Level.WARNING;

  if (Platform.environment['CI'] != null ||
      Platform.environment['REALM_DISABLE_ANALYTICS'] != null) {
    _log.info('Skipping metrics upload');
    return;
  }

  final flutterInfo = options.flutter ? await FlutterInfo.get() : null;
  final hostId = await machineId();

  final metrics = await generateMetrics(
    distinctId: hostId,
    targetOsType: options.targetOsType,
    targetOsVersion: options.targetOsVersion,
    anonymizedMacAddress: hostId,
    anonymizedBundleId: pubspec.name.strongHash(),
    framework: flutterInfo != null ? 'flutter' : 'dart native',
    frameworkVersion: flutterInfo != null
        ? '${flutterInfo.frameworkVersion}'
            ' (${flutterInfo.channel})' // to mimic Platform.version
            ' (${flutterInfo.frameworkCommitDate})' // -"-
        : Platform.version,
  );

  const encoder = JsonEncoder.withIndent('  ');
  final payload = encoder.convert(metrics.toJson());
  _log.info('Uploading metrics for ${pubspec.name}...\n$payload');
  final base64Payload = base64Encode(utf8.encode(payload));

  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse(
        'https://webhooks.mongodb-realm.com'
        '/api/client/v2.0/app/realmsdkmetrics-zmhtm/service/metric_webhook/incoming_webhook/metric'
        '?data=$base64Payload}',
      ),
    );
    await request.close();
  } finally {
    client.close(force: true);
  }
}

// log to stdout
final _log = Logger('metrics')
  ..onRecord.listen((record) {
    stdout.writeln('[${record.level.name}] ${record.message}');
  });

Future<Digest> machineId() async {
  String? id;
  try {
    // No easy access to mac-address from dart, as used by other SDKs,
    // but we can do better..
    if (Platform.isLinux) {
      // For linux use /etc/machine-id
      // Can be changed by administrator but with unpredictable consequences!
      // (see https://man7.org/linux/man-pages/man5/machine-id.5.html)
      final process = await Process.start('cat', ['/etc/machine-id']);
      id = await process.stdout.transform(utf8.decoder).join();
    } else if (Platform.isMacOS) {
      // For MacOS, use the IOPlatformUUID value from I/O Kit registry in
      // IOPlatformExpertDevice class
      final process = await Process.start('ioreg', [
        '-rd1',
        '-c',
        'IOPlatformExpertDevice',
      ]);
      id = await process.stdout.transform(utf8.decoder).join();
      final r = RegExp('"IOPlatformUUID" = "([^"]*)"', dotAll: true);
      id = r.firstMatch(id)?.group(1); // extract IOPlatformUUID
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
      final process = await Process.start(r'%windir%\System32\Reg.exe', [
        'QUERY',
        r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography',
        '/v',
        'MachineGuid',
      ]);
      id = await process.stdout.transform(systemEncoding.decoder).join();
    }
  } catch (e, s) {
    _log.warning('failed to get machine id', e, s);
  }
  id ??= Platform.localHostname; // fallback
  return id.strongHash(); // strong hash for privacy
}

extension _StringEx on String {
  static const _defaultSalt = <int>[
    75,
    97,
    115,
    112,
    101,
    114,
    32,
    119,
    97,
    115,
    32,
    104,
    101,
    114
  ];
  Digest strongHash({List<int> salt = _defaultSalt}) =>
      sha256.convert([...salt, ...utf8.encode(this)]);
}
