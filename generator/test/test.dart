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

import 'realmobject.dart';

part 'test.g.dart';

class _Car {
  @RealmProperty()
  String make;

  @RealmProperty(type: "string")
  String model;

  @RealmProperty(type: "int", defaultValue: "50", optional: true,)
  String kilometers;

  @RealmProperty(optional: true, defaultValue: "5")
  _Car myCarsLooonName;

  @RealmProperty(type: "Car[]", optional: true)
  @RealmProperty()
  List<_Car> otherCarsMyLongName;

  @RealmProperty(optional: true)
  List<int> myInts;

  @RealmProperty(optional: true)
  List<double> myDoubles;

  @RealmProperty(optional: true)
  List<String> myString;

  @RealmProperty(optional: true)
  List<bool> myBools;
}