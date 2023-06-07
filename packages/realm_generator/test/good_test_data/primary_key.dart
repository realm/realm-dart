import 'package:realm_common/realm_common.dart';

part 'primary_key.realm.dart';

@RealmModel()
class _IntPK {
  @PrimaryKey()
  late int id;
}

@RealmModel()
class _NullableIntPK {
  @PrimaryKey()
  late int? id;
}

@RealmModel()
class _StringPK {
  @PrimaryKey()
  late String id;
}

@RealmModel()
class _NullableStringPK {
  @PrimaryKey()
  late String? id;
}

@RealmModel()
class _ObjectIdPK {
  @PrimaryKey()
  late ObjectId id;
}

@RealmModel()
class _NullableObjectIdPK {
  @PrimaryKey()
  late ObjectId? id;
}

@RealmModel()
class _UuidPK {
  @PrimaryKey()
  late Uuid id;
}

@RealmModel()
class _NullableUuidPK {
  @PrimaryKey()
  late Uuid? id;
}
