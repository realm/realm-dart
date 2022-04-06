import 'package:realm_common/realm_common.dart';

//part 'nullable_primary_key.g.dart';

@RealmModel()
class _NullableIntPK {
  @PrimaryKey()
  int? id;
}

@RealmModel()
class _NullableStringPK {
  @PrimaryKey()
  String? id;
}
