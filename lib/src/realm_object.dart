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
import 'dart:ffi';

import 'package:realm_common/realm_common.dart';

import 'list.dart';
import 'native/realm_core.dart';
import 'realm_class.dart';
import 'type_utils.dart';

typedef DartDynamic = dynamic;

abstract class RealmAccessor implements RealmAccessorMarker {
  @override
  T getValue<T>(covariant RealmObject object, String propertyName);
  @override
  T? getObject<T>(covariant RealmObject object, String propertyName);
  @override
  RealmList<T> getList<T>(covariant RealmObject object, String propertyName);
  @override
  void set<T>(covariant RealmObject object, String propertyName, T value, {bool isDefault = false, bool update = false});
}

class RealmValuesAccessor implements RealmAccessor {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  T getValue<T>(RealmObject object, String propertyName) => _values[propertyName] as T;

  @override
  T? getObject<T>(RealmObject object, String propertyName) => _values[propertyName] as T?;

  @override
  RealmList<T> getList<T>(RealmObject object, String propertyName) => _values[propertyName] as RealmList<T>;

  @override
  void set<T extends Object?>(RealmObject object, String propertyName, T value, {bool isDefault = false, bool update = false}) {
    _values[propertyName] = value;
  }

  void setAll(RealmObject object, RealmCoreAccessor accessor, {bool update = false}) {
    for (final p in object.instanceSchema) {
      var value = _values[p.name];
      final isDefault = value == null;
      value ??= p.defaultValue;
      accessor.set(object, p.name, value, isDefault: isDefault, update: update);
    }
  }
}

class RealmObjectMetadata {
  final int key;
  final SchemaObject schema;
  final Map<String, RealmPropertyMetadata> _byName;
  final Map<int, RealmPropertyMetadata> _byKey;

  RealmObjectMetadata(this.key, this.schema, Iterable<RealmPropertyMetadata> propertyMetadata)
      : _byKey = <int, RealmPropertyMetadata>{for (final m in propertyMetadata) m.key: m},
        _byName = <String, RealmPropertyMetadata>{for (final m in propertyMetadata) m.schema.name: m};

  RealmPropertyMetadata operator [](String propertyName) =>
      _byName[propertyName] ?? (throw RealmException("Property '$propertyName' does not exist on class '${schema.name}'"));

  RealmPropertyMetadata getPropertyMetaByKey(int propertyKey) => _byKey[propertyKey]!;

  String get name => schema.name;
  Type get type => schema.type;
  SchemaProperty? get primaryKey => schema.primaryKey;
}

class RealmPropertyMetadata {
  final int key;
  final SchemaProperty schema;

  const RealmPropertyMetadata(this.key, this.schema);

  String get name => schema.name;
  Type get type => schema.type;
}

class RealmCoreAccessor implements RealmAccessor {
  final RealmObjectMetadata metadata;

  RealmCoreAccessor(this.metadata);

  @override
  T getValue<T>(RealmObject object, String propertyName) {
    final propertyMeta = metadata[propertyName];
    final value = realmCore.getProperty(object, propertyMeta.key);
    return value as T;
  }

  @override
  T? getObject<T>(RealmObject object, String propertyName) {
    final propertyMeta = metadata[propertyName];
    final value = realmCore.getProperty(object, propertyMeta.key);
    if (value is RealmObjectHandle) {
      final realm = object.realm;
      return RealmObjectInternal.create<T>(
        realm,
        value,
        realm.metadata.getLinkMeta<T>(propertyMeta)!,
      );
    }
    return null;
  }

  @override
  RealmList<ElementT> getList<ElementT>(RealmObject object, String propertyName) {
    final propertyMeta = metadata[propertyName];
    final handle = realmCore.getListProperty(object, propertyMeta.key);
    final realm = object.realm;
    return RealmListInternal.create(
      handle,
      realm,
      realm.metadata.getLinkMeta<ElementT>(propertyMeta),
    );
  }

