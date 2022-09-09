// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_object_test.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class ObjectIdPrimaryKey extends _ObjectIdPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  ObjectIdPrimaryKey(
    ObjectId id,
  ) {
    _idProperty.setValue(this, id);
  }

  ObjectIdPrimaryKey._();

  static const _idProperty = ValueProperty<ObjectId>(
    'id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId get id => _idProperty.getValue(this);
  @override
  set id(ObjectId value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<ObjectIdPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<ObjectIdPrimaryKey>(
    ObjectType.topLevel,
    ObjectIdPrimaryKey._,
    'ObjectIdPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableObjectIdPrimaryKey extends _NullableObjectIdPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  NullableObjectIdPrimaryKey(
    ObjectId? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableObjectIdPrimaryKey._();

  static const _idProperty = ValueProperty<ObjectId?>(
    'id',
    RealmPropertyType.objectid,
    primaryKey: true,
  );
  @override
  ObjectId? get id => _idProperty.getValue(this);
  @override
  set id(ObjectId? value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<NullableObjectIdPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<NullableObjectIdPrimaryKey>(
    ObjectType.topLevel,
    NullableObjectIdPrimaryKey._,
    'NullableObjectIdPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class IntPrimaryKey extends _IntPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  IntPrimaryKey(
    int id,
  ) {
    _idProperty.setValue(this, id);
  }

  IntPrimaryKey._();

  static const _idProperty = ValueProperty<int>(
    'id',
    RealmPropertyType.int,
    primaryKey: true,
  );
  @override
  int get id => _idProperty.getValue(this);
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<IntPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<IntPrimaryKey>(
    ObjectType.topLevel,
    IntPrimaryKey._,
    'IntPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableIntPrimaryKey extends _NullableIntPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  NullableIntPrimaryKey(
    int? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableIntPrimaryKey._();

  static const _idProperty = ValueProperty<int?>(
    'id',
    RealmPropertyType.int,
    primaryKey: true,
  );
  @override
  int? get id => _idProperty.getValue(this);
  @override
  set id(int? value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<NullableIntPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<NullableIntPrimaryKey>(
    ObjectType.topLevel,
    NullableIntPrimaryKey._,
    'NullableIntPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class StringPrimaryKey extends _StringPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  StringPrimaryKey(
    String id,
  ) {
    _idProperty.setValue(this, id);
  }

  StringPrimaryKey._();

  static const _idProperty = ValueProperty<String>(
    'id',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String get id => _idProperty.getValue(this);
  @override
  set id(String value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<StringPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<StringPrimaryKey>(
    ObjectType.topLevel,
    StringPrimaryKey._,
    'StringPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableStringPrimaryKey extends _NullableStringPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  NullableStringPrimaryKey(
    String? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableStringPrimaryKey._();

  static const _idProperty = ValueProperty<String?>(
    'id',
    RealmPropertyType.string,
    primaryKey: true,
  );
  @override
  String? get id => _idProperty.getValue(this);
  @override
  set id(String? value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<NullableStringPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<NullableStringPrimaryKey>(
    ObjectType.topLevel,
    NullableStringPrimaryKey._,
    'NullableStringPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class UuidPrimaryKey extends _UuidPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  UuidPrimaryKey(
    Uuid id,
  ) {
    _idProperty.setValue(this, id);
  }

  UuidPrimaryKey._();

  static const _idProperty = ValueProperty<Uuid>(
    'id',
    RealmPropertyType.uuid,
    primaryKey: true,
  );
  @override
  Uuid get id => _idProperty.getValue(this);
  @override
  set id(Uuid value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<UuidPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<UuidPrimaryKey>(
    ObjectType.topLevel,
    UuidPrimaryKey._,
    'UuidPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class NullableUuidPrimaryKey extends _NullableUuidPrimaryKey
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  NullableUuidPrimaryKey(
    Uuid? id,
  ) {
    _idProperty.setValue(this, id);
  }

  NullableUuidPrimaryKey._();

  static const _idProperty = ValueProperty<Uuid?>(
    'id',
    RealmPropertyType.uuid,
    primaryKey: true,
  );
  @override
  Uuid? get id => _idProperty.getValue(this);
  @override
  set id(Uuid? value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<NullableUuidPrimaryKey>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<NullableUuidPrimaryKey>(
    ObjectType.topLevel,
    NullableUuidPrimaryKey._,
    'NullableUuidPrimaryKey',
    {
      'id': _idProperty,
    },
    _idProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class RemappedFromAnotherFile extends _RemappedFromAnotherFile
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  RemappedFromAnotherFile({
    RemappedClass? linkToAnotherClass,
  }) {
    _linkToAnotherClassProperty.setValue(this, linkToAnotherClass);
  }

  RemappedFromAnotherFile._();

  static const _linkToAnotherClassProperty =
      ObjectProperty<RemappedClass>('property with spaces', 'myRemappedClass');
  @override
  RemappedClass? get linkToAnotherClass =>
      _linkToAnotherClassProperty.getValue(this);
  @override
  set linkToAnotherClass(covariant RemappedClass? value) =>
      _linkToAnotherClassProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<RemappedFromAnotherFile>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<RemappedFromAnotherFile>(
    ObjectType.topLevel,
    RemappedFromAnotherFile._,
    'class with spaces',
    {
      'property with spaces': _linkToAnotherClassProperty,
    },
  );
  @override
  SchemaObject get instanceSchema => schema;
}

class BoolValue extends _BoolValue
    with RealmEntityMixin, RealmObjectBaseMixin, RealmObjectMixin {
  BoolValue(
    int key,
    bool value,
  ) {
    _keyProperty.setValue(this, key);
    _valueProperty.setValue(this, value);
  }

  BoolValue._();

  static const _keyProperty = ValueProperty<int>(
    'key',
    RealmPropertyType.int,
    primaryKey: true,
  );
  @override
  int get key => _keyProperty.getValue(this);
  @override
  set key(int value) => throw RealmUnsupportedSetError();

  static const _valueProperty = ValueProperty<bool>(
    'value',
    RealmPropertyType.bool,
  );
  @override
  bool get value => _valueProperty.getValue(this);
  @override
  set value(bool value) => _valueProperty.setValue(this, value);

  @override
  Stream<RealmObjectChanges<BoolValue>> get changes =>
      RealmObjectBaseMixin.getChanges(this);

  static const schema = SchemaObject<BoolValue>(
    ObjectType.topLevel,
    BoolValue._,
    'BoolValue',
    {
      'key': _keyProperty,
      'value': _valueProperty,
    },
    _keyProperty,
  );
  @override
  SchemaObject get instanceSchema => schema;
}
