
add_definitions( -DG_LOG_DOMAIN="stitcher" )

include( FindPkgConfig )

pkg_search_module(GLIB2         REQUIRED    glib-2.0 )
pkg_search_module(GOBJECT2      REQUIRED    gobject-2.0 )
pkg_search_module(JSON_GLIB     REQUIRED    json-glib-1.0 )
pkg_search_module(MAGICKCORE    REQUIRED    MagickCore )

include_directories(
                    ${GLIB2_INCLUDE_DIRS}
                    ${GOBJECT2_INCLUDE_DIRS}
                    ${JSON_GLIB_INCLUDE_DIRS}
                    ${MAGICKCORE_INCLUDE_DIRS}
)

link_directories(
    ${GLIB2_LIBRARY_DIRS}
    ${GOBJECT2_LIBRARY_DIRS}
    ${JSON_GLIB_LIBRARY_DIRS}
    ${MAGICKCORE_LIBRARY_DIRS}
)

add_executable( stitcher
                main.c
                options.c
                layout.c
                leaf.c
                item.c
                state.c
)

target_link_libraries( stitcher
        ${GLIB2_LIBRARIES}
        ${GOBJECT2_LIBRARIES}
        ${JSON_GLIB_LIBRARIES}
        ${MAGICKCORE_LIBRARIES}
)

set_target_properties( stitcher
    PROPERTIES
        COMPILE_FLAGS "${GLIB2_CFLAGS_OTHER} ${GOBJECT2_CFLAGS_OTHER} ${JSON_GLIB_CFLAGS_OTHER} ${MAGICKCORE_CFLAGS_OTHER}"
        LINK_FLAGS "${GLIB2_LDFLAGS_OTHER} ${GOBJECT2_LDFLAGS_OTHER} ${JSON_GLIB_LDFLAGS_OTHER} ${MAGICKCORE_LDFLAGS_OTHER} -lm"
)

install(TARGETS stitcher RUNTIME DESTINATION bin)
install(FILES stitcher.1 DESTINATION share/man/man1/)
