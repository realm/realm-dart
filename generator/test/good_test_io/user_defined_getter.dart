import 'package:realm_common/realm_common.dart';
import '../../../lib/realm.dart';

part 'user_defined_getter.g.dart';

@RealmModel()
class _Person {
  late String name;
  String get lastName => name.split(' ').first; // <-- should be ignored by generator
}
