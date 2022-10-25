import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> copyBundledFile(String fromPath, String toPath) async {
  await File(p.join('test', fromPath)).copy(toPath);
}
