import 'package:realm_common/realm_common.dart';
import '../../../lib/realm.dart'; //For partial file references

part 'required_arg_with_default_value.g.dart';

@RealmModel()
class _Person {
  int age = 47;
}
