
TP_FIND_INCLUDE( glib-2.0 glib.h 			TPLIRC_INCLUDE_DIRS )
TP_FIND_LIB_INCLUDE( glib-2.0 glibconfig.h		TPLIRC_INCLUDE_DIRS )
TP_FIND_INCLUDE( lirc/lirc_client.h                     TPLIRC_INCLUDE_DIRS )

TP_ORDER_PATHS( TPLIRC_INCLUDE_DIRS include )

include_directories(

    ${PROJECT_SOURCE_DIR}/engine/public/include
    ${TPLIRC_INCLUDE_DIRS}    
    )

add_executable( tp-lirc main.c )

TP_FIND_LIBRARY( glib-2.0           TPLIRC_LIBRARIES )
TP_FIND_LIBRARY( gio-2.0            TPLIRC_LIBRARIES )
TP_FIND_LIBRARY( gobject-2.0        TPLIRC_LIBRARIES )
TP_FIND_LIBRARY( gthread-2.0        TPLIRC_LIBRARIES )
TP_FIND_LIBRARY( lirc_client        TPLIRC_LIBRARIES )

target_link_libraries( tp-lirc tpcore ${TPLIRC_LIBRARIES} )
    
set_target_properties( tp-lirc PROPERTIES OUTPUT_NAME tp )
