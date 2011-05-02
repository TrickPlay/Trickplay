include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )
    pkg_check_modules(JSON_GLIB REQUIRED json-glib-1.0)
    pkg_check_modules(CLUTTER_GST REQUIRED clutter-gst-1.0)
    pkg_check_modules(GSTREAMER REQUIRED gstreamer-0.10)
    pkg_check_modules(GSTVIDEO REQUIRED gstreamer-video-0.10)
    pkg_check_modules(GSTBASE REQUIRED gstreamer-base-0.10)
    pkg_check_modules(GSTINTERFACES REQUIRED gstreamer-interfaces-0.10)
    pkg_check_modules(GSTAUDIO REQUIRED gstreamer-audio-0.10)
    pkg_check_modules(XML2 REQUIRED libxml-2.0)
    pkg_check_modules(GLIB2 REQUIRED glib-2.0)
    pkg_check_modules(CLUTTER REQUIRED clutter-1.0)
    pkg_check_modules(PANGO REQUIRED pango)
    pkg_check_modules(CAIRO REQUIRED cairo)
    pkg_check_modules(GL gl)
    pkg_check_modules(ATK REQUIRED atk)

    list( APPEND        TPCMP_INCLUDE_DIRS
            ${JSON_GLIB_INCLUDE_DIRS}
            ${CLUTTER_GST_INCLUDE_DIRS}
            ${GSTREAMER_INCLUDE_DIRS}
            ${GSTVIDEO_INCLUDE_DIRS}
            ${GSTBASE_INCLUDE_DIRS}
            ${GSTINTERFACES_INCLUDE_DIRS}
            ${GSTAUDIO_INCLUDE_DIRS}
            ${XML2_INCLUDE_DIRS}
            ${GLIB2_INCLUDE_DIRS}
            ${CLUTTER_INCLUDE_DIRS}
            ${PANGO_INCLUDE_DIRS}
            ${CAIRO_INCLUDE_DIRS}
            ${GL_INCLUDE_DIRS}
            ${ATK_INCLUDE_DIRS}
    )
    list( APPEND        TPCMP_LIBRARY_NAMES
            ${JSON_GLIB_LIBRARIES}
            ${CLUTTER_GST_LIBRARIES}
            ${GSTREAMER_LIBRARIES}
            ${GSTVIDEO_LIBRARIES}
            ${GSTBASE_LIBRARIES}
            ${GSTINTERFACES_LIBRARIES}
            ${GSTAUDIO_LIBRARIES}
            ${XML2_LIBRARIES}
            ${GLIB2_LIBRARIES}
            ${CLUTTER_LIBRARIES}
            ${PANGO_LIBRARIES}
            ${CAIRO_LIBRARIES}
            ${GL_LIBRARIES}
            ${ATK_LIBRARIES}
    )
ELSE( PKG_CONFIG_FOUND )
    TP_FIND_INCLUDE( json-glib-1.0 json-glib/json-glib.h    TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( clutter-1.0 clutter-gst/clutter-gst.h  TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( gstreamer-0.10 gst/gst.h               TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( glib-2.0 glib.h 			TPCMP_INCLUDE_DIRS )
    TP_FIND_LIB_INCLUDE( glib-2.0 glibconfig.h		TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( clutter-1.0 clutter/clutter.h 		TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( pango-1.0 pango/pango.h		TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( cairo cairo.h				TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( libxml2 libxml/parser.h       		TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( GL/gl.h                                TPCMP_INCLUDE_DIRS )
    TP_FIND_INCLUDE( atk-1.0 atk/atk.h 			            TPCMP_INCLUDE_DIRS )

    list( APPEND                        TPCMP_LIBRARY_NAMES

        # This one must come before the clutter libraries - so we
        # get the json symbols from here
        json-glib-1.0
        
        clutter-glx-1.0
        clutter-gst-1.0
        clutter-gst-0.10
        gstreamer-0.10
        gstvideo-0.10
        gstbase-0.10
        gstinterfaces-0.10
        gstaudio-0.10
        xml2
        glib-2.0
        gobject-2.0
        gthread-2.0
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
