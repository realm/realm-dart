/*
 * Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef RUNTIME_INCLUDE_DART_API_DL_H_
#define RUNTIME_INCLUDE_DART_API_DL_H_

#include "dart_api.h"
#include "dart_native_api.h"

/** \mainpage Dynamically Linked Dart API
 *
 * This exposes a subset of symbols from dart_api.h and dart_native_api.h
 * available in every Dart embedder through dynamic linking.
 *
 * All symbols are postfixed with _DL to indicate that they are dynamically
 * linked and to prevent conflicts with the original symbol.
 *
 * Link `dart_api_dl.c` file into your library and invoke
 * `Dart_InitializeApiDL` with `NativeApi.initializeApiDLData`.
 */

#ifdef __cplusplus
#define DART_EXTERN extern "C"
#else
#define DART_EXTERN extern
#endif

DART_EXTERN intptr_t Dart_InitializeApiDL(void* data);

// ============================================================================
// IMPORTANT! Never update these signatures without properly updating
// DART_API_DL_MAJOR_VERSION and DART_API_DL_MINOR_VERSION.
//
// Verbatim copy of `dart_native_api.h` and `dart_api.h` symbol names and types
// to trigger compile-time errors if the sybols in those files are updated
// without updating these.
//
// Function return and argument types, and typedefs are carbon copied. Structs
// are typechecked nominally in C/C++, so they are not copied, instead a
// comment is added to their definition.
typedef int64_t Dart_Port_DL;

typedef void (*Dart_NativeMessageHandler_DL)(Dart_Port_DL dest_port_id,
                                             Dart_CObject* message);

// dart_native_api.h symbols can be called on any thread.
#define DART_NATIVE_API_DL_SYMBOLS(F)                                          \
  /***** dart_native_api.h *****/                                              \
  /* Dart_Port */                                                              \
  F(Dart_PostCObject, bool, (Dart_Port_DL port_id, Dart_CObject * message))    \
  F(Dart_PostInteger, bool, (Dart_Port_DL port_id, int64_t message))           \
  F(Dart_NewNativePort, Dart_Port_DL,                                          \
    (const char* name, Dart_NativeMessageHandler_DL handler,                   \
     bool handle_concurrently))                                                \
  F(Dart_CloseNativePort, bool, (Dart_Port_DL native_port_id))

// dart_api.h symbols can only be called on Dart threads.
#define DART_API_DL_SYMBOLS(F)                                                 \
  /***** dart_api.h *****/                                                     \
  /* Errors */                                                                 \
  F(Dart_IsError, bool, (Dart_Handle handle))                                  \
  F(Dart_IsApiError, bool, (Dart_Handle handle))                               \
  F(Dart_IsUnhandledExceptionError, bool, (Dart_Handle handle))                \
  F(Dart_IsCompilationError, bool, (Dart_Handle handle))                       \
  F(Dart_IsFatalError, bool, (Dart_Handle handle))                             \
  F(Dart_GetError, const char*, (Dart_Handle handle))                          \
  F(Dart_ErrorHasException, bool, (Dart_Handle handle))                        \
  F(Dart_ErrorGetException, Dart_Handle, (Dart_Handle handle))                 \
  F(Dart_ErrorGetStackTrace, Dart_Handle, (Dart_Handle handle))                \
  F(Dart_NewApiError, Dart_Handle, (const char* error))                        \
  F(Dart_NewCompilationError, Dart_Handle, (const char* error))                \
  F(Dart_NewUnhandledExceptionError, Dart_Handle, (Dart_Handle exception))     \
  F(Dart_PropagateError, void, (Dart_Handle handle))                           \
  /* Dart_Handle, Dart_PersistentHandle, Dart_WeakPersistentHandle */          \
  F(Dart_HandleFromPersistent, Dart_Handle, (Dart_PersistentHandle object))    \
  F(Dart_HandleFromWeakPersistent, Dart_Handle,                                \
    (Dart_WeakPersistentHandle object))                                        \
  F(Dart_NewPersistentHandle, Dart_PersistentHandle, (Dart_Handle object))     \
  F(Dart_SetPersistentHandle, void,                                            \
    (Dart_PersistentHandle obj1, Dart_Handle obj2))                            \
  F(Dart_DeletePersistentHandle, void, (Dart_PersistentHandle object))         \
  F(Dart_NewWeakPersistentHandle, Dart_WeakPersistentHandle,                   \
    (Dart_Handle object, void* peer, intptr_t external_allocation_size,        \
     Dart_WeakPersistentHandleFinalizer callback))                             \
  F(Dart_DeleteWeakPersistentHandle, void, (Dart_WeakPersistentHandle object)) \
  F(Dart_UpdateExternalSize, void,                                             \
    (Dart_WeakPersistentHandle object, intptr_t external_allocation_size))     \
  F(Dart_NewFinalizableHandle, Dart_FinalizableHandle,                         \
    (Dart_Handle object, void* peer, intptr_t external_allocation_size,        \
     Dart_HandleFinalizer callback))                                           \
  F(Dart_DeleteFinalizableHandle, void,                                        \
    (Dart_FinalizableHandle object, Dart_Handle strong_ref_to_object))         \
  F(Dart_UpdateFinalizableExternalSize, void,                                  \
    (Dart_FinalizableHandle object, Dart_Handle strong_ref_to_object,          \
     intptr_t external_allocation_size))                                       \
  /* Dart_Port */                                                              \
  F(Dart_Post, bool, (Dart_Port_DL port_id, Dart_Handle object))               \
  F(Dart_NewSendPort, Dart_Handle, (Dart_Port_DL port_id))                     \
  F(Dart_SendPortGetId, Dart_Handle,                                           \
    (Dart_Handle port, Dart_Port_DL * port_id))                                \
  /* Scopes */                                                                 \
  F(Dart_EnterScope, void, ())                                                 \
  F(Dart_ExitScope, void, ())                                                  \
                                                                               \
                                                                               \
