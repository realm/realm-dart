import 'package:realm_common/realm_common.dart';

part 'realm_object_reference_default_values.realm.dart';

@RealmModel()
class _Person {
  int x = 0;
  late _Person? parent = Person();
}

class Person extends _Person {} // mock class for testing
