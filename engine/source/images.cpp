#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>

#include "FreeImage.h"
//#include "tiffio.h"
//#include "tiffio.hxx"

#include "common.h"
#include "images.h"
#include "profiler.h"

#define TP_IMAGES_CACHE_ENABLED 0

namespace Images
{

    //-------------------------------------------------------------------------

    class Cache
    {
    public:

        virtual ~Cache();

        struct Entry
        {
        public:

            static Entry * make( guchar * pixels, int width, int height, int pitch, int depth, int bgr )
            {
                Entry * entry = g_slice_new( Entry );

                entry->pixels = pixels;
                entry->width = width;
                entry->height = height;
                entry->pitch = pitch;
                entry->depth = depth;
                entry->bgr = bgr;

                return entry;
            }

            static void destroy( Entry * entry )
            {
                if ( entry )
                {
                    g_free( entry->pixels );
                    g_slice_free( Entry, entry );
                }
            }

            guchar *    pixels;
            int         width;
            int         height;
            int         pitch;
            int         depth;
            int         bgr;

        private:

            Entry()
            {}

            Entry( const Entry & )
            {}

            ~Entry()
            {}
        };

        Entry * find( const char * name ) const;

        void insert( const char * name, Entry * entry );

    private:

        typedef std::map< String, Entry * >   EntryMap;

        EntryMap    entries;
    };

    Cache::~Cache()
    {
        for ( EntryMap::iterator it = entries.begin(); it != entries.end(); ++it )
        {
            Entry::destroy( it->second );
        }
    }

    Cache::Entry * Cache::find( const char * name ) const
    {
        EntryMap::const_iterator it = entries.find( name );

        if ( it == entries.end() )
        {
            g_debug( "IMAGE CACHE : MISS %s", name );

            return NULL;
        }

        g_debug( "IMAGE CACHE : HIT %s", name );

        return it->second;
    }

    void Cache::insert( const char * name, Entry * entry )
    {
        g_assert( name );
        g_assert( entry );

        Entry::destroy( entries[ name ] );

        entries[ name ] = entry;

        g_debug( "IMAGE CACHE : ADDED %s", name );
    }

    //-------------------------------------------------------------------------

    unsigned char * decode_image( FIBITMAP * image, int & width, int & height, int & pitch, int & depth , int & bgr )
    {
        g_assert( image );

        unsigned char * result = NULL;

        // Convert it to either 24 or 32 bits (if it has transparency)

        unsigned int bpp = FreeImage_GetBPP( image );

        FIBITMAP * final_image = image;

        bool unload_final_image = false;

        if ( bpp != 32 && bpp != 24 )
        {
            PROFILER( "Images::convert_bpp" );

            FIBITMAP * image2 = NULL;

            if ( !FreeImage_IsTransparent( image ) )
            {
                image2 = FreeImage_ConvertTo24Bits( image );
                bpp = 24;
            }

            // Use this as a fallback in case we tried to convert it to 24 bits and that
            // did not work.

            if ( !image2 )
            {
                image2 = FreeImage_ConvertTo32Bits( image );
                bpp = 32;
            }

            // Bail if the conversion fails

            if ( ! image2 )
            {
                g_debug( "FAILED TO CONVERT IMAGE TO %u BITS", bpp );
                return NULL;
            }

            final_image = image2;

            unload_final_image = true;
        }

        // Allocate a buffer and convert the image to raw bits

        width  = FreeImage_GetWidth( final_image );
        height = FreeImage_GetHeight( final_image );
        pitch  = FreeImage_GetPitch( final_image );
        depth  = ( bpp == 32 ? 4 : 3 );

        result = g_new( unsigned char , height * pitch );

        {
            PROFILER( "Images::convert_to_raw" );

            FreeImage_ConvertToRawBits( ( BYTE * )result, final_image, pitch, bpp, FI_RGBA_BLUE_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_RED_MASK, TRUE );

            // Dump the image

            if ( unload_final_image )
            {
                FreeImage_Unload( final_image );
            }
        }

#if 1
        {

            PROFILER( "Images::convert_to_rgba" );

            // Now, convert from BGR(A) to RGB(A) which is what GL wants
            // Note that clutter also accepts BGR, but its conversion seems
            // slower than this.

            guchar * line = result;
            guchar * p;
            guchar px[3];


            for ( int row = 0; row < height; ++row )
            {
                p = line;

                for ( int col = 0; col < width; ++col )
                {
                    px[0] = p[0];
                    px[1] = p[1];
                    px[2] = p[2];

                    p[0] = px[2];
                    p[1] = px[1];
                    p[2] = px[0];

                    p += depth;
                }
                line += pitch;
            }

            bgr = 0;
        }

#else

        bgr = 1;

#endif

        return result;
    }


    unsigned char * decode_image( const void * data, size_t length, int & width, int & height, int & pitch, int & depth , int & bgr )
    {
        PROFILER( "Images::decode_memory" );

        // Wrap the data into a FreeImage memory stream. This does not copy the data

        FIMEMORY * mem = FreeImage_OpenMemory( ( BYTE * )data, length );

        if ( !mem )
        {
            g_debug( "FAILED TO OPEN FREEIMAGE MEMORY STREAM" );
            return NULL;
        }

        // Get the image format and bail if it is unknown

        FREE_IMAGE_FORMAT format = FreeImage_GetFileTypeFromMemory( mem, 0 );

        if ( format == FIF_UNKNOWN )
        {
            g_debug( "UNKNOWN IMAGE FORMAT" );
            FreeImage_CloseMemory( mem );
            return NULL;
        }

        // Load the image

        FIBITMAP * image = FreeImage_LoadFromMemory( format, mem, 0 );

        // Close the memory stream

        FreeImage_CloseMemory( mem );

        // Bail if the image is no good

        if ( !image )
        {
            g_debug( "FAILED TO LOAD IMAGE" );
            return NULL;
        }

        unsigned char * result = decode_image( image, width, height, pitch, depth, bgr );

        FreeImage_Unload( image );

        return result;
    }