  @override
  void set<T>(RealmObject object, String propertyName, T value, {bool isDefault = false, bool update = false}) {
    final propertyMeta = metadata[propertyName];
    try {
      if (value is RealmList<Object?>) {
        final handle = realmCore.getListProperty(object, propertyMeta.key);
        if (update) realmCore.listClear(handle);
        for (var i = 0; i < value.length; i++) {
          RealmListInternal.setValue(handle, object.realm, i, value[i], update: update);
        }
        return;
      }
      if (value is RealmObject && !value.isManaged) {
        object.realm.add<RealmObject>(value, update: update); // Compiler issue. Why is the explicit type argument needed?
      }
      realmCore.setProperty(object, propertyMeta.key, value, isDefault);
    } on Exception catch (e) {
      throw RealmException("Error setting property ${metadata.type}.$propertyName Error: $e");
    }
  }
}

mixin RealmEntityMixin {
  Realm? _realm;

  /// The [Realm] instance this object belongs to.
  Realm get realm => _realm ?? (throw RealmStateError('$this not managed'));

  /// True if the object belongs to a realm.
  bool get isManaged => _realm != null;
}

extension RealmEntityInternal on RealmEntityMixin {
  void setRealm(Realm value) => _realm = value;
}

/// An object that is persisted in `Realm`.
///
/// `RealmObjects` are generated from Realm data model classes marked with `@RealmModel` annotation and named with an underscore.
///
/// A data model class `_MyClass` will have a `RealmObject` generated with name `MyClass`.
///
/// [RealmObject] should not be used directly as it is part of the generated class hierarchy. ex: `MyClass extends _MyClass with RealmObject`.
/// {@category Realm}
abstract class RealmObject implements RealmObjectMarker {
  /// Get a reference to the static [T.schema] from an instance.
  SchemaObject get instanceSchema;

  /// The [Realm] instance this object belongs to.
  Realm get realm;

  /// True if the object belongs to a realm.
  bool get isManaged;

  /// Gets a value indicating whether this object is managed and represents a row in the database.
  ///
  /// If a managed object has been removed from the [Realm], it is no longer valid and accessing properties on it
  /// will throw an exception.
  /// The Object is not valid if its [Realm] is closed or object is deleted.
  /// Unmanaged objects are always considered valid.
  bool get isValid;

  /// Allows listening for property changes on this Realm object
  ///
  /// Returns a [Stream] of [RealmObjectChanges<T>] that can be listened to.
  ///
  /// If the object is not managed a [RealmStateError] is thrown.
  Stream get changes;

  DynamicRealmObject get dynamic;
}

/// @nodoc
mixin RealmObjectMixin on RealmEntityMixin implements Finalizable, RealmObject {
  RealmObjectHandle? _handle;
  RealmAccessor _accessor = RealmValuesAccessor();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RealmObject) return false;
    if (!isManaged || !other.isManaged) return false;
    return realmCore.objectEquals(this, other);
  }

  @override
  bool get isValid => isManaged ? realmCore.objectIsValid(this) : true;

  @override
  Stream<RealmObjectChanges<RealmObject>> get changes => throw RealmError("Invalid usage. Use the generated inheritors of RealmObject");

  /// @nodoc
  static Stream<RealmObjectChanges<T>> getChanges<T extends RealmObject>(T object) {
    if (!object.isManaged) {
      throw RealmStateError("Object is not managed");
    }

    final controller = RealmObjectNotificationsController<T>(object);
    return controller.createStream();
  }

  // invocation.memberName in noSuchMethod is a Symbol, which hides its _name field. The idiomatic
  // way to obtain it is via Mirrors, which is not available in Flutter. Symbol.toString returns
  // Symbol("name"), so we use a simple regex to extract the symbol name. This is a bit fragile, but
  // is the approach used by the Flutter team as well: https://github.com/dart-lang/sdk/issues/28372.
  // If it turns out not to be reliable, we can instead construct symbols from the property names in
  // the Accessor metadata and compare symbols directly.
  static final RegExp _symbolRegex = RegExp('Symbol\\("(?<symbolName>.*)"\\)');

  @override
  DartDynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final name = _symbolRegex.firstMatch(invocation.memberName.toString())?.namedGroup("symbolName");
      if (name == null) {
        throw RealmError(
            "Could not find symbol name for ${invocation.memberName}. This is likely a bug in the Realm SDK - please file an issue at https://github.com/realm/realm-dart/issues");
      }
      return instanceSchema[name].getValue(this);
    }

    return super.noSuchMethod(invocation);
  }

  late final DynamicRealmObject dynamic = DynamicRealmObject._(this);
}

