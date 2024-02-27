// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexed_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeWithIndexes(WithIndexes value) {
  return {
    'anInt': value.anInt.toEJson(),
    'aBool': value.aBool.toEJson(),
    'string': value.string.toEJson(),
    'timestamp': value.timestamp.toEJson(),
    'objectId': value.objectId.toEJson(),
    'uuid': value.uuid.toEJson()
  };
}

WithIndexes decodeWithIndexes(EJsonValue ejson) {
  return switch (ejson) {
    {
      'anInt': EJsonValue anInt,
      'aBool': EJsonValue aBool,
      'string': EJsonValue string,
      'timestamp': EJsonValue timestamp,
      'objectId': EJsonValue objectId,
      'uuid': EJsonValue uuid
    } =>
      WithIndexes(fromEJson(anInt), fromEJson(aBool), fromEJson(string),
          fromEJson(timestamp), fromEJson(objectId), fromEJson(uuid)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension WithIndexesEJsonEncoderExtension on WithIndexes {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeWithIndexes(this);
}

EJsonValue encodeNoIndexes(NoIndexes value) {
  return {
    'anInt': value.anInt.toEJson(),
    'aBool': value.aBool.toEJson(),
    'string': value.string.toEJson(),
    'timestamp': value.timestamp.toEJson(),
    'objectId': value.objectId.toEJson(),
    'uuid': value.uuid.toEJson()
  };
}

NoIndexes decodeNoIndexes(EJsonValue ejson) {
  return switch (ejson) {
    {
      'anInt': EJsonValue anInt,
      'aBool': EJsonValue aBool,
      'string': EJsonValue string,
      'timestamp': EJsonValue timestamp,
      'objectId': EJsonValue objectId,
      'uuid': EJsonValue uuid
    } =>
      NoIndexes(fromEJson(anInt), fromEJson(aBool), fromEJson(string),
          fromEJson(timestamp), fromEJson(objectId), fromEJson(uuid)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension NoIndexesEJsonEncoderExtension on NoIndexes {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeNoIndexes(this);
}

EJsonValue encodeObjectWithFTSIndex(ObjectWithFTSIndex value) {
  return {
    'title': value.title.toEJson(),
    'summary': value.summary.toEJson(),
    'nullableSummary': value.nullableSummary.toEJson()
  };
}

ObjectWithFTSIndex decodeObjectWithFTSIndex(EJsonValue ejson) {
  return switch (ejson) {
    {
      'title': EJsonValue title,
      'summary': EJsonValue summary,
      'nullableSummary': EJsonValue nullableSummary
    } =>
      ObjectWithFTSIndex(fromEJson(title), fromEJson(summary),
          nullableSummary: fromEJson(nullableSummary)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension ObjectWithFTSIndexEJsonEncoderExtension on ObjectWithFTSIndex {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeObjectWithFTSIndex(this);
}
