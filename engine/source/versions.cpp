#include "sqlite3.h"
#include "openssl/opensslv.h"
#include "zlib.h"
#include "curl/curl.h"
#include "expat.h"
#include "fontconfig.h"
#include "cairo/cairo-version.h"
#include "pango/pango.h"
#include "clutter/clutter.h"
#include "ft2build.h"
#include "freetype/freetype.h"
#include "gif_lib.h"
#include "tiffio.h"
#include "jpeglib.h"
#define PNG_SKIP_SETJMP_CHECK 1
#include "png.h"

#include "versions.h"
#include "util.h"

const gchar * clean_version( const gchar * dirty, FreeLater & free_later )
{
    gchar ** parts = g_strsplit( dirty, "\n" , 2 );

    free_later( parts );

    if ( g_strv_length( parts ) > 0 )
    {
        return g_strstrip( parts[ 0 ] );
    }

    return dirty;
}

void dump_versions()
{
    FreeLater free_later;

    g_info( "Versions:" );
    g_info( "\ttrickplay    %d.%d.%d", TP_MAJOR_VERSION, TP_MINOR_VERSION, TP_PATCH_VERSION );
    g_info( "\tglib         %d.%d.%d (%d.%d.%d)", GLIB_MAJOR_VERSION, GLIB_MINOR_VERSION, GLIB_MICRO_VERSION, glib_major_version, glib_minor_version, glib_micro_version );
    g_info( "\tsqlite       %s (%s)", SQLITE_VERSION, sqlite3_libversion() );
    g_info( "\tlua          %s", LUA_RELEASE );
    g_info( "\topenssl      %s", OPENSSL_VERSION_TEXT );
    g_info( "\tzlib         %s", ZLIB_VERSION );
    g_info( "\tcurl         %s (%s)", LIBCURL_VERSION, curl_version_info( CURLVERSION_NOW )->version );
    g_info( "\texpat        (%s)", XML_ExpatVersion() );
    g_info( "\tgif          %s", clean_version( GIF_LIB_VERSION, free_later ) );
    g_info( "\ttiff         (%s)", clean_version( TIFFGetVersion(), free_later ) );
    g_info( "\tjpeg         %d", JPEG_LIB_VERSION );
    g_info( "\tpng          %s (%lu)", PNG_LIBPNG_VER_STRING, png_access_version_number() );
    g_info( "\tfreetype     %d.%d.%d", FREETYPE_MAJOR, FREETYPE_MINOR, FREETYPE_PATCH );
    g_info( "\tfontconfig   %d.%d.%d", FC_MAJOR, FC_MINOR, FC_REVISION );
    g_info( "\tcairo        %d.%d.%d", CAIRO_VERSION_MAJOR, CAIRO_VERSION_MINOR, CAIRO_VERSION_MICRO );
    g_info( "\tpango        %s (%s)", PANGO_VERSION_STRING, pango_version_string() );
    g_info( "\tclutter      %s [%s-%s]", CLUTTER_VERSION_S, CLUTTER_FLAVOUR, CLUTTER_COGL );
}
