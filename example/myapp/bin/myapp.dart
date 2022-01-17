import 'package:realm_dart/realm.dart';

part 'myapp.g.dart';
/*
class _Car {
  @RealmProperty()
  late String make;
}

class _Person {
  @RealmProperty()
  late String name; 
}

void main(List<String> arguments) {
  var config = Configuration();
  config.schema.add(Car);

  var realm = new Realm(config);

  realm.write(() {
    print('Creating Realm object of type Car');
    var car = realm.create(new Car()..make = "Audi");
    print('The car is ${car.make}');
    
    car.make = "VW";
    print("The car is ${car.make}");
  });

  var objects = realm.objects<Car>();
  var indexedCar = objects[0];
  print('The indexedCar is ${indexedCar.make}');

  print("Done");
}
*/