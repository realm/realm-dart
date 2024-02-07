import 'package:realm_common/realm_common.dart';

part 'realm_set.realm.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make;
}

@RealmModel()
class _RealmSets {
  @PrimaryKey()
  late int key;

  late Set<bool> boolSet;
  late Set<bool?> nullableBoolSet;

  late Set<int> intSet;
  late Set<int?> nullableintSet;

  late Set<String> stringSet;
  late Set<String?> nullablestringSet;

  late Set<double> doubleSet;
  late Set<double?> nullabledoubleSet;

  late Set<DateTime> dateTimeSet;
  late Set<DateTime?> nullabledateTimeSet;

  late Set<ObjectId> objectIdSet;
  late Set<ObjectId?> nullableobjectIdSet;

  late Set<Uuid> uuidSet;
  late Set<Uuid?> nullableuuidSet;

  late Set<RealmValue> realmValueSet;
  late Set<_Car> realmObjectsSet;
}
