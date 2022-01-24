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

FutureOr<T?> safe<T>(FutureOr<T> Function() f, {String message = 'Ignoring error', Function(Object e, StackTrace s)? onError}) async {
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
  if (!Platform.isWindows) {
    return Logger('metrics')
      ..onRecord.listen((record) {
        try {
          stdout.writeln('[${record.level.name}] ${record.message}');
          if (record.error != null) {
            stdout.writeln(record.error);
          }
        } catch (_) {}
      });
  }

  return WindowsLogger('metrics');
}

//uses print on Windows because the Logger..onRecord crashesh with closed stream on Windows currently
class WindowsLogger implements Logger {
  final Logger _logger;

  WindowsLogger(String name) : _logger = Logger(name);

  @override
  Level get level => _logger.level;
  @override
  set level(Level? value) => _logger.level = value;

  @override
  void log(Level logLevel, Object? message, [Object? error, StackTrace? stackTrace, Zone? zone]) {
    print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }

  @override
  Map<String, Logger> get children => _logger.children;

  @override
  void clearListeners() {
    _logger.clearListeners();
  }

  @override
  void config(Object? message, [Object? error, StackTrace? stackTrace]) {
   print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }

  @override
  void fine(Object? message, [Object? error, StackTrace? stackTrace]) {
    print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }

  @override
  void finer(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.finer(message, error, stackTrace);
  }

  @override
  void finest(Object? message, [Object? error, StackTrace? stackTrace]) {
    print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }

  @override
  String get fullName => _logger.fullName;

  @override
  void info(Object? message, [Object? error, StackTrace? stackTrace]) {
    print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }

  @override
  bool isLoggable(Level value) {
    return _logger.isLoggable(value);
  }

  @override
  String get name => _logger.name;

  @override
  Stream<LogRecord> get onRecord => _logger.onRecord;

  @override
  Logger? get parent => _logger.parent;

  @override
  void severe(Object? message, [Object? error, StackTrace? stackTrace]) {
    print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }

  @override
  void shout(Object? message, [Object? error, StackTrace? stackTrace]) {
    print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }

  @override
  void warning(Object? message, [Object? error, StackTrace? stackTrace]) {
    print("$message ${error ?? ''} ${stackTrace ?? ''}");
  }
}