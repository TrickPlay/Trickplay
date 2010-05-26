#include <cstdlib>
#include <iostream>
#include <fstream>

#include "common.h"
#include "images.h"
#include "profiler.h"
#include "util.h"
#include "image_decoders.h"

//-----------------------------------------------------------------------------
// Set to 1 to get debug output

#define TP_IMAGES_DEBUG         1

//-----------------------------------------------------------------------------
// Set to 1 to enable caching of images (not hooked up yet)

#define TP_IMAGES_CACHE_ENABLED 0

//-----------------------------------------------------------------------------

inline void images_debug( const gchar * format, ... )
{
#if TP_IMAGES_DEBUG
    va_list args;
    va_start( args, format );
    g_logv( G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, format, args );
    va_end( args );
#else
#endif
}

//=============================================================================
// Wraps around an external decoder

class ExternalDecoder : public Images::Decoder
{
public:

    ExternalDecoder( TPImageDecoder _decoder, gpointer _decoder_data )
    :
        decoder( _decoder ),
        decoder_data( _decoder_data )
    {
        g_assert( decoder );
    }

    virtual const char * name()
    {
        return "External Decoder";
    }

    virtual int decode( gpointer data, gsize size, TPImage * image )
    {
        images_debug( "  INVOKING EXTERNAL DECODER WITH BUFFER OF %d BYTES", size );

        int result = decoder( data, size, image, decoder_data );

        images_debug( "    EXTERNAL DECODER RETURNED %d", result );

        if ( result == TP_IMAGE_DECODE_OK )
        {
            images_debug( "      pixels      : %p", image->pixels );
            images_debug( "      width       : %u", image->width );
            images_debug( "      height      : %u", image->height );
            images_debug( "      pitch       : %u", image->pitch );
            images_debug( "      depth       : %u", image->depth );
            images_debug( "      bgr         : %u", image->bgr );
            images_debug( "      free_pixels : %p", image->free_pixels );

            g_assert( image->pixels != NULL );
            g_assert( image->pitch >= image->width * image->depth );
            g_assert( image->depth == 3 || image->depth == 4 );
            g_assert( image->bgr == 0 );
        }
        else
        {
            g_assert( image->pixels == NULL );
        }

        return result;
    }

