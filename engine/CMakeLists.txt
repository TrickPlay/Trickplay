
add_definitions( -DTP_GIT_VERSION="${GIT_VERSION}" )

add_subdirectory( lua )
add_subdirectory( clutter_alpha_mode )

set( ENGINE_SRC     ${PROJECT_SOURCE_DIR}/engine )
set( LB_GENERATOR   ${ENGINE_SRC}/lb/bin/lb.py )
set( BINDINGS_SRC   ${ENGINE_SRC}/bindings )

set( 3RD_PARTY_SOURCE_FILES )
set( ENGINE_LIBRARY_NAMES )
set( ENGINE_SOURCE_FILES )
set( LB_FILES )

include_directories( ${ENGINE_SRC}/lua/lua-5.2.0/src )
include_directories( ${ENGINE_SRC}/clutter_alpha_mode )
include_directories( ${PROJECT_BINARY_DIR}/engine )


include( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/CMakeLists.txt )


if ( TP_WITH_GAMESERVICE )
    add_subdirectory( libgameservice )
    include_directories( ${ENGINE_SRC}/libgameservice )
    add_definitions( -DTP_WITH_GAMESERVICE=1 )
endif( TP_WITH_GAMESERVICE )


#------------------------------------------------------------------------------
# Include directories
#------------------------------------------------------------------------------

include( FindPkgConfig )

