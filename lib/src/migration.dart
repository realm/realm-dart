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

class Migration {
  final SchemaHandle _schema;
  final Realm oldRealm;
  final Realm newRealm;

  Migration._(this.oldRealm, this.newRealm, this._schema);

  T? findInNewRealm<T extends RealmObject>(RealmObject oldObject) {
    if (!oldObject.isManaged) {
      throw UnsupportedError('Only managed RealmObject instances can be looked up in the new Realm');
    }

    final metadata = newRealm.metadata.getByType(T);
    final handle = realmCore.findExisting(newRealm, metadata.classKey, oldObject.handle);
    if (handle == null) {
      return null;
    }

    final accessor = RealmCoreAccessor(metadata, true);
    var object = RealmObjectInternal.create(T, newRealm, handle, accessor);
    return object as T;
  }

  void renameProperty(String className, String oldPropertyName, String newPropertyName) {
    realmCore.renameProperty(newRealm, className, oldPropertyName, newPropertyName, _schema);
  }

  void removeType(String className) {
    realmCore.removeType(newRealm, className);
  }
}

/// @nodoc
extension MigrationInternal on Migration {
  static Migration create(Realm oldRealm, Realm newRealm, SchemaHandle schema) {
    return Migration._(oldRealm, newRealm, schema);
  }
}
