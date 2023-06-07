import 'package:realm_common/realm_common.dart';

part 'unsupported_realm_set_of_nullable_realmvalue.realm.dart';

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  late Set<RealmValue?> wrong1;
}