/* extenders*/                                                                 \
                                                                               \
F(Dart_Allocate, Dart_Handle, (Dart_Handle type))                              \
                                                                               \
F(Dart_AllocateWithNativeFields, Dart_Handle, (                                \
    Dart_Handle type,                                                          \
    intptr_t num_native_fields,                                                 \
    const intptr_t* native_fields))                                             \
                                                                               \
F(Dart_BooleanValue, Dart_Handle, (Dart_Handle boolean_obj,                    \
                                            bool* value))                      \
                                                                               \
F(Dart_ClassLibrary, Dart_Handle, (Dart_Handle cls_type))                      \
                                                                               \
F(Dart_ClassName, Dart_Handle, (Dart_Handle cls_type))                         \
                                                                               \
F(Dart_Cleanup, char*, ())                                                     \
                                                                               \
F(Dart_ClosureFunction, Dart_Handle, (Dart_Handle closure))                    \
                                                                               \
F(Dart_CreateIsolateGroup, Dart_Isolate, (                                     \
    const char* script_uri,                                                    \
    const char* name,                                                          \
    const uint8_t* isolate_snapshot_data,                                      \
    const uint8_t* isolate_snapshot_instructions,                              \
    Dart_IsolateFlags* flags,                                                   \
    void* isolate_group_data,                                                  \
    void* isolate_data,                                                        \
    char** error))                                                             \
                                                                               \
F(Dart_CreateIsolateGroupFromKernel, Dart_Isolate, (                           \
    const char* script_uri,                                                    \
    const char* name,                                                          \
    const uint8_t* kernel_buffer,                                              \
    intptr_t kernel_buffer_size,                                               \
    Dart_IsolateFlags* flags,                                                   \
    void* isolate_group_data,                                                  \
    void* isolate_data,                                                        \
    char** error))                                                             \
                                                                               \
F(Dart_CurrentIsolate, Dart_Isolate, ())                                       \
                                                                               \
F(Dart_CurrentIsolateData, void*, ())                                          \
                                                                               \
F(Dart_CurrentIsolateGroup, Dart_IsolateGroup, ())                             \
                                                                               \
F(Dart_CurrentIsolateGroupData, void*, ())                                     \
                                                                               \
F(Dart_DebugName, Dart_Handle, ())                                             \
                                                                               \
