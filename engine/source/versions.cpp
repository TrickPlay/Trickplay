#include "ossp/uuid.h"
#include "sqlite3.h"
#include "openssl/opensslv.h"
#include "zlib.h"
#include "curl/curl.h"
#include "expat.h"
#include "fontconfig/fontconfig.h"
#include "cairo/cairo-version.h"
#include "pango/pango.h"
#include "json-glib/json-glib.h"
#define CLUTTER_VERSION_MIN_REQUIRED CLUTTER_VERSION_CUR_STABLE
#include "clutter/clutter.h"
#include "ft2build.h"
#include "freetype/freetype.h"
#include "gif_lib.h"
#include "tiffio.h"
#include "jpeglib.h"
#include "sndfile.h"
#include "upnp/upnp.h"
#ifdef TP_HAS_READLINE
#include "readline/readline.h"
#endif

#define PNG_SKIP_SETJMP_CHECK 1
#include "png.h"

#include "versions.h"
#include "util.h"
#include "trickplay/trickplay.h"

static String clean_version( const gchar * dirty )
{
    String result( dirty );

    gchar ** parts = g_strsplit( dirty, "\n" , 2 );

    if ( g_strv_length( parts ) > 0 )
    {
        result = g_strstrip( parts[ 0 ] );
    }

    g_strfreev( parts );

    return result;
}

// If build passes us a GIT revision then use it, otherwise just define it as blank
#if !defined(TP_GIT_VERSION)
	#define TP_GIT_VERSION "nogit"
#endif

void dump_versions()
{
    VersionMap v = get_versions();

    g_info( "VERSIONS" );
    g_info( "--------" );
    g_info( "%-10s %d.%d.%d [%s]" , "trickplay" , TP_MAJOR_VERSION , TP_MINOR_VERSION , TP_PATCH_VERSION, TP_GIT_VERSION );
    g_info( "" );

    for ( VersionMap::iterator it = v.begin(); it != v.end(); ++it )
    {
        const StringVector & vs( it->second );

        String line( vs[ 0 ] );

        if ( line != vs[ 1 ] )
        {
            line += "/";
            line += vs[ 1 ];
        }

        if ( ! vs[ 2 ].empty() )
        {
            line += " [";
            line += vs[ 2 ];
            line += "]";
        }

        g_info( "%-10s %s" , it->first.c_str() , line.c_str() );
    }
}

VersionMap get_versions()
{
    VersionMap result;

    result[ "glib" ].push_back( Util::format( "%d.%d.%d" , glib_major_version, glib_minor_version, glib_micro_version ) );
    result[ "glib" ].push_back( Util::format( "%d.%d.%d",  GLIB_MAJOR_VERSION, GLIB_MINOR_VERSION, GLIB_MICRO_VERSION ) );

    result[ "sqlite" ].push_back( sqlite3_libversion() );
    result[ "sqlite" ].push_back( SQLITE_VERSION );

    result[ "lua" ].push_back( LUA_RELEASE );

    result[ "openssl" ].push_back( OPENSSL_VERSION_TEXT );

    result[ "zlib" ].push_back( ZLIB_VERSION );

    result[ "curl" ].push_back( curl_version_info( CURLVERSION_NOW )->version );
    result[ "curl" ].push_back( LIBCURL_VERSION );

    result[ "expat" ].push_back( XML_ExpatVersion() );

#ifdef GIF_LIB_VERSION
    result[ "gif" ].push_back( clean_version( GIF_LIB_VERSION ) );
#else
    result[ "gif" ].push_back( Util::format( "%d.%d.%d", GIFLIB_MAJOR, GIFLIB_MINOR, GIFLIB_RELEASE ) );
#endif

    result[ "tiff" ].push_back( clean_version( TIFFGetVersion() ) );

    result[ "jpeg" ].push_back( Util::format( "%d" , JPEG_LIB_VERSION ) );

    result[ "png" ].push_back( png_get_libpng_ver(NULL) );
    result[ "png" ].push_back( PNG_LIBPNG_VER_STRING );

    result[ "freetype" ].push_back( Util::format( "%d.%d.%d" , FREETYPE_MAJOR, FREETYPE_MINOR, FREETYPE_PATCH ) );

    result[ "fontconfig" ].push_back( Util::format( "%d.%d.%d", FC_MAJOR, FC_MINOR, FC_REVISION ) );

    result[ "cairo" ].push_back( Util::format( "%d.%d.%d", CAIRO_VERSION_MAJOR, CAIRO_VERSION_MINOR, CAIRO_VERSION_MICRO ) );

    result[ "pango" ].push_back( pango_version_string() );
    result[ "pango" ].push_back( PANGO_VERSION_STRING );

    result[ "clutter" ].push_back( Util::format( "%d.%d.%d" , clutter_major_version , clutter_minor_version , clutter_micro_version ) );
    result[ "clutter" ].push_back( CLUTTER_VERSION_S );
#ifdef CLUTTER_VERSION_1_10
    result[ "clutter" ].push_back( Util::format( "%s" , g_type_name(G_TYPE_FROM_INSTANCE(clutter_get_default_backend())) ) );
#else
    result[ "clutter" ].push_back( Util::format( "%s-%s" , CLUTTER_FLAVOUR, CLUTTER_COGL ) );
#endif

    result[ "sndfile" ].push_back( sf_version_string() );

    result[ "uuid" ].push_back( Util::format( "0x%08x", uuid_version() ) );
    result[ "uuid" ].push_back( Util::format( "0x%08x", UUID_VERSION ) );

    result[ "json" ].push_back( JSON_VERSION_S );

    result[ "upnp" ].push_back( UPNP_VERSION_STRING );

#ifdef TP_HAS_READLINE
    result[ "readline" ].push_back( rl_library_version );
    result[ "readline" ].push_back( Util::format( "%d.%d", RL_VERSION_MAJOR, RL_VERSION_MINOR ) );
#endif

    // Fix it up

    for ( VersionMap::iterator it = result.begin(); it != result.end(); ++it )
    {
        if ( it->second.size() < 2 )
        {
            it->second.push_back( it->second[ 0 ] );
        }

        if ( it->second.size() < 3 )
        {
            it->second.push_back( "" );
        }
    }

    return result;
}
