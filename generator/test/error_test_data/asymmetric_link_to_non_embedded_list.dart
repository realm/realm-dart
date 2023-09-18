import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Symmetric {}

@RealmModel(ObjectType.asymmetricObject)
class _Asymmetric {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late List<_Symmetric> illegal;
}
