cmake_minimum_required(VERSION 3.15)

project(realm-dart-extension-main)

message ("Realm Dart Extension")
message ("CMAKE_BINARY_DIR is ${CMAKE_BINARY_DIR}")
message ("PROJECT_SOURCE_DIR is ${PROJECT_SOURCE_DIR}")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_CXX_EXTENSIONS off)

set(REALM_PLATFORM "Node")

set(_SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING=1)

#set(DART_INCLUDE_DIR "" CACHE PATH "Location of Dart SDK include (.h) files.")

#add_library(realm-dart-extension SHARED realm-dart-extension.cpp realm-dart-extension-dllmain-win.cpp)

#target_include_directories(realm-dart-extension PUBLIC ${DART_INCLUDE_DIR})


#target_compile_definitions(realm-object-store PUBLIC -DREALM_PLATFORM_NODE=1)

#target_link_libraries(realm-dart-extension "c:\\Users\\lubo\\Downloads\\dartsdk-windows-x64-release\\dart-sdk\\bin\\dart.lib")

#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "..\..")
#set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../..)

#set_target_properties( sample_extension
#  PROPERTIES
#  RUNTIME_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/../../"
#)

#message ("Copy target is ${CMAKE_BINARY_DIR}/src/realm-dart-extension/${CONFIGURATION}/realm-dart-extension.dll")
#add_custom_command(TARGET realm-dart-extension POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_BINARY_DIR}/src/realm-dart-extension/$<CONFIGURATION>/realm-dart-extension.dll"  ${PROJECT_SOURCE_DIR}/lib)

add_subdirectory(src/realm-dart-extension)
#add_subdirectory(src/object-store)
