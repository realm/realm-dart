import 'package:realm_common/realm_common.dart';

part 'date_primary_key.realm.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late DateTime id;
}
