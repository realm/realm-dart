part 'test.g.dart';


class RealmProperty {
  final bool primaryKey;
  final String type;
  final String defaultValue;
  final bool optional;
  final String mapTo;
  const RealmProperty({this.type, this.defaultValue, this.optional, this.mapTo, this.primaryKey});
}

class _MyClass123 {
  @RealmProperty(type: "string")
  int myField;
}