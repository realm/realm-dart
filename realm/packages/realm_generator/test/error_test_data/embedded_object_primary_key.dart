import 'package:realm_common/realm_common.dart';

part 'embedded_object_primary_key.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class _Bad {
  @PrimaryKey()
  late int id;
}
