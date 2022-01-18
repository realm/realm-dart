import 'package:realm_dart/realm.dart';

part 'myapp.g.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late final String make;
}

void main(List<String> arguments) {
  var config = Configuration([Car.schema]);
  var realm = Realm(config);

  realm.write(() {
    print('Creating Realm object of type Car');
    var car = realm.add(Car("Audi"));
    print('The car is ${car.make}');
    
    car.make = "VW";
    print("The car is ${car.make}");
  });

  var objects = realm.all<Car>();
  var indexedCar = objects[0];
  print('The indexedCar is ${indexedCar.make}');

  print("Done");
}
