////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

#ifndef REALM_DART_DECIMAL128_H
#define REALM_DART_DECIMAL128_H

#include <realm.h>

RLM_API realm_decimal128_t realm_dart_decimal128_from_string(const char* string);
RLM_API realm_string_t realm_dart_decimal128_to_string(realm_decimal128_t x);

RLM_API realm_decimal128_t realm_dart_decimal128_nan();
RLM_API bool realm_dart_decimal128_is_nan(realm_decimal128_t x);
RLM_API realm_decimal128_t realm_dart_decimal128_from_int64(int64_t low);
RLM_API int64_t realm_dart_decimal128_to_int64(realm_decimal128_t x);
RLM_API realm_decimal128_t realm_dart_decimal128_negate(realm_decimal128_t x);
RLM_API realm_decimal128_t realm_dart_decimal128_add(realm_decimal128_t x, realm_decimal128_t y);
RLM_API realm_decimal128_t realm_dart_decimal128_subtract(realm_decimal128_t x, realm_decimal128_t y);
RLM_API realm_decimal128_t realm_dart_decimal128_multiply(realm_decimal128_t x, realm_decimal128_t y);
RLM_API realm_decimal128_t realm_dart_decimal128_divide(realm_decimal128_t x, realm_decimal128_t y);
RLM_API bool realm_dart_decimal128_equal(realm_decimal128_t x, realm_decimal128_t y);
RLM_API bool realm_dart_decimal128_less_than(realm_decimal128_t x, realm_decimal128_t y);
RLM_API bool realm_dart_decimal128_greater_than(realm_decimal128_t x, realm_decimal128_t y);
RLM_API int realm_dart_decimal128_compare_to(realm_decimal128_t x, realm_decimal128_t y);

// work-around for Dart FFI issue
RLM_API realm_decimal128_t realm_dart_decimal128_copy(realm_decimal128_t x);

#endif // REALM_DART_DECIMAL128_H