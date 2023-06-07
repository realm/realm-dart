import 'package:realm_common/realm_common.dart';

part 'repeated_field_annotations.realm.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  @MapTo('key')
  @PrimaryKey()
  late int id;
}
