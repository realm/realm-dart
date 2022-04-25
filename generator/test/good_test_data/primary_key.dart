import 'package:realm_common/realm_common.dart';

@RealmModel()
class _IntPK {
  @PrimaryKey()
  late int id;
}

@RealmModel()
class _StringPK {
  @PrimaryKey()
  late String id;
}

@RealmModel()
class _ObjectIdPK {
  @PrimaryKey()
  late ObjectId id;
}

@RealmModel()
class _UuidPK {
  @PrimaryKey()
  late Uuid id;
}
