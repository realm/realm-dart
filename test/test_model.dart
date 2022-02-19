////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

// ignore_for_file: unused_local_variable

import '../lib/realm.dart';

part 'test_model.g.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make;
}

@RealmModel()
class _Person {
  late String name;
}

@RealmModel()
class _Dog {
  @PrimaryKey()
  late String name;

  late int? age;

  _Person? owner;
}

@RealmModel()
class _Team {
  late String name;
  late List<_Person> players;
  late List<int> scores;
}

@RealmModel()
class _Student {
  @PrimaryKey()
  late int number;
  late String? name;
  late int? yearOfBirth;
  late _School? school;
}

@RealmModel()
class _School {
  @PrimaryKey()
  late String name;
  late String? city;
  List<_Student> students = [];
  late _School? branchOfSchool;
  late List<_School> branches;
}
