#include <cstdlib>
#include <iostream>
#include <fstream>
#include <algorithm>

#include "clutter/clutter.h"

#include "common.h"
#include "images.h"
#include "profiler.h"
#include "util.h"
#include "image_decoders.h"

//=============================================================================
// Set to OFF to stop image debug log

Debug_OFF images_debug;

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

        static gsize header_size = 64;

        char header[ header_size ];

        stream.read( header, header_size );

        images_debug( "  INVOKING EXTERNAL DECODER TO DETECT IMAGE FORMAT WITH %d BYTES", stream.gcount() );

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

        FreeLater free_later( buffer );

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
// Wraps around a TPImage to make it a little safer

Image * Image::make( const TPImage & image )
{
    return new Image( g_slice_dup( TPImage,  &image ) );
}

//-----------------------------------------------------------------------------

Image * Image::decode( gpointer data, gsize size, const gchar * content_type )
{
    TPImage * image = Images::decode_image( data, size, content_type );

    return image ? new Image( image ) : NULL;
}

//-----------------------------------------------------------------------------

Image * Image::decode( const gchar * filename )
{
    TPImage * image = Images::decode_image( filename );

    return image ? new Image( image ) : NULL;
}

//-----------------------------------------------------------------------------

Image * Image::screenshot()
{
    TPImage image;

    ClutterActor * stage = clutter_stage_get_default();

    gfloat width;
    gfloat height;

    clutter_actor_get_size( stage , & width , & height );

    image.pixels = clutter_stage_read_pixels( CLUTTER_STAGE( stage ) , 0 , 0 , width , height );

    if ( ! image.pixels )
    {
        return 0;
    }

    // The alpha component of the stage is meaningless, so we set it
    // to 255 for every pixel.

    guchar * p = ( guchar * ) image.pixels + 3;

    for ( int i = 0; i < width * height ; ++i , p += 4  )
    {
        *p = 255;
    }

    image.width = width;
    image.height = height;
    image.depth = 4;
    image.pitch = width * 4;
    image.bgr = 0;
    image.free_pixels = g_free;

    return Image::make( image );
}

//-----------------------------------------------------------------------------

Image::Image()
{
    g_assert( false );
}

//-----------------------------------------------------------------------------

Image::Image( TPImage * _image )
:
    image( _image )
{
    g_assert( image );
}

//-----------------------------------------------------------------------------

Image::Image( const Image & )
{
    g_assert( false );
}

//-----------------------------------------------------------------------------

Image::~Image()
{
    Images::destroy_image( image );
}

//-----------------------------------------------------------------------------

Image * Image::convert_to_cairo_argb32() const
{
    TPImage * result = g_slice_new0( TPImage );

    result->bgr = FALSE;
    result->depth = 4;
    result->height = image->height;
    result->width = image->width;
    result->pitch = image->width * 4;
    result->pixels = malloc( image->width * image->height * 4 );
    result->free_pixels = NULL;

    guint8 * dest_pixel = ( guint8 * ) result->pixels;

    const guint8 * source_pixel;

    double mult;

    for ( unsigned int r = 0; r < image->height; ++r )
    {
        source_pixel = ( ( const guint8 * ) image->pixels ) + ( image->pitch * r );

        for ( unsigned int c = 0; c < image->width; ++c )
        {
            if ( image->depth == 3 )
            {
#if ( G_BYTE_ORDER == G_LITTLE_ENDIAN )
                *(dest_pixel++) = source_pixel[2];
                *(dest_pixel++) = source_pixel[1];
                *(dest_pixel++) = source_pixel[0];
                *(dest_pixel++) = 255;
#else
                *(dest_pixel++) = 255;
                *(dest_pixel++) = source_pixel[0];
                *(dest_pixel++) = source_pixel[1];
                *(dest_pixel++) = source_pixel[2];
#endif
                source_pixel += 3;

            }
            else
            {
                mult = source_pixel[ 3 ] / 255.0;

#if ( G_BYTE_ORDER == G_LITTLE_ENDIAN )

                *(dest_pixel++) = source_pixel[2] * mult;
                *(dest_pixel++) = source_pixel[1] * mult;
                *(dest_pixel++) = source_pixel[0] * mult;
                *(dest_pixel++) = source_pixel[3];
#else
                *(dest_pixel++) = source_pixel[3];
                *(dest_pixel++) = source_pixel[0] * mult;
                *(dest_pixel++) = source_pixel[1] * mult;
                *(dest_pixel++) = source_pixel[2] * mult;
#endif
                source_pixel += 4;
            }
        }
    }

    return new Image( result );
}

