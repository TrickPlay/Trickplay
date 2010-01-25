
set( ENGINE_SRC		${PROJECT_SOURCE_DIR}/engine )

set( LB_GENERATOR       ${ENGINE_SRC}/lb/bin/lb.py )

list( APPEND CMAKE_MODULE_PATH ${ENGINE_SRC}/cmake )

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
    gio-2.0
    Xfixes     
    expat
)

set(
    CURL_LIBS
    
    ssl
    crypto
    curl
#    ${CURL_LIBRARY}
)

set(
    TOKYO_LIBS
	
    tokyocabinet
)

set(
    AVAHI_LIBS
    
    avahi-core
    avahi-common
    avahi-glib
)

include_directories(
    
    ${ENGINE_SRC}/public/include
    ${ENGINE_SRC}/source
    ${ENGINE_SRC}/lb/include

    ${LUA_INCLUDE_DIR}    
    ${CLUTTER_INCLUDE_DIRS} 
    ${GTK2_GTK_INCLUDE_DIR}
    ${GLIB2_INCLUDE_DIR}
    ${CURL_INCLUDE_DIRS}
    ${CAIRO_INCLUDE_DIRS}
    ${PANGO_INCLUDE_DIRS}
)

set( BINDINGS_SRC ${ENGINE_SRC}/bindings )

set(

    LB_FILES
    
    ${BINDINGS_SRC}/clutter.lb
    ${BINDINGS_SRC}/timer.lb
    ${BINDINGS_SRC}/url_request.lb
    ${BINDINGS_SRC}/local_hash.lb
    ${BINDINGS_SRC}/globals.lb
    ${BINDINGS_SRC}/app.lb
    ${BINDINGS_SRC}/system.lb
    ${BINDINGS_SRC}/settings.lb
    ${BINDINGS_SRC}/profile.lb
    ${BINDINGS_SRC}/xml.lb
    ${BINDINGS_SRC}/restricted.lb
    ${BINDINGS_SRC}/apps.lb
)

add_definitions( -DG_LOG_DOMAIN="TrickPlay" ) 

#------------------------------------------------------------------------------

foreach( LB_FILE ${LB_FILES} )

	get_filename_component( LB_FILE_NAME ${LB_FILE} NAME )

	list( APPEND GENERATED_FILES ${LB_FILE_NAME}.cpp )
        
	file( TO_NATIVE_PATH ${LB_FILE} NATIVE_LB_FILE )
	
	add_custom_command( 
		OUTPUT ${LB_FILE_NAME}.cpp
		COMMAND ${LB_GENERATOR} -l ${NATIVE_LB_FILE}
		DEPENDS ${LB_FILE} ${LB_GENERATOR} )

endforeach( LB_FILE )

set_source_files_properties( ${GENERATED_FILES} PROPERTIES GENERATED TRUE )

#------------------------------------------------------------------------------

set(CMAKE_CXX_FLAGS "-Wall -Wno-unused-variable")

link_directories(
    /opt/local/lib
    /usr/local/lib
)


add_library(
    
    tpcore
    
    SHARED
    
    ${ENGINE_SRC}/source/context.cpp
    ${ENGINE_SRC}/source/network.cpp
    ${ENGINE_SRC}/source/storage.cpp
    ${ENGINE_SRC}/source/console.cpp
    ${ENGINE_SRC}/source/db.cpp
    ${ENGINE_SRC}/source/sysdb.cpp
    ${ENGINE_SRC}/source/mdns.cpp
    ${ENGINE_SRC}/source/controllers.cpp
    ${ENGINE_SRC}/source/keys.cpp

    ${GENERATED_FILES}
    ${ENGINE_SRC}/lb/src/lb.c
)

set_target_properties(tpcore PROPERTIES LINK_INTERFACE_LIBRARIES tpcore)

target_link_libraries(
    
    tpcore
    
    dl
    sqlite3
    ${LUA_LIBRARIES}
    ${CLUTTER_LIBS}
    ${CURL_LIBS}
    ${TOKYO_LIBS}
    ${AVAHI_LIBS}
)



