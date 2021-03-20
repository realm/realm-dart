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

import 'dart:core';

class Helpers {
  static DateTime createDateTime(int miliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(miliseconds, isUtc: true);
  }

  static dynamic invokeStatic(Type type, String name) native "Helpers_invokeStatic";
}

extension SymbolHelper on Symbol {
   String get name {
      String name = this.toString();
      name = name.substring(8, name.length - 2);
      return name;
   }
} 