IF( PKG_CONFIG_FOUND )

    pkg_check_modules(CURL          REQUIRED    libcurl)
    pkg_check_modules(GLIB2         REQUIRED    glib-2.0)
    pkg_check_modules(GIO_UNIX      REQUIRED    gio-unix-2.0)
    pkg_check_modules(CAIRO         REQUIRED    cairo)
    pkg_check_modules(PANGO         REQUIRED    pango)
    pkg_check_modules(COGL                      cogl-1.0)
    pkg_check_modules(CLUTTER       REQUIRED    clutter-1.0)
    pkg_check_modules(CLUTTERGST    REQUIRED    clutter-gst-2.0)
    pkg_check_modules(FONTCONFIG    REQUIRED    fontconfig)
    pkg_check_modules(FREETYPE2     REQUIRED    freetype2)
    pkg_check_modules(LIBPNG        REQUIRED    libpng)
    pkg_check_modules(JSON_GLIB     REQUIRED    json-glib-1.0)
    pkg_check_modules(ATK           REQUIRED    atk)
    pkg_check_modules(SNDFILE       REQUIRED    sndfile)
    pkg_check_modules(SOUP          REQUIRED    libsoup-2.4)
    pkg_check_modules(SQLITE        REQUIRED    sqlite3)
    pkg_check_modules(OPENSSL       REQUIRED    openssl)
    pkg_check_modules(EXIF          REQUIRED    libexif)
    pkg_check_modules(EXPAT                     expat)

    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" OR TP_CLUTTER_BACKEND_EGL)
        pkg_check_modules(UUID      REQUIRED    uuid)
    else(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" OR TP_CLUTTER_BACKEND_EGL)
        pkg_check_modules(UUID      REQUIRED    ossp-uuid)
    endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" OR TP_CLUTTER_BACKEND_EGL)

    if (TP_CONTROLLER_DISCOVERY_MDNS AND NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )
        pkg_check_modules(AVAHI_CORE REQUIRED avahi-core)
        pkg_check_modules(AVAHI_GLIB REQUIRED avahi-glib)
    endif (TP_CONTROLLER_DISCOVERY_MDNS AND NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )

    list(APPEND ENGINE_INCLUDE_DIRS

        ${CURL_INCLUDE_DIRS}
        ${GLIB2_INCLUDE_DIRS}
        ${GIO_UNIX_INCLUDE_DIRS}
        ${CAIRO_INCLUDE_DIRS}
        ${PANGO_INCLUDE_DIRS}
        ${COGL_INCLUDE_DIRS}
        ${CLUTTER_INCLUDE_DIRS}
        ${CLUTTERGST_INCLUDE_DIRS}
        ${FONTCONFIG_INCLUDE_DIRS}
        ${FREETYPE2_INCLUDE_DIRS}
        ${LIBPNG_INCLUDE_DIRS}
        ${JSON_GLIB_INCLUDE_DIRS}
        ${UUID_INCLUDE_DIRS}
        ${ATK_INCLUDE_DIRS}
        ${SNDFILE_INCLUDE_DIRS}
        ${SOUP_INCLUDE_DIRS}
        ${SQLITE_INCLUDE_DIRS}
        ${OPENSSL_INCLUDE_DIRS}
        ${AVAHI_CORE_INCLUDE_DIRS}
        ${AVAHI_GLIB_INCLUDE_DIRS}
        ${EXIF_INCLUDE_DIRS}
        ${EXPAT_INCLUDE_DIRS}
    )

    list(APPEND ENGINE_LIBRARY_NAMES
        ${CURL_LIBRARIES}
        ${GLIB2_LIBRARIES}
        ${GIO_UNIX_LIBRARIES}
        ${CAIRO_LIBRARIES}
        ${PANGO_LIBRARIES}
        ${COGL_LIBRARIES}
        ${CLUTTER_LIBRARIES}
        ${CLUTTERGST_LIBRARIES}
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
        ${AVAHI_CORE_LIBRARIES}
        ${AVAHI_GLIB_LIBRARIES}
        ${EXIF_LIBRARIES}
        ${EXPAT_LIBRARIES}
    )


ELSE ( PKG_CONFIG_FOUND )

    TP_FIND_INCLUDE( curl/curl.h                            ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( glib-2.0 glib.h                        ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( gio-unix-2.0 gio/gunixsocketaddress.h  ENGINE_INCLUDE_DIRS )
    TP_FIND_LIB_INCLUDE( glib-2.0 glibconfig.h              ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( cairo cairo.h                          ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( pango-1.0 pango/pango.h                ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( clutter-1.0 clutter/clutter.h          ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( cogl-1.0 cogl/cogl.h                   ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( fontconfig fontconfig/fontconfig.h     ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( freetype2 freetype/freetype.h          ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( png.h                                  ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( json-glib-1.0 json-glib/json-glib.h    ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( ossp/uuid.h                            ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( atk-1.0 atk/atk.h                      ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( sndfile.h                              ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( libsoup-2.4 libsoup/soup.h             ENGINE_INCLUDE_DIRS )
    TP_FIND_INCLUDE( libexif/exif-data.h                    ENGINE_INCLUDE_DIRS )

    if (TP_CONTROLLER_DISCOVERY_MDNS AND NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )
        TP_FIND_INCLUDE( avahi-core core.h                  ENGINE_INCLUDE_DIRS )
        TP_FIND_INCLUDE( avahi-glib glib-watch.h            ENGINE_INCLUDE_DIRS )
        TP_FIND_INCLUDE( avahi-common watch.h               ENGINE_INCLUDE_DIRS )
        list( APPEND ENGINE_LIBRARY_NAMES avahi-core avahi-common avahi-glib )
    endif (TP_CONTROLLER_DISCOVER_MDNS AND NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin" )


#------------------------------------------------------------------------------
# Libraries
#------------------------------------------------------------------------------

    list(APPEND ENGINE_LIBRARY_NAMES

        soup-2.4

        gthread-2.0 gobject-2.0 gmodule-2.0 glib-2.0 gio-2.0

        cairo pango-1.0 pangocairo-1.0 fontconfig

        ssl crypto curl

        sqlite3

        # Make sure this one comes before the clutter libraries, otherwise
        # we will get json symbols from them - and those are outdated
        json-glib-1.0

        sndfile

        exif
    )

    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        list(APPEND ENGINE_LIBRARY_NAMES uuid )
    else(IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
        list(APPEND ENGINE_LIBRARY_NAMES ossp-uuid )
    endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

    #------------------------------------------------------------------------------
    # Use the right clutter libraries based on the backend used

    if (TP_CLUTTER_BACKEND_EGL)

        list( APPEND ENGINE_LIBRARY_NAMES clutter-eglnative-1.0 cares )

    else (TP_CLUTTER_BACKEND_EGL)

        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

            list( APPEND ENGINE_LIBRARY_NAMES clutter-osx-1.0 clutter-glx-1.0 cogl )

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

        list(APPEND ENGINE_INCLUDE_DIRS ${UPNP_INCLUDE_DIRS} )
        list(APPEND ENGINE_LIBRARY_NAMES ${UPNP_LIBRARIES} )

    ELSE( PKG_CONFIG_FOUND)

        TP_FIND_INCLUDE( upnp/upnp.h ENGINE_INCLUDE_DIRS )
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

if ( TP_FONT_DEBUG )

    add_definitions( -DTP_FONT_DEBUG=1 )

endif( TP_FONT_DEBUG )

# -----------------------------------------------------------------------------
# These packages aren't in pkg-config

if( NOT(EXPAT_FOUND) )
    # expat only doesn't exist on broken version of shitty Ubuntu
    TP_FIND_INCLUDE( expat.h                                ENGINE_INCLUDE_DIRS )
    list( APPEND ENGINE_LIBRARY_NAMES expat )
endif( NOT(EXPAT_FOUND) )

TP_FIND_INCLUDE( jpeglib.h                              ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( tiffio.h                               ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( tiffio.hxx                             ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( gif_lib.h                              ENGINE_INCLUDE_DIRS )
TP_FIND_INCLUDE( uriparser/Uri.h                        ENGINE_INCLUDE_DIRS )

list( APPEND  ENGINE_LIBRARY_NAMES jpeg png tiff tiffxx gif uriparser )

#------------------------------------------------------------------------------
# Avahi for MDNS

if (TP_CONTROLLER_DISCOVERY_MDNS)
    add_definitions( -DTP_CONTROLLER_DISCOVERY_MDNS=1 )
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        list( APPEND ENGINE_SOURCE_FILES ${ENGINE_SRC}/source/controller_discovery_mdns.mm )
    else(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        list( APPEND ENGINE_SOURCE_FILES ${ENGINE_SRC}/source/controller_discovery_mdns.cpp )
    endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
endif (TP_CONTROLLER_DISCOVERY_MDNS)

#------------------------------------------------------------------------------

if (NOT TP_CLUTTER_BACKEND_EGL)

    TP_FIND_INCLUDE( readline/readline.h ENGINE_INCLUDE_DIRS )

    list( APPEND ENGINE_LIBRARY_NAMES readline )

    add_definitions( -DTP_HAS_READLINE=1 )

endif (NOT TP_CLUTTER_BACKEND_EGL)

#------------------------------------------------------------------------------

if ( TP_WITH_WEBGL )

    add_definitions( -DTP_WITH_WEBGL=1 )


    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        list( APPEND LB_FILES ${BINDINGS_SRC}/typed_array.lb )
        list( APPEND LB_SPECIAL_MAC_FILES ${BINDINGS_SRC}/webgl.lb )
        list( APPEND ENGINE_SOURCE_FILES
            ${ENGINE_SRC}/source/typed_array.cpp
            ${ENGINE_SRC}/source/webgl.mm)
    else(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        list( APPEND LB_FILES ${BINDINGS_SRC}/webgl.lb ${BINDINGS_SRC}/typed_array.lb )
        list( APPEND ENGINE_SOURCE_FILES
            ${ENGINE_SRC}/source/typed_array.cpp
            ${ENGINE_SRC}/source/webgl.cpp)

        if (NOT TP_CLUTTER_BACKEND_EGL)

            list( APPEND ENGINE_LIBRARY_NAMES GL )

        endif (NOT TP_CLUTTER_BACKEND_EGL)

    endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

endif ( TP_WITH_WEBGL )


#------------------------------------------------------------------------------

if ( TP_FORCE_VERIFICATION )

    add_definitions( -DTP_FORCE_VERIFICATION=1 )
    add_definitions( -DTP_VERIFICATION_CODE="${TP_FORCE_VERIFICATION}" )

    string( LENGTH "${TP_FORCE_VERIFICATION}" CODE_LENGTH )

    if ( NOT CODE_LENGTH EQUAL 3 )
        message( FATAL_ERROR "VERIFICATION CODE MUST BE 3 CHARACTERS LONG" )
    endif( NOT CODE_LENGTH EQUAL 3 )

endif( TP_FORCE_VERIFICATION )

#------------------------------------------------------------------------------

if ( TP_UNLICENSED_TIMEOUT )

    add_definitions( -DTP_UNLICENSED_TIMEOUT="${TP_UNLICENSED_TIMEOUT}" )

endif( TP_UNLICENSED_TIMEOUT )

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

if (TP_JPEG_FORCE_ALPHA)

    add_definitions( -DTP_JPEG_FORCE_ALPHA=1 )

endif (TP_JPEG_FORCE_ALPHA)

#------------------------------------------------------------------------------
# Profiling
#------------------------------------------------------------------------------

set( LB_OPTIONS -l )

if (TP_PROFILING )

    add_definitions( -DTP_PROFILING=1 )

    list( APPEND LB_OPTIONS -p )

endif( TP_PROFILING )

#------------------------------------------------------------------------------
# Tracing
#------------------------------------------------------------------------------

if ( TP_TRACING )

    list( APPEND LB_OPTIONS -t )

endif( TP_TRACING )

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
    ${BINDINGS_SRC}/controller.lb
    ${BINDINGS_SRC}/controllers.lb
    ${BINDINGS_SRC}/tuner.lb
    ${BINDINGS_SRC}/tuners.lb
    ${BINDINGS_SRC}/mediaplayer.lb
    ${BINDINGS_SRC}/idle.lb
    ${BINDINGS_SRC}/json.lb
    ${BINDINGS_SRC}/regex.lb

    ${BINDINGS_SRC}/clutter_actor.lb
    ${BINDINGS_SRC}/clutter_container.lb
    ${BINDINGS_SRC}/clutter_rectangle.lb
    ${BINDINGS_SRC}/clutter_text.lb
    ${BINDINGS_SRC}/clutter_clone.lb
    ${BINDINGS_SRC}/clutter_group.lb
    ${BINDINGS_SRC}/clutter_image.lb
    ${BINDINGS_SRC}/clutter_timeline.lb
    ${BINDINGS_SRC}/clutter_animator.lb
    ${BINDINGS_SRC}/clutter_state.lb
    ${BINDINGS_SRC}/clutter_score.lb
# clutter_screen.lb has mac-specific code in it, so needs to be treated specially -- see below
    ${BINDINGS_SRC}/clutter_alpha.lb
    ${BINDINGS_SRC}/clutter_interval.lb
    ${BINDINGS_SRC}/clutter_path.lb
    ${BINDINGS_SRC}/clutter_constraint.lb

    ${BINDINGS_SRC}/sprite_sheet.lb
    ${BINDINGS_SRC}/sprite.lb
    ${BINDINGS_SRC}/nineslice.lb

    ${BINDINGS_SRC}/socket.lb

    ${BINDINGS_SRC}/uri.lb

    ${BINDINGS_SRC}/physics.lb
    ${BINDINGS_SRC}/trickplay.lb
    ${BINDINGS_SRC}/bitmap.lb
    ${BINDINGS_SRC}/canvas.lb
    ${BINDINGS_SRC}/http.lb
    ${BINDINGS_SRC}/keyboard.lb
    ${BINDINGS_SRC}/ease.lb
    ${BINDINGS_SRC}/matrix.lb
    ${BINDINGS_SRC}/physics_bullet.lb

)

# Deal with clutter_screen.lb which has Objective-C code in it for OSX
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    list( APPEND LB_SPECIAL_MAC_FILES ${BINDINGS_SRC}/clutter_screen.lb )
else(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    list( APPEND LB_FILES ${BINDINGS_SRC}/clutter_screen.lb )
endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")


if (TP_WITH_GAMESERVICE)
    list ( APPEND LB_FILES
        ${BINDINGS_SRC}/gameservice.lb
    )
endif(TP_WITH_GAMESERVICE)

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
        OUTPUT ${LB_FILE_NAME}.cpp ${LB_FILE_NAME}.h
        COMMAND ${LB_GENERATOR} ${LB_OPTIONS} "${NATIVE_LB_FILE}"
        DEPENDS ${LB_FILE} ${LB_GENERATOR} )

endforeach( LB_FILE )

foreach( LB_FILE ${LB_SPECIAL_MAC_FILES} )

    get_filename_component( LB_FILE_NAME ${LB_FILE} NAME )

    list( APPEND GENERATED_FILES ${LB_FILE_NAME}.mm )

    file( TO_NATIVE_PATH ${LB_FILE} NATIVE_LB_FILE )

    add_custom_command(
        OUTPUT ${LB_FILE_NAME}.mm ${LB_FILE_NAME}.h
        COMMAND ${LB_GENERATOR} ${LB_OPTIONS} --mac "${NATIVE_LB_FILE}"
        DEPENDS ${LB_FILE} ${LB_GENERATOR} )

endforeach( LB_FILE )

set_source_files_properties( ${GENERATED_FILES} PROPERTIES GENERATED TRUE )

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
    ${ENGINE_SRC}/source/media.cpp
    ${ENGINE_SRC}/source/mediaplayers.cpp
    ${ENGINE_SRC}/source/server.cpp
    ${ENGINE_SRC}/source/images.cpp
    ${ENGINE_SRC}/source/clutter_util.cpp

    ${ENGINE_SRC}/source/pushtexture.cpp
    ${ENGINE_SRC}/source/spritesheet.cpp
    ${ENGINE_SRC}/source/nineslice.cpp

    ${ENGINE_SRC}/source/controller_server.cpp
    ${ENGINE_SRC}/source/controller_list.cpp
    ${ENGINE_SRC}/source/controller_lirc.cpp
    ${ENGINE_SRC}/source/controller_delegates.cpp
    ${ENGINE_SRC}/source/tuner_list.cpp
    ${ENGINE_SRC}/source/tuner_delegates.cpp
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
    ${ENGINE_SRC}/source/log.cpp
    ${ENGINE_SRC}/source/keyboard.cpp
    ${ENGINE_SRC}/source/jpeg_utils.cpp
    ${ENGINE_SRC}/source/console_commands.cpp
    ${ENGINE_SRC}/source/app_resource.cpp
    ${ENGINE_SRC}/source/plugin.cpp
    ${ENGINE_SRC}/source/desktop_controller.cpp
    ${ENGINE_SRC}/source/physics_bullet.cpp
)

if (TP_WITH_GAMESERVICE)
    list ( APPEND ENGINE_SOURCE_FILES
        ${ENGINE_SRC}/source/gameservice_support.cpp
        ${ENGINE_SRC}/source/gameservice_util.cpp
    )

    list( APPEND

        ENGINE_LIBRARIES

        gameservice
        tptxmpp
    )

endif(TP_WITH_GAMESERVICE)

#------------------------------------------------------------------------------
# OSX Cursor glue stuff
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

list( APPEND

    ENGINE_SOURCE_FILES

    ${ENGINE_SRC}/source/osx/osx-cursor-glue.m
)

FIND_LIBRARY (APPKIT_LIBRARY AppKit)
MARK_AS_ADVANCED (APPKIT_LIBRARY)
FIND_LIBRARY (CORESERVICES_LIBRARY CoreServices)
MARK_AS_ADVANCED (CORESERVICES_LIBRARY)
FIND_LIBRARY (OSX_GL_LIBRARY OpenGL)
MARK_AS_ADVANCED (OSX_GL_LIBRARY)

list( APPEND

    ENGINE_LIBRARIES

    ${APPKIT_LIBRARY}
    ${CORESERVICES_LIBRARY}
    ${OSX_GL_LIBRARY}
    objc
)

endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

#------------------------------------------------------------------------------

add_library(

    tpcore

    STATIC

    ${ENGINE_SOURCE_FILES}

    ${GENERATED_FILES}

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
    tplua
    clutteralphamode

    LinearMath
    BulletDynamics
    BulletCollision
    BulletSoftBody
)
