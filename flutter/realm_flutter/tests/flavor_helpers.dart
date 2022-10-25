import 'dart:io';

import 'package:flutter/services.dart';

Future<void> copyBundledFile(String fromPath, String toPath) async {
  final data = await rootBundle.load(fromPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(toPath).writeAsBytes(bytes);
}
