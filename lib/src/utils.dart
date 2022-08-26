////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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

extension IterableEx<T> on Iterable<T> {
  T? get singleOrNull => cast<T?>().singleWhere((_) => true, orElse: () => null);

  T? singleWhereOrNull(bool Function(T) test) => where(test).singleOrNull;

  T? get firstOrNull => cast<T?>().firstWhere((_) => true, orElse: () => null);

  T? firstWhereOrNull(bool Function(T) test) => where(test).firstOrNull;
}
