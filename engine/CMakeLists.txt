
add_definitions( -DTP_GIT_VERSION="${GIT_VERSION}" )

set( ENGINE_SRC		${PROJECT_SOURCE_DIR}/engine )
set( LB_GENERATOR   ${ENGINE_SRC}/lb/bin/lb.py )
set( BINDINGS_SRC	${ENGINE_SRC}/bindings )

set( 3RD_PARTY_SOURCE_FILES )
set( ENGINE_LIBRARY_NAMES )
set( ENGINE_SOURCE_FILES )
set( LB_FILES )

include( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/CMakeLists.txt )

#------------------------------------------------------------------------------
# Include directories
#------------------------------------------------------------------------------

include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )
    pkg_check_modules(CURL REQUIRED libcurl)
    pkg_check_modules(GLIB2 REQUIRED glib-2.0)
    pkg_check_modules(GIO_UNIX REQUIRED gio-unix-2.0)
    pkg_check_modules(CAIRO REQUIRED cairo)
    pkg_check_modules(PANGO REQUIRED pango)
    pkg_check_modules(CLUTTER REQUIRED clutter-1.0)
    pkg_check_modules(FONTCONFIG REQUIRED fontconfig)
    pkg_check_modules(FREETYPE2 REQUIRED freetype2)
    pkg_check_modules(LIBPNG REQUIRED libpng)
    pkg_check_modules(JSON_GLIB REQUIRED json-glib-1.0)
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    pkg_check_modules(UUID REQUIRED uuid)
else(IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
    pkg_check_modules(UUID REQUIRED ossp-uid)
endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    pkg_check_modules(ATK REQUIRED atk)
    pkg_check_modules(SNDFILE REQUIRED sndfile)
    pkg_check_modules(SOUP REQUIRED libsoup-2.4)
    pkg_check_modules(SQLITE REQUIRED sqlite3)
    pkg_check_modules(OPENSSL REQUIRED openssl)
    # Next one not required, cos we really only care about curl
    pkg_check_modules(CARES libcares)

if (TP_CONTROLLER_DISCOVERY_MDNS)
    pkg_check_modules(AVAHI_CORE REQUIRED avahi-core)
    pkg_check_modules(AVAHI_GLIB REQUIRED avahi-glib)
endif (TP_CONTROLLER_DISCOVERY_MDNS)

    list(APPEND ENGINE_INCLUDE_DIRS
                    ${CURL_INCLUDE_DIRS}
                    ${GLIB2_INCLUDE_DIRS}
                    ${GIO_UNIX_INCLUDE_DIRS}
                    ${CAIRO_INCLUDE_DIRS}
                    ${PANGO_INCLUDE_DIRS}
                    ${CLUTTER_INCLUDE_DIRS}
                    ${FONTCONFIG_INCLUDE_DIRS}/fontconfig
                    ${FREETYPE2_INCLUDE_DIRS}
                    ${LIBPNG_INCLUDE_DIRS}
                    ${JSON_GLIB_INCLUDE_DIRS}
                    ${UUID_INCLUDE_DIRS}
                    ${ATK_INCLUDE_DIRS}
                    ${SNDFILE_INCLUDE_DIRS}
                    ${SOUP_INCLUDE_DIRS}
                    ${SQLITE_INCLUDE_DIRS}
                    ${OPENSSL_INCLUDE_DIRS}
                    ${CARES_INCLUDE_DIRS}
                    ${AVAHI_CORE_INCLUDE_DIRS}
                    ${AVAHI_GLIB_INCLUDE_DIRS}
        )

    list(APPEND ENGINE_LIBRARY_NAMES
                    ${CURL_LIBRARIES}
                    ${GLIB2_LIBRARIES}
                    ${GIO_UNIX_LIBRARIES}
                    ${CAIRO_LIBRARIES}
                    ${PANGO_LIBRARIES}
                    ${CLUTTER_LIBRARIES}
                    ${FONTCONFIG_LIBRARIES}
                    ${FREETYPE2_LIBRARIES}
                    ${LIBPNG_LIBRARIES}
                    ${JSON_LIBRARIES}
                    ${UUID_LIBRARIES}
                    ${ATK_LIBRARIES}
                    ${SNDFILE_LIBRARIES}
                    ${SOUP_LIBRARIES}
                    ${SQLITE_LIBRARIES}
                    ${OPENSSL_LIBRARIES}
                    ${CARES_LIBRARIES}
                    ${AVAHI_CORE_LIBRARIES}
                    ${AVAHI_GLIB_LIBRARIES}
        )

ELSE ( PKG_CONFIG_FOUND )
    TP_FIND_INCLUDE( curl/curl.h 						ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( glib-2.0 glib.h 			    	ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( gio-unix-2.0 gio/gunixsocketaddress.h 	ENGINE_INCLUDE_DIRS )
    TP_FIND_LIB_INCLUDE( glib-2.0 glibconfig.h			ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( cairo cairo.h						ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( pango-1.0 pango/pango.h			ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( clutter-1.0 clutter/clutter.h 		ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( fontconfig fontconfig.h            ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( freetype2 freetype/freetype.h      ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( png.h								ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( json-glib-1.0 json-glib/json-glib.h 	ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( ossp/uuid.h						ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( atk-1.0 atk/atk.h 			        ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( sndfile.h							ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( libsoup-2.4 libsoup/soup.h         ENGINE_INCLUDE_DIRS )
    if (TP_CONTROLLER_DISCOVERY_MDNS)
        TP_FIND_INCLUDE( avahi-core core.h						ENGINE_INCLUDE_DIRS )
        TP_FIND_INCLUDE( avahi-glib glib-watch.h				ENGINE_INCLUDE_DIRS )
        TP_FIND_INCLUDE( avahi-common watch.h					ENGINE_INCLUDE_DIRS )
        list( APPEND ENGINE_LIBRARY_NAMES	avahi-core avahi-common avahi-glib )
    endif (TP_CONTROLLER_DISCOVER_MDNS)


#------------------------------------------------------------------------------
# Libraries
#------------------------------------------------------------------------------

    list( 
        APPEND        ENGINE_LIBRARY_NAMES

        soup-2.4

        gthread-2.0 gobject-2.0 gmodule-2.0 glib-2.0 gio-2.0

        cairo pango-1.0 pangocairo-1.0 fontconfig

        ssl crypto cares curl

        sqlite3

        # Make sure this one comes before the clutter libraries, otherwise
        # we will get json symbols from them - and those are outdated
        json-glib-1.0

        sndfile
    )
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        list(
            APPEND ENGINE_LIBRARY_NAMES
            uuid
        )
    else(IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
        list(
            APPEND ENGINE_LIBRARY_NAMES
            ossp-uuid
        )
    endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

    #------------------------------------------------------------------------------
    # Use the right clutter libraries based on the backend used
    
    if (TP_CLUTTER_BACKEND_EGL)
    
        list( APPEND ENGINE_LIBRARY_NAMES clutter-eglnative-1.0 )
    
    else (TP_CLUTTER_BACKEND_EGL)
    
        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        
            list( APPEND ENGINE_LIBRARY_NAMES clutter-osx-1.0 clutter-glx-1.0 )
            
        else(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        
            list( APPEND ENGINE_LIBRARY_NAMES clutter-glx-1.0 GL X11 Xext Xdamage Xcomposite Xfixes )
            
        endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    
    endif (TP_CLUTTER_BACKEND_EGL)

ENDIF ( PKG_CONFIG_FOUND )

#------------------------------------------------------------------------------
# UPnP - must come after uuid cos it export some uuid symbols badly

if ( TP_CONTROLLER_DISCOVERY_UPNP OR TP_UPNP_CLIENT)

    IF( PKG_CONFIG_FOUND )
        pkg_check_modules(UPNP libupnp)
    
        list(APPEND ENGINE_INCLUDE_DIRS
                        ${UPNP_INCLUDE_DIRS}
        )
    
        list(APPEND ENGINE_LIBRARY_NAMES
                    ${UPNP_LIBRARIES}
        )
    ELSE( PKG_CONFIG_FOUND)
        TP_FIND_INCLUDE( upnp/upnp.h							ENGINE_INCLUDE_DIRS )
        list( APPEND ENGINE_LIBRARY_NAMES upnp )
        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
            list( APPEND ENGINE_LIBRARY_NAMES ixml )
        endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    ENDIF( PKG_CONFIG_FOUND )


	if ( TP_CONTROLLER_DISCOVERY_UPNP )
		
		add_definitions( -DTP_CONTROLLER_DISCOVERY_UPNP=1 )
		
		list( APPEND ENGINE_SOURCE_FILES ${ENGINE_SRC}/source/controller_discovery_upnp.cpp )
	
	endif ( TP_CONTROLLER_DISCOVERY_UPNP )
	
	if ( TP_UPNP_CLIENT )
	
		add_definitions( -DTP_UPNP_CLIENT=1 )
		
		list( APPEND LB_FILES ${BINDINGS_SRC}/upnp.lb )
	
	endif( TP_UPNP_CLIENT )
	
endif( TP_CONTROLLER_DISCOVERY_UPNP OR TP_UPNP_CLIENT )


# -----------------------------------------------------------------------------
# These packages aren't in pkg-config

TP_FIND_INCLUDE( expat.h 								ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( jpeglib.h							    ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( tiffio.h 							    ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( tiffio.hxx							    ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( gif_lib.h							    ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( uriparser/Uri.h						ENGINE_INCLUDE_DIRS )

list( APPEND        ENGINE_LIBRARY_NAMES
        expat
        jpeg png tiff tiffxx gif
        uriparser
)



#------------------------------------------------------------------------------
# Avahi for MDNS

if (TP_CONTROLLER_DISCOVERY_MDNS)
	add_definitions( -DTP_CONTROLLER_DISCOVERY_MDNS=1 )
    list( APPEND ENGINE_SOURCE_FILES ${ENGINE_SRC}/source/controller_discovery_mdns.cpp )
endif (TP_CONTROLLER_DISCOVERY_MDNS)


#------------------------------------------------------------------------------

if (NOT TP_CLUTTER_BACKEND_EGL)

	TP_FIND_INCLUDE( readline/readline.h ENGINE_INCLUDE_DIRS )
	
	list( APPEND ENGINE_LIBRARY_NAMES readline )
	
	add_definitions( -DTP_HAS_READLINE=1 ) 	

endif (NOT TP_CLUTTER_BACKEND_EGL)

#------------------------------------------------------------------------------

TP_ORDER_PATHS( ENGINE_INCLUDE_DIRS include )

list(REMOVE_DUPLICATES ENGINE_INCLUDE_DIRS)

include_directories(
    
    ${ENGINE_SRC}/public/include
    ${ENGINE_SRC}/source
    ${ENGINE_SRC}/lb/include
    
    ${ENGINE_INCLUDE_DIRS}    
)


#------------------------------------------------------------------------------

foreach( LIB ${ENGINE_LIBRARY_NAMES} )
    TP_FIND_LIBRARY( ${LIB} ENGINE_LIBRARIES )
endforeach( LIB )

#------------------------------------------------------------------------------
# all warnings
#------------------------------------------------------------------------------

set(CMAKE_CXX_FLAGS "-Wall -Wno-unused-variable")

#------------------------------------------------------------------------------
# log domain for glib log functions
#------------------------------------------------------------------------------

add_definitions( -DG_LOG_DOMAIN="tp" ) 

#------------------------------------------------------------------------------
# Add a -D for the clutter backend
#------------------------------------------------------------------------------

if (TP_CLUTTER_BACKEND_EGL)

    add_definitions( -DTP_CLUTTER_BACKEND_EGL=1 )

endif (TP_CLUTTER_BACKEND_EGL)

#------------------------------------------------------------------------------
# Add define for TP_PRODUCTION
#------------------------------------------------------------------------------

if (TP_PRODUCTION)

	add_definitions( -DTP_PRODUCTION=1 )
	add_definitions( -DG_DISABLE_ASSERT=1 )
	
endif (TP_PRODUCTION)

#------------------------------------------------------------------------------
# Profiling
#------------------------------------------------------------------------------

set( LB_OPTIONS -l )

if (TP_PROFILING )

    add_definitions( -DTP_PROFILING=1 )
    
    list( APPEND LB_OPTIONS -p )
    
endif( TP_PROFILING )

#------------------------------------------------------------------------------
# Files generated by LB
#------------------------------------------------------------------------------

list( APPEND LB_FILES
    
    ${BINDINGS_SRC}/globals.lb
    ${BINDINGS_SRC}/editor.lb

    ${BINDINGS_SRC}/timer.lb
    
    ${BINDINGS_SRC}/url_request.lb
    ${BINDINGS_SRC}/app.lb
    ${BINDINGS_SRC}/system.lb
    ${BINDINGS_SRC}/settings.lb
    ${BINDINGS_SRC}/profile.lb
    ${BINDINGS_SRC}/xml.lb
    ${BINDINGS_SRC}/stopwatch.lb
    ${BINDINGS_SRC}/restricted.lb
    ${BINDINGS_SRC}/apps.lb
    ${BINDINGS_SRC}/controllers.lb
    ${BINDINGS_SRC}/mediaplayer.lb
    ${BINDINGS_SRC}/idle.lb
    ${BINDINGS_SRC}/json.lb

	${BINDINGS_SRC}/audiosampler.lb

    ${BINDINGS_SRC}/clutter_actor.lb
    ${BINDINGS_SRC}/clutter_container.lb
    ${BINDINGS_SRC}/clutter_screen.lb
    ${BINDINGS_SRC}/clutter_rectangle.lb
    ${BINDINGS_SRC}/clutter_text.lb
    ${BINDINGS_SRC}/clutter_clone.lb
    ${BINDINGS_SRC}/clutter_group.lb
    ${BINDINGS_SRC}/clutter_image.lb
    ${BINDINGS_SRC}/clutter_timeline.lb
	${BINDINGS_SRC}/clutter_score.lb
    ${BINDINGS_SRC}/clutter_alpha.lb
    ${BINDINGS_SRC}/clutter_interval.lb    
    ${BINDINGS_SRC}/clutter_path.lb
    
    ${BINDINGS_SRC}/socket.lb
    
    ${BINDINGS_SRC}/uri.lb
    
    ${BINDINGS_SRC}/physics.lb
    ${BINDINGS_SRC}/trickplay.lb
    ${BINDINGS_SRC}/bitmap.lb
    ${BINDINGS_SRC}/canvas.lb
)

#------------------------------------------------------------------------------

if (NOT TP_PRODUCTION)

	list( APPEND LB_FILES ${BINDINGS_SRC}/devtools.lb )

endif (NOT TP_PRODUCTION)

#------------------------------------------------------------------------------

foreach( LB_FILE ${LB_FILES} )

	get_filename_component( LB_FILE_NAME ${LB_FILE} NAME )

	list( APPEND GENERATED_FILES ${LB_FILE_NAME}.cpp )
        
	file( TO_NATIVE_PATH ${LB_FILE} NATIVE_LB_FILE )
	
	add_custom_command( 
		OUTPUT ${LB_FILE_NAME}.cpp
		COMMAND ${LB_GENERATOR} ${LB_OPTIONS} ${NATIVE_LB_FILE}
		DEPENDS ${LB_FILE} ${LB_GENERATOR} )

endforeach( LB_FILE )

set_source_files_properties( ${GENERATED_FILES} PROPERTIES GENERATED TRUE )

#------------------------------------------------------------------------------
# Lua has to be built as C++ in order to get exceptions. Since most distributions
# do not already do that, we include Lua directly into our engine.

set( LUA_VERSION 5.1.4 )

set( LUA_ROOT ${PROJECT_SOURCE_DIR}/engine/lua/lua-${LUA_VERSION} )

add_definitions( -DLUA_USE_LINUX=1 )

include_directories( ${LUA_ROOT}/src ) 

set( LUA_SOURCE_FILES

    ${LUA_ROOT}/src/lapi.c
    ${LUA_ROOT}/src/lcode.c
    ${LUA_ROOT}/src/ldebug.c
    ${LUA_ROOT}/src/ldo.c
    ${LUA_ROOT}/src/ldump.c
    ${LUA_ROOT}/src/lfunc.c
    ${LUA_ROOT}/src/lgc.c
    ${LUA_ROOT}/src/llex.c
    ${LUA_ROOT}/src/lmem.c
    ${LUA_ROOT}/src/lobject.c
    ${LUA_ROOT}/src/lopcodes.c
    ${LUA_ROOT}/src/lparser.c
    ${LUA_ROOT}/src/lstate.c
    ${LUA_ROOT}/src/lstring.c
    ${LUA_ROOT}/src/ltable.c
    ${LUA_ROOT}/src/ltm.c
    ${LUA_ROOT}/src/lundump.c
    ${LUA_ROOT}/src/lvm.c
    ${LUA_ROOT}/src/lzio.c
    ${LUA_ROOT}/src/lauxlib.c
    ${LUA_ROOT}/src/lbaselib.c
    ${LUA_ROOT}/src/ldblib.c
    ${LUA_ROOT}/src/lmathlib.c
    ${LUA_ROOT}/src/loslib.c
    ${LUA_ROOT}/src/ltablib.c
    ${LUA_ROOT}/src/lstrlib.c
    ${LUA_ROOT}/src/loadlib.c
    ${LUA_ROOT}/src/liolib.c
#    ${LUA_ROOT}/src/linit.c
)

set_source_files_properties(

    ${LUA_SOURCE_FILES}
    
    PROPERTIES 
        LANGUAGE CXX
)

#------------------------------------------------------------------------------

list( APPEND 

	ENGINE_SOURCE_FILES

    ${ENGINE_SRC}/source/notify.cpp
    ${ENGINE_SRC}/source/context.cpp
    ${ENGINE_SRC}/source/app.cpp    
    ${ENGINE_SRC}/source/network.cpp
    ${ENGINE_SRC}/source/console.cpp
    ${ENGINE_SRC}/source/db.cpp
    ${ENGINE_SRC}/source/sysdb.cpp
    ${ENGINE_SRC}/source/keys.cpp
    ${ENGINE_SRC}/source/mediaplayers.cpp
    ${ENGINE_SRC}/source/server.cpp
    ${ENGINE_SRC}/source/images.cpp    
    ${ENGINE_SRC}/source/clutter_util.cpp    

    ${ENGINE_SRC}/source/controller_server.cpp
    ${ENGINE_SRC}/source/controller_list.cpp    
    ${ENGINE_SRC}/source/controller_lirc.cpp    
    ${ENGINE_SRC}/source/profiler.cpp
    ${ENGINE_SRC}/source/downloads.cpp
    ${ENGINE_SRC}/source/event_group.cpp
    ${ENGINE_SRC}/source/installer.cpp
    ${ENGINE_SRC}/source/versions.cpp
    ${ENGINE_SRC}/source/image_decoders.cpp
    ${ENGINE_SRC}/source/signature.cpp
    ${ENGINE_SRC}/source/actions.cpp
    ${ENGINE_SRC}/source/thread_pool.cpp
    ${ENGINE_SRC}/source/debugger.cpp
    ${ENGINE_SRC}/source/socket.cpp
    ${ENGINE_SRC}/source/json.cpp

    ${ENGINE_SRC}/lb/src/lb.cpp

    ${ENGINE_SRC}/source/user_data.cpp
    ${ENGINE_SRC}/source/util.cpp
    
    ${ENGINE_SRC}/source/physics.cpp
    
    ${ENGINE_SRC}/source/app_push_server.cpp
    ${ENGINE_SRC}/source/bitmap.cpp
    ${ENGINE_SRC}/source/audio_sampling.cpp
    ${ENGINE_SRC}/source/toast.cpp
    ${ENGINE_SRC}/source/http_server.cpp
    ${ENGINE_SRC}/source/http_trickplay_api_support.cpp
)

#------------------------------------------------------------------------------

add_library(
    
    tpcore
    
    STATIC

	${ENGINE_SOURCE_FILES}    
    
    ${GENERATED_FILES}
    
    ${LUA_SOURCE_FILES}
    
    ${3RD_PARTY_SOURCE_FILES}
)

set_target_properties(
    
    tpcore
    
    PROPERTIES
    LINK_INTERFACE_LIBRARIES tpcore
    COMPILE_FLAGS -fvisibility=hidden
)


target_link_libraries(

    tpcore
    
    ${ENGINE_LIBRARIES}
    m
    dl
)



