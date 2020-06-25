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

#include "dart_init.hpp"


#include "dart_string.hpp"
#include "dart_protected.hpp"
#include "dart_function.hpp"
#include "dart_value.hpp"
#include "dart_context.hpp"
#include "dart_object.hpp"
#include "dart_exception.hpp"
#include "dart_return_value.hpp"
#include "dart_class.hpp"

#include "js_object_accessor.hpp"

namespace realm {
namespace dartvm {


void dart_init(Dart::Env env, Dart::Value realmLibrary, const std::string& filesDir) {
	___DartError::use_native_exceptions = true;

#ifdef FLUTTER
	RealmPackageName = "realm_flutter";
#else
	RealmPackageName = "realm";
#endif // FLUTTER

	flutter::FilesDir = filesDir;

	RealmLibrary = Dart_NewPersistentHandle(realmLibrary);

	DartCoreLibrary = Dart::GetLibrary("dart:core") || handleError;
	DartCoreLibrary = Dart_NewPersistentHandle(DartCoreLibrary);

	DartDateTimeType = Dart_GetType(DartCoreLibrary, Dart_NewStringFromCString("DateTime"), 0, nullptr) || handleError;
	DartDateTimeType = Dart_NewPersistentHandle(DartDateTimeType);

	

	RealmDynamicObjectType = Dart_GetType(realmLibrary, Dart_NewStringFromCString("DynamicObject"), 0, nullptr) || handleError;
	RealmDynamicObjectType = Dart_NewPersistentHandle(RealmDynamicObjectType);

	RealmHelpersType = Dart_GetType(realmLibrary, Dart_NewStringFromCString("Helpers"), 0, nullptr) || handleError;
	RealmHelpersType = Dart_NewPersistentHandle(RealmHelpersType);


	Dart_Handle helpersLibrary = Dart_ClassLibrary(RealmHelpersType) || handleError;
	Dart_SetNativeResolver(helpersLibrary, helpers_resolve, nullptr) || handleError;


	RealmTypeStaticPropertiesType = Dart_GetType(realmLibrary, Dart_NewStringFromCString("TypeStaticProperties"), 0, nullptr) || handleError;
	RealmTypeStaticPropertiesType = Dart_NewPersistentHandle(RealmTypeStaticPropertiesType);


	Dart::Function realm_constructor = js::RealmClass<Types>::create_constructor(env);

	___DartError::use_native_exceptions = false;
}

} // dartvm
} // realm
