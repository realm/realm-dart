set(SOURCES
     realm_dart.cpp
     realm_dart_scheduler.cpp
     dart-include/dart_api_dl.c
)

set(HEADERS
    realm_dart.h
    realm_dart_scheduler.h
    realm-core/src/realm.h
)

set (INCLUDE_DIRS
    dart-include
    dart-include/internal
)

if(NOT CMAKE_SYSTEM_NAME STREQUAL iOS)
    add_library(realm_dart SHARED ${SOURCES} ${HEADERS})
    set_target_properties(realm_dart PROPERTIES POSITION_INDEPENDENT_CODE 1)
else() #iOS
    # building a static library for iOS
    add_library(realm_dart STATIC ${SOURCES} ${HEADERS})
    set(CMAKE_SYSTEM_NAME iOS)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

    set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO)

    add_subdirectory(ios)
    target_link_libraries(realm_dart realm_flutter_ios)
endif()

target_include_directories(realm_dart PUBLIC ${INCLUDE_DIRS})

if(APPLE)
    target_link_libraries(realm_dart "-framework CoreFoundation")
endif()

option(REALM_BUILD_CORE_FROM_SOURCE "Build Realm Core from source" ON)
if(REALM_BUILD_CORE_FROM_SOURCE)
    set(REALM_BUILD_LIB_ONLY ON)
    set(REALM_ENABLE_SYNC ON)

    if(ANDROID)
        message ("Realm Flutter Android build enabled")
        set(REALM_ANDROID ON)
    endif()

    add_subdirectory(realm-core EXCLUDE_FROM_ALL)
endif()

target_compile_definitions(RealmFFIStatic PUBLIC -DRealm_EXPORTS)

target_link_libraries(realm_dart RealmFFIStatic)

set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/binary")
if(ANDROID)
    find_package(Threads REQUIRED)
    target_link_libraries(realm_dart Threads::Threads)

    add_subdirectory(android)
    target_link_libraries(realm_dart realm_flutter_android)

    #core requires these options for the final *.so file. See more realm-core/CMakeLists.txt
    add_compile_options(-Wl,-gc-sections)

    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/binary/android/${ANDROID_ABI}")

    if (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
        message("Stripping enabled for Release or MinSizeRel builds")
        add_custom_command(TARGET realm_dart
        POST_BUILD
        COMMAND ${CMAKE_STRIP} $<TARGET_FILE:realm_dart>)
    endif()
endif()


string(APPEND OUTPUT_DIR "${PROJECT_SOURCE_DIR}/binary")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    string(APPEND OUTPUT_DIR "/windows")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/binary/linux")
elseif (APPLE)
    string(APPEND OUTPUT_DIR "/macos")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${OUTPUT_DIR}")
endif()

# using RUNTIME_OUTPUT_DIRECTORY_<CONFIG> to output the binaries in the target directory wihtout creating a sub directory
# for multi-configuration generators (VS, XCode)
# https://cmake.org/cmake/help/v2.8.8/cmake.html#prop_tgt:RUNTIME_OUTPUT_DIRECTORY
set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIR}")
set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIR}")
set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${OUTPUT_DIR}")
set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${OUTPUT_DIR}")