F(Dart_DoubleValue, Dart_Handle, (Dart_Handle double_obj,                      \
                                           double* value))                     \
                                                                               \
F(Dart_DumpNativeStackTrace, void, (void* context))                            \
                                                                               \
F(Dart_EmptyString, Dart_Handle, ())                                           \
                                                                               \
F(Dart_EnterIsolate, void, (Dart_Isolate isolate))                             \
                                                                               \
F(Dart_ExitIsolate, void, ())                                                  \
                                                                               \
F(Dart_False, Dart_Handle, ())                                                 \
                                                                               \
F(Dart_FunctionIsStatic, Dart_Handle, (Dart_Handle function,                   \
                                                bool* is_static))              \
                                                                               \
F(Dart_FunctionName, Dart_Handle, (Dart_Handle function))                      \
                                                                               \
F(Dart_FunctionOwner, Dart_Handle, (Dart_Handle function))                     \
                                                                               \
F(Dart_GetClass, Dart_Handle, (Dart_Handle library,                            \
                                        Dart_Handle class_name))               \
                                                                               \
F(Dart_GetDataFromByteBuffer, Dart_Handle, (                                   \
    Dart_Handle byte_buffer))                                                  \
                                                                               \
F(Dart_GetField, Dart_Handle, (Dart_Handle container,                          \
                                        Dart_Handle name))                     \
                                                                               \
F(Dart_GetImportsOfScheme, Dart_Handle, (Dart_Handle scheme))                  \
                                                                               \
F(Dart_GetLoadedLibraries, Dart_Handle, ())                                    \
                                                                               \
F(Dart_GetMessageNotifyCallback, Dart_MessageNotifyCallback, ())               \
                                                                               \
F(Dart_GetNativeArguments, Dart_Handle, (                                      \
    Dart_NativeArguments args,                                                 \
    int num_arguments,                                                         \
    const Dart_NativeArgument_Descriptor* arg_descriptors,                     \
    Dart_NativeArgument_Value* arg_values))                                    \
                                                                               \
F(Dart_GetNativeArgument, Dart_Handle, (                                       \
    Dart_NativeArguments args,                                                 \
    int index))                                                                \
                                                                               \
F(Dart_GetNativeBooleanArgument, Dart_Handle, (                                \
    Dart_NativeArguments args,                                                 \
    int index,                                                                 \
    bool* value))                                                              \
                                                                               \
F(Dart_GetNativeDoubleArgument, Dart_Handle, (                                 \
    Dart_NativeArguments args,                                                 \
    int index,                                                                 \
    double* value))                                                            \
                                                                               \
F(Dart_GetNativeArgumentCount, int, (Dart_NativeArguments args))               \
                                                                               \
F(Dart_GetNativeFieldsOfArgument, Dart_Handle, (                               \
    Dart_NativeArguments args,                                                 \
    int arg_index,                                                             \
    int num_fields,                                                             \
    intptr_t* field_values))                                                    \
                                                                               \
F(Dart_GetNativeInstanceField, Dart_Handle, (Dart_Handle obj,                  \
                                                      int index,               \
                                                      intptr_t* value))        \
                                                                               \
F(Dart_GetNativeInstanceFieldCount, Dart_Handle, (                             \
    Dart_Handle obj,                                                           \
    int* count))                                                               \
                                                                               \
F(Dart_GetNativeIntegerArgument, Dart_Handle, (                                \
    Dart_NativeArguments args,                                                 \
    int index,                                                                 \
    int64_t* value))                                                           \
                                                                               \
F(Dart_GetNativeIsolateGroupData, void*, (                                     \
    Dart_NativeArguments args))                                                \
                                                                               \
F(Dart_SetNativeResolver, Dart_Handle, (Dart_Handle library,                   \
    Dart_NativeEntryResolver resolver,                                         \
    Dart_NativeEntrySymbol symbol))                                            \
                                                                               \
F(Dart_GetNativeResolver, Dart_Handle, (Dart_Handle library,                   \
    Dart_NativeEntryResolver* resolver))                                       \
                                                                               \
F(Dart_GetNativeStringArgument, Dart_Handle, (                                 \
    Dart_NativeArguments args,                                                 \
    int arg_index,                                                             \
    void** peer))                                                              \
                                                                               \
