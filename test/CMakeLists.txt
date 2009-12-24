
cmake_minimum_required( VERSION 2.6 )

project( TP )

set( LUA_INCLUDE        /opt/local/include )
set( LUA_LIB            /opt/local/lib )

set( LB                 /Users/craig/code/trickplay/lb )
set( LB_GENERATOR       ${LB}/bin/lb.py )

set( CLUTTER_INCLUDE    /opt/local/include/clutter-1.0 )
set( GLIB_INCLUDE       /opt/local/include/glib-2.0 )
set( GLIB_LIB_INCLUDE   /opt/local/lib/glib-2.0/include )
set( CAIRO_INCLUDE      /opt/local/include/cairo )
set( PANGO_INCLUDE      /opt/local/include/pango-1.0 )
set( CURL_INCLUDE			/opt/local/include/curl )

# This one is temporary
set( GTK_INCLUDE			/opt/local/include/gtk-2.0 )

set(
    CLUTTER_LIBS

    clutter-glx-1.0
    pangocairo-1.0
    gthread-2.0
    gdk_pixbuf-2.0
    m
    GL
    X11
    Xext
    Xdamage
    Xcomposite
    pango-1.0
    cairo
    gobject-2.0
    gmodule-2.0
    glib-2.0
    Xfixes     
)

set(
    CURL_LIBS
    
    ssl
    crypto
    curl
)

set(
	TOKYO_LIBS
	
	tokyocabinet
)

include_directories(
    
    ${PROJECT_SOURCE_DIR}
    ${LUA_INCLUDE}
    ${LB}/include
    ${GLIB_INCLUDE}
    ${GLIB_LIB_INCLUDE}
    ${CAIRO_INCLUDE}
    ${PANGO_INCLUDE}
    ${CLUTTER_INCLUDE}
    ${CURL_INCLUDE}
    ${GTK_INCLUDE}
)

link_directories(

    ${LUA_LIB}
)

set(

    LB_FILES
    
    clutter.lb
    timer.lb
    url_request.lb
    local_hash.lb
)

add_definitions( -DG_LOG_DOMAIN="TrickPlay" ) 

#------------------------------------------------------------------------------

foreach( LB_FILE ${LB_FILES} )

	get_filename_component( LB_FILE_NAME ${LB_FILE} NAME )
	get_filename_component( LB_FILE_NAME_NO_EXT ${LB_FILE} NAME_WE )

	list( APPEND GENERATED_FILES ${LB_FILE_NAME_NO_EXT}.cpp )
        
	file( TO_NATIVE_PATH ${LB_FILE} NATIVE_LB_FILE )
	add_custom_command( 
		OUTPUT ${LB_FILE_NAME_NO_EXT}.cpp
		COMMAND ${LB_GENERATOR} -i -l ${PROJECT_SOURCE_DIR}/${NATIVE_LB_FILE}
		DEPENDS ${LB_FILE} ${LB_GENERATOR} )
        

endforeach( LB_FILE )

set_source_files_properties( ${GENERATED_FILES} PROPERTIES GENERATED TRUE )

#------------------------------------------------------------------------------

add_executable(
    
    tp
    
    main.cpp
    network.cpp
    storage.cpp
    ${GENERATED_FILES}
    ${LB}/src/lb.c
    
)

target_link_libraries(
    
    tp
    
    dl
    lua
    
    ${CLUTTER_LIBS}
    ${CURL_LIBS}
    ${TOKYO_LIBS}
)
