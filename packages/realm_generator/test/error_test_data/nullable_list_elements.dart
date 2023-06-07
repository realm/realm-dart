import 'package:realm_common/realm_common.dart';

//part 'nullable_list_elements.realm.dart';

@RealmModel()
class _Other {}

@RealmModel()
class _Bad {
  @PrimaryKey()
  late int id;

  late List<int?> okay;
  late List<_Other?> wrong;
}
