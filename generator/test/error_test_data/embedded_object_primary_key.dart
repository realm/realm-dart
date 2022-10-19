import 'package:realm_common/realm_common.dart';

//part 'embedded_object_primary_key.g.dart';

@RealmModel(RealmModelType.embedded)
class _Bad {
  @PrimaryKey()
  late int id;
}