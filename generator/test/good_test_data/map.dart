import 'dart:typed_data';

import 'package:realm_common/realm_common.dart';

//part 'map.g.dart';

@RealmModel()
class _LotsOfMaps {
  late Map<String, _Person?> persons;
  late Map<String, bool> bools;
  late Map<String, DateTime> dateTimes;
  late Map<String, Decimal128> decimals;
  late Map<String, double> doubles;
  late Map<String, int> ints;
  late Map<String, ObjectId> objectIds;
  late Map<String, RealmValue> any;
  late Map<String, String> strings;
  late Map<String, Uint8List> binary;
  late Map<String, Uuid> uuids;
}

@RealmModel()
class _Person {
  late String name;
}
