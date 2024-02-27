// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodePersonIntName(PersonIntName value) {
  return {'name': value.name.toEJson()};
}

PersonIntName decodePersonIntName(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name} => PersonIntName(fromEJson(name)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PersonIntNameEJsonEncoderExtension on PersonIntName {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodePersonIntName(this);
}

EJsonValue encodeStudentV1(StudentV1 value) {
  return {
    'name': value.name.toEJson(),
    'yearOfBirth': value.yearOfBirth.toEJson()
  };
}

StudentV1 decodeStudentV1(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name, 'yearOfBirth': EJsonValue yearOfBirth} =>
      StudentV1(fromEJson(name), yearOfBirth: fromEJson(yearOfBirth)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension StudentV1EJsonEncoderExtension on StudentV1 {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeStudentV1(this);
}

EJsonValue encodeMyObjectWithTypo(MyObjectWithTypo value) {
  return {'nmae': value.nmae.toEJson(), 'vlaue': value.vlaue.toEJson()};
}

MyObjectWithTypo decodeMyObjectWithTypo(EJsonValue ejson) {
  return switch (ejson) {
    {'nmae': EJsonValue nmae, 'vlaue': EJsonValue vlaue} =>
      MyObjectWithTypo(fromEJson(nmae), fromEJson(vlaue)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension MyObjectWithTypoEJsonEncoderExtension on MyObjectWithTypo {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeMyObjectWithTypo(this);
}

EJsonValue encodeMyObjectWithoutTypo(MyObjectWithoutTypo value) {
  return {'name': value.name.toEJson(), 'value': value.value.toEJson()};
}

MyObjectWithoutTypo decodeMyObjectWithoutTypo(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name, 'value': EJsonValue value} =>
      MyObjectWithoutTypo(fromEJson(name), fromEJson(value)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension MyObjectWithoutTypoEJsonEncoderExtension on MyObjectWithoutTypo {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeMyObjectWithoutTypo(this);
}

EJsonValue encodeMyObjectWithoutValue(MyObjectWithoutValue value) {
  return {'name': value.name.toEJson()};
}

MyObjectWithoutValue decodeMyObjectWithoutValue(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name} => MyObjectWithoutValue(fromEJson(name)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension MyObjectWithoutValueEJsonEncoderExtension on MyObjectWithoutValue {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeMyObjectWithoutValue(this);
}
