import 'package:realm_common/realm_common.dart';
import '../../../lib/realm.dart';

part 'required_arg_with_default_value.g.dart';

@RealmModel()
class _Person {
  int age = 47;
}