/// @nodoc
//RealmObject package internal members
extension RealmObjectInternal on RealmObject {
  @pragma('vm:never-inline')
  void keepAlive() {
    realm.keepAlive();
    handle.keepAlive();
  }

  void manage(Realm realm, RealmObjectHandle handle, RealmCoreAccessor accessor, bool update) {
    final self = this as RealmObjectMixin;

    if (self._handle != null) {
      //most certainly a bug hence we throw an Error
      throw ArgumentError("Object is already managed");
    }

    self._handle = handle;
    self._realm = realm;

    final a = self._accessor;
    if (a is RealmValuesAccessor) {
      a.setAll(this, accessor, update: update);
    }

    self._accessor = accessor;
  }

  static T create<T extends Object?>(Realm realm, RealmObjectHandle handle, RealmObjectMetadata metadata) {
    T? object;
    if (isStrictSubtype<T, RealmObjectMixin?>()) {
      final schema = realm.schema.getByType<T>();
      object = schema?.objectFactory();
    } else {
      // dynamic
      object = _ConcreteRealmObject() as T; // compiler needs the cast
    }
    if (object is RealmObjectMixin) {
      object._handle = handle;
      object._accessor = RealmCoreAccessor(metadata);
      object._realm = realm;
      return object;
    }
    throw RealmError('$T is not a RealmObject');
  }

  RealmObjectHandle get handle => (this as RealmObjectMixin)._handle!;
  RealmAccessor get accessor => (this as RealmObjectMixin)._accessor;
}

/// An exception being thrown when a `Realm` operation or [RealmObject] access fails.
/// {@category Realm}
class RealmException implements Exception {
  final String message;

  RealmException(this.message);

  @override
  String toString() {
    return "RealmException: $message";
  }
}

/// Describes the changes in on a single RealmObject since the last time the notification callback was invoked.
class RealmObjectChanges<T extends RealmObject> implements Finalizable {
  // ignore: unused_field
  final RealmObjectChangesHandle _handle;

  /// The realm object being monitored for changes.
  final T object;

  /// `True` if the object was deleted.
  bool get isDeleted => realmCore.getObjectChangesIsDeleted(_handle);

  /// The property names that have changed.
  List<String> get properties {
    final propertyKeys = realmCore.getObjectChangesProperties(_handle);
    return object.realm.getPropertyNames(object.runtimeType, propertyKeys);
  }

  const RealmObjectChanges._(this._handle, this.object);
}

/// @nodoc
extension RealmObjectChangesInternal<T extends RealmObject> on RealmObjectChanges<T> {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }
}

/// @nodoc
class RealmObjectNotificationsController<T extends RealmObject> extends NotificationsController {
  T realmObject;
  late final StreamController<RealmObjectChanges<T>> streamController;

  RealmObjectNotificationsController(this.realmObject);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeObjectNotifications(realmObject, this);
  }

  Stream<RealmObjectChanges<T>> createStream() {
    streamController = StreamController<RealmObjectChanges<T>>(onListen: start, onPause: stop, onResume: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! RealmObjectChangesHandle) {
      throw RealmError("Invalid changes handle. RealmObjectChangesHandle expected");
    }

    final changes = RealmObjectChanges<T>._(changesHandle, realmObject);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}

/// @nodoc
class _ConcreteRealmObject with RealmEntityMixin, RealmObjectMixin {
  @override
  SchemaObject get instanceSchema => (_accessor as RealmCoreAccessor).metadata.schema;
}

/// Exposes a set of dynamic methods on the RealmObject type. These allow you to
/// access properties by name rather than via the strongly typed API.
///
/// {@category Realm}
class DynamicRealmObject {
  final RealmObject _obj;

  DynamicRealmObject._(this._obj);

  /// Gets a property by its name. If a generic type is specified, the property
  /// type will be validated against the type. Otherwise the result will be wrapped
  /// in [Object?].
  T get<T extends Object?>(String propertyName) {
    final property = _obj.instanceSchema[propertyName];
    final result = property.getValue(_obj);
    if (result is T) return result;
    throw RealmException(
        "Property '$propertyName' on class '${_obj.instanceSchema.name}' is not the correct type. Expected '$T', got '${result.runtimeType}'.");
  }
}
