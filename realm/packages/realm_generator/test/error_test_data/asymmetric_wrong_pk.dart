import 'package:realm_common/realm_common.dart';

@RealmModel(ObjectType.asymmetricObject)
class _BadAsymmetric {
  @PrimaryKey()
  late ObjectId wrongName;
}
