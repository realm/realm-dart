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
namespace dartvm {

template<typename MemberType>
class Protected {
protected:
	Dart::Env m_env;
	Dart_PersistentHandle m_ref;
public:
	Protected() : m_env(nullptr), m_ref(nullptr) {}

	Protected(Dart::Env env, MemberType value) : m_env(env) {
		m_ref = Dart_NewPersistentHandle(value);
	}

	Protected(const Protected& other) : m_env(other.m_env), m_ref(other.m_ref) {
		Dart_Handle handle = Dart_HandleFromPersistent(other.m_ref);
		m_ref = Dart_NewPersistentHandle(handle);
	}

	Protected(Protected&& other) : Protected() {
		swap(*this, other);
	}

	friend void swap(Protected& first, Protected& second) {
		std::swap(first.m_env, second.m_env);
		std::swap(first.m_ref, second.m_ref);
	}

	//uses the copy and swap idiom
	Protected& operator=(Protected other) {
		swap(*this, other);
		return *this;
	}

	~Protected() {
		if (m_ref == nullptr) {
			return;
		}

		try {
			Dart_Isolate isolate = Dart_CurrentIsolate();
			//make sure there is current isolate. On Dart VM shutdown there might be no current isolate so just drop the handles
			if (isolate != nullptr) {
				Dart_DeletePersistentHandle(m_ref);
			}
			m_ref = nullptr;
		}
		catch (...) {}
	}

	operator MemberType() const {
		Dart_Handle handle = Dart_HandleFromPersistent(m_ref);
		return handle;
	}

	explicit operator bool() const {
		if (m_ref == nullptr) {
			return false;
		}

		Dart_Handle handle = Dart_HandleFromPersistent(m_ref);
		return handle != nullptr;
	}

	bool operator==(const MemberType &other) const {
		MemberType memberType = *this;
		
	    return memberType == other;
	}

	bool operator!=(const MemberType& other) const {
		MemberType memberType = *this;
		return memberType != other;
	}

	bool operator==(const Protected<MemberType> &other) const {
		MemberType thisValue = *this;
		MemberType otherValue = *other;
		return thisValue == otherValue;
	}

	bool operator!=(const Protected<MemberType> &other) const {
		MemberType thisValue = *this;
		MemberType otherValue = *other;
		return thisValue != otherValue;
	}

	struct Comparator {
	    bool operator()(const Protected<MemberType>& a, const Protected<MemberType>& b) const {
			MemberType aValue = a;
			MemberType bValue = b;
			return aValue == bValue;
	    }
	};
};

} // dartvm

namespace js {

template<>
class Protected<dartvm::Types::GlobalContext> {
	dartvm::Types::GlobalContext m_ctx;
  public:
	Protected(dartvm::Types::GlobalContext ctx) : m_ctx(ctx) {}

	operator Dart::Env() const {
		return m_ctx;
    }

	//bool operator==(const Protected<dartvm::Types::GlobalContext>& other) const {
	//	//GlobalContext always equals Dart::Env
	//	return true;
	//}
};

template<>
class Protected<dartvm::Types::Value> : public dartvm::Protected<Dart::Value> {
  public:
    Protected(Dart::Env env, Dart::Value value) : dartvm::Protected<Dart::Value>(env, value) {}
};

} // js
} // realm
