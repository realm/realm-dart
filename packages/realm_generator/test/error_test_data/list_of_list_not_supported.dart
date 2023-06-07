import 'package:realm_common/realm_common.dart';

//part 'list_of_list_not_supported.realm.dart';

@RealmModel()
class _Bad {
  late int x;
  var listOfLists = [
    [0],
    [1]
  ];
}
