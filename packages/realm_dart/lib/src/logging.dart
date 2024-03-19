// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:logging/logging.dart';

import 'native/realm_core.dart';

// Using classes to make a fancy hierarchical enum
sealed class RealmLogCategory {
  /// All possible log categories.
  static final values = [
    realm,
    realm.app,
    realm.sdk,
    realm.storage,
    realm.storage.notification,
    realm.storage.object,
    realm.storage.query,
    realm.storage.transaction,
    realm.sync,
    realm.sync.client,
    realm.sync.client.changeset,
    realm.sync.client.network,
    realm.sync.client.reset,
    realm.sync.client.session,
    realm.sync.server,
  ];

  /// The root category for all log messages from the Realm SDK.
  static final realm = _RealmLogCategory();

  final String _name;
  final RealmLogCategory? _parent;

  RealmLogCategory._(this._name, this._parent);

  /// Returns `true` if this category contains the given [category].
  bool contains(RealmLogCategory category) {
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

  static final _map = {for (final category in RealmLogCategory.values) category.toString(): category};

  /// Returns the [RealmLogCategory] for the given [category] string.
  /// Will throw if the category is not recognized.
  factory RealmLogCategory.fromString(String category) => _map[category]!;
}

class _LeafLogCategory extends RealmLogCategory {
  _LeafLogCategory(super.name, RealmLogCategory super.parent) : super._();
}

class _RealmLogCategory extends RealmLogCategory {
  _RealmLogCategory() : super._('Realm', null);

  late final app = _LeafLogCategory('App', this);
  late final sdk = _LeafLogCategory('SDK', this);
  late final storage = _StorageLogCategory(this);
  late final sync = _SyncLogCategory(this);
}

class _SyncLogCategory extends RealmLogCategory {
  _SyncLogCategory(RealmLogCategory parent) : super._('Sync', parent);

  late final client = _ClientLogCategory(this);
  late final server = _LeafLogCategory('Server', this);
}

class _ClientLogCategory extends RealmLogCategory {
  _ClientLogCategory(RealmLogCategory parent) : super._('Client', parent);

  late final changeset = _LeafLogCategory('Changeset', this);
  late final network = _LeafLogCategory('Network', this);
  late final reset = _LeafLogCategory('Reset', this);
  late final session = _LeafLogCategory('Session', this);
}

class _StorageLogCategory extends RealmLogCategory {
  _StorageLogCategory(RealmLogCategory parent) : super._('Storage', parent);

  late final notification = _LeafLogCategory('Notification', this);
  late final object = _LeafLogCategory('Object', this);
  late final query = _LeafLogCategory('Query', this);
  late final transaction = _LeafLogCategory('Transaction', this);
}

/// Specifies the criticality level above which messages will be logged
/// by the default sync client logger.
/// {@category Realm}
enum RealmLogLevel {
  /// Log everything. This will seriously harm the performance of the
  /// sync client and should never be used in production scenarios.
  all(Level.ALL),

  /// A version of [debug] that allows for very high volume output.
  /// This may seriously affect the performance of the sync client.
  trace(Level.FINEST),

  /// Reveal information that can aid debugging, no longer paying
  /// attention to efficiency.
  debug(Level.FINER),

  /// Same as [info], but prioritize completeness over minimalism.
  detail(Level.FINE),

  /// Log operational sync client messages, but in a minimalist fashion to
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
  /// corresponds to this [RealmLogLevel].
  final Level level;

  const RealmLogLevel(this.level);
}

/// A record of a log message from the Realm SDK.
typedef RealmLogRecord = ({RealmLogCategory category, RealmLogLevel level, String message});

/// A logger that logs messages from the Realm SDK.
class RealmLogger {
  static final _controller = StreamController<RealmLogRecord>.broadcast(
    onListen: () => realmCore.loggerAttach(),
    onCancel: () => realmCore.loggerDetach(),
  );

  const RealmLogger();

  /// Set the log [level] for the given [category].
  void setLogLevel(RealmLogLevel level, {RealmLogCategory? category}) {
    category ??= RealmLogCategory.realm;
    realmCore.setLogLevel(level, category: category);
  }

  Stream<RealmLogRecord> get onRecord => _controller.stream;

  void _raise(RealmLogRecord record) {
    _controller.add(record);
  }

  void _log(RealmLogLevel level, Object message, {RealmLogCategory? category}) {
    category ??= RealmLogCategory.realm.sdk;
    realmCore.logMessage(RealmLogCategory.realm.sdk, level, message.toString());
  }
}

extension RealmLoggerInternal on RealmLogger {
  void raise(RealmLogRecord record) => _raise(record);
  void log(RealmLogLevel level, Object message, {RealmLogCategory? category}) => _log(level, message, category: category);
}
