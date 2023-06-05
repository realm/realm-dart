// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_set_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeCar(Car value) {
  return {'make': value.make.toEJson(), 'color': value.color.toEJson()};
}

Car decodeCar(EJsonValue ejson) {
  return switch (ejson) {
    {'make': EJsonValue make, 'color': EJsonValue color} =>
      Car(make.to<String>(), color: color.to<String?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension CarEJsonEncoderExtension on Car {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeCar(this);
}

EJsonValue encodeTestRealmSets(TestRealmSets value) {
  return {
    'key': value.key.toEJson(),
    'boolSet': value.boolSet.toEJson(),
    'intSet': value.intSet.toEJson(),
    'stringSet': value.stringSet.toEJson(),
    'doubleSet': value.doubleSet.toEJson(),
    'dateTimeSet': value.dateTimeSet.toEJson(),
    'objectIdSet': value.objectIdSet.toEJson(),
    'uuidSet': value.uuidSet.toEJson(),
    'mixedSet': value.mixedSet.toEJson(),
    'objectsSet': value.objectsSet.toEJson(),
    'binarySet': value.binarySet.toEJson(),
    'nullableBoolSet': value.nullableBoolSet.toEJson(),
    'nullableIntSet': value.nullableIntSet.toEJson(),
    'nullableStringSet': value.nullableStringSet.toEJson(),
    'nullableDoubleSet': value.nullableDoubleSet.toEJson(),
    'nullableDateTimeSet': value.nullableDateTimeSet.toEJson(),
    'nullableObjectIdSet': value.nullableObjectIdSet.toEJson(),
    'nullableUuidSet': value.nullableUuidSet.toEJson(),
    'nullableBinarySet': value.nullableBinarySet.toEJson()
  };
}

TestRealmSets decodeTestRealmSets(EJsonValue ejson) {
  return switch (ejson) {
    {
      'key': EJsonValue key,
      'boolSet': EJsonValue boolSet,
      'intSet': EJsonValue intSet,
      'stringSet': EJsonValue stringSet,
      'doubleSet': EJsonValue doubleSet,
      'dateTimeSet': EJsonValue dateTimeSet,
      'objectIdSet': EJsonValue objectIdSet,
      'uuidSet': EJsonValue uuidSet,
      'mixedSet': EJsonValue mixedSet,
      'objectsSet': EJsonValue objectsSet,
      'binarySet': EJsonValue binarySet,
      'nullableBoolSet': EJsonValue nullableBoolSet,
      'nullableIntSet': EJsonValue nullableIntSet,
      'nullableStringSet': EJsonValue nullableStringSet,
      'nullableDoubleSet': EJsonValue nullableDoubleSet,
      'nullableDateTimeSet': EJsonValue nullableDateTimeSet,
      'nullableObjectIdSet': EJsonValue nullableObjectIdSet,
      'nullableUuidSet': EJsonValue nullableUuidSet,
      'nullableBinarySet': EJsonValue nullableBinarySet
    } =>
      TestRealmSets(key.to<int>(),
          boolSet: boolSet.to<Set<bool>>(),
          intSet: intSet.to<Set<int>>(),
          stringSet: stringSet.to<Set<String>>(),
          doubleSet: doubleSet.to<Set<double>>(),
          dateTimeSet: dateTimeSet.to<Set<DateTime>>(),
          objectIdSet: objectIdSet.to<Set<ObjectId>>(),
          uuidSet: uuidSet.to<Set<Uuid>>(),
          mixedSet: mixedSet.to<Set<RealmValue>>(),
          objectsSet: objectsSet.to<Set<Car>>(),
          binarySet: binarySet.to<Set<Uint8List>>(),
          nullableBoolSet: nullableBoolSet.to<Set<bool?>>(),
          nullableIntSet: nullableIntSet.to<Set<int?>>(),
          nullableStringSet: nullableStringSet.to<Set<String?>>(),
          nullableDoubleSet: nullableDoubleSet.to<Set<double?>>(),
          nullableDateTimeSet: nullableDateTimeSet.to<Set<DateTime?>>(),
          nullableObjectIdSet: nullableObjectIdSet.to<Set<ObjectId?>>(),
          nullableUuidSet: nullableUuidSet.to<Set<Uuid?>>(),
          nullableBinarySet: nullableBinarySet.to<Set<Uint8List?>>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TestRealmSetsEJsonEncoderExtension on TestRealmSets {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTestRealmSets(this);
}
