option(REALM_BUILD_CORE_FROM_SOURCE "Build Realm Core from source" ON)
if(REALM_BUILD_CORE_FROM_SOURCE)
    set(REALM_BUILD_LIB_ONLY ON)
    set(REALM_ENABLE_SYNC OFF)

    add_subdirectory(realm-core EXCLUDE_FROM_ALL)
endif()

add_subdirectory(dart-dl)

set(SOURCES
    realm_dart.cpp
    realm_dart_scheduler.cpp
)

set(HEADERS
    realm_dart.h
    realm_dart_scheduler.h
    realm-core/src/realm.h
)

add_library(realm_dart SHARED ${SOURCES} ${HEADERS})
target_compile_definitions(RealmFFIStatic PUBLIC -DRealm_EXPORTS)

target_link_libraries(realm_dart dart-dl RealmFFIStatic Realm::Storage)

if(CMAKE_C_COMPILER_ID STREQUAL MSVC)
    target_link_options(realm_dart PRIVATE /WHOLEARCHIVE:$<TARGET_FILE:RealmFFIStatic>)
elseif(CMAKE_C_COMPILER_ID STREQUAL GCC)
    target_link_options(realm_dart PRIVATE LINKER:--whole-archive,-l$<TARGET_FILE:RealmFFIStatic>,--no-whole-archive)
elseif(CMAKE_C_COMPILER_ID MATCHES "Clang$")
    target_link_options(realm_dart PRIVATE -force_load $<TARGET_FILE:RealmFFIStatic>)
endif()

string(APPEND OUTPUT_DIR "${PROJECT_SOURCE_DIR}/binary")
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    string(APPEND OUTPUT_DIR "/windows")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    string(APPEND OUTPUT_DIR "/linux")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    string(APPEND OUTPUT_DIR "/macos")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
    string(APPEND OUTPUT_DIR "/android/${CMAKE_ANDROID_ARCH_ABI}")
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    string(APPEND OUTPUT_DIR "/ios")
endif()

if(ANDROID)
    target_sources(realm_dart PRIVATE
        android/platform.cpp
    )

    # Core requires these options for the final *.so file. See more realm-core/CMakeLists.txt
    target_link_options(realm_dart PRIVATE LINKER:-gc-sections)

    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/binary/android/${ANDROID_ABI}")

    # Add a custom target to strip the binary
    add_custom_target(strip ${CMAKE_STRIP} $<TARGET_FILE:realm_dart>)
elseif(CMAKE_SYSTEM_NAME STREQUAL iOS)
    target_sources(realm_dart PRIVATE
        ios/platform.mm
    )
    set_target_properties(realm_dart PROPERTIES
        FRAMEWORK TRUE
        PUBLIC_HEADER "${HEADERS}"
    )

    add_custom_command(TARGET realm_dart POST_BUILD
        COMMAND rm -rf ${OUTPUT_DIR}/realm_dart.xcframework
        COMMAND xcodebuild -create-xcframework -framework $<TARGET_FILE:realm_dart>/.. -output ${OUTPUT_DIR}/realm_dart.xcframework
    )
endif()

if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
    # using RUNTIME_OUTPUT_DIRECTORY_<CONFIG> to output the binaries in the target directory wihtout creating a sub directory
    # for multi-configuration generators (VS, XCode)
    # https://cmake.org/cmake/help/v2.8.8/cmake.html#prop_tgt:RUNTIME_OUTPUT_DIRECTORY
    set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${OUTPUT_DIR}")

    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL "${OUTPUT_DIR}")
    set_target_properties(realm_dart PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${OUTPUT_DIR}")
endif()
