import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:metrics/metrics.dart';
import 'package:metrics/src/flutter_info.dart';
import 'package:metrics/src/options.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

Future<void> main(List<String> arguments) async {
  late Options options;
  bool displayUsage = false;
  try {
    options = parseOptions(arguments);
    displayUsage = options.help;
  } catch (e) {
    displayUsage = true;
  }
  if (displayUsage) {
    print('dart run metrics [arguments]');
    print(usage);
    return;
  }

  final pubspecPath = path.join(path.current, 'pubspec.yaml');
  final pubspec = Pubspec.parse(await File(pubspecPath).readAsString());

  hierarchicalLoggingEnabled = true;
  _log.level = options.verbose ? Level.INFO : Level.WARNING;

  // Ensure realm_generator has run (EXPENSIVE!)
  // Not really needed currently, as we don't pick up features yet,
  // but it ensures the realm_generator has been run
  final process = await Process.start('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  await stdout.addStream(process.stdout);

  if (Platform.environment['CI'] != null ||
      Platform.environment['REALM_DISABLE_ANALYTICS'] != null) {
    _log.info('Skipping metrics upload');
    return;
  }

  try {
    await uploadMetrics(options, pubspec);
  } catch (e, s) {
    _log.warning('Failed to upload metrics', e, s);
    // We don't set exitCode > 0 on runtime errors!
    // This script is called during build (via gradle, podspec, etc.)
    // and we don't want to be the cause of a broken build!
  }
  exit(0); // why is this needed?
}

Future<void> uploadMetrics(Options options, Pubspec pubspec) async {
  if (options.flutter) {}
  final hostId = await machineId();

  final metrics = await generateMetrics(
    distinctId: hostId,
    targetOsType: options.targetOsType,
    targetOsVersion: options.targetOsVersion,
    anonymizedMacAddress:
        hostId, // cannot get this with dart, using hostId instead :-/ (similar to realm-js)
    anonymizedBundleId: pubspec.name.strongHash(), 
    framework: options.flutter ? 'flutter' : 'dart',
    frameworkVersion: options.flutter ? (await flutterInfo()).frameworkVersion : Platform.version,
  );

  const encoder = JsonEncoder.withIndent('  ');
  final payload = encoder.convert(metrics.toJson());
  _log.info('Uploading metrics for ${pubspec.name}...\n$payload');
  final base64Payload = base64Encode(utf8.encode(payload));

  final client = HttpClient();
  final request = await client.getUrl(
    Uri.parse(
      'https://webhooks.mongodb-realm.com'
      '/api/client/v2.0/app/realmsdkmetrics-zmhtm/service/metric_webhook/incoming_webhook/metric'
      '?data=$base64Payload}',
    ),
  );
  await request.close();
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