//-----------------------------------------------------------------------------

String Image::checksum() const
{
    GChecksum * ck = g_checksum_new( G_CHECKSUM_MD5 );

    guchar * source;

    for ( unsigned int r = 0; r < image->height; ++r )
    {
        source = ( ( guchar * ) image->pixels ) + ( image->pitch * r );

        g_checksum_update( ck , source , image->width * image->depth );
    }

    String result( g_checksum_get_string( ck ) );

    g_checksum_free( ck );

    return result;
}

//-----------------------------------------------------------------------------

static void surface_destroy_image( void * image )
{
    delete ( Image * ) image;
}

//-----------------------------------------------------------------------------

cairo_surface_t * Image::cairo_surface() const
{
    Image * cairo_image = convert_to_cairo_argb32();

    if ( ! cairo_image )
    {
        return 0;
    }

    cairo_surface_t * surface = cairo_image_surface_create_for_data(
        ( unsigned char * ) cairo_image->pixels(),
        CAIRO_FORMAT_ARGB32,
        cairo_image->width(),
        cairo_image->height(),
        cairo_image->pitch() );

    if ( ! surface )
    {
        delete cairo_image;

        return 0;
    }

    // We attach the image to the cairo surface so that it will be
    // destroyed when the surface is destroyed.

    static cairo_user_data_key_t image_key;

    cairo_surface_set_user_data( surface , & image_key , cairo_image , surface_destroy_image );

    return surface;
}

//-----------------------------------------------------------------------------

bool Image::write_to_png( const gchar * filename ) const
{
    bool result = false;

    if ( cairo_surface_t * surface = this->cairo_surface() )
    {
        result = ( CAIRO_STATUS_SUCCESS == cairo_surface_write_to_png( surface , filename ) );

        cairo_surface_destroy( surface );
    }

    return result;
}


//=============================================================================

Images::Images()
:
    external_decoder( NULL )
{
    g_static_rec_mutex_init( & mutex );

    Decoder * png  = ImageDecoders::make_png_decoder();
    Decoder * jpeg = ImageDecoders::make_jpeg_decoder();
    Decoder * tiff = ImageDecoders::make_tiff_decoder();
    Decoder * gif  = ImageDecoders::make_gif_decoder();

    // This is the default order of decoders. The most common
    // type should go first. This order may be affected
    // dynamically by "hints" - see below.

    decoders.push_back( png );
    decoders.push_back( jpeg );
    decoders.push_back( gif );
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

    hints[ ".gif" ] = gif;
    hints[ ".GIF" ] = gif;
    hints[ "/gif" ] = gif;
    hints[ "/GIF" ] = gif;


#if TP_IMAGE_CACHE_ENABLED

    cache_limit = TP_IMAGE_CACHE_DEFAULT_LIMIT_BYTES;

    cache_size = 0;

#endif
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

#if TP_IMAGE_CACHE_ENABLED

    for( CacheMap::iterator it = cache.begin(); it != cache.end(); ++it )
    {
        destroy_image( it->second.first );
    }

#endif

    g_static_rec_mutex_free( & mutex );
}

//-----------------------------------------------------------------------------

Images::Images( const Images & )
{
    g_assert( false );
}

