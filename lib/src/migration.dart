////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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

import 'realm_class.dart';
import 'native/realm_core.dart';
import './realm_object.dart';

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
    final handle = realmCore.findExisting(newRealm, metadata.key, oldObject.handle);
    if (handle == null) {
      return null;
    }

    return RealmObjectInternal.create<T>(newRealm, handle, metadata, true);
  }

  /// Renames a property during a migration.
  void renameProperty(String className, String oldPropertyName, String newPropertyName) {
    realmCore.renameProperty(newRealm, className, oldPropertyName, newPropertyName, _schema);
  }

  /// Deletes a type during a migration. All the data associated with the type, as well as its schema,
  /// will be deleted from the Realm.
  ///
  /// If you don't call this, the data will not be deleted, even if the type is not present in the new schema.
  ///
  /// Returns `true` if the table was present in the old Realm and was deleted. Returns `false` if it didn't exist.
  bool deleteType(String className) {
    return realmCore.deleteType(newRealm, className);
  }
}

/// @nodoc
extension MigrationInternal on Migration {
  static Migration create(MigrationRealm oldRealm, Realm newRealm, SchemaHandle schema) {
    return Migration._(oldRealm, newRealm, schema);
  }
}
