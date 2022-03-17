import 'package:realm_common/realm_common.dart';
import '../../../lib/realm.dart';

part 'optional_argument.g.dart';

@RealmModel()
class _Person {
  _Person? spouse;
}
