
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




TP_ORDER_PATHS( TPCMP_INCLUDE_DIRS include )

include_directories(

    ${PROJECT_SOURCE_DIR}/engine/public/include
    
    ${TPCMP_INCLUDE_DIRS}    
    )

add_executable( tp-cmp main.c audio.c )

# This one must come before the clutter libraries - so we
# get the json symbols from here

TP_FIND_LIBRARY( json-glib-1.0      TPCMP_LIBRARIES )

TP_FIND_LIBRARY( clutter-glx-1.0    TPCMP_LIBRARIES )
TP_FIND_LIBRARY( clutter-gst-1.0   TPCMP_LIBRARIES )
TP_FIND_LIBRARY( clutter-gst-0.10    TPCMP_LIBRARIES )
TP_FIND_LIBRARY( gstreamer-0.10     TPCMP_LIBRARIES )
TP_FIND_LIBRARY( gstvideo-0.10      TPCMP_LIBRARIES )
TP_FIND_LIBRARY( gstbase-0.10       TPCMP_LIBRARIES )
TP_FIND_LIBRARY( gstinterfaces-0.10 TPCMP_LIBRARIES )
TP_FIND_LIBRARY( gstaudio-0.10      TPCMP_LIBRARIES )
TP_FIND_LIBRARY( xml2               TPCMP_LIBRARIES )
TP_FIND_LIBRARY( glib-2.0           TPCMP_LIBRARIES )
TP_FIND_LIBRARY( gobject-2.0        TPCMP_LIBRARIES )
TP_FIND_LIBRARY( gthread-2.0        TPCMP_LIBRARIES )


target_link_libraries( tp-cmp tpcore ${TPCMP_LIBRARIES} )

set_target_properties( tp-cmp 
    PROPERTIES 
        LINKER_LANGUAGE CXX
        OUTPUT_NAME trickplay )

install(TARGETS tp-cmp RUNTIME DESTINATION bin)

add_definitions( -DG_LOG_DOMAIN="tp-cmp" )
