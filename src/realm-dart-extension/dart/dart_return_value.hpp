////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
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
////////////////////////////////////////////////////////////////////////////

#pragma once

#include "dart_types.hpp"

namespace realm {
namespace js {

template<>
class ReturnValue<dartvm::Types> {
	Dart::Env m_env;
	Dart::Value m_value;

  public:
	ReturnValue(Dart::Env env) : m_env(env), m_value(Dart_Null()) {}
	ReturnValue(Dart::Env env, Dart::Value value) : m_env(env), m_value(value) {}

	Dart::Value ToValue() {
		return m_value;
	}

    void set(const Dart::Value &value) {
        m_value = value;
    }

    void set(const std::string &string) {
		m_value = Dart_NewStringFromCString(string.c_str());
    }

    void set(const char *str) {
        if (!str) {
            m_value = Dart_Null();
        }
        else {
			m_value = Dart_NewStringFromCString(str);
        }
    }

    void set(bool boolean) {
		m_value = Dart_NewBoolean(boolean);
    }
    
	void set(double number) {
		m_value = Dart_NewDouble(number);
    }
    
	void set(int32_t number) {
		m_value = Dart_NewInteger(number);
    }
    
	void set(uint32_t number) {
		m_value = Dart_NewInteger(number);
    }

    void set(realm::Mixed mixed) {
		//m_value = Dart::Value(m_env, Value<dartvm::Types>::from_mixed(m_env, mixed));

        throw std::runtime_error("not implemented");
    }

    void set_null() {
        m_value = Dart_Null();
    }


    void set_undefined() {
        m_value = Dart_Null();
    }

    template<typename T>
    void set(util::Optional<T> value) {
        if (value) {
            set(*value);
        }
        else {
			set_undefined();
        }
    }
};
    
} // js
} // realm
