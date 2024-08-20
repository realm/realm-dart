// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:logging/logging.dart';

import 'handles/realm_core.dart';

// Using classes to make a fancy hierarchical enum
sealed class LogCategory {
  /// All possible log categories.
  static final values = [
    realm,
    realm.sdk,
    realm.storage,
    realm.storage.notification,
    realm.storage.object,
    realm.storage.query,
    realm.storage.transaction,
  ];

  /// The root category for all log messages from the Realm SDK.
  static final realm = _RealmLogCategory();

  final String _name;
  final LogCategory? _parent;

  LogCategory._(this._name, this._parent);

  /// Returns `true` if this category contains the given [category].
  bool _contains(LogCategory category) {
    var current = category;
    while (current != this) {
      final isRoot = current == realm;
      if (isRoot) {
        return false;
      }
      current = current._parent!;
    }
    return true;
  }

  // cache the toString result
  late final String _toString = (_parent == null ? _name : '$_parent.$_name');
  @override
  String toString() => _toString;

  static final _map = {for (final category in LogCategory.values) category.toString(): category};

  /// Returns the [LogCategory] for the given [category] string.
  /// Will throw if the category is not recognized.
  factory LogCategory.fromString(String category) => _map[category]!;
}

class _LeafLogCategory extends LogCategory {
  _LeafLogCategory(super.name, LogCategory super.parent) : super._();
}

class _RealmLogCategory extends LogCategory {
  _RealmLogCategory() : super._('Realm', null);

  late final sdk = _LeafLogCategory('SDK', this);
  late final storage = _StorageLogCategory(this);
}

class _StorageLogCategory extends LogCategory {
  _StorageLogCategory(LogCategory parent) : super._('Storage', parent);

  late final notification = _LeafLogCategory('Notification', this);
  late final object = _LeafLogCategory('Object', this);
  late final query = _LeafLogCategory('Query', this);
  late final transaction = _LeafLogCategory('Transaction', this);
}

/// Specifies the criticality level above which messages will be logged
/// by the default client logger.
/// {@category Realm}
enum LogLevel {
  /// Log everything. This will seriously harm the performance of the
  /// database and should never be used in production scenarios.
  all(Level.ALL),

  /// A version of [debug] that allows for very high volume output.
  /// This may seriously affect the performance of the database.
  trace(Level.FINEST),

  /// Reveal information that can aid debugging, no longer paying
  /// attention to efficiency.
  debug(Level.FINER),

  /// Same as [info], but prioritize completeness over minimalism.
  detail(Level.FINE),

  /// Log operational database messages, but in a minimalist fashion to
  /// avoid general overhead from logging and to keep volume down.
  info(Level.INFO),

  /// Log errors and warnings.
  warn(Level.WARNING),

  /// Log errors only.
  error(Level.SEVERE),

  /// Log only fatal errors.
  fatal(Level.SHOUT),

  /// Turn off logging.
  off(Level.OFF),
  ;

  /// The [Level] from package [logging](https://pub.dev/packages/logging) that
  /// corresponds to this [LogLevel].
  final Level level;

  const LogLevel(this.level);
}

/// A record of a log message from the Realm SDK.
typedef LogRecord = ({LogCategory category, LogLevel level, String message});

/// A logger that logs messages from the Realm SDK.
///
/// To subscribe to log messages, use [onRecord].
///
/// Example:
/// ```dart
/// hierarchyLoggingEnabled = true;
/// final logSubscription = Realm.logger.onRecord.listen((record) {
///   Logger(record.category.toString()).log(record.level.level, record.message);
///   // or just print(record);
/// });
/// ...
/// logSubscription.cancel(); // when done
/// ```
///
/// If no listeners are attached to [onRecord] in any isolate, the trace will go
/// to stdout.
class RealmLogger {
  static final _controller = StreamController<LogRecord>.broadcast(
    onListen: () => realmCore.loggerAttach(),
    onCancel: () => realmCore.loggerDetach(),
  );

  const RealmLogger();

  /// Set the log [level] for the given [category].
  ///
  /// If [category] is not provided, the log level will be set [LogCategory.realm].
  void setLogLevel(LogLevel level, {LogCategory? category}) {
    category ??= LogCategory.realm;
    realmCore.setLogLevel(level, category: category);
  }

  /// The stream of log records.
  ///
  /// This is a broadcast stream. It is safe to listen to it multiple times.
  /// If no listeners are attached in any isolate, the trace will go to stdout.
  Stream<LogRecord> get onRecord => _controller.stream;

  void _raise(LogRecord record) {
    _controller.add(record);
  }

  void _log(LogLevel level, Object message, {LogCategory? category}) {
    category ??= LogCategory.realm.sdk;
    realmCore.logMessage(LogCategory.realm.sdk, level, message.toString());
  }
}

extension RealmLoggerInternal on RealmLogger {
  void raise(LogRecord record) => _raise(record);
  void log(LogLevel level, Object message, {LogCategory? category}) => _log(level, message, category: category);
}

extension RealmLogCategoryInternal on LogCategory {
  bool contains(LogCategory category) => _contains(category);
}