F(Dart_GetNativeSymbol, Dart_Handle, (                                         \
    Dart_Handle library,                                                       \
    Dart_NativeEntrySymbol* resolver))                                         \
                                                                               \
F(Dart_GetNonNullableType, Dart_Handle, (Dart_Handle library,                  \
                        Dart_Handle class_name,                                \
                        intptr_t number_of_type_arguments,                     \
                        Dart_Handle* type_arguments))                          \
                                                                               \
F(Dart_GetNullableType, Dart_Handle, (                                         \
    Dart_Handle library,                                                       \
    Dart_Handle class_name,                                                    \
    intptr_t number_of_type_arguments,                                         \
    Dart_Handle* type_arguments))                                              \
                                                                               \
F(Dart_GetPeer, Dart_Handle, (Dart_Handle object, void** peer))                \
                                                                               \
F(Dart_GetStaticMethodClosure, Dart_Handle, (                                  \
    Dart_Handle library,                                                       \
    Dart_Handle cls_type,                                                      \
    Dart_Handle function_name))                                                \
                                                                               \
F(Dart_GetStickyError, Dart_Handle, ())                                        \
                                                                               \
F(Dart_GetType, Dart_Handle, (Dart_Handle library,                             \
                                       Dart_Handle class_name,                 \
                                       intptr_t number_of_type_arguments,      \
                                       Dart_Handle* type_arguments))           \
                                                                               \
F(Dart_GetTypeOfExternalTypedData, Dart_TypedData_Type, (                      \
    Dart_Handle object))                                                       \
                                                                               \
F(Dart_GetTypeOfTypedData, Dart_TypedData_Type, (                              \
    Dart_Handle object))                                                       \
                                                                               \
F(Dart_HasStickyError, bool, ())                                               \
                                                                               \
F(Dart_IdentityEquals, bool, (Dart_Handle obj1,                                \
                                             Dart_Handle obj2))                \
                                                                               \
F(Dart_InstanceGetType, Dart_Handle, (Dart_Handle instance))                   \
                                                                               \
F(Dart_IntegerFitsIntoInt64, Dart_Handle, (Dart_Handle integer,                \
                                                    bool* fits))                \
                                                                               \
F(Dart_IntegerFitsIntoUint64, Dart_Handle, (Dart_Handle integer,               \
                                                     bool* fits))               \
                                                                               \
F(Dart_IntegerToHexCString, Dart_Handle, (Dart_Handle integer,                 \
                                                   const char** value))        \
                                                                               \
F(Dart_IntegerToInt64, Dart_Handle, (Dart_Handle integer,                      \
                                              int64_t* value))                 \
                                                                               \
F(Dart_IntegerToUint64, Dart_Handle, (Dart_Handle integer,                     \
                                               uint64_t* value))               \
                                                                               \
F(Dart_Invoke, Dart_Handle, (Dart_Handle target,                               \
                                      Dart_Handle name,                        \
                                      int number_of_arguments,                 \
                                      Dart_Handle* arguments))                 \
                                                                               \
F(Dart_InvokeClosure, Dart_Handle, (Dart_Handle closure,                       \
                   int number_of_arguments,                                    \
                   Dart_Handle* arguments))                                    \
                                                                               \
F(Dart_InvokeConstructor, Dart_Handle, (Dart_Handle object,                    \
                       Dart_Handle name,                                       \
                       int number_of_arguments,                                \
                       Dart_Handle* arguments))                                \
                                                                               \
F(Dart_IsBoolean, bool, (Dart_Handle object))                                  \
                                                                               \
F(Dart_IsByteBuffer, bool, (Dart_Handle object))                               \
                                                                               \
F(Dart_IsClosure, bool, (Dart_Handle object))                                  \
                                                                               \
F(Dart_IsDouble, bool, (Dart_Handle object))                                   \
                                                                               \
F(Dart_IsExternalString, bool, (Dart_Handle object))                           \
                                                                               \
F(Dart_IsFunction, bool, (Dart_Handle handle))                                 \
                                                                               \
F(Dart_IsFuture, bool, (Dart_Handle object))                                   \
                                                                               \
