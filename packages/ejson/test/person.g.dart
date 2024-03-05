// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue _encodePerson(Person value) {
  return {
    'name': value.name.toEJson(),
    'birthDate': value.birthDate.toEJson(),
    'income': value.income.toEJson(),
    'spouse': value.spouse.toEJson()
  };
}

Person _decodePerson(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'birthDate': EJsonValue birthDate,
      'income': EJsonValue income,
      'spouse': EJsonValue spouse
    } =>
      Person(fromEJson(name), fromEJson(birthDate), fromEJson(income),
          spouse: fromEJson(spouse)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PersonEJsonEncoderExtension on Person {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodePerson(this);
}

void registerPerson() => register(_encodePerson, _decodePerson);
