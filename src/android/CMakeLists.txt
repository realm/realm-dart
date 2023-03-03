target_sources(realm_dart PRIVATE
    android/platform.cpp
)

# Core requires these options for the final *.so file. See more realm-core/CMakeLists.txt
target_link_options(realm_dart PRIVATE LINKER:-gc-sections)

# Add a custom target to strip the binary
add_custom_target(strip ${CMAKE_STRIP} $<TARGET_FILE:realm_dart>)