F(Dart_IsInstance, bool, (Dart_Handle object))                                 \
                                                                               \
F(Dart_IsInteger, bool, (Dart_Handle object))                                  \
                                                                               \
F(Dart_IsKernel, bool, (const uint8_t* buffer,                                 \
    intptr_t buffer_size))                                                     \
                                                                               \
F(Dart_IsKernelIsolate, bool, (Dart_Isolate isolate))                          \
                                                                               \
F(Dart_IsLegacyType, Dart_Handle, (Dart_Handle type,                           \
    bool* result))                                                             \
                                                                               \
F(Dart_IsLibrary, bool, (Dart_Handle object))                                  \
                                                                               \
F(Dart_IsList, bool, (Dart_Handle object))                                     \
                                                                               \
F(Dart_IsMap, bool, (Dart_Handle object))                                      \
                                                                               \
F(Dart_IsNonNullableType, Dart_Handle, (Dart_Handle type,                      \
                                                bool* result))                 \
                                                                               \
F(Dart_IsNull, bool, (Dart_Handle object))                                     \
                                                                               \
F(Dart_IsNumber, bool, (Dart_Handle object))                                   \
                                                                               \
F(Dart_IsolateData, void*, (Dart_Isolate isolate))                             \
                                                                               \
F(Dart_IsolateFlagsInitialize, void, (Dart_IsolateFlags* flags))                \
                                                                               \
F(Dart_IsolateGroupData, void*, (Dart_Isolate isolate))                        \
                                                                               \
F(Dart_IsolateMakeRunnable, char*, (Dart_Isolate isolate))                     \
                                                                               \
F(Dart_IsolateServiceId, const char*, (Dart_Isolate isolate))                  \
                                                                               \
F(Dart_IsPausedOnExit, bool, ())                                               \
                                                                               \
F(Dart_IsPausedOnStart, bool, ())                                              \
                                                                               \
F(Dart_IsPrecompiledRuntime, bool, ())                                         \
                                                                               \
F(Dart_IsServiceIsolate, bool, (Dart_Isolate isolate))                         \
                                                                               \
F(Dart_IsString, bool, (Dart_Handle object))                                   \
                                                                               \
F(Dart_IsStringLatin1, bool, (Dart_Handle object))                             \
                                                                               \
F(Dart_IsTearOff, bool, (Dart_Handle object))                                  \
                                                                               \
F(Dart_IsType, bool, (Dart_Handle handle))                                     \
                                                                               \
F(Dart_IsTypedData, bool, (Dart_Handle object))                                \
                                                                               \
F(Dart_IsTypeVariable, bool, (Dart_Handle handle))                             \
                                                                               \
F(Dart_IsVariable, bool, (Dart_Handle handle))                                 \
                                                                               \
F(Dart_IsVMFlagSet, bool, (const char* flag_name))                              \
                                                                               \
F(Dart_KernelIsolateIsRunning, bool, ())                                       \
                                                                               \
F(Dart_KernelListDependencies, Dart_KernelCompilationResult, ())               \
                                                                               \
F(Dart_KernelPort, Dart_Port, ())                                              \
                                                                               \
F(Dart_KillIsolate, void, (Dart_Isolate isolate))                              \
                                                                               \
F(Dart_LibraryHandleError, Dart_Handle, (Dart_Handle library,                  \
                                                  Dart_Handle error))          \
                                                                               \
F(Dart_LibraryResolvedUrl, Dart_Handle, (Dart_Handle library))                 \
                                                                               \
F(Dart_LibraryUrl, Dart_Handle, (Dart_Handle library))                         \
                                                                               \
F(Dart_ListGetAsBytes, Dart_Handle, (Dart_Handle list,                         \
                                              intptr_t offset,                 \
                                              uint8_t* native_array,           \
                                              intptr_t length))                \
                                                                               \
F(Dart_ListGetAt, Dart_Handle, (Dart_Handle list,                              \
                                               intptr_t index))                \
                                                                               \
F(Dart_ListGetRange, Dart_Handle, (Dart_Handle list,                           \
                                            intptr_t offset,                   \
                                            intptr_t length,                   \
                                            Dart_Handle* result))              \
                                                                               \
