// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_map_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeCar(Car value) {
  return {'make': value.make.toEJson(), 'color': value.color.toEJson()};
}

Car decodeCar(EJsonValue ejson) {
  return switch (ejson) {
    {'make': EJsonValue make, 'color': EJsonValue color} =>
      Car(fromEJson(make), color: fromEJson(color)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension CarEJsonEncoderExtension on Car {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeCar(this);
}

EJsonValue encodeEmbeddedValue(EmbeddedValue value) {
  return {'intValue': value.intValue.toEJson()};
}

EmbeddedValue decodeEmbeddedValue(EJsonValue ejson) {
  return switch (ejson) {
    {'intValue': EJsonValue intValue} => EmbeddedValue(fromEJson(intValue)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension EmbeddedValueEJsonEncoderExtension on EmbeddedValue {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeEmbeddedValue(this);
}

EJsonValue encodeTestRealmMaps(TestRealmMaps value) {
  return {
    'key': value.key.toEJson(),
    'boolMap': value.boolMap.toEJson(),
    'intMap': value.intMap.toEJson(),
    'stringMap': value.stringMap.toEJson(),
    'doubleMap': value.doubleMap.toEJson(),
    'dateTimeMap': value.dateTimeMap.toEJson(),
    'objectIdMap': value.objectIdMap.toEJson(),
    'uuidMap': value.uuidMap.toEJson(),
    'binaryMap': value.binaryMap.toEJson(),
    'decimalMap': value.decimalMap.toEJson(),
    'nullableBoolMap': value.nullableBoolMap.toEJson(),
    'nullableIntMap': value.nullableIntMap.toEJson(),
    'nullableStringMap': value.nullableStringMap.toEJson(),
    'nullableDoubleMap': value.nullableDoubleMap.toEJson(),
    'nullableDateTimeMap': value.nullableDateTimeMap.toEJson(),
    'nullableObjectIdMap': value.nullableObjectIdMap.toEJson(),
    'nullableUuidMap': value.nullableUuidMap.toEJson(),
    'nullableBinaryMap': value.nullableBinaryMap.toEJson(),
    'nullableDecimalMap': value.nullableDecimalMap.toEJson(),
    'objectsMap': value.objectsMap.toEJson(),
    'embeddedMap': value.embeddedMap.toEJson(),
    'mixedMap': value.mixedMap.toEJson()
  };
}

TestRealmMaps decodeTestRealmMaps(EJsonValue ejson) {
  return switch (ejson) {
    {
      'key': EJsonValue key,
      'boolMap': EJsonValue boolMap,
      'intMap': EJsonValue intMap,
      'stringMap': EJsonValue stringMap,
      'doubleMap': EJsonValue doubleMap,
      'dateTimeMap': EJsonValue dateTimeMap,
      'objectIdMap': EJsonValue objectIdMap,
      'uuidMap': EJsonValue uuidMap,
      'binaryMap': EJsonValue binaryMap,
      'decimalMap': EJsonValue decimalMap,
      'nullableBoolMap': EJsonValue nullableBoolMap,
      'nullableIntMap': EJsonValue nullableIntMap,
      'nullableStringMap': EJsonValue nullableStringMap,
      'nullableDoubleMap': EJsonValue nullableDoubleMap,
      'nullableDateTimeMap': EJsonValue nullableDateTimeMap,
      'nullableObjectIdMap': EJsonValue nullableObjectIdMap,
      'nullableUuidMap': EJsonValue nullableUuidMap,
      'nullableBinaryMap': EJsonValue nullableBinaryMap,
      'nullableDecimalMap': EJsonValue nullableDecimalMap,
      'objectsMap': EJsonValue objectsMap,
      'embeddedMap': EJsonValue embeddedMap,
      'mixedMap': EJsonValue mixedMap
    } =>
      TestRealmMaps(fromEJson(key),
          boolMap: fromEJson(boolMap),
          intMap: fromEJson(intMap),
          stringMap: fromEJson(stringMap),
          doubleMap: fromEJson(doubleMap),
          dateTimeMap: fromEJson(dateTimeMap),
          objectIdMap: fromEJson(objectIdMap),
          uuidMap: fromEJson(uuidMap),
          binaryMap: fromEJson(binaryMap),
          decimalMap: fromEJson(decimalMap),
          nullableBoolMap: fromEJson(nullableBoolMap),
          nullableIntMap: fromEJson(nullableIntMap),
          nullableStringMap: fromEJson(nullableStringMap),
          nullableDoubleMap: fromEJson(nullableDoubleMap),
          nullableDateTimeMap: fromEJson(nullableDateTimeMap),
          nullableObjectIdMap: fromEJson(nullableObjectIdMap),
          nullableUuidMap: fromEJson(nullableUuidMap),
          nullableBinaryMap: fromEJson(nullableBinaryMap),
          nullableDecimalMap: fromEJson(nullableDecimalMap),
          objectsMap: fromEJson(objectsMap),
          embeddedMap: fromEJson(embeddedMap),
          mixedMap: fromEJson(mixedMap)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TestRealmMapsEJsonEncoderExtension on TestRealmMaps {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTestRealmMaps(this);
}
