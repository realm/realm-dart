import 'dart:io';

Future<void> copyOldFormatRealmTo(String path) async {
  const realmBundleFile = 'flutter/realm_flutter/tests/data/realm_files/old-format.realm';
  await File(realmBundleFile).copy(path);
}
