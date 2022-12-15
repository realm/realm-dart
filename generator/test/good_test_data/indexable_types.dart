import 'package:realm_common/realm_common.dart';

// part 'indexable_types.g.dart';

@RealmModel()
class _Indexable {
  @Indexed()
  late bool aBool;
  @Indexed()
  bool? aNullableBool;
  @Indexed()
  late int anInt;
  @Indexed()
  int? aNullableInt;
  @Indexed()
  late String aString;
  @Indexed()
  String? aNullableString;
  @Indexed()
  late ObjectId anObjectId;
  @Indexed()
  ObjectId? aNullableObjectId;
  @Indexed()
  late Uuid anUuid;
  @Indexed()
  Uuid? aNullableUuid;
  @Indexed()
  late DateTime aDateTime;
  @Indexed()
  DateTime? aNullableDateTime;
  @Indexed()
  late RealmValue aRealmValue;
}
