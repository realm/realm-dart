cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "realm")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "realm_plugin")

add_library(${PLUGIN_NAME} SHARED "realm_plugin.cpp")
apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(realm_bundled_libraries
  "${PROJECT_SOURCE_DIR}/binary/windows/realm_dart.dll"
  PARENT_SCOPE
)

# message ("CMAKE_BINARY_DIR is ${CMAKE_BINARY_DIR}")
# message ("PROJECT_SOURCE_DIR is ${PROJECT_SOURCE_DIR}")
# message ("CMAKE_CURRENT_SOURCE_DIR is ${CMAKE_CURRENT_SOURCE_DIR}")

# This works cause realm plugin is always accessed through the .plugin_symlinks directory.
# For example the tests app refers to the realm plugin using this path .../realm-dart/flutter/realm_flutter/tests/windows/flutter/ephemeral/.plugin_symlinks/realm/windows
set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../ephemeral")
include(${EPHEMERAL_DIR}/generated_config.cmake)

set(APP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../..")

# message ("APP_DIR is ${APP_DIR}")
set(APP_PUBSPEC_FILE "${APP_DIR}/pubspec.yaml")

# message ("APP_PUBSPEC_FILE is ${APP_PUBSPEC_FILE}")
file(READ "${APP_PUBSPEC_FILE}" PUBSPEC_CONTENT)
string(REGEX MATCH "name:[ \r\n\t]*([a-z0-9_]*)" _ ${PUBSPEC_CONTENT})

# message ("Pubspec name 0 is ${CMAKE_MATCH_0}")
# message ("Package name is ${CMAKE_MATCH_1}")
set(APP_DIR_NAME ${CMAKE_MATCH_1})
set(BUNDLE_ID ${CMAKE_MATCH_1})

add_definitions(-DAPP_DIR_NAME="${APP_DIR_NAME}")
add_definitions(-DBUNDLE_ID="${BUNDLE_ID}")

# message ("FLUTTER_TOOL_ENVIRONMENT is ${FLUTTER_TOOL_ENVIRONMENT}")
# message ("FLUTTER_ROOT is ${FLUTTER_ROOT}")
execute_process(COMMAND "${FLUTTER_ROOT}\\bin\\dart.bat" "run" "realm" "install" "--target-os-type" "windows" # "--debug"
  OUTPUT_VARIABLE output
  RESULT_VARIABLE result
  COMMAND_ERROR_IS_FATAL ANY
)
message(STATUS "cmd output: ${output}")
message(STATUS "cmd result: ${result}")
