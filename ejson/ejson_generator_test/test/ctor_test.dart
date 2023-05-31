import 'package:ejson/ejson.dart';
import 'package:test/test.dart';

part 'ctor_test.g.dart';

class Empty {
  @ejson
  const Empty();
}

class Simple {
  final int i;
  @ejson
  const Simple(this.i);
}

class Named {
  String s;
  @ejson
  Named.nameIt(this.s);
}

class RequiredNamedParameters {
  final String s;
  @ejson
  RequiredNamedParameters({required this.s});
}

class OptionalNamedParameters {
  String s;
  @ejson
  OptionalNamedParameters({this.s = 'rabbit'});
}

class OptionalParameters {
  String s;
  @ejson
  OptionalParameters([this.s = 'racoon']);
}

class PrivateMembers {
  final int _id;

  int get id => _id;

  @ejson
  PrivateMembers(int id) : _id = id;
}

void main() {
  customEncoders.addAll({
    Empty: encodeEmpty,
    Simple: encodeSimple,
    Named: encodeNamed,
    RequiredNamedParameters: encodeRequiredNamedParameters,
    OptionalNamedParameters: encodeOptionalNamedParameters,
    OptionalParameters: encodeOptionalParameters,
    PrivateMembers: encodePrivateMembers,
  });

  customDecoders.addAll({
    Empty: decodeEmpty,
    Simple: decodeSimple,
    Named: decodeNamed,
    RequiredNamedParameters: decodeRequiredNamedParameters,
    OptionalNamedParameters: decodeOptionalNamedParameters,
    OptionalParameters: decodeOptionalParameters,
    PrivateMembers: decodePrivateMembers,
  });

  test('@ejson encode', () {
    expect(Empty().toEJson(), {});
    expect(Simple(42).toEJson(), {
      'i': {'\$numberLong': 42}
    });
    expect(Named.nameIt('foobar').toEJson(), {'s': 'foobar'});
    expect(RequiredNamedParameters(s: 'foobar').toEJson(), {'s': 'foobar'});
    expect(OptionalNamedParameters().toEJson(), {'s': 'rabbit'});
    expect(OptionalParameters().toEJson(), {'s': 'racoon'});
    expect(PrivateMembers(42).toEJson(), {
      'id': {'\$numberLong': 42}
    });
  });
}
