import 'dart:io';

import 'package:flutter/services.dart';

Future<void> copyOldFormatRealmTo(String path) async {
  const assetFile = 'data/realm_files/old-format.realm';
  final data = await rootBundle.load(assetFile);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(path).writeAsBytes(bytes);
}
