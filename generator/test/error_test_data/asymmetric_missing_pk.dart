import 'package:realm_common/realm_common.dart';

@RealmModel(ObjectType.asymmetricObject)
class _BadAsymmetric {
  // missing @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
}