F(Dart_ListLength, Dart_Handle, (Dart_Handle list,                             \
                                                intptr_t* length))             \
                                                                               \
F(Dart_ListSetAsBytes, Dart_Handle, (Dart_Handle list,                         \
                                              intptr_t offset,                 \
                                              const uint8_t* native_array,     \
                                              intptr_t length))                \
                                                                               \
F(Dart_ListSetAt, Dart_Handle, (Dart_Handle list,                              \
                                         intptr_t index,                       \
                                         Dart_Handle value))                   \
                                                                               \
F(Dart_LoadLibraryFromKernel, Dart_Handle, (                                   \
    const uint8_t* kernel_buffer,                                              \
    intptr_t kernel_buffer_size))                                              \
                                                                               \
F(Dart_LoadScriptFromKernel, Dart_Handle, (                                    \
    const uint8_t* kernel_buffer,                                              \
    intptr_t kernel_size))                                                     \
                                                                               \
F(Dart_LookupLibrary, Dart_Handle, (Dart_Handle url))                          \
                                                                               \
F(Dart_MapContainsKey, Dart_Handle, (Dart_Handle map,                          \
                                                    Dart_Handle key))          \
                                                                               \
F(Dart_MapGetAt, Dart_Handle, (Dart_Handle map, Dart_Handle key))              \
                                                                               \
F(Dart_MapKeys, Dart_Handle, (Dart_Handle map))                                \
                                                                               \
F(Dart_New, Dart_Handle, (Dart_Handle type,                                    \
                                   Dart_Handle constructor_name,               \
                                   int number_of_arguments,                    \
                                   Dart_Handle* arguments))                    \
                                                                               \
F(Dart_NewBoolean, Dart_Handle, (bool value))                                  \
                                                                               \
F(Dart_NewByteBuffer, Dart_Handle, (Dart_Handle typed_data))                   \
                                                                               \
F(Dart_NewDouble, Dart_Handle, (double value))                                 \
                                                                               \
F(Dart_NewExternalLatin1String, Dart_Handle, (                                 \
    const uint8_t* latin1_array,                                               \
    intptr_t length,                                                           \
    void* peer,                                                                \
    intptr_t external_allocation_size,                                         \
    Dart_WeakPersistentHandleFinalizer callback))                              \
                                                                               \
F(Dart_NewExternalTypedData, Dart_Handle, (                                    \
    Dart_TypedData_Type type,                                                  \
    void* data,                                                                \
    intptr_t length))                                                          \
                                                                               \
F(Dart_NewExternalTypedDataWithFinalizer, Dart_Handle, (                       \
    Dart_TypedData_Type type,                                                  \
    void* data,                                                                \
    intptr_t length,                                                           \
    void* peer,                                                                \
    intptr_t external_allocation_size,                                         \
    Dart_WeakPersistentHandleFinalizer callback))                              \
                                                                               \
F(Dart_NewExternalUTF16String, Dart_Handle, (                                  \
    const uint16_t* utf16_array,                                               \
    intptr_t length,                                                           \
    void* peer,                                                                \
    intptr_t external_allocation_size,                                         \
    Dart_WeakPersistentHandleFinalizer callback))                              \
                                                                               \
F(Dart_NewInteger, Dart_Handle, (int64_t value))                               \
                                                                               \
F(Dart_NewIntegerFromHexCString, Dart_Handle, (                                \
    const char* value))                                                        \
                                                                               \
F(Dart_NewIntegerFromUint64, Dart_Handle, (uint64_t value))                    \
                                                                               \
F(Dart_NewList, Dart_Handle, (intptr_t length))                                \
                                                                               \
F(Dart_NewListOf, Dart_Handle, (Dart_CoreType_Id element_type_id,              \
                                         intptr_t length))                     \
                                                                               \
F(Dart_NewListOfType, Dart_Handle, (Dart_Handle element_type,                  \
                                             intptr_t length))                 \
                                                                               \
F(Dart_NewListOfTypeFilled, Dart_Handle, (                                     \
    Dart_Handle element_type,                                                  \
    Dart_Handle fill_object,                                                    \
    intptr_t length))                                                          \
                                                                               \
F(Dart_NewStringFromCString, Dart_Handle, (const char* str))                   \
                                                                               \
