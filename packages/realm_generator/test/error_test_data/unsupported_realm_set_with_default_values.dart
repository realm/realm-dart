import 'package:realm_common/realm_common.dart';

part 'unsupported_realm_set_with_default_values.realm.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  late Set<bool> wrong1 = {true, false};
}
