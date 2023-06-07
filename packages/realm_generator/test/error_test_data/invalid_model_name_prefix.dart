import 'package:realm_common/realm_common.dart';

//part 'invalid_model_name_prefix.realm.dart';

@RealmModel()
class Bad {
  // missing _ or $ prefix
}
