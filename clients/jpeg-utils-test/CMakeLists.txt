include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )
    pkg_check_modules(GLIB2 REQUIRED glib-2.0)

    list( APPEND TPJPEG_INCLUDE_DIRS
            ${GLIB2_INCLUDE_DIRS}
    )
    list( APPEND TPJPEG_LIBRARY_NAMES
            ${GLIB2_LIBRARIES}
    )
ELSE( PKG_CONFIG_FOUND )
    TP_FIND_INCLUDE( glib-2.0 glib.h TPJPEG_INCLUDE_DIRS )

    list( APPEND TPJPEG_LIBRARY_NAMES
        glib-2.0
    )

ENDIF( PKG_CONFIG_FOUND )

foreach( LIB ${TPJPEG_LIBRARY_NAMES} )
    TP_FIND_LIBRARY( ${LIB} TPJPEG_LIBRARIES )
endforeach( LIB )



TP_ORDER_PATHS( TPJPEG_INCLUDE_DIRS include )
include_directories( ${PROJECT_SOURCE_DIR}/engine/source  ${TPJPEG_INCLUDE_DIRS}  )
add_executable( jpeg-utils-test main.cpp )
target_link_libraries( jpeg-utils-test tpcore ${TPJPEG_LIBRARY_NAMES} )
set_target_properties( jpeg-utils-test 
    PROPERTIES LINKER_LANGUAGE CXX 
    OUTPUT_NAME jpeg-find-orientation)

