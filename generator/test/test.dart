import 'realmobject.dart';

part 'test.g.dart';

class _Car {
  @RealmProperty()
  String make;

  @RealmProperty(type: "string")
  String model;

  @RealmProperty(type: "int", defaultValue: "50", optional: true,)
  String kilometers;

  @RealmProperty(optional: true, defaultValue: "5")
  _Car myCarsLooonName;

  @RealmProperty(type: "Car[]", optional: true)
  @RealmProperty()
  List<_Car> otherCarsMyLongName;

  @RealmProperty(optional: true)
  List<int> myInts;

  @RealmProperty(optional: true)
  List<double> myDoubles;

  @RealmProperty(optional: true)
  List<String> myString;

  @RealmProperty(optional: true)
  List<bool> myBools;
}