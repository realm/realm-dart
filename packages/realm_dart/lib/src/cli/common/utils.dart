// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

extension IterableEx<T> on Iterable<T> {
  T? get firstOrNull => cast<T?>().firstWhere((element) => true, orElse: () => null);
}

extension StringEx on String {
  String takeUntil(Pattern p) {
    var idx = indexOf(p);
    if (idx < 0) idx = length;
    return substring(0, idx);
  }
}

bool isRealmCI = Platform.environment['REALM_CI'] != null;

FutureOr<T?> safe<T>(FutureOr<T> Function() f, {String message = 'Ignoring error', void Function(Object e, StackTrace s)? onError}) async {
  try {
    return await f();
  } catch (e, s) {
    if (onError != null) {
      onError(e, s);
    } else {
      if (isRealmCI) rethrow; // on internal CI we want to see all errors
      log.warning(message, e, s);
    }
    return null;
  }
}

// log to stdout
final log = createLogger();

Logger createLogger() {
  return Logger('metrics')
    ..onRecord.listen((record) {
      try {
        if (Platform.isWindows) {
          print('[${record.level.name}] ${record.message}');
          if (record.error != null) {
            print(record.error);
          }
          return;
        }

        stdout.writeln('[${record.level.name}] ${record.message}');
        if (record.error != null) {
          stdout.writeln(record.error);
        }
      } catch (_) {}
    });
}
