import 'package:ejson_annotation/ejson_annotation.dart';

// This file is used to test lint rules using
//  dart run custom_lint
// or
//  melos test:lint
class Person {
  final String name;
  // expect_lint: mismatched_getter_type
  final int age;

  @ejson
  // expect_lint: too_many_annotated_constructors
  Person(this.name, {required this.age});

  @ejson
  // expect_lint: too_many_annotated_constructors, mismatched_getter_type
  Person.second(this.name, double age) : age = age.toInt();

  @ejson
  // expect_lint: too_many_annotated_constructors, missing_getter
  Person.third(String navn, int alder) : this(navn, age: alder);
}
