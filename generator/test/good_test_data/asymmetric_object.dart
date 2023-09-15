import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Asymmetric {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late List<_Embedded> children;
  late _Embedded? farther;
  late _Embedded? mother;
}

@RealmModel(ObjectType.embeddedObject)
class _Embedded {
  late String name;
  late int age;
}
