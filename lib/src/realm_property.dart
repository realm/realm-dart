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

// @dart=2.10

import 'package:meta/meta.dart';

/// A annotation class used to define Realm data model classes and their properties
class RealmProperty {
  
  /// Realm will use this property as the primary key
  final bool primaryKey;
  
  /// The Realm type of this property
  final String type;
  
  /// The default value for this property
  final String defaultValue;
  
  /// `true` if this property is optional
  final bool optional;
  
  /// An alias to another property of the same RealmObject
  final String mapTo;
  
  const RealmProperty({@required this.type, this.defaultValue, this.optional, this.mapTo, this.primaryKey});
}

/// A RealmProperty in a schema. Used for runtime representation of `RealmProperty`
class SchemaProperty extends RealmProperty {
  final String propertyName;
  const SchemaProperty(this.propertyName, { type, defaultValue, optional, mapTo, primaryKey }) 
    : super(type: type, defaultValue: defaultValue, optional: optional, mapTo: mapTo, primaryKey: primaryKey);
}