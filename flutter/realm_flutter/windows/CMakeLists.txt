cmake_minimum_required(VERSION 3.19)
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

# message ("FLUTTER_TOOL_ENVIRONMENT is ${FLUTTER_TOOL_ENVIRONMENT}")
# message ("FLUTTER_ROOT is ${FLUTTER_ROOT}")

execute_process(COMMAND "${FLUTTER_ROOT}\\bin\\flutter.bat" "pub" "run" "realm" "install" "--target-os-type" "windows" "--package-name" "realm" #"--debug"
  OUTPUT_VARIABLE output
  RESULT_VARIABLE result
  COMMAND_ERROR_IS_FATAL ANY
)
message(STATUS "cmd output: ${output}")
message(STATUS "cmd result: ${result}")

# message("CMAKE_HOST_SYSTEM_VERSION ${CMAKE_HOST_SYSTEM_VERSION}")
execute_process(
  COMMAND "${FLUTTER_ROOT}\\bin\\flutter.bat" "pub" "run" "realm" "metrics" "--verbose" "--flutter-root" "${FLUTTER_ROOT}\\bin" "--target-os-type" "windows" "--target-os-version" "${CMAKE_HOST_SYSTEM_VERSION}" #"--pause-isolates-on-start" "--enable-vm-service"
  # COMMAND ${CMAKE_COMMAND} -E true
  OUTPUT_VARIABLE output
  RESULT_VARIABLE result
  # COMMAND_ERROR_IS_FATAL LAST
)
message(STATUS "cmd output: ${output}")
message(STATUS "cmd result: ${result}")
