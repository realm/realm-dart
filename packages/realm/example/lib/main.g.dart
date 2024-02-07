// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeCar(Car value) {
  return {
    'make': value.make.toEJson(),
    'model': value.model.toEJson(),
    'kilometers': value.kilometers.toEJson(),
    'owner': value.owner.toEJson()
  };
}

Car decodeCar(EJsonValue ejson) {
  return switch (ejson) {
    {
      'make': EJsonValue make,
      'model': EJsonValue model,
      'kilometers': EJsonValue kilometers,
      'owner': EJsonValue owner
    } =>
      Car(make.to<String>(),
          model: model.to<String?>(),
          kilometers: kilometers.to<int?>(),
          owner: owner.to<Person?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension CarEJsonEncoderExtension on Car {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeCar(this);
}

EJsonValue encodePerson(Person value) {
  return {'name': value.name.toEJson(), 'age': value.age.toEJson()};
}

Person decodePerson(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name, 'age': EJsonValue age} =>
      Person(name.to<String>(), age: age.to<int>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PersonEJsonEncoderExtension on Person {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodePerson(this);
}
