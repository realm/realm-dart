set(SOURCES
     platform.mm
)

set(HEADERS
    platform.h
    ../realm-core/src/realm.h
)

add_library(realm_flutter_ios STATIC ${SOURCES} ${HEADERS})