    virtual int decode( const char * filename, TPImage * image )
    {
        std::ifstream stream;

        stream.open( filename, std::ios_base::in | std::ios_base::binary );

        if ( ! stream.good() )
        {
            stream.close();
            return TP_IMAGE_DECODE_FAILED;
        }

        // We read the first few bytes of the file and pass that to the decoder
        // to see if it can detect the image format and tell us that it is
        // supported.

        // This attempts to optimize by not reading in the whole file before we
        // know whether the decoder supports it.

        static gsize header_size = 128;

        char header[ header_size ];

        stream.read( header, header_size );

        images_debug( "  INVOKING EXTERNAL DECODER TO DETECT IMAGE FORMAT WITH %d BYTES", header_size );

        int r = decoder( header, stream.gcount(), NULL, decoder_data );

        images_debug( "    EXTERNAL DECODER RETURNED %d", r );

        if ( r != TP_IMAGE_SUPPORTED_FORMAT )
        {
            stream.close();

            // Return unsupported format so that we will try other decoders

            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        // The decoder says that it supports the format, so we load
        // the whole file into memory and call the decoder again.

        stream.seekg( 0, std::ios::end );

        if ( stream.fail() )
        {
            stream.close();
            return TP_IMAGE_DECODE_FAILED;
        }

        std::ios::streampos pos = stream.tellg();

        if ( pos == -1 )
        {
            stream.close();
            return TP_IMAGE_DECODE_FAILED;
        }

        gchar * buffer = g_new( gchar, pos );

        if ( ! buffer )
        {
            stream.close();
            return TP_IMAGE_DECODE_FAILED;
        }

        Util::GFreeLater free_buffer( buffer );

        stream.seekg( 0 );

        stream.read( buffer, pos );

        if ( stream.fail() )
        {
            stream.close();
            return TP_IMAGE_DECODE_FAILED;
        }

        return decode( buffer, pos, image );
    }

private:

    TPImageDecoder  decoder;
    gpointer        decoder_data;
};

//=============================================================================

Images::Images()
:
    external_decoder( NULL )
{
    Decoder * png  = ImageDecoders::make_png_decoder();
    Decoder * jpeg = ImageDecoders::make_jpeg_decoder();
    Decoder * tiff = ImageDecoders::make_tiff_decoder();

    // This is the default order of decoders. The most common
    // type should go first. This order may be affected
    // dynamically by "hints" - see below.

    decoders.push_back( png );
    decoders.push_back( jpeg );
    decoders.push_back( tiff );

    // This maps the last 4 characters of a file name or mime type
    // to specific decoders. It lets us rearrange the decoders so
    // that we may hit the correct one sooner.

    hints[ ".tif" ] = tiff;
    hints[ ".TIF" ] = tiff;
    hints[ "tiff" ] = tiff;
    hints[ "TIFF" ] = tiff;

    hints[ ".png" ] = png;
    hints[ ".PNG" ] = png;
    hints[ "/png" ] = png;
    hints[ "/PNG" ] = png;

    hints[ ".jpg" ] = jpeg;
    hints[ ".JPG" ] = jpeg;
    hints[ "jpeg" ] = jpeg;
    hints[ "JPEG" ] = jpeg;
}

//-----------------------------------------------------------------------------

Images::~Images()
{
    while ( ! decoders.empty() )
    {
        delete decoders.front();
        decoders.pop_front();
    }

    if ( external_decoder )
    {
        delete external_decoder;
    }
}

//-----------------------------------------------------------------------------

Images::Images( const Images & )
{
    g_assert( false );
}

//-----------------------------------------------------------------------------

Images::Images * Images::get( bool destroy )
{
    static Images * self = NULL;

    if ( ! destroy )
    {
        if ( ! self )
        {
            self = new Images();
        }

        g_assert( self );
    }
    else
    {
        if ( self )
        {
            delete self;
            self = NULL;
        }
    }

    return self;
}

//-----------------------------------------------------------------------------

void Images::shutdown()
{
    Images::get( true );
}

//-----------------------------------------------------------------------------

void Images::set_external_decoder( TPImageDecoder decoder, gpointer decoder_data )
{
    Images * self( Images::get() );

    if ( self->external_decoder )
    {
        delete self->external_decoder;
        self->external_decoder = NULL;
    }

    self->external_decoder = new ExternalDecoder( decoder, decoder_data );
}

//-----------------------------------------------------------------------------

Images::DecoderList Images::get_decoders( const char * _hint )
{
    Images * self( Images::get() );

    DecoderList result( self->decoders );

    if ( _hint )
    {
        String hint( _hint );

        if ( hint.length() >= 4 )
        {
            hint = hint.substr( hint.length() - 4 , 4 );

            HintMap::const_iterator it = self->hints.find( hint );

            // If we find a decoder that matches the hint, we just insert
            // an instance of it at the head of the list. Yes, this means there
            // will be two of the same in the list, but chances are that the
            // first one will succeed, so we don't bother making sure the list
            // is perfect.

            if ( it != self->hints.end() )
            {
                result.push_front( it->second );
            }

        }
    }

    // The external decoder always goes first

    if ( self->external_decoder )
    {
        result.push_front( self->external_decoder );
    }

    return result;
}

//-----------------------------------------------------------------------------

TPImage * Images::decode_image( gpointer data, gsize size, const char * content_type )
{
    PROFILER( "Images::decode_image/data" );

    TPImage image;
    memset( &image, 0, sizeof( TPImage ) );

    DecoderList decoders = get_decoders( content_type );

    for ( DecoderList::const_iterator it = decoders.begin(); it != decoders.end(); ++it )
    {
        images_debug( "TRYING TO DECODE '%s' USING %s", content_type ? content_type : "<unknown>", ( * it )->name() );

        int r = ( * it )->decode( ( gpointer ) data, size, &image );

        if ( r == TP_IMAGE_UNSUPPORTED_FORMAT )
        {
            images_debug( "  UNSUPPORTED" );
            continue;
        }

        if ( r == TP_IMAGE_DECODE_FAILED )
        {
            images_debug( "  FAILED" );
            break;
        }

        images_debug( "  DECODED" );

        // It was decoded

        g_assert( image.pixels );
        g_assert( image.depth == 3 || image.depth == 4 );
        g_assert( image.width * image.depth >= image.pitch );
        g_assert( image.bgr == 0 || image.bgr == 1 );

        return g_slice_dup( TPImage, &image );
    }

    g_warning( "FAILED TO DECODE IMAGE FROM MEMORY" );

    return NULL;
}

//-----------------------------------------------------------------------------

TPImage * Images::decode_image( const char * filename )
{
    PROFILER( "Images::decode_image/file" );

    if ( ! g_file_test( filename, G_FILE_TEST_IS_REGULAR ) )
    {
        g_warning( "IMAGE DOES NOT EXIST %s", filename );
        return NULL;
    }

    TPImage image;
    memset( &image, 0, sizeof( TPImage ) );

    DecoderList decoders = get_decoders( filename );

    for ( DecoderList::const_iterator it = decoders.begin(); it != decoders.end(); ++it )
    {
        images_debug( "TRYING TO DECODE '%s' USING %s", filename, ( * it )->name() );

        int r = ( * it )->decode( filename, &image );

        if ( r == TP_IMAGE_UNSUPPORTED_FORMAT )
        {
            images_debug( "  UNSUPPORTED" );
            continue;
        }

        if ( r == TP_IMAGE_DECODE_FAILED )
        {
            images_debug( "  FAILED" );
            break;
        }

        images_debug( "  DECODED" );

        // It was decoded

        g_assert( image.pixels );
        g_assert( image.depth == 3 || image.depth == 4 );
        g_assert( image.width * image.depth >= image.pitch );
        g_assert( image.bgr == 0 || image.bgr == 1 );

        return g_slice_dup( TPImage, &image );
    }

    g_warning( "FAILED TO DECODE %s", filename );

    return NULL;
}

//-----------------------------------------------------------------------------

void Images::destroy_image( TPImage * image )
{
    if ( image )
    {
        if ( image->pixels )
        {
            if ( image->free_pixels )
            {
                image->free_pixels( image->pixels );
            }
            else
            {
                free( image->pixels );
            }
        }

        g_slice_free( TPImage, image );
    }
}

//-----------------------------------------------------------------------------

void Images::set_clutter_texture( ClutterTexture * texture, TPImage * image )
{
    PROFILER( "Images::set_clutter_texture" );

    g_assert( texture );
    g_assert( image );

    clutter_texture_set_from_rgb_data(
        texture,
        ( const guchar * ) image->pixels,
        image->depth == 4,
        image->width,
        image->height,
        image->pitch,
        image->depth,
        image->bgr ? CLUTTER_TEXTURE_RGB_FLAG_BGR : CLUTTER_TEXTURE_NONE,
        NULL );
}

//-----------------------------------------------------------------------------

bool Images::load_texture( ClutterTexture * texture, gpointer data, gsize size, const char * content_type )
{
    TPImage * image = decode_image( data, size, content_type );

    if ( ! image )
    {
        return false;
    }

    set_clutter_texture( texture, image );

    destroy_image( image );

    return true;
}

//-----------------------------------------------------------------------------

bool Images::load_texture( ClutterTexture * texture, const char * filename )
{
    TPImage * image = decode_image( filename );

    if ( ! image )
    {
        return false;
    }

    set_clutter_texture( texture, image );

    destroy_image( image );

    return true;
}



    //-------------------------------------------------------------------------

 #if TP_IMAGES_CACHE_ENABLED

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
        images_debug( "IMAGE CACHE : MISS %s", name );

        return NULL;
    }

    images_debug( "IMAGE CACHE : HIT %s", name );

    return it->second;
}

void Cache::insert( const char * name, Entry * entry )
{
    g_assert( name );
    g_assert( entry );

    Entry::destroy( entries[ name ] );

    entries[ name ] = entry;

    images_debug( "IMAGE CACHE : ADDED %s", name );
}

#endif

