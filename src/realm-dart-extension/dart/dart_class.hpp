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


#include <ctype.h>
#include <unordered_set>
#include <vector>
#include <functional>
#include <string>
#include <unordered_map>
#include <exception>

#include "js_class.hpp"
#include "js_util.hpp"

#include "dart_types.hpp"

//forward declare the types for gcc to compile correctly
namespace realm {
	namespace js {
		template<typename T>
		struct RealmObjectClass;
	}
	namespace dartvm {
		struct Types;
	}
}

namespace realm {
namespace dartvm {

template<typename T>
using ClassDefinition = js::ClassDefinition<Types, T>;

using ConstructorType = js::ConstructorType<Types>;
using ArgumentsMethodType = js::ArgumentsMethodType<Types>;
using Arguments = js::Arguments<Types>;
using PropertyType = js::PropertyType<Types>;
using IndexPropertyType = js::IndexPropertyType<Types>;
using StringPropertyType = js::StringPropertyType<Types>;

template<typename ClassType>
class WrappedObject;

template<typename ClassType>
class WrappedObject {
	using Internal = typename ClassType::Internal;
public:
	WrappedObject() {
		m_internal = nullptr;
	}

	static std::string name;
	static Dart_Handle dart_library;
	static Dart_Handle dart_type;

	static Dart::Object create_instance(Dart::Env env, Internal* internal = nullptr, Dart::Function constructor = nullptr);
	static bool is_instance(Dart::Env env, const Dart::Object& object);
	static WrappedObject<ClassType>* try_unwrap(const Dart::Object& object);
	Internal* get_internal();
	void set_internal(Internal* internal);

private:
	std::unique_ptr<Internal> m_internal;

	static void finalizer(void* isolate_callback_data, Dart_WeakPersistentHandle handle, void* peer);
};


template<typename ClassType>
std::string WrappedObject<ClassType>::name;

template<typename ClassType>
Dart_Handle WrappedObject<ClassType>::dart_library = nullptr;

template<typename ClassType>
Dart_Handle WrappedObject<ClassType>::dart_type = nullptr;


template<typename ClassType>
class ObjectWrap {
    using Internal = typename ClassType::Internal;
    using ParentClassType = typename ClassType::Parent;

  public:
    static Dart::Function create_constructor(Dart::Env env);
	static Dart::Object create_instance(Dart::Env env, Internal* internal = nullptr, Dart::Function constructor = nullptr);
	static void on_context_destroy(Dart::Env env, std::string realmPath);
	static bool is_instance(Dart::Env env, const Dart::Object& object);
	static Internal* get_internal(Dart::Env env, const Dart::Object& object);
	static void set_internal(Dart::Env env, const Dart::Object& object, Internal* data);

  private:
    static ClassType s_class;
	static std::unordered_map<std::string, Dart_NativeFunction> native_functions;

	static Dart::Function init_class(Dart::Env env);
	static void constructor_callback(Dart_NativeArguments arguments);
	static Dart_NativeFunction resolve_native_function(Dart_Handle name, int argc, bool* auto_setup_scope);
	
	//static void create_empty_list(Dart_NativeArguments arguments);
};

template<>
class ObjectWrap<void> {
  public:
    using Internal = void;