//-----------------------------------------------------------------------------

Images * Images::get( bool destroy )
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

    Util::GSRMutexLock lock( & self->mutex );

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

    Util::GSRMutexLock lock( & self->mutex );

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
    PROFILER( "Images::decode_image/data" , PROFILER_INTERNAL_CALLS );

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
        g_assert( image.width * image.depth <= image.pitch );
        g_assert( image.bgr == 0 || image.bgr == 1 );

        return g_slice_dup( TPImage, &image );
    }

    g_warning( "FAILED TO DECODE IMAGE FROM MEMORY" );

    return NULL;
}

//-----------------------------------------------------------------------------

TPImage * Images::decode_image( const char * filename )
{
    PROFILER( "Images::decode_image/file" , PROFILER_INTERNAL_CALLS );

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
        g_assert( image.width * image.depth <= image.pitch );
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

void Images::load_texture( ClutterTexture * texture, TPImage * image )
{
    PROFILER( "Images::load_texture/clutter" , PROFILER_INTERNAL_CALLS );

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

#ifndef TP_PRODUCTION

    // If the image does not exist in our map, we add it and also set
    // a weak ref so we know when it is destroyed. If it is already in
    // the map, we just update its information.

    Images * self( Images::get() );

    Util::GSRMutexLock lock( & self->mutex );

    ImageInfo info( image );

    ImageMap::iterator it( self->images.find( texture ) );

    if ( it == self->images.end() )
    {
        self->images[ texture ] = info;

        g_object_weak_ref( G_OBJECT( texture ), texture_destroyed_notify, self );
    }
    else
    {
        it->second = info;
    }

#endif

}

//-----------------------------------------------------------------------------

#ifndef TP_PRODUCTION

// This gets called when an image is destroyed - we just remove it from
// the map.

void Images::texture_destroyed_notify( gpointer data, GObject * instance )
{
    Images * self = ( Images *) data;

    Util::GSRMutexLock lock( & self->mutex );

    self->images.erase( ( gpointer ) instance );
}

#endif

//-----------------------------------------------------------------------------

#ifndef TP_PRODUCTION

bool Images::compare( std::pair< gpointer , ImageInfo > a, std::pair< gpointer , ImageInfo > b )
{
    return a.second.bytes < b.second.bytes;
}

#endif

//-----------------------------------------------------------------------------

void Images::dump()
{
#ifndef TP_PRODUCTION

    Images * self( Images::get() );

    Util::GSRMutexLock lock( & self->mutex );

    typedef std::vector< std::pair< gpointer , ImageInfo> > ImageVector;

    ImageVector v( self->images.begin() , self->images.end() );

    std::sort( v.begin() , v.end() , Images::compare );


    gsize total = 0;
    int i = 1;

    g_info( "Loaded images:" );

    for ( ImageVector::const_iterator it = v.begin(); it != v.end(); ++it , ++i )
    {
        gchar * source = ( gchar * ) g_object_get_data( G_OBJECT( it->first ), "tp-src" );

        g_info( "  %3d) %4u x %-4u : %8.2f KB : %s", i, it->second.width, it->second.height, it->second.bytes / 1024.0, source ? source : "" );

        total += it->second.bytes;
    }

    g_info( "" );
    g_info( "%d image(s), %1.2f KB, %1.2f MB", --i, total / 1024.0, total / ( 1024.0 * 1024.0 ) );
    g_info( "" );

#endif
}

//-----------------------------------------------------------------------------

void Images::dump_cache()
{
#if TP_IMAGE_CACHE_ENABLED

    Images * self( Images::get() );

    Util::GSRMutexLock lock( & self->mutex );

    gsize total = 0;
    int i = 1;

    g_info( "Image cache:" );

    for ( CacheMap::const_iterator it = self->cache.begin(); it != self->cache.end(); ++it, ++i )
    {
        gsize bytes = it->second.first->pitch * it->second.first->height;

        g_info( "  %3d) %ux%u : %1.2f KB : %u hit(s) : %s", i, it->second.first->width, it->second.first->height, bytes / 1024.0, it->second.second, it->first.c_str() );

        total += bytes;
    }

    g_info( "" );
    g_info( "%d image(s), %1.2f KB, %1.2f MB", --i, total / 1024.0, total / ( 1024.0 * 1024.0 ) );
    g_info( "" );

#else

    g_info( "Image cache is disabled" );

#endif
}

//-----------------------------------------------------------------------------

void Images::set_cache_limit( guint bytes )
{
#if TP_IMAGE_CACHE_ENABLED

    Images * self( Images::get() );

    Util::GSRMutexLock lock( & self->mutex );

    self->cache_limit = bytes;

#endif
}

//-----------------------------------------------------------------------------

void Images::load_texture( ClutterTexture * texture, const Image * image )
{
    g_assert( image );

    load_texture( texture, image->image );
}

//-----------------------------------------------------------------------------

bool Images::load_texture( ClutterTexture * texture, gpointer data, gsize size, const char * content_type )
{
    TPImage * image = decode_image( data, size, content_type );

    if ( ! image )
    {
        return false;
    }

    load_texture( texture, image );

    destroy_image( image );

    return true;
}

//-----------------------------------------------------------------------------

bool Images::load_texture( ClutterTexture * texture, const char * filename )
{

#if TP_IMAGE_CACHE_ENABLED

    Images * self( Images::get() );

    Util::GSRMutexLock lock( & self->mutex );

    CacheMap::iterator it = self->cache.find( filename );

    if ( it != self->cache.end() )
    {
        load_texture( texture, it->second.first );

        it->second.second++;

        return true;
    }

#endif


    TPImage * image = decode_image( filename );

    if ( ! image )
    {
        return false;
    }

    load_texture( texture, image );

#if TP_IMAGE_CACHE_ENABLED

    CacheEntry & entry( self->cache[ filename ] );

    entry.first = image;
    entry.second = 0;

    self->cache_size += image->height * image->pitch;

    self->prune_cache();

#else

    destroy_image( image );

#endif

    return true;
}

//-----------------------------------------------------------------------------

#if TP_IMAGE_CACHE_ENABLED

#define TPImageSize( t ) ( t->height * t->pitch )

bool Images::prune_sort( const PruneEntry & a, const PruneEntry & b )
{
    return ( a.second.second < b.second.second || ( ( b.second.second == a.second.second ) && ( TPImageSize( a.second.first ) < TPImageSize( b.second.first ) ) ) );
}

void Images::prune_cache()
{
    Util::GSRMutexLock lock( & mutex );

    if ( cache_size < cache_limit )
    {
        return;
    }

    PruneVector prune;

    prune.reserve( cache.size() );

    for( CacheMap::const_iterator it = cache.begin(); it != cache.end(); ++it )
    {
        prune.push_back( PruneEntry( it->first, it->second ) );
    }

    std::sort( prune.begin(), prune.end(), prune_sort );

    images_debug( "PRUNE LIST:" );

    for( PruneVector::const_iterator it = prune.begin(); it != prune.end(); ++it )
    {
        images_debug( "%d : %u : %s", it->second.second, TPImageSize( it->second.first ) , it->first.c_str() );
    }

    guint target_limit = cache_limit * 0.85;

    for( PruneVector::const_iterator it = prune.begin(); it != prune.end() && cache_size > target_limit; ++it )
    {
        cache.erase( it->first );

        cache_size -= TPImageSize( it->second.first );

        images_debug( "DROPPING %s : %u", it->first.c_str(), TPImageSize( it->second.first ) );

        destroy_image( it->second.first );
    }

    images_debug( "CACHE SIZE IS NOW %u", cache_size );
}

#endif

//-----------------------------------------------------------------------------
