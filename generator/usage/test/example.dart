part 'example.g.dart';

class RealmProperty {
  final bool primaryKey;
  final String type;
  final String defaultValue;
  final bool optional;
  final String mapTo;
  const RealmProperty({this.type, this.defaultValue, this.optional, this.mapTo, this.primaryKey});
}

class _Car {
  @RealmProperty()
  String make;

  @RealmProperty(type: "string")
  String model;

  @RealmProperty(defaultValue: "50", optional: true)
  String kilometers;

  @RealmProperty(optional: true, defaultValue: "5")
  _Car secondCar;

  @RealmProperty(optional: true)
  List<_Car> allOtherCars;
}