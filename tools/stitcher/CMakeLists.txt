
add_definitions( -DG_LOG_DOMAIN="stitcher" )
add_definitions( -DTP_GIT_VERSION="${GIT_VERSION}" )

include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )
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
ELSE( PKG_CONFIG_FOUND )
    TP_FIND_INCLUDE( glib-2.0       glib.h                  STITCHER_INCLUDE_DIRS )
    TP_FIND_LIB_INCLUDE( glib-2.0   glibconfig.h            STITCHER_INCLUDE_DIRS )
    TP_FIND_INCLUDE( gobject-2.0    gobject/gobject.h       STITCHER_INCLUDE_DIRS )
    TP_FIND_INCLUDE( json-glib-1.0  json-glib/json-glib.h   STITCHER_INCLUDE_DIRS )
    TP_FIND_INCLUDE( MagickCore     magickcore/MagicCore.h  STITCHER_INCLUDE_DIRS )

    list( APPEND                        STITCHER_LIBRARY_NAMES

        glib-2.0
        json-glib-1.0
        gobject-2.0
        MagickCore
    )

ENDIF( PKG_CONFIG_FOUND )

foreach( LIB ${STITCHER_LIBRARY_NAMES} )
    TP_FIND_LIBRARY( ${LIB} STITCHER_LIBRARIES )
endforeach( LIB )

TP_ORDER_PATHS( STITCHER_INCLUDE_DIRS include )

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

target_link_libraries( stitcher ${STITCHER_LIBRARIES} )

set_target_properties( tp-cmp
    PROPERTIES
        LINKER_LANGUAGE C
        OUTPUT_NAME stitcher )

install(TARGETS stitcher RUNTIME DESTINATION bin)
install(FILES stitcher.1 DESTINATION share/man/man1/)