    //-------------------------------------------------------------------------

    bool load_texture_from_data( ClutterTexture * texture, FIBITMAP * image, const char * name = NULL, Cache * cache = NULL )
    {
        int width;
        int height;
        int pitch;
        int depth;
        int bgr;

        unsigned char * pixels = decode_image( image, width, height, pitch, depth, bgr );

        if ( !pixels )
        {
            return false;
        }

        PROFILER( "Images::pass_to_clutter" );

        // Give it to clutter

        clutter_texture_set_from_rgb_data(
            texture,
            ( const guchar * )pixels,
            depth == 4,
            width,
            height,
            pitch,
            depth,
            bgr ? CLUTTER_TEXTURE_RGB_FLAG_BGR : CLUTTER_TEXTURE_NONE,
            NULL );

        if ( name && cache )
        {
            cache->insert( name, Cache::Entry::make( pixels, width, height, pitch, depth, bgr ) );
        }
        else
        {
            // Free the pixels

            g_free( pixels );
        }

        return true;
    }

    bool load_texture_from_data( ClutterTexture * texture, const void * data, size_t length, const char * name, Cache * cache )
    {
        int width;
        int height;
        int pitch;
        int depth;
        int bgr;

        unsigned char * pixels = decode_image( data, length, width, height, pitch, depth, bgr );

        if ( !pixels )
        {
            return false;
        }

        PROFILER( "Images::pass_to_clutter" );

        // Give it to clutter

        clutter_texture_set_from_rgb_data(
            texture,
            ( const guchar * )pixels,
            depth == 4,
            width,
            height,
            pitch,
            depth,
            bgr ? CLUTTER_TEXTURE_RGB_FLAG_BGR : CLUTTER_TEXTURE_NONE,
            NULL );

        if ( name && cache )
        {
            cache->insert( name, Cache::Entry::make( pixels, width, height, pitch, depth, bgr ) );
        }
        else
        {
            // Free the pixels

            g_free( pixels );
        }

        return true;
    }

    //-------------------------------------------------------------------------

    bool load_texture_from_file( ClutterTexture * texture, const char * file_name )
    {
        static Cache * cache = NULL;

#if TP_IMAGES_CACHE_ENABLED

        if ( ! cache )
        {
            cache = new Cache();
        }

        if ( cache )
        {
            if ( Cache::Entry * entry = cache->find( file_name ) )
            {
                clutter_texture_set_from_rgb_data(
                    texture,
                    entry->pixels,
                    entry->depth == 4,
                    entry->width,
                    entry->height,
                    entry->pitch,
                    entry->depth,
                    entry->bgr ? CLUTTER_TEXTURE_RGB_FLAG_BGR : CLUTTER_TEXTURE_NONE,
                    NULL );

                return true;
            }
        }

#endif

#if 0
        if ( g_str_has_suffix( file_name, ".tifCC" ) )
        {
            PROFILER( "Images::load_tif" );

#if 1
            // Directly from a file

            TIFF * tif = TIFFOpen( file_name, "r" );
#else
            // Using an input string stream

            gchar * data = NULL;
            gsize length = 0;

            GError * error = NULL;

            if ( !g_file_get_contents( file_name, &data, &length, &error ) )
            {
                return false;
            }

            std::istringstream s( String( data, length ) );


            TIFF * tif = TIFFStreamOpen( file_name , & s );
#endif

            if ( !tif )
            {
                g_debug( "FAILED FOR %s", file_name );
            }
            else
            {
                g_debug("OPENED %s", file_name );

                uint32 width;
                uint32 height;

                TIFFGetField( tif, TIFFTAG_IMAGEWIDTH, &width );
                TIFFGetField( tif, TIFFTAG_IMAGELENGTH, &height );

                size_t npixels = width * height;

                uint32 * raster = (uint32*) _TIFFmalloc( width * height * sizeof( uint32 ) );

                if ( raster )
                {
                    g_debug( "GOT RASTER" );

                    if ( TIFFReadRGBAImageOriented( tif, width, height, raster, ORIENTATION_TOPLEFT, 1 ) )
                    {
                        g_debug( "DECODED" );

                        PROFILER( "Images::load_texture_from_data" );

                        clutter_texture_set_from_rgb_data(
                            texture,
                            (const guchar *)raster,
                            TRUE,
                            width,
                            height,
                            width * 4,
                            4,
                            CLUTTER_TEXTURE_NONE,
                            NULL );

                        result = true;
                    }
                    _TIFFfree(raster);
                }
                TIFFClose(tif);
            }
        }
#endif

        PROFILER( "Images::decode_file" );

        FREE_IMAGE_FORMAT f = FreeImage_GetFileType(file_name);

        FIBITMAP * image = FreeImage_Load(f,file_name);

        if ( ! image )
        {
            g_warning( "FAILED TO LOAD IMAGE %s", file_name );
            return false;
        }

        bool result = load_texture_from_data( texture, image, file_name, cache );

        FreeImage_Unload( image );

        return result;
    }
}
