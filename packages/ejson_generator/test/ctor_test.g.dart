// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ctor_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue _encodeEmpty(Empty value) {
  return {};
}

Empty _decodeEmpty(EJsonValue ejson) {
  return switch (ejson) {
    Map m when m.isEmpty => Empty(),
    _ => raiseInvalidEJson(ejson),
  };
}

extension EmptyEJsonEncoderExtension on Empty {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeEmpty(this);
}

void registerEmpty() => register(_encodeEmpty, _decodeEmpty);

EJsonValue _encodeSimple(Simple value) {
  return {'i': value.i.toEJson()};
}

Simple _decodeSimple(EJsonValue ejson) {
  return switch (ejson) {
    {'i': EJsonValue i} => Simple(fromEJson(i)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension SimpleEJsonEncoderExtension on Simple {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeSimple(this);
}

void registerSimple() => register(_encodeSimple, _decodeSimple);

EJsonValue _encodeNamed(Named value) {
  return {'namedCtor': value.namedCtor.toEJson()};
}

Named _decodeNamed(EJsonValue ejson) {
  return switch (ejson) {
    {'namedCtor': EJsonValue namedCtor} => Named.nameIt(fromEJson(namedCtor)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension NamedEJsonEncoderExtension on Named {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeNamed(this);
}

void registerNamed() => register(_encodeNamed, _decodeNamed);

EJsonValue _encodeRequiredNamedParameters(RequiredNamedParameters value) {
  return {'requiredNamed': value.requiredNamed.toEJson()};
}

RequiredNamedParameters _decodeRequiredNamedParameters(EJsonValue ejson) {
  return switch (ejson) {
    {'requiredNamed': EJsonValue requiredNamed} =>
      RequiredNamedParameters(requiredNamed: fromEJson(requiredNamed)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension RequiredNamedParametersEJsonEncoderExtension
    on RequiredNamedParameters {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeRequiredNamedParameters(this);
}

void registerRequiredNamedParameters() =>
    register(_encodeRequiredNamedParameters, _decodeRequiredNamedParameters);

EJsonValue _encodeOptionalNamedParameters(OptionalNamedParameters value) {
  return {'optionalNamed': value.optionalNamed.toEJson()};
}

OptionalNamedParameters _decodeOptionalNamedParameters(EJsonValue ejson) {
  return switch (ejson) {
    {'optionalNamed': EJsonValue optionalNamed} =>
      OptionalNamedParameters(optionalNamed: fromEJson(optionalNamed)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension OptionalNamedParametersEJsonEncoderExtension
    on OptionalNamedParameters {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeOptionalNamedParameters(this);
}

void registerOptionalNamedParameters() =>
    register(_encodeOptionalNamedParameters, _decodeOptionalNamedParameters);

EJsonValue _encodeOptionalParameters(OptionalParameters value) {
  return {'optional': value.optional.toEJson()};
}

OptionalParameters _decodeOptionalParameters(EJsonValue ejson) {
  return switch (ejson) {
    {'optional': EJsonValue optional} =>
      OptionalParameters(fromEJson(optional)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension OptionalParametersEJsonEncoderExtension on OptionalParameters {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodeOptionalParameters(this);
}

void registerOptionalParameters() =>
    register(_encodeOptionalParameters, _decodeOptionalParameters);

EJsonValue _encodePrivateMembers(PrivateMembers value) {
  return {'id': value.id.toEJson()};
}

PrivateMembers _decodePrivateMembers(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => PrivateMembers(fromEJson(id)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PrivateMembersEJsonEncoderExtension on PrivateMembers {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodePrivateMembers(this);
}

void registerPrivateMembers() =>
    register(_encodePrivateMembers, _decodePrivateMembers);

EJsonValue _encodePerson(Person value) {
  return {
    'name': value.name.toEJson(),
    'birthDate': value.birthDate.toEJson(),
    'income': value.income.toEJson(),
    'spouse': value.spouse.toEJson(),
    'cprNumber': value.cprNumber.toEJson()
  };
}

Person _decodePerson(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'birthDate': EJsonValue birthDate,
      'income': EJsonValue income,
      'spouse': EJsonValue spouse,
      'cprNumber': EJsonValue cprNumber
    } =>
      Person(fromEJson(name), fromEJson(birthDate), fromEJson(income),
          spouse: fromEJson(spouse), cprNumber: fromEJson(cprNumber)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PersonEJsonEncoderExtension on Person {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => _encodePerson(this);
}

void registerPerson() => register(_encodePerson, _decodePerson);
