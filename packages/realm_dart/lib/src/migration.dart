// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'native/schema_handle.dart';
import 'realm_class.dart';
import 'realm_object.dart';

/// A [Migration] object is passed to you when you migrate your database from one version
/// to another. It contains the properties for the Realm before and after the migration.
/// After the migration is complete, [newRealm] will become the authoritative version of
/// the file.
///
/// {@category Realm}
class Migration {
  final SchemaHandle _schema;

  /// The Realm as it existed just before the migration. Since the models have changed,
  /// this Realm can only be accessed via the dynamic API.
  final MigrationRealm oldRealm;

  /// The Realm as it exists after the migration. Before the end of the callback, you need
  /// to make sure that all relevant data has been migrated from [oldRealm] into [newRealm].
  final Realm newRealm;

  Migration._(this.oldRealm, this.newRealm, this._schema);

  /// Finds an object obtained from [oldRealm] in [newRealm]. This is useful when you
  /// are working with objects without primary keys and want to update some information
  /// about the object as part of the migration.
  T? findInNewRealm<T extends RealmObject>(RealmObject oldObject) {
    if (!oldObject.isManaged) {
      throw UnsupportedError('Only managed RealmObject instances can be looked up in the new Realm');
    }

    final metadata = newRealm.metadata.getByType(T);
    final handle = newRealm.handle.findExisting(metadata.classKey, oldObject.handle);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata, true);
    var object = RealmObjectInternal.create(T, newRealm, handle, accessor);
    return object as T;
  }

  /// Renames a property during a migration.
  void renameProperty(String className, String oldPropertyName, String newPropertyName) {
    newRealm.handle.renameProperty(className, oldPropertyName, newPropertyName, _schema);
  }

  /// Deletes a type during a migration. All the data associated with the type, as well as its schema,
  /// will be deleted from the Realm.
  ///
  /// If you don't call this, the data will not be deleted, even if the type is not present in the new schema.
  ///
  /// Returns `true` if the table was present in the old Realm and was deleted. Returns `false` if it didn't exist.
  bool deleteType(String className) {
    return newRealm.handle.deleteType(className);
  }
}

/// @nodoc
extension MigrationInternal on Migration {
  static Migration create(MigrationRealm oldRealm, Realm newRealm, SchemaHandle schema) {
    return Migration._(oldRealm, newRealm, schema);
  }
}
