import 'package:ejson/ejson.dart';
import 'package:ejson/src/decoding.dart';
import 'package:ejson_annotation/ejson_annotation.dart';

part 'person.g.dart';

class Person {
  final String name;
  final DateTime birthDate;
  Duration get age => DateTime.now().difference(birthDate);

  final double income;
  final Person? spouse;

  final children = <Person>[];

  @ejson // annotate constructor to generate decoder and encoder
  Person(this.name, this.birthDate, this.income, {this.spouse});

  @override
  operator ==(other) =>
      identical(this, other) || (other is Person && other.name == name && other.birthDate == birthDate && other.income == income && other.spouse == spouse);

  @override
  String toString() => 'Person{name: $name, birthDate: $birthDate, income: $income, spouse: $spouse}';

  @override
  int get hashCode => Object.hashAll([name, birthDate, income, spouse]);
}
