target_sources(realm_dart PRIVATE
    ios/platform.mm
)
set_target_properties(realm_dart PROPERTIES
    FRAMEWORK TRUE
    PUBLIC_HEADER "${HEADERS}"
    MACOSX_FRAMEWORK_IDENTIFIER io.realm.dart
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING "1.0.0"
    MACOSX_FRAMEWORK_BUNDLE_VERSION "1.0.0"
)

target_link_options(realm_dart PRIVATE SHELL:-framework UIKIT)

# https://developer.apple.com/forums/thread/716965
add_cxx_flag_if_supported(-fno-objc-msgsend-selector-stubs)

if(NOT $ENV{REALM_CI})
    add_custom_command(TARGET realm_dart POST_BUILD
        COMMAND rm -rf /ios/realm_dart.xcframework
        COMMAND xcodebuild -create-xcframework -framework $<TARGET_FILE:realm_dart>/.. -output /ios/realm_dart.xcframework
    )
endif()