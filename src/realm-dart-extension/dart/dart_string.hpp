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

#pragma once

#include "dart_types.hpp"

namespace realm {
namespace js {

template<>
class String<dartvm::Types> {
    std::string m_str;

  public:
    String(const char* s) : m_str(s) {}
    String(const std::string& s) : m_str(s) {}
    String(const Dart::String& s);
    String(Dart::String&& s) : String(s) {}

    operator std::string() const& {
        return m_str;
    }

    operator std::string() && {
        return std::move(m_str);
    }

    Dart::String ToString(Dart::Env env) {
        return Dart_NewStringFromCString(m_str.c_str());
    }
};

inline String<dartvm::Types>::String(const Dart::String& s) {
	//m_str = s.Utf8Value();
    const char* str;
    Dart_StringToCString(s, &str);
    m_str = std::string(str);
}

} // js
} // realm