F(Dart_NewStringFromUTF16, Dart_Handle, (                                      \
    const uint16_t* utf16_array,                                               \
    intptr_t length))                                                          \
                                                                               \
F(Dart_NewStringFromUTF32, Dart_Handle, (                                      \
    const int32_t* utf32_array,                                                \
    intptr_t length))                                                          \
                                                                               \
F(Dart_NewStringFromUTF8, Dart_Handle, (                                       \
    const uint8_t* utf8_array,                                                 \
    intptr_t length))                                                          \
                                                                               \
F(Dart_NewTypedData, Dart_Handle, (Dart_TypedData_Type type,                   \
                                            intptr_t length))                  \
                                                                               \
F(Dart_NotifyIdle, void, (int64_t deadline))                                   \
                                                                               \
F(Dart_NotifyLowMemory, void, ())                                              \
                                                                               \
F(Dart_Null, Dart_Handle, ())                                                  \
                                                                               \
F(Dart_ObjectEquals, Dart_Handle, (Dart_Handle obj1,                           \
                                            Dart_Handle obj2,                  \
                                            bool* equal))                      \
                                                                               \
F(Dart_ObjectIsType, Dart_Handle, (Dart_Handle object,                         \
                                            Dart_Handle type,                  \
                                            bool*  instanceof))                \
                                                                               \
F(Dart_PrepareToAbort, void, ())                                               \
                                                                               \
F(Dart_ReThrowException, Dart_Handle, (Dart_Handle exception,                  \
                                                Dart_Handle stacktrace))       \
                                                                               \
F(Dart_RootLibrary, Dart_Handle, ())                                           \
                                                                               \
F(Dart_ScopeAllocate, uint8_t*, (intptr_t size))                               \
                                                                               \
F(Dart_SetBooleanReturnValue, void, (Dart_NativeArguments args,                \
                                              bool retval))                    \
                                                                               \
F(Dart_SetDartLibrarySourcesKernel, void, (                                    \
    const uint8_t* platform_kernel,                                            \
    const intptr_t platform_kernel_size))                                      \
                                                                               \
F(Dart_SetDoubleReturnValue, void, (Dart_NativeArguments args,                 \
                                             double retval))                   \
                                                                               \
F(Dart_SetEnvironmentCallback, Dart_Handle, (                                  \
    Dart_EnvironmentCallback callback))                                        \
                                                                               \
F(Dart_SetField, Dart_Handle, (Dart_Handle container,                          \
                                        Dart_Handle name,                      \
                                        Dart_Handle value))                    \
                                                                               \
F(Dart_SetIntegerReturnValue, void, (Dart_NativeArguments args,                \
                                              int64_t retval))                 \
                                                                               \
F(Dart_SetLibraryTagHandler, Dart_Handle, (                                    \
    Dart_LibraryTagHandler handler))                                           \
                                                                               \
F(Dart_SetMessageNotifyCallback, void, (                                       \
    Dart_MessageNotifyCallback message_notify_callback))                       \
                                                                               \
F(Dart_SetNativeInstanceField, Dart_Handle, (Dart_Handle obj,                  \
                                                      int index,               \
                                                      intptr_t value))         \
                                                                               \
F(Dart_SetPausedOnExit, void, (bool paused))                                   \
                                                                               \
F(Dart_SetPausedOnStart, void, (bool paused))                                  \
                                                                               \
F(Dart_SetPeer, Dart_Handle, (Dart_Handle object, void* peer))                 \
                                                                               \
F(Dart_SetReturnValue, void, (Dart_NativeArguments args,                       \
                                       Dart_Handle retval))                    \
                                                                               \
F(Dart_SetRootLibrary, Dart_Handle, (Dart_Handle library))                     \
                                                                               \
F(Dart_SetShouldPauseOnExit, void, (bool should_pause))                        \
                                                                               \
F(Dart_SetShouldPauseOnStart, void, (bool should_pause))                       \
                                                                               \
F(Dart_SetStickyError, void, (Dart_Handle error))                              \
                                                                               \
F(Dart_SetWeakHandleReturnValue, void, (                                       \
    Dart_NativeArguments args,                                                 \
    Dart_WeakPersistentHandle rval))                                           \
                                                                               \