	static Dart::Function create_constructor(Dart::Env env) {
		return nullptr;
	}
};

static inline Dart_Handle get_this(Dart_NativeArguments args) {
	size_t count = Dart_GetNativeArgumentCount(args);
	if (count == 0) {
		return nullptr;
	}

	Dart_Handle thiz = Dart_GetNativeArgument(args, 0) || handleError;
	return thiz;
}

static std::vector<Dart_Handle> get_arguments(Dart_NativeArguments args) {
	size_t count = Dart_GetNativeArgumentCount(args);
	std::vector<Dart::Value> arguments;
	
	//the zero item is always the this object
	if (count > 1) {
		arguments.reserve(count);
		for (u_int i = 1; i < count; i++) {
			Dart_Handle arg = Dart_GetNativeArgument(args, i) || handleError;
			arguments.push_back(arg);
		}
	}

	return arguments;
}

template<typename ClassType>
ClassType ObjectWrap<ClassType>::s_class;


template<typename ClassType>
std::unordered_map<std::string, Dart_NativeFunction> ObjectWrap<ClassType>::native_functions;

template<typename ClassType>
void WrappedObject<ClassType>::finalizer(void* isolate_callback_data, Dart_WeakPersistentHandle handle, void* peer) {
	delete (WrappedObject<ClassType>*)peer;
}

template<typename ClassType>
Dart::Object WrappedObject<ClassType>::create_instance(Dart::Env env, Internal* internal, Dart::Function constructor) {
	//have the realm user Constructor as argument here and call its _constructor named constructor which will create the real instance and will mark the RealmObject as managed

	bool isRealmObjectClass = std::is_same<ClassType, realm::js::RealmObjectClass<realm::dartvm::Types>>::value;
	bool isResultsClass = std::is_same<ClassType, realm::js::ResultsClass<realm::dartvm::Types>>::value;
	if (isRealmObjectClass && constructor == nullptr) {
		throw std::runtime_error("Argument `constructor` is required to create an instance of RealmObject");
	}

	Dart_Handle targetType = WrappedObject<ClassType>::dart_type;
	if (isRealmObjectClass) {
		targetType = constructor;
	}


	Dart_Handle constructorName = Dart_NewStringFromCString("_constructor") || handleError;
	
	Dart_Handle instance;
	if (isResultsClass) {
		instance = Dart_New(targetType, constructorName, 0, nullptr);
	}
	else {
		auto allocatedObject = Dart_Allocate(targetType /*WrappedObject<ClassType>::dart_type*/) || handleError;
		instance = Dart_InvokeConstructor(allocatedObject, constructorName, 0, nullptr) || handleError;
	}
	
	WrappedObject<ClassType>* wrappedObject = new WrappedObject<ClassType>();
	if (internal != nullptr) {
		wrappedObject->set_internal(internal);
	}

	Dart_SetPeer(instance, wrappedObject) || handleError;
	auto res = Dart_NewWeakPersistentHandle(instance, wrappedObject, sizeof(wrappedObject), &WrappedObject<ClassType>::finalizer);
	if (res == nullptr) {
		throw std::runtime_error("Error creating peer handle");
	}

	return instance;
}

template<typename ClassType>
void ObjectWrap<ClassType>::constructor_callback(Dart_NativeArguments arguments) {
	try {
		Dart::HandleScope scope;

		auto argumentList = dartvm::get_arguments(arguments);
		dartvm::Arguments args{ CurrentEnv(), argumentList.size(), argumentList.data() };
		dartvm::ReturnValue result(CurrentEnv());

		//Dart_Handle thiz = dartvm::get_this(arguments, false);
		//bool d = Dart_IsNull(thiz);

		Dart_Handle instance = create_instance(CurrentEnv());

		s_class.constructor(CurrentEnv(), instance, args);

		Dart_SetReturnValue(arguments, instance);
	}
	//Dart: check if this is catching dart errors just to rethrow them again. 
	catch (const std::exception & e) {
		//Dart: as per dart guidance the error should be propagated using Dart_SetReturnValue.
		auto exception = Dart_NewApiError(e.what());
		Dart_ThrowException(exception);
	}
}

//template<typename ClassType>
//void ObjectWrap<ClassType>::create_empty_list(Dart_NativeArguments arguments) {
//	bool isListClass = std::is_same<ClassType, realm::js::ListClass<realm::dartvm::Types>>::value;
//
//	if (!isListClass) {
//		throw std::runtime_error("create_empty_list invoked on non ListClass type");
//	}
//
//	WrappedObject<ClassType>::create_instance(env, new ::realm::List())
//}

template<typename ClassType>
WrappedObject<ClassType>* WrappedObject<ClassType>::try_unwrap(const Dart::Object& object) {
	if (Dart_IsNull(object)) {
		throw std::runtime_error("Invalid `object` argument");
	}

	WrappedObject<ClassType>* wrappedObject;
	Dart_GetPeer(object, (void**)&wrappedObject) || handleError;
	return wrappedObject;
}

template<typename ClassType>
inline typename ClassType::Internal* WrappedObject<ClassType>::get_internal() {
	return m_internal.get();
}

template<typename ClassType>
inline void WrappedObject<ClassType>::set_internal(Internal* internal) {
	m_internal = std::unique_ptr<Internal>(internal);
}

template<typename ClassType>
inline bool WrappedObject<ClassType>::is_instance(Dart::Env env, const Dart::Object& object) {
	if (dart_type == nullptr) {
		std::string typeName(typeid(ClassType).name());
		std::string errorMessage = util::format("is_instance: Class %1 not initialized. Call init() first", typeName);
	}

	bool isInstance = false;
	Dart_ObjectIsType(object, dart_type, &isInstance) || handleError;
	
	//Dart: non wrapped RealmObject instances are considered unmanaged and not instances of RealmObject
	if (isInstance) {
		bool isRealmObjectClass = std::is_same<ClassType, realm::js::RealmObjectClass<realm::dartvm::Types>>::value;
		if (isRealmObjectClass) {
			WrappedObject<ClassType>* wrapped = WrappedObject<ClassType>::try_unwrap(object);
			if (wrapped == nullptr) {
				return false;
			}

			/*typename ClassType::Internal* internal = ;
			if (internal == nullptr) {
				return false;
			}*/
		}
	}

	return isInstance;
}

template<typename ClassType>
Dart::Function ObjectWrap<ClassType>::create_constructor(Dart::Env env) {

	Dart_Handle dart_type = init_class(env);
	
	/*const std::map<int, VoidFunc> nativeMap;



	const std::map<int, DartFunc> methodMap = {
		{ 1, { WrapDoWork<DoWork> } },
		{ 2, { WrapStatic<DoWork> } }
	};*/


	//pair<int, DartFunc*>& pair = methodMap.at(1);
	//for (auto& pair : methodMap) {
		//DartFunc dartfunc = pair.second;
		//Dart_NativeFunction fu = WrapStaticDoWork<pair.second>;

		/* auto myFunc = [&](Dart_NativeArguments arguments) -> void {

		 };

		 Dart_NativeFunction mynative = myFunc;*/

		 //std::function<void(Dart_NativeArguments arguments)*> mynativeFunc = (Dart_NativeFunction)myFunc;

	//}
	//DartFunc* myfunc = &WrapDoWork<DoWork>;
	


	//void(*foo)(Dart_NativeArguments);
	//foo = &wrap_static<myfunc>;

	
	
	
	return dart_type;
}

template<typename ClassType>
Dart_NativeFunction ObjectWrap<ClassType>::resolve_native_function(Dart_Handle name, int argc, bool* auto_setup_scope) {
	if (!Dart_IsString(name)) {
		return nullptr;
	}

	Dart_NativeFunction result = nullptr;
	if (auto_setup_scope == nullptr) {
		return nullptr;
	}

	Dart_EnterScope();
	const char* cname;
	Dart_StringToCString(name, &cname) || handleError;

	std::string nativeFunctionName = std::string(cname);
	if (native_functions.count(nativeFunctionName)) {
		result = native_functions.at(nativeFunctionName);
	}

	Dart_ExitScope();
	return result;
}


template<typename ClassType>
Dart::Function ObjectWrap<ClassType>::init_class(Dart::Env env) {
	//Dart: move all logic to WrappedObject<ClassType>::init_class

	bool isResultsClass = std::is_same<ClassType, realm::js::ResultsClass<realm::dartvm::Types>>::value;
	bool isListClass = std::is_same<ClassType, realm::js::ListClass<realm::dartvm::Types>>::value;

	std::string classNamePrefix = "";
	if (isResultsClass || isListClass) {
		classNamePrefix = "Realm";
	}
	std::string className = util::format("%1%2", classNamePrefix.c_str(), s_class.name.c_str());
	WrappedObject<ClassType>::dart_type = Dart_GetType(RealmLibrary, Dart_NewStringFromCString(className.c_str()), 0, nullptr) || handleError;
	WrappedObject<ClassType>::dart_type = Dart_NewPersistentHandle(WrappedObject<ClassType>::dart_type);

	WrappedObject<ClassType>::dart_library = Dart_ClassLibrary(WrappedObject<ClassType>::dart_type) || handleError;
	WrappedObject<ClassType>::dart_library = Dart_NewPersistentHandle(WrappedObject<ClassType>::dart_library);

	

	WrappedObject<ClassType>::name = className;

	Dart_SetNativeResolver(WrappedObject<ClassType>::dart_library, resolve_native_function, nullptr) || handleError;

	//find the dart library for this class
	//setup a dart native resolver for this library Dart_SetNativeResolver
	//go over all static methods, methods, properties and static properties and setp them up in a std::map by name and function pointer which will be the result of native resolver when its called
	//for the static members use wrap_static 

	if (reinterpret_cast<void*>(s_class.constructor) != nullptr) {
		std::string nativeFunctionName = util::format("%1_constructor", s_class.name);
		Dart_NativeFunction nativeFunction = constructor_callback;
		native_functions.emplace(nativeFunctionName, nativeFunction);
	}


	for (auto& pair : s_class.static_methods) {
		std::string nativeFunctionName = util::format("%1_%2", s_class.name, pair.first);
		Dart_NativeFunction nativeFunction = pair.second;
		native_functions.emplace(nativeFunctionName, nativeFunction);
	}

	for (auto& pair : s_class.static_properties) {
		const std::string propertyName = pair.first;
		const PropertyType& property = pair.second;

		if (property.getter) {
			std::string nativeFunctionName = util::format("%1_get_%2", s_class.name, propertyName);
			Dart_NativeFunction nativeFunction = property.getter;
			native_functions.emplace(nativeFunctionName, nativeFunction);
		}

		if (property.setter) {
			std::string nativeFunctionName = util::format("%1_set_%2", s_class.name, propertyName);
			Dart_NativeFunction nativeFunction = property.setter;
			native_functions.emplace(nativeFunctionName, nativeFunction);
		}
	}

	for (auto& pair : s_class.methods) {
		std::string nativeFunctionName = util::format("%1_%2", s_class.name, pair.first);
		Dart_NativeFunction nativeFunction = pair.second;
		native_functions.emplace(nativeFunctionName, nativeFunction);
	}

	for (auto& pair : s_class.properties) {
		const std::string propertyName = pair.first;
		const PropertyType& property = pair.second;

		if (property.getter) {
			std::string nativeFunctionName = util::format("%1_get_%2", s_class.name, propertyName);
			Dart_NativeFunction nativeFunction = property.getter;
			native_functions.emplace(nativeFunctionName, nativeFunction);
		}

		if (property.setter) {
			std::string nativeFunctionName = util::format("%1_set_%2", s_class.name, propertyName);
			Dart_NativeFunction nativeFunction = property.setter;
			native_functions.emplace(nativeFunctionName, nativeFunction);
		}
	}

	if (s_class.index_accessor.getter) {
		std::string nativeFunctionName = util::format("%1_get_by_index", s_class.name);
		Dart_NativeFunction nativeFunction = s_class.index_accessor.getter;
		native_functions.emplace(nativeFunctionName, nativeFunction);
	}

	if (s_class.index_accessor.setter) {
		std::string nativeFunctionName = util::format("%1_set_by_index", s_class.name);
		Dart_NativeFunction nativeFunction = s_class.index_accessor.setter;
		native_functions.emplace(nativeFunctionName, nativeFunction);
	}

	if (s_class.string_accessor.getter) {
		std::string nativeFunctionName = util::format("%1_get_property", s_class.name);
		Dart_NativeFunction nativeFunction = s_class.string_accessor.getter;
		native_functions.emplace(nativeFunctionName, nativeFunction);
	}

	if (s_class.string_accessor.setter) {
		std::string nativeFunctionName = util::format("%1_set_property", s_class.name);
		Dart_NativeFunction nativeFunction = s_class.string_accessor.setter;
		native_functions.emplace(nativeFunctionName, nativeFunction);
	}

	return WrappedObject<ClassType>::dart_type;
}

template<typename ClassType>
Dart::Object ObjectWrap<ClassType>::create_instance(Dart::Env env, Internal* internal, Dart::Function constructor) {
	return WrappedObject<ClassType>::create_instance(env, internal, constructor);
}

template<typename ClassType>
inline void ObjectWrap<ClassType>::on_context_destroy(Dart::Env env, std::string realmPath) {
}

template<typename ClassType>
inline bool ObjectWrap<ClassType>::is_instance(Dart::Env env, const Dart::Object& object) {
	return WrappedObject<ClassType>::is_instance(env, object);
}

template<typename ClassType>
typename ClassType::Internal* ObjectWrap<ClassType>::get_internal(Dart::Env env, const Dart::Object& object) {
	 auto wrappedObject = WrappedObject<ClassType>::try_unwrap(object);
	 if (wrappedObject == nullptr) {
		 throw std::runtime_error("Invalid wrapped object");
	 }

	 Internal* internal = wrappedObject->get_internal();
	 return internal;
}

template<typename ClassType>
void ObjectWrap<ClassType>::set_internal(Dart::Env env, const Dart::Object & object, Internal* internal) {
	auto wrappedObject = WrappedObject<ClassType>::try_unwrap(object);
	if (wrappedObject == nullptr) {
		throw std::runtime_error("Invalid wrapped object");
	}

	wrappedObject->set_internal(internal);
}

void helpers_invokeStatic(Dart_NativeArguments arguments) {
	Dart_Handle type = Dart_GetNativeArgument(arguments, 0) || handleError;
	Dart_Handle staticMethodName = Dart_GetNativeArgument(arguments, 1) || handleError;
	
	Dart_Handle result = Dart_Invoke(type, staticMethodName, 0, nullptr);
	Dart_SetReturnValue(arguments, result);
}

Dart_NativeFunction helpers_resolve(Dart_Handle name, int argc, bool* auto_setup_scope) {
	if (!Dart_IsString(name)) {
		return nullptr;
	}

	Dart_NativeFunction result = nullptr;
	if (auto_setup_scope == nullptr) {
		return nullptr;
	}

	Dart_EnterScope();
	const char* cname;
	Dart_StringToCString(name, &cname) || handleError;

	std::string methodName = cname;
	if (methodName == "Helpers_invokeStatic") {
		return helpers_invokeStatic;
	}

	Dart_ExitScope();
	return result;
}

} // dartvm

namespace js {

template<typename ClassType>
class ObjectWrap<dartvm::Types, ClassType> : public dartvm::ObjectWrap<ClassType> {};


#/*define HANDLE_WRAP_EXCEPTION           \
catch (const Napi::Error & e) { \
	throw;\
}\
catch (const node::Exception & e) {\
	Napi::Error error = Napi::Error::New(info.Env(), e.what());\
	copy_object(env, e.m_value, error);\
	throw error;\
}\
catch (const std::exception & e) {\
	throw Napi::Error::New(info.Env(), e.what());\
}*/

//template<dartvm::ArgumentsMethodType F>
//void wrap_static(Dart_NativeArguments arguments) {
//	wrap_internal<F>(arguments, true);
//}

template<dartvm::ArgumentsMethodType F>
void wrap(Dart_NativeArguments arguments) {
	try {
		auto argumentList = dartvm::get_arguments(arguments);
		dartvm::Arguments args{ CurrentEnv(), argumentList.size(), argumentList.data() };

		dartvm::ReturnValue result(CurrentEnv());

		Dart_Handle thiz = dartvm::get_this(arguments);

		F(CurrentEnv(), thiz, args, result);
		Dart_Handle res = result.ToValue();
		Dart_SetReturnValue(arguments, res);
	}
	//Dart: check if this is catching dart errors just to rethrow them again. 
	catch (const std::exception & e) {
		//Dart: as per dart guidance the error should be propagated using setreturn value.
		auto exception = Dart_NewApiError(e.what());
		Dart_ThrowException(exception);
	}
}

//template<dartvm::PropertyType::GetterType F>
//void wrap_static(Dart_NativeArguments arguments) {
//	wrap_internal<F>(arguments, true);
//}

template<dartvm::PropertyType::GetterType F>
//Napi::Value wrap(const Napi::CallbackInfo& info) {
void wrap(Dart_NativeArguments arguments) {
	try {
		dartvm::ReturnValue result(CurrentEnv());

		Dart_Handle thiz = dartvm::get_this(arguments);

		F(CurrentEnv(), thiz, result);
		Dart_Handle res = result.ToValue();
		Dart_SetReturnValue(arguments, res);
	}
	//Dart: check if this is catching dart errors just to rethrow them again. 
	catch (const std::exception & e) {
		//Dart: as per dart guidance the error should be propagated using setreturn value.
		auto exception = Dart_NewApiError(e.what());
		Dart_ThrowException(exception);
	}
}

//template<dartvm::PropertyType::GetterType F>
//void wrap_internal(Dart_NativeArguments arguments, bool isStatic) {
//	
//}


//template<dartvm::PropertyType::SetterType F>
//void wrap_static(Dart_NativeArguments arguments) {
//	//func(arguments, true);
//	//wrap<F>(arguments, true);
//}

template<dartvm::PropertyType::SetterType F>
//void wrap(const Napi::CallbackInfo& info, const Napi::Value& value) {
void wrap(Dart_NativeArguments arguments) {
	try {
		auto argumentList = dartvm::get_arguments(arguments);

		Dart_Handle thiz = dartvm::get_this(arguments);
		auto value = argumentList[0];

		F(CurrentEnv(), thiz, value);
	}
	//Dart: check if this is catching dart errors just to rethrow them again. 
	catch (const std::exception & e) {
		//Dart: as per dart guidance the error should be propagated using setreturn value.
		auto exception = Dart_NewApiError(e.what());
		Dart_ThrowException(exception);
	}


	/*Napi::Env env = info.Env();

	try {
		F(env, info.This().As<Napi::Object>(), value);
	}
	HANDLE_WRAP_EXCEPTION*/
}

//template<dartvm::PropertyType::SetterType F>
//void wrap_internal(Dart_NativeArguments arguments, bool isStatic) {
//	
//}

template<dartvm::IndexPropertyType::GetterType F>
//Napi::Value wrap(const Napi::CallbackInfo& info, const Napi::Object& instance, uint32_t index) {
void wrap(Dart_NativeArguments arguments) {
	try {
		dartvm::ReturnValue result(CurrentEnv());

		auto argumentList = dartvm::get_arguments(arguments);

		Dart_Handle thiz = dartvm::get_this(arguments);
		auto indexValue = argumentList[0];

		int64_t index;
		Dart_IntegerToInt64(indexValue, &index) || handleError;


		F(CurrentEnv(), thiz, index, result);
		Dart_Handle res = result.ToValue();
		Dart_SetReturnValue(arguments, res);
	}
	//Dart: check if this is catching dart errors just to rethrow them again. 
	catch (const std::exception & e) {
		//Dart: as per dart guidance the error should be propagated using setreturn value.
		auto exception = Dart_NewApiError(e.what());
		Dart_ThrowException(exception);
	}


	//Napi::Env env = info.Env();
	//node::ReturnValue result(env);

	//try {
	//	try {
	//		F(env, instance, index, result);
	//		return result.ToValue();
	//	}
	//	catch (const std::out_of_range& e) {
	//		// Out-of-bounds index getters should just return undefined in JS.
	//		result.set_undefined();
	//		return result.ToValue();
	//	}
	//}
	//HANDLE_WRAP_EXCEPTION
}

template<dartvm::IndexPropertyType::SetterType F>
//Napi::Value wrap(const Napi::CallbackInfo& info, const Napi::Object& instance, uint32_t index, const Napi::Value& value) {
void wrap(Dart_NativeArguments arguments) {
	//Napi::Env env = info.Env();

	//try {
	//	bool success = F(env, instance, index, value);

	//	// Indicate that the property was intercepted.
	//	return Napi::Value::From(env, success);
	//}
	//HANDLE_WRAP_EXCEPTION
}

template<dartvm::StringPropertyType::GetterType F>
//Napi::Value wrap(const Napi::CallbackInfo& info, const Napi::Object& instance, const Napi::String& property) {
void wrap(Dart_NativeArguments arguments) {
	try {
		void* peer;
		Dart_Handle propertyName = Dart_GetNativeStringArgument(arguments, 1, &peer) || handleError;

		dartvm::ReturnValue result(CurrentEnv());

		Dart_Handle thiz = dartvm::get_this(arguments);

		F(CurrentEnv(), thiz, propertyName, result);
		Dart_Handle res = result.ToValue();
		Dart_SetReturnValue(arguments, res);
	}
	//Dart: check if this is catching dart errors just to rethrow them again. 
	catch (const std::exception & e) {
		//Dart: as per dart guidance the error should be propagated using setreturn value.
		auto exception = Dart_NewApiError(e.what());
		Dart_ThrowException(exception);
	}


	/*Napi::Env env = info.Env();
	node::ReturnValue result(env);

	try {
		F(env, instance, property, result);
		return result.ToValue();
	}
	HANDLE_WRAP_EXCEPTION*/
}

template<dartvm::StringPropertyType::SetterType F>
//Napi::Value wrap(const Napi::CallbackInfo& info, const Napi::Object& instance, const Napi::String& property, const Napi::Value& value) {
void wrap(Dart_NativeArguments arguments) {
	try {
		void* peer;
		Dart_Handle propertyName = Dart_GetNativeStringArgument(arguments, 1, &peer) || handleError;

		Dart_Handle propertyValue = Dart_GetNativeArgument(arguments, 2) || handleError;

		Dart_Handle thiz = dartvm::get_this(arguments);

		F(CurrentEnv(), thiz, propertyName, propertyValue);
	}
	//Dart: check if this is catching dart errors just to rethrow them again. 
	catch (const std::exception & e) {
		//Dart: as per dart guidance the error should be propagated using setreturn value.
		auto exception = Dart_NewApiError(e.what());
		Dart_ThrowException(exception);
	}
	
	
	
	/*Napi::Env env = info.Env();
	try {
		bool success = F(env, instance, property, value);
		return Napi::Value::From(env, success);
	}
	HANDLE_WRAP_EXCEPTION*/
}

template<dartvm::StringPropertyType::EnumeratorType F>
//Napi::Value wrap(const Napi::CallbackInfo& info, const Napi::Object& instance) {
void wrap(Dart_NativeArguments arguments) {
	/*Napi::Env env = info.Env();

	try {
		auto names = F(env, instance);

		int count = (int)names.size();
		Napi::Array array = Napi::Array::New(env, count);
		for (int i = 0; i < count; i++) {
			array.Set(i, names[i]);
		}

		return array;
	}
	HANDLE_WRAP_EXCEPTION*/
}

} // js
} // realm
