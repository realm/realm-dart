import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:metrics/metrics.dart';

Future<void> main(List<String> arguments) async {
  // Ensure realm_generator has run (EXPENSIVE!)
  // Not really needed currently, as we don't pick up features yet.
  final process = await Process.start('dart', ['run', 'build_runner', 'build']);
  await stdout.addStream(process.stdout);

  final id = await machineId();

  final metrics = await generateMetrics(id);

  const encoder = JsonEncoder.withIndent('  ');
  final payload = encoder.convert(metrics.toJson());
  print(payload);
  final client = HttpClient();
  final base64Payload = base64Encode(utf8.encode(payload));
  final request = await client.getUrl(
    Uri.parse(
      'https://webhooks.mongodb-realm.com'
      '/api/client/v2.0/app/realmsdkmetrics-zmhtm/service/metric_webhook/incoming_webhook/metric'
      '?data=$base64Payload}',
    ),
  );
  final response = await request.close();
  print(response.statusCode);

  await process.exitCode;
}

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
  } catch (_) {} // ignore: empty_catches
  id ??= Platform.localHostname; // fallback
  return sha256.convert(utf8.encode(id)); // strong hash for privacy
}