F(Dart_ShouldPauseOnExit, bool, ())                                            \
                                                                               \
F(Dart_ShouldPauseOnStart, bool, ())                                           \
                                                                               \
F(Dart_WaitForEvent, Dart_Handle, (int64_t timeout_millis))                    \
                                                                               \
F(Dart_WriteProfileToTimeline, bool, (Dart_Port main_port,                      \
                                               char** error))                  \
                                                                               \
F(Dart_ShutdownIsolate, void, ())                                              \
                                                                               \
F(Dart_StartProfiling, void, ())                                                \
                                                                               \
F(Dart_StopProfiling, void, ())                                                 \
                                                                               \
F(Dart_StringGetProperties, Dart_Handle, (Dart_Handle str,                     \
                                                   intptr_t* char_size,        \
                                                   intptr_t* str_len,          \
                                                   void** peer))               \
                                                                               \
F(Dart_StringLength, Dart_Handle, (Dart_Handle str,                            \
                                                  intptr_t* length))           \
                                                                               \
F(Dart_StringStorageSize, Dart_Handle, (Dart_Handle str,                       \
                                                 intptr_t* size))              \
                                                                               \
F(Dart_StringToCString, Dart_Handle, (Dart_Handle str,                         \
                                               const char** cstr))             \
                                                                               \
F(Dart_StringToLatin1, Dart_Handle, (Dart_Handle str,                          \
                                              uint8_t* latin1_array,           \
                                              intptr_t* length))               \
                                                                               \
F(Dart_StringToUTF16, Dart_Handle, (Dart_Handle str,                           \
                                             uint16_t* utf16_array,            \
                                             intptr_t* length))                \
                                                                               \
F(Dart_StringToUTF8, Dart_Handle, (Dart_Handle str,                            \
                                            uint8_t** utf8_array,              \
                                            intptr_t* length))                 \
                                                                               \
F(Dart_ThreadDisableProfiling, void, ())                                        \
                                                                               \
F(Dart_ThreadEnableProfiling, void, ())                                         \
                                                                               \
F(Dart_ThrowException, Dart_Handle, (Dart_Handle exception))                   \
                                                                               \
F(Dart_ToString, Dart_Handle, (Dart_Handle object))                            \
                                                                               \
F(Dart_True, Dart_Handle, ())                                                  \
                                                                               \
F(Dart_TypedDataAcquireData, Dart_Handle, (Dart_Handle object,                 \
                                                    Dart_TypedData_Type* type, \
                                                    void** data,               \
                                                    intptr_t* len))            \
                                                                               \
F(Dart_TypedDataReleaseData, Dart_Handle, (Dart_Handle object))                \
                                                                               \
F(Dart_TypeDynamic, Dart_Handle, ())                                           \
                                                                               \
F(Dart_TypeNever, Dart_Handle, ())                                             \
                                                                               \
F(Dart_TypeToNonNullableType, Dart_Handle, (Dart_Handle type))                 \
                                                                               \
F(Dart_TypeToNullableType, Dart_Handle, (Dart_Handle type))                    \
                                                                               \
F(Dart_TypeVoid, Dart_Handle, ())                                              \
                                                                               \
F(Dart_VersionString, const char*, ())                                         \


#define DART_API_ALL_DL_SYMBOLS(F)                                             \
  DART_NATIVE_API_DL_SYMBOLS(F)                                                \
  DART_API_DL_SYMBOLS(F)
// IMPORTANT! Never update these signatures without properly updating
// DART_API_DL_MAJOR_VERSION and DART_API_DL_MINOR_VERSION.
//
// End of verbatim copy.
// ============================================================================

#define DART_API_DL_DECLARATIONS(name, R, A)                                   \
  typedef R(*name##_Type) A;                                                   \
  DART_EXTERN name##_Type name##_DL;

DART_API_ALL_DL_SYMBOLS(DART_API_DL_DECLARATIONS)

#undef DART_API_DL_DEFINITIONS

#undef DART_EXTERN

#endif /* RUNTIME_INCLUDE_DART_API_DL_H_ */ /* NOLINT */
