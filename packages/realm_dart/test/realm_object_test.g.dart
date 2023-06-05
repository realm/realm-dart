// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_object_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeObjectIdPrimaryKey(ObjectIdPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

ObjectIdPrimaryKey decodeObjectIdPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => ObjectIdPrimaryKey(id.to<ObjectId>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension ObjectIdPrimaryKeyEJsonEncoderExtension on ObjectIdPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeObjectIdPrimaryKey(this);
}

EJsonValue encodeNullableObjectIdPrimaryKey(NullableObjectIdPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

NullableObjectIdPrimaryKey decodeNullableObjectIdPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => NullableObjectIdPrimaryKey(id.to<ObjectId?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension NullableObjectIdPrimaryKeyEJsonEncoderExtension
    on NullableObjectIdPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeNullableObjectIdPrimaryKey(this);
}

EJsonValue encodeIntPrimaryKey(IntPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

IntPrimaryKey decodeIntPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => IntPrimaryKey(id.to<int>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension IntPrimaryKeyEJsonEncoderExtension on IntPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeIntPrimaryKey(this);
}

EJsonValue encodeNullableIntPrimaryKey(NullableIntPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

NullableIntPrimaryKey decodeNullableIntPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => NullableIntPrimaryKey(id.to<int?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension NullableIntPrimaryKeyEJsonEncoderExtension on NullableIntPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeNullableIntPrimaryKey(this);
}

EJsonValue encodeStringPrimaryKey(StringPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

StringPrimaryKey decodeStringPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => StringPrimaryKey(id.to<String>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension StringPrimaryKeyEJsonEncoderExtension on StringPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeStringPrimaryKey(this);
}

EJsonValue encodeNullableStringPrimaryKey(NullableStringPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

NullableStringPrimaryKey decodeNullableStringPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => NullableStringPrimaryKey(id.to<String?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension NullableStringPrimaryKeyEJsonEncoderExtension
    on NullableStringPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeNullableStringPrimaryKey(this);
}

EJsonValue encodeUuidPrimaryKey(UuidPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

UuidPrimaryKey decodeUuidPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => UuidPrimaryKey(id.to<Uuid>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension UuidPrimaryKeyEJsonEncoderExtension on UuidPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeUuidPrimaryKey(this);
}

EJsonValue encodeNullableUuidPrimaryKey(NullableUuidPrimaryKey value) {
  return {'id': value.id.toEJson()};
}

NullableUuidPrimaryKey decodeNullableUuidPrimaryKey(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => NullableUuidPrimaryKey(id.to<Uuid?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension NullableUuidPrimaryKeyEJsonEncoderExtension
    on NullableUuidPrimaryKey {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeNullableUuidPrimaryKey(this);
}

EJsonValue encodeRemappedFromAnotherFile(RemappedFromAnotherFile value) {
  return {'linkToAnotherClass': value.linkToAnotherClass.toEJson()};
}

RemappedFromAnotherFile decodeRemappedFromAnotherFile(EJsonValue ejson) {
  return switch (ejson) {
    {'linkToAnotherClass': EJsonValue linkToAnotherClass} =>
      RemappedFromAnotherFile(
          linkToAnotherClass: linkToAnotherClass.to<RemappedClass?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension RemappedFromAnotherFileEJsonEncoderExtension
    on RemappedFromAnotherFile {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeRemappedFromAnotherFile(this);
}

EJsonValue encodeBoolValue(BoolValue value) {
  return {'key': value.key.toEJson(), 'value': value.value.toEJson()};
}

BoolValue decodeBoolValue(EJsonValue ejson) {
  return switch (ejson) {
    {'key': EJsonValue key, 'value': EJsonValue value} =>
      BoolValue(key.to<int>(), value.to<bool>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension BoolValueEJsonEncoderExtension on BoolValue {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeBoolValue(this);
}
