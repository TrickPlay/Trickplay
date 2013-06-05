include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )
    pkg_search_module(CLUTTER_GST   REQUIRED    clutter-gst-2.0 )
    pkg_check_modules(GSTVIDEO      REQUIRED    gstreamer-video-1.0)
    pkg_check_modules(COGL                      cogl-1.0)

    list( APPEND        TPCMP_INCLUDE_DIRS
            ${CLUTTER_GST_INCLUDE_DIRS}
            ${GSTVIDEO_INCLUDE_DIRS}
            ${COGL_INCLUDE_DIRS}
    )
    list( APPEND        TPCMP_LIBRARY_NAMES
            ${CLUTTER_GST_LIBRARIES}
            ${GSTVIDEO_LIBRARIES}
    )
ELSE( PKG_CONFIG_FOUND )
    TP_FIND_INCLUDE( clutter-1.0 clutter-gst/clutter-gst.h  TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( gstreamer-0.10 gst/gst.h               TPCMP_INCLUDE_DIRS )

    list( APPEND                        TPCMP_LIBRARY_NAMES

        # This one must come before the clutter libraries - so we
        # get the json symbols from here
        clutter-gst-1.0
        gstvideo-0.10
    )

ENDIF( PKG_CONFIG_FOUND )

foreach( LIB ${TPCMP_LIBRARY_NAMES} )
    TP_FIND_LIBRARY( ${LIB} TPCMP_LIBRARIES )
endforeach( LIB )



TP_ORDER_PATHS( TPCMP_INCLUDE_DIRS include )

include_directories(

    ${PROJECT_SOURCE_DIR}/engine/public/include
    
    ${TPCMP_INCLUDE_DIRS}    
    )

add_executable( tp-cmp main.c audio.c )



target_link_libraries( tp-cmp tpcore ${TPCMP_LIBRARIES} )

set_target_properties( tp-cmp 
    PROPERTIES 
        LINKER_LANGUAGE CXX
        OUTPUT_NAME trickplay )

install(TARGETS tp-cmp RUNTIME DESTINATION bin)

add_definitions( -DG_LOG_DOMAIN="tp-cmp" )
