import 'package:realm_common/realm_common.dart';

part 'illigal_constructor.realm.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  _Bad(this.id);
}
