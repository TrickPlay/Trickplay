
cmake_minimum_required( VERSION 2.6 )

project( TP )

set( LB                 ${PROJECT_SOURCE_DIR}/../lb )
set( LB_GENERATOR       ${LB}/bin/lb.py )

list( APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR} )

find_package(Lua51 REQUIRED)
find_package(GLIB2 REQUIRED)
find_package(CURL REQUIRED)
find_package(Cairo REQUIRED)
find_package(Pango REQUIRED)
find_package(Clutter REQUIRED)

# This one is temporary
find_package(GTK2 REQUIRED)


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
    ${LB}/include

    ${LUA_INCLUDE_DIR}    
    ${CLUTTER_INCLUDE_DIRS} 
    ${GTK2_GTK_INCLUDE_DIR}
    ${GLIB2_INCLUDE_DIR}
    ${CURL_INCLUDE_DIRS}
    ${CAIRO_INCLUDE_DIRS}
    ${PANGO_INCLUDE_DIRS}
)


set(

    LB_FILES
    
    clutter.lb
    timer.lb
    url_request.lb
    local_hash.lb
    globals.lb
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

link_directories(
    /opt/local/lib
)



add_executable(
    
    tp
    
    main.c
    context.cpp
    network.cpp
    storage.cpp

    ${GENERATED_FILES}
    ${LB}/src/lb.c
    
)

target_link_libraries(
    
    tp
    
    dl
    
    ${LUA_LIBRARIES}
    ${CLUTTER_LIBS}
    ${CURL_LIBS}
    ${TOKYO_LIBS}
)
