import 'package:realm_common/realm_common.dart';

@RealmModel(ObjectType.asymmetricObject)
class _Asymmetric {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
}

@RealmModel()
class _Bad {
  _Asymmetric? asymmetric;
}
