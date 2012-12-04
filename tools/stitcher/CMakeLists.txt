
add_definitions( -DG_LOG_DOMAIN='"stitcher"' )
add_definitions( -DTP_GIT_VERSION="${GIT_VERSION}" )

include( FindPkgConfig )

pkg_search_module(GLIB2         REQUIRED    glib-2.0 )
pkg_search_module(GOBJECT2      REQUIRED    gobject-2.0 )
pkg_check_modules(JSON_GLIB     REQUIRED    json-glib-1.0 )
pkg_check_modules(MAGICKCORE    REQUIRED    MagickCore )

list( APPEND        STITCHER_INCLUDE_DIRS
        ${GLIB2_INCLUDE_DIRS}
        ${GOBJECT2_INCLUDE_DIRS}
        ${JSON_GLIB_INCLUDE_DIRS}
        ${MAGICKCORE_INCLUDE_DIRS}
)
list( APPEND        STITCHER_LIBRARY_NAMES
        ${GLIB2_LIBRARIES}
        ${GOBJECT2_LIBRARIES}
        ${JSON_GLIB_LIBRARIES}
        ${MAGICKCORE_LIBRARIES}
)

include_directories(
    ${STITCHER_INCLUDE_DIRS}
)

add_executable( stitcher
                main.c
                options.c
                layout.c
                leaf.c
                item.c
                output.c
)

target_link_libraries( stitcher ${STITCHER_LIBRARY_NAMES} )

set_target_properties( stitcher
    PROPERTIES
        LINKER_LANGUAGE C
        OUTPUT_NAME stitcher )

install(TARGETS stitcher RUNTIME DESTINATION bin)
install(FILES stitcher.1 DESTINATION share/man/man1/)
