#include <cstdlib>
#include <iostream>
#include <fstream>
#include <algorithm>

#define CLUTTER_VERSION_MIN_REQUIRED CLUTTER_VERSION_CUR_STABLE
#include "clutter/clutter.h"
#include "libexif/exif-data.h"

#include "common.h"
#include "images.h"
#include "profiler.h"
#include "util.h"
#include "image_decoders.h"
#include "context.h"
#include "thread_pool.h"
#include "app.h"

//=============================================================================

#define TP_LOG_DOMAIN   "IMAGES"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//=============================================================================

static ThreadPool * get_images_threadpool( bool destroy = false )
{
    static ThreadPool * tp = 0;

    if ( destroy )
    {
        if ( tp )
        {
            delete tp;
            tp = 0;
        }
    }
    else
    {
        if ( ! tp )
        {
            tp = new ThreadPool( 2 );
        }
    }

    return tp;
}

//=============================================================================
// Wraps around an external decoder

class ExternalDecoder : public Images::Decoder
{
public:

    ExternalDecoder( TPContext * _context , TPImageDecoder _decoder, gpointer _decoder_data )
    :
        context( _context ),
        decoder( _decoder ),
        decoder_data( _decoder_data )
    {
        g_assert( decoder );
    }

    bool enabled( ) const
    {
        return context->get_bool( TP_IMAGE_DECODER_ENABLED , true );
    }

    virtual const char * name()
    {
        return "External Decoder";
    }

