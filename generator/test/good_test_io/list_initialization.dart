import 'package:realm_common/realm_common.dart';
import '../../../lib/realm.dart'; //For partial file references

part 'list_initialization.g.dart';

@RealmModel()
class _Person {
  late List<_Person> children;
}
