import 'realmobject.dart';

part 'test.generated.dart';

class _Car {
  @RealmProperty(type: "string")
  String name;

  @RealmProperty(type: "Car")
  _Car secondCar;
}