    virtual int decode( gpointer data, gsize size, TPImage * image )
    {
        if ( ! enabled() )
        {
            tplog( "  EXTERNAL IMAGE DECODER IS DISABLED" );

            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        tplog( "  INVOKING EXTERNAL DECODER WITH BUFFER OF %d BYTES", size );

        int result = decoder( data, size, image, decoder_data );

        tplog( "    EXTERNAL DECODER RETURNED %d", result );

        if ( result == TP_IMAGE_DECODE_OK )
        {
            tplog( "      pixels      : %p", image->pixels );
            tplog( "      width       : %u", image->width );
            tplog( "      height      : %u", image->height );
            tplog( "      pitch       : %u", image->pitch );
            tplog( "      depth       : %u", image->depth );
            tplog( "      bgr         : %u", image->bgr );
            tplog( "      pm_alpha    : %u", image->pm_alpha );
            tplog( "      free_image  : %p", image->free_image );

            g_assert( image->pixels != NULL );
            g_assert( image->pitch >= image->width * image->depth );
            g_assert( image->depth == 3 || image->depth == 4 );
            g_assert( image->bgr == 0 );

            Image::premultiply_alpha( image );
        }
        else
        {
            g_assert( image->pixels == NULL );

            // We change to unsupported format so that no matter what
            // the external decoder does, we try the internal decoders.

            result = TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        return result;
    }

    virtual int decode( const char * filename, TPImage * image )
    {
        if ( ! enabled() )
        {
            tplog( "  EXTERNAL IMAGE DECODER IS DISABLED" );

            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

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

        tplog( "  INVOKING EXTERNAL DECODER TO DETECT IMAGE FORMAT WITH %d BYTES", stream.gcount() );

        int r = decoder( header, stream.gcount(), NULL, decoder_data );

        tplog( "    EXTERNAL DECODER RETURNED %d", r );

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

    TPContext *     context;
    TPImageDecoder  decoder;
    gpointer        decoder_data;
};

//=============================================================================
// Wraps around a TPImage to make it a little safer

Image * Image::make( const TPImage & image )
{
    Image *img = new Image( g_slice_dup( TPImage,  &image ) );

    // This next line is superfluous but helps clang realize we're not leaking that buffer
    img->image->pixels = image.pixels;

    return img;
}

//-----------------------------------------------------------------------------

Image * Image::decode( gpointer data, gsize size, bool read_tags , const gchar * content_type )
{
    TPImage * image = Images::decode_image( data, size, content_type );

    Image * result = image ? new Image( image ) : 0;

    if ( result && read_tags )
    {
    	result->load_tags( data , size );
    }

    return result;
}

//-----------------------------------------------------------------------------

Image * Image::decode( const gchar * filename , bool read_tags )
{
    TPImage * image = Images::decode_image( filename );

    Image * result = image ? new Image( image ) : 0;

    if ( result && read_tags )
    {
    	result->load_tags( filename );
    }

    return result;
}

//-----------------------------------------------------------------------------

Image * Image::screenshot( ClutterActor *stage )
{
    TPImage image;

    if ( ! stage )
    {
    	return 0;
    }

    if ( ! CLUTTER_ACTOR_IS_VISIBLE( stage ) )
    {
    	return 0;
    }

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
    image.free_image = Image::free_image_with_g_free;
    image.pm_alpha = 0;

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

Image * Image::make( cairo_surface_t * surface )
{
    g_assert( surface );

    if ( cairo_image_surface_get_format( surface ) != CAIRO_FORMAT_ARGB32 )
    {
        return 0;
    }

    guint8 * source = ( guint8 * ) cairo_image_surface_get_data( surface );

    if ( ! source )
    {
        return 0;
    }

    TPImage result;

    memset( & result , 0 , sizeof( result ) );

    result.depth = 4;
    result.width = cairo_image_surface_get_width( surface );
    result.height = cairo_image_surface_get_height( surface );
    result.pitch = result.width * 4;
    result.free_image = 0;
    result.pixels = malloc( result.height * result.pitch );
    result.pm_alpha = 1;

    if ( ! result.pixels )
    {
        return 0;
    }

    guint8 * destination = ( guint8 * ) result.pixels;

    int source_stride = cairo_image_surface_get_stride( surface );

    for ( unsigned int r = 0; r < result.height; ++r )
    {
        guint8 * source_pixel = source;
        guint8 * dest_pixel = destination;

        for ( unsigned int c = 0; c < result.width; ++c , source_pixel += 4 )
        {
#if ( G_BYTE_ORDER == G_LITTLE_ENDIAN )
            *(dest_pixel++) = source_pixel[2];
            *(dest_pixel++) = source_pixel[1];
            *(dest_pixel++) = source_pixel[0];
            *(dest_pixel++) = source_pixel[3];
#else
            *(dest_pixel++) = source_pixel[1];
            *(dest_pixel++) = source_pixel[2];
            *(dest_pixel++) = source_pixel[3];
            *(dest_pixel++) = source_pixel[0];
#endif
        }

        destination += result.pitch;
        source += source_stride;
    }

    return Image::make( result );
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
    result->free_image = 0;
    result->pm_alpha = 1;

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
            	if ( ! image->pm_alpha )
            	{
            		mult = source_pixel[ 3 ] / 255.0;
            	}
            	else
            	{
            		mult = 1;
            	}

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

//-----------------------------------------------------------------------------

bool Image::is_packed() const
{
    return image->pitch == image->width * image->depth;
}

//-----------------------------------------------------------------------------

Image * Image::make_packed_copy() const
{
    if ( ! image )
    {
        return 0;
    }

    TPImage result = * image;

    result.pitch = result.width * result.depth;
    result.pixels = malloc( result.height * result.pitch );
    result.free_image = 0;

    if ( ! result.pixels )
    {
        return 0;
    }

    const guint8 * source_row = ( const guint8 * ) image->pixels;

    guint8 * dest_row = ( guint8 * ) result.pixels;

    for ( unsigned int r = 0; r < result.height; ++r )
    {
        memcpy( dest_row , source_row , result.pitch );

        source_row += image->pitch;
        dest_row += result.pitch;
    }

    return Image::make( result );
}

//-----------------------------------------------------------------------------

Image * Image::make_copy() const
{
    if ( ! image )
    {
        return 0;
    }

    TPImage result = * image;

    result.pixels = malloc( result.height * result.pitch );
    result.free_image = 0;

    if ( ! result.pixels )
    {
        return 0;
    }

    memcpy( result.pixels , image->pixels , result.height * result.pitch );

    return Image::make( result );
}

//-----------------------------------------------------------------------------

void Image::flip_y()
{
    if ( image->height == 0 )
    {
        return;
    }
    unsigned int pitch = image->pitch;

    guint8 * top_row = ( guint8 * ) image->pixels;
    guint8 * bot_row = top_row + ( pitch * ( image->height - 1 ) );

    guint8 * temp_row = ( guint8 * ) malloc( pitch );

    if ( ! temp_row )
    {
        return;
    }

    while( bot_row > top_row )
    {
        memcpy( temp_row , top_row , pitch );
        memcpy( top_row , bot_row , pitch );
        memcpy( bot_row , temp_row , pitch );

        top_row += pitch;
        bot_row -= pitch;
    }

    free( temp_row );
}

//-----------------------------------------------------------------------------

#define MULT(d,a,t)                             \
  G_STMT_START {                                \
    t = d * a + 128;                            \
    d = ((t >> 8) + t) >> 8;                    \
  } G_STMT_END

void Image::premultiply_alpha( TPImage * image )
{
	g_assert( image );

    if ( image->depth != 4 || image->pm_alpha )
    {
        return;
    }

    guint8 * row = ( guint8 * ) image->pixels;

    for ( unsigned int r = 0; r < image->height; ++r )
    {
        guint8 * p = row;

        for ( unsigned int c = 0; c < image->width; ++c , p += 4 )
        {
            guint8 a = p[3];

            unsigned int t1;
            unsigned int t2;
            unsigned int t3;

            MULT(p[0] , a , t1 );
            MULT(p[1] , a , t2 );
            MULT(p[2] , a , t3 );
        }

        row += image->pitch;
    }

    image->pm_alpha = 1;
}

#undef MULT

void Image::premultiply_alpha( )
{
	premultiply_alpha( image );
}

//-----------------------------------------------------------------------------

void Image::destroy( void * image )
{
    delete ( Image * ) image;
}

//-----------------------------------------------------------------------------

class DecodeTask : public ThreadPool::Task
{
public:

    DecodeTask( Image::DecodeAsyncCallback _callback , gpointer _user , GDestroyNotify _destroy_notify )
    :
        image( 0 ),
        callback( _callback ),
        user( _user ),
        destroy_notify( _destroy_notify )
    {
    }

    virtual ~DecodeTask()
    {
        if ( image )
        {
            delete image;
        }

        if ( destroy_notify )
        {
            destroy_notify( user );
        }
    }

    virtual void process_main_thread()
    {
        if ( callback )
        {
            callback( image , user );

            image = 0;
        }
    }

protected:

    Image *                     image;

private:

    Image::DecodeAsyncCallback  callback;
    gpointer                    user;
    GDestroyNotify              destroy_notify;
};

//-----------------------------------------------------------------------------

class DecodeFileTask : public DecodeTask
{
public:

    DecodeFileTask( const gchar * _filename , bool _read_tags , Image::DecodeAsyncCallback _callback , gpointer _user , GDestroyNotify _destroy_notify )
    :
        DecodeTask( _callback , _user , _destroy_notify ),
        filename( _filename ),
    	read_tags( _read_tags )
    {

    }

    virtual void process()
    {
        image = Image::decode( filename.c_str() , read_tags );
    }

private:

    String                      filename;
    bool						read_tags;
};

//-----------------------------------------------------------------------------

class DecodeBufferTask : public DecodeTask
{
public:

    DecodeBufferTask( GByteArray * _bytes , bool _read_tags , const gchar * _content_type , Image::DecodeAsyncCallback _callback , gpointer _user , GDestroyNotify _destroy_notify )
    :
        DecodeTask( _callback , _user , _destroy_notify ),
        bytes( _bytes ),
        read_tags( _read_tags ),
        content_type( _content_type ? _content_type : "" )
    {
        g_byte_array_ref( bytes );
    }

    virtual ~DecodeBufferTask()
    {
        g_byte_array_unref( bytes );
    }

    virtual void process()
    {
        image = Image::decode( bytes->data , bytes->len , read_tags , content_type.c_str() );
    }

private:

    GByteArray *    bytes;
    bool			read_tags;
    String          content_type;
};

//-----------------------------------------------------------------------------

void Image::decode_async( const gchar * filename , bool read_tags , DecodeAsyncCallback callback , gpointer user , GDestroyNotify destroy_notify )
{
    g_assert( filename );

    get_images_threadpool()->push( new DecodeFileTask( filename , read_tags , callback , user , destroy_notify ) );
}

//-----------------------------------------------------------------------------

void Image::decode_async( GByteArray * bytes , bool read_tags , const gchar * content_type , DecodeAsyncCallback callback , gpointer user , GDestroyNotify destroy_notify )
{
    g_assert( bytes );
    g_assert( bytes->data );
    g_assert( bytes->len );

    get_images_threadpool()->push( new DecodeBufferTask( bytes , read_tags , content_type , callback , user , destroy_notify ) );
}

//-----------------------------------------------------------------------------

typedef struct
{
	ExifData * 		exif_data;
	JSON::Object * 	tags;

} ExifClosure;

static void foreach_exif_entry( ExifEntry * entry , void * _closure )
{
	if ( ! entry )
	{
		return;
	}

	//.........................................................................
	// Bail out of types we don't handle

	switch( entry->format )
	{
	case EXIF_FORMAT_UNDEFINED:
	case EXIF_FORMAT_FLOAT:
	case EXIF_FORMAT_DOUBLE:
		return;
	default:
		break;
	}

	//.........................................................................

	unsigned char component_size = exif_format_get_size( entry->format );

	ExifIfd ifd = exif_content_get_ifd( entry->parent );

	const char * tag_name = exif_tag_get_name_in_ifd( entry->tag , ifd );

	if ( ! tag_name || ! entry->data || ! entry->size || ! component_size || ! entry->components )
	{
		return;
	}

	//.........................................................................
	// Add a prefix based on the IFD

	String name( tag_name );

	switch( ifd )
	{
	case EXIF_IFD_0:
		name = "IMAGE/" + name;
		break;
	case EXIF_IFD_1:
		name = "THUMBNAIL/" + name;
		break;
	case EXIF_IFD_EXIF:
		name = "EXIF/" + name;
		break;
	case EXIF_IFD_GPS:
		name = "GPS/" + name;
		break;
	case EXIF_IFD_INTEROPERABILITY:
		name = "INTEROP/" + name;
		break;
	default:
		return;
	}

	ExifClosure * closure = ( ExifClosure * ) _closure;

	JSON::Object * tags = closure->tags;

	//.........................................................................
	// ASCII ones are easy

	if ( entry->format == EXIF_FORMAT_ASCII )
	{
		(*tags)[ name ] = String( ( const char * ) entry->data , entry->size );
		return;
	}

	//.........................................................................

	if ( ( entry->components * component_size ) != entry->size )
	{
		return;
	}

	ExifByteOrder byte_order = exif_data_get_byte_order( closure->exif_data );

	const unsigned char * data = entry->data;

	JSON::Array array;

	for ( unsigned long i = 0; i < entry->components; ++i )
	{
		switch( entry->format )
		{
		case EXIF_FORMAT_BYTE:
			array.append( JSON::Value( int( * data ) ) );
			break;

		case EXIF_FORMAT_SHORT:
			array.append( JSON::Value( int( exif_get_short( data , byte_order ) ) ) );
			break;

		case EXIF_FORMAT_LONG:
			array.append( JSON::Value( int( exif_get_long( data , byte_order ) ) ) );
			break;

		case EXIF_FORMAT_SBYTE:
			array.append( JSON::Value( int( * ( ( const char * ) data ) ) ) );
			break;

		case EXIF_FORMAT_SSHORT:
			array.append( JSON::Value( exif_get_sshort( data , byte_order ) ) );
			break;

		case EXIF_FORMAT_SLONG:
			array.append( JSON::Value( exif_get_slong( data , byte_order ) ) );
			break;

		// TODO: I don't like representing a rational number as a string with a slash,

		case EXIF_FORMAT_SRATIONAL:
		{
			ExifSRational r = exif_get_srational( data , byte_order );
			array.append( Util::format("%ld/%ld" , r.numerator , r.denominator ) );
			break;
		}

		case EXIF_FORMAT_RATIONAL:
		{
			ExifRational r = exif_get_rational( data , byte_order );
			array.append( Util::format("%lu/%lu" , r.numerator , r.denominator ) );
			break;
		}
		default:
			break;
		}

		data += component_size;
	}

	if ( array.size() == 1 )
	{
		(*tags)[ name ] = array[ 0 ];
	}
	else if ( array.size() > 1 )
	{
		(*tags)[ name ] = array;
	}
}


static void load_exif_tags( ExifData * ed , JSON::Object & tags )
{
	tplog2( "  LOADING EXIF TAGS" );

	exif_data_set_option( ed , EXIF_DATA_OPTION_IGNORE_UNKNOWN_TAGS );
	exif_data_set_option( ed , EXIF_DATA_OPTION_FOLLOW_SPECIFICATION );

	exif_data_fix( ed );

	ExifClosure closure;

	closure.exif_data = ed;
	closure.tags = & tags;

	for ( int i = 0; i < EXIF_IFD_COUNT; ++i )
	{
		if ( ExifContent * c = ed->ifd[i] )
		{
			exif_content_foreach_entry( c , foreach_exif_entry , & closure );
		}
	}

	tplog2( "  LOADED EXIF TAGS" );
}

//-----------------------------------------------------------------------------

void Image::load_tags( const gchar * filename )
{
	g_assert( filename );

	if ( ExifData * ed = exif_data_new_from_file( filename ) )
	{
		load_exif_tags( ed , tags );
		exif_data_unref( ed );
	}
	else
	{
		tplog2( "  FAILED TO LOAD TAGS" );
	}
}

//-----------------------------------------------------------------------------

void Image::load_tags( gpointer data , gsize size )
{
	g_assert( data );
	g_assert( size );

	if ( ExifData * ed = exif_data_new_from_data( ( const unsigned char * ) data , size ) )
	{
		load_exif_tags( ed , tags );
		exif_data_unref( ed );
	}
	else
	{
		tplog2( "  FAILED TO LOAD TAGS" );
	}
}

//-----------------------------------------------------------------------------

const JSON::Object & Image::get_tags() const
{
	return tags;
}

//-----------------------------------------------------------------------------

void Image::free_image_with_g_free( TPImage * image )
{
	g_assert( image );
	g_assert( image->pixels );

	g_free( image->pixels );
}

//=============================================================================

Images::Images()
:
    external_decoder( 0 ),
    cache( 0 )
{
#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_init( & mutex );
#else
    g_rec_mutex_init( &mutex );
#endif

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

#ifndef TP_PRODUCTION

    // Get rid of the weak ref in case an image is destroyed after we are.

    for ( ImageMap::iterator it = images.begin(); it != images.end(); ++it )
    {
        g_object_weak_unref( G_OBJECT( it->first ), texture_destroyed_notify, this );
    }

#endif

    if ( cache )
    {
    	delete cache;
    }

#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_free( & mutex );
#else
    g_rec_mutex_clear( &mutex );
#endif
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
    get_images_threadpool( true );
}

//-----------------------------------------------------------------------------

void Images::set_external_decoder( TPContext * context , TPImageDecoder decoder, gpointer decoder_data )
{
    Images * self( Images::get(false) );

    Util::GSRMutexLock lock( & self->mutex );

    if ( self->external_decoder )
    {
        delete self->external_decoder;
        self->external_decoder = NULL;
    }

    self->external_decoder = new ExternalDecoder( context , decoder, decoder_data );
}

//-----------------------------------------------------------------------------

Images::DecoderList Images::get_decoders( const char * _hint )
{
    Images * self( Images::get(false) );

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
        tplog( "TRYING TO DECODE '%s' USING %s", content_type ? content_type : "<unknown>", ( * it )->name() );

        int r = ( * it )->decode( ( gpointer ) data, size, &image );

        if ( r == TP_IMAGE_UNSUPPORTED_FORMAT )
        {
            tplog( "  UNSUPPORTED" );
            continue;
        }

        if ( r == TP_IMAGE_DECODE_FAILED )
        {
            tplog( "  FAILED" );
            break;
        }

        tplog( "  DECODED" );

        // It was decoded

        g_assert( image.pixels );
        g_assert( image.depth == 3 || image.depth == 4 );
        g_assert( image.width * image.depth <= image.pitch );
        g_assert( image.bgr == 0 || image.bgr == 1 );

        return g_slice_dup( TPImage, &image );
    }

    tpwarn( "FAILED TO DECODE IMAGE FROM MEMORY" );

    return NULL;
}

//-----------------------------------------------------------------------------

TPImage * Images::decode_image( const char * filename )
{
    PROFILER( "Images::decode_image/file" , PROFILER_INTERNAL_CALLS );

    if ( ! g_file_test( filename, G_FILE_TEST_IS_REGULAR ) )
    {
        tpwarn( "IMAGE DOES NOT EXIST %s", filename );
        return NULL;
    }

    TPImage image;
    memset( &image, 0, sizeof( TPImage ) );

    DecoderList decoders = get_decoders( filename );

    for ( DecoderList::const_iterator it = decoders.begin(); it != decoders.end(); ++it )
    {
        tplog( "TRYING TO DECODE '%s' USING %s", filename, ( * it )->name() );

        int r = ( * it )->decode( filename, &image );

        if ( r == TP_IMAGE_UNSUPPORTED_FORMAT )
        {
            tplog( "  UNSUPPORTED" );
            continue;
        }

        if ( r == TP_IMAGE_DECODE_FAILED )
        {
            tplog( "  FAILED" );
            break;
        }

        tplog( "  DECODED" );

        // It was decoded

        g_assert( image.pixels );
        g_assert( image.depth == 3 || image.depth == 4 );
        g_assert( image.width * image.depth <= image.pitch );
        g_assert( image.bgr == 0 || image.bgr == 1 );

        return g_slice_dup( TPImage, &image );
    }

    tpwarn( "FAILED TO DECODE %s", filename );

    return NULL;
}

//-----------------------------------------------------------------------------

void Images::destroy_image( TPImage * image )
{
    if ( image )
    {
        if ( image->pixels )
        {
            if ( image->free_image )
            {
                image->free_image( image );
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

void Images::load_texture( ClutterTexture * texture, TPImage * image , guint x , guint y , guint w , guint h )
{
    PROFILER( "Images::load_texture/clutter" , PROFILER_INTERNAL_CALLS );

    g_assert( texture );
    g_assert( image );

    const guchar * pixels = ( const guchar * ) image->pixels;

    guint width = image->width;
    guint height = image->height;

    if ( w != 0 && h != 0 )
    {
        pixels += x * image->depth + y * image->pitch;
        width = w;
        height = h;
    }

    ClutterTextureFlags flags = image->bgr ? CLUTTER_TEXTURE_RGB_FLAG_BGR : CLUTTER_TEXTURE_NONE;

    if ( image->depth == 4 && image->pm_alpha )
    {
    	flags = ( ClutterTextureFlags ) ( flags | CLUTTER_TEXTURE_RGB_FLAG_PREMULT );
    }

    clutter_texture_set_from_rgb_data(
        texture,
        pixels,
        image->depth == 4,
        width,
        height,
        image->pitch,
        image->depth,
        flags,
        NULL );

#ifndef TP_PRODUCTION

    ImageInfo info( image );

    if ( w !=0 && h != 0 )
    {
        info.width = w;
        info.height = h;
        info.bytes = w * h * image->depth;
    }

    add_to_image_list( texture , info );

#endif

}

//-----------------------------------------------------------------------------

void Images::add_to_image_list( ClutterTexture * texture , bool cached )
{
#ifndef TP_PRODUCTION

	g_assert( texture );

        if ( cached )
        {
            gchar * source = ( gchar * ) g_object_get_data( G_OBJECT( texture ), "tp-src" );
            const gchar * prepend = "* ";

            gint new_length = strlen( source ) + strlen( prepend ) + 2 ;

            gchar * new_source = g_new( gchar , new_length );

            snprintf( new_source , new_length , "%s%s" , prepend , source );\

            g_object_set_data_full( G_OBJECT( texture ) , "tp-src" , new_source , g_free );
        }

	add_to_image_list( texture , ImageInfo( texture ) );

#endif
}

//-----------------------------------------------------------------------------

#ifndef TP_PRODUCTION

//-----------------------------------------------------------------------------

void Images::add_to_image_list( ClutterTexture * texture , const ImageInfo & info )
{
	g_assert( texture );

	// If the image does not exist in our map, we add it and also set
    // a weak ref so we know when it is destroyed. If it is already in
    // the map, we just update its information.

    Images * self( Images::get() );

    Util::GSRMutexLock lock( & self->mutex );

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
}

//-----------------------------------------------------------------------------
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
    Images * self( Images::get(false) );

    if ( ! self->cache )
    {
    	g_info( "Cache is disabled or empty." );
    	return;
    }

    self->cache->dump();
}

//-----------------------------------------------------------------------------

void Images::load_texture( ClutterTexture * texture, const Image * image , guint x , guint y , guint w , guint h )
{
    g_assert( image );

    load_texture( texture, image->image , x , y , w , h );
}

//-----------------------------------------------------------------------------

bool Images::load_texture( ClutterTexture * texture, gpointer data, gsize size, const char * content_type )
{
    TPImage * image = decode_image( data, size, content_type );

    if ( ! image )
    {
        return false;
    }

    load_texture( texture, image, 0, 0, image->width, image->height );

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

    load_texture( texture, image, 0, 0, image->width, image->height );

    destroy_image( image );

    return true;
}

//-----------------------------------------------------------------------------

bool Images::cache_put( TPContext * context , const String & key , CoglHandle texture , const JSON::Object & tags )
{
	g_assert( context );

	if ( texture == COGL_INVALID_HANDLE )
	{
		return false;
	}

	Images * self = Images::get(false);

	// If the cache has not been created yet, do so now

	if ( ! self->cache )
	{
		int limit = context->get_int( TP_TEXTURE_CACHE_LIMIT , TP_TEXTURE_CACHE_LIMIT_DEFAULT );

		if ( limit <= 0 )
		{
			return false;
		}

		self->cache = new Cache( limit );
	}

	return self->cache->put( key , texture , tags );
}

//-----------------------------------------------------------------------------

CoglHandle Images::cache_get( const String & key , JSON::Object & tags )
{
	Images * self = Images::get(false);

	if ( ! self->cache )
	{
		return COGL_INVALID_HANDLE;
	}

	return self->cache->get( key , tags );
}

//-----------------------------------------------------------------------------

bool Images::cache_has( const String & key )
{
	Images * self = Images::get(false);

	if ( ! self->cache )
	{
		return false;
	}

	return self->cache->has( key );
}

//=============================================================================

#ifdef CLUTTER_VERSION_1_10
#define TP_COGL_TEXTURE(t) (COGL_TEXTURE(t))
#else
#define TP_COGL_TEXTURE(t) (t)
#endif

Images::Cache::Entry::Entry( CoglHandle _handle , const JSON::Object & _tags )
:
    handle( cogl_handle_ref( _handle ) ),
    timestamp( ::timestamp() ),
    tags( _tags )
{
	// Size in MB

	size = ( cogl_texture_get_height( TP_COGL_TEXTURE( handle ) ) * cogl_texture_get_rowstride( TP_COGL_TEXTURE( handle ) ) ) / ( 1024.0 * 1024.0 );
}

Images::Cache::Entry::~Entry()
{
	cogl_handle_unref( handle );
}

void Images::Cache::Entry::update_timestamp()
{
	timestamp = ::timestamp();
}


Images::Cache::Cache( int _limit )
:
    limit( _limit ),
    size( 0 )
{
}

Images::Cache::~Cache()
{
	for ( Map::iterator it = map.begin(); it != map.end(); ++it )
	{
		delete it->second;
	}
}

bool Images::Cache::put( const String & key , CoglHandle texture , const JSON::Object & tags )
{
	// Arguments have already been checked

	Map::iterator it( map.find( key ) );

	// An entry exists for this key

	if ( it != map.end() )
	{
		size -= it->second->size;

		delete it->second;

		map.erase( it );

		tplog2( "CACHE REMOVED '%s' : SIZE = %1.2f" , key.c_str() , size );
	}

	Entry * entry = new Entry( texture , tags );

	if ( ! entry )
	{
		return false;
	}

	map[ key ] = entry;

	size += entry->size;

	tplog2( "CACHE ADDED '%s' : SIZE = %1.2f" , key.c_str() , size );

	if ( size > limit )
	{
		prune();
	}

	return true;
}

CoglHandle Images::Cache::get( const String & key , JSON::Object & tags )
{
	Map::iterator it( map.find( key ) );

	if ( it == map.end() )
	{
		tplog2( "CACHE MISS FOR '%s'" , key.c_str() );

		return COGL_INVALID_HANDLE;
	}

	it->second->update_timestamp();

	tplog2( "CACHE HIT FOR '%s'" , key.c_str() );

	tags = it->second->tags;

	return it->second->handle;
}

bool Images::Cache::has( const String & key )
{
	return map.find( key ) != map.end();
}

bool Images::Cache::prune_sort( const PruneEntry & a , const PruneEntry & b )
{
	return a.second->timestamp < b.second->timestamp;
}

void Images::Cache::prune()
{
	tplog2( "CACHE PRUNING : SIZE = %1.2f" , size );

	// Copy all of the entries to a vector

	PruneVector v;

	v.reserve( map.size() );

	for ( Map::const_iterator it = map.begin(); it != map.end(); ++it )
	{
		v.push_back( PruneEntry( it->first , it->second ) );
	}

	// Sort them in order of timestamp, oldest ones will be first

	std::sort( v.begin() , v.end() , prune_sort );

	// Set our target cache size

	double target_size = limit * 0.70;

	// Now, get rid of each one, until we reach our target size

	for ( PruneVector::const_iterator it = v.begin(); it != v.end() && size > target_size; ++it )
	{
		size -= it->second->size;

		tplog2( "  DROPPED '%s' : SIZE = %1.2f" , it->first.c_str() , size );

		delete it->second;

		map.erase( it->first );

	}

	tplog2( "CACHE PRUNED : SIZE = %1.2f" , size );
}


void Images::Cache::dump()
{
	// Copy all of the entries to a vector

	PruneVector v;

	v.reserve( map.size() );

	for ( Map::const_iterator it = map.begin(); it != map.end(); ++it )
	{
		v.push_back( PruneEntry( it->first , it->second ) );
	}

	// Sort them in order of timestamp, oldest ones will be first

	std::sort( v.begin() , v.end() , prune_sort );

	double total = 0;
	int i = 1;

	g_info( "Texture cache:" );

	if ( ! v.empty() )
	{
		double now = v.back().second->timestamp;

		for ( PruneVector::const_iterator it = v.begin(); it != v.end(); ++it , ++i )
		{
			g_info( "  %3d) %4u x %-4u : %8.2f KB : %8.3f s : %s" ,
					i ,
					cogl_texture_get_width( TP_COGL_TEXTURE( it->second->handle ) ),
					cogl_texture_get_height( TP_COGL_TEXTURE( it->second->handle ) ),
					it->second->size * 1024.0,
					( now - it->second->timestamp ) / 1000,
					it->first.c_str() );

			total += it->second->size;
		}
	}

    g_info( "" );
    g_info( "%d texture(s), %1.2f MB (limit is %d MB)", --i, total , limit );
    g_info( "" );

}
