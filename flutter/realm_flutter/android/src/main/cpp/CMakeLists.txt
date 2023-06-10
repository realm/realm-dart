cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "realm")

project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "realm_plugin")

set(CMAKE_VERBOSE_MAKEFILE TRUE CACHE BOOL "" FORCE)

add_library(${PLUGIN_NAME} SHARED "realm_plugin.cpp")

set(APP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../..")
message("APP_DIR is ${APP_DIR}")
message("PROJECT_SOURCE_DIR is ${PROJECT_SOURCE_DIR}")


#function(print_directory_variables dir)
#    # Dump variables:
#    get_property(_variableNames DIRECTORY ${dir} PROPERTY VARIABLES)
#    list (SORT _variableNames)
#    foreach (_variableName ${_variableNames})
#        get_directory_property(_variableValue DIRECTORY ${dir} DEFINITION ${_variableName})
#        message(STATUS "DIR ${dir}: ${_variableName}=${_variableValue}")
#    endforeach()
#endfunction(print_directory_variables)
#
#print_directory_variables(.)

# execute_process(COMMAND "echo"
#   OUTPUT_VARIABLE output  
#   RESULT_VARIABLE result
#   COMMAND_ERROR_IS_FATAL ANY
# )

# set(APP_PUBSPEC_FILE "${APP_DIR}/pubspec.yaml")
# # message ("APP_PUBSPEC_FILE is ${APP_PUBSPEC_FILE}")
# file(READ "${APP_PUBSPEC_FILE}" PUBSPEC_CONTENT)
# string(REGEX MATCH "name:[ \r\n\t]*([a-z0-9_]*)" _ ${PUBSPEC_CONTENT})
# # message ("Pubspec name 0 is ${CMAKE_MATCH_0}")
# # message ("Package name is ${CMAKE_MATCH_1}")
# set(APP_DIR_NAME ${CMAKE_MATCH_1})
# set(BUNDLE_ID ${CMAKE_MATCH_1})
# # string(ASCII 114, 101, 97, 108, 109, 32, 105, 115, 32, 103, 114, 101, 97, 116 PREFIX)
# # string(PREPEND BUNDLE_ID ${PREFIX})
# # message ("BUNDLE_ID is ${BUNDLE_ID}")
# # string(SHA256 )

# #message ("BINARY_NAME is ${BINARY_NAME}")
# add_definitions(-DAPP_DIR_NAME="${APP_DIR_NAME}")
# add_definitions(-DBUNDLE_ID="${BUNDLE_ID}")