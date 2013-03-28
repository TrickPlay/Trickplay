
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>
#include <fstream>
#include <algorithm>

#include "tiffio.h"
#include "tiffio.hxx"
#include "jpeglib.h"

#define PNG_SKIP_SETJMP_CHECK 1

#include "png.h"

#include "gif_lib.h"

#include "image_decoders.h"
#include "common.h"
#include "profiler.h"
#include "util.h"
#include "jpeg_utils.h"

//=============================================================================

#define TP_LOG_DOMAIN   "IMAGES"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//=============================================================================

namespace ImageDecoders
{
class TIFFDecoder : public Images::Decoder
{
public:

    virtual const char* name()
    {
        return "TIFF Decoder";
    }

    virtual int decode( gpointer data, gsize size, TPImage* image )
    {
        PROFILER( "Images::TIFF_decode/memory" , PROFILER_INTERNAL_CALLS );

        imstream stream( ( char* )data, size );

        TIFF* tiff = TIFFStreamOpen( "memory", &stream );

        if ( ! tiff )
        {
            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        int result = decode( tiff, image );

        TIFFClose( tiff );

        return result;
    }

    virtual int decode( const char* filename, TPImage* image )
    {
        PROFILER( "Images::TIFF_decode/file" , PROFILER_INTERNAL_CALLS );

        TIFF* tiff = TIFFOpen( filename, "r" );

        if ( ! tiff )
        {
            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        int result = decode( tiff, image );

        TIFFClose( tiff );

        return result;
    }

private:

    int decode( TIFF* tiff, TPImage* image )
    {
        g_assert( tiff );
        g_assert( image );

        int result = TP_IMAGE_DECODE_FAILED;

        uint32 width;
        uint32 height;

        TIFFGetField( tiff, TIFFTAG_IMAGEWIDTH, &width );
        TIFFGetField( tiff, TIFFTAG_IMAGELENGTH, &height );

        uint32* pixels = ( uint32* )_TIFFmalloc( width * height * 4 );

        if ( pixels )
        {
            if ( TIFFReadRGBAImageOriented( tiff, width, height, pixels, ORIENTATION_TOPLEFT, 1 ) )
            {
                image->pixels = pixels;
                image->width = width;
                image->height = height;
                image->pitch = width * 4;
                image->depth = 4;
                image->bgr = 0;
                image->free_image = free_image;
                image->pm_alpha = 0;

                Image::premultiply_alpha( image );

                result = TP_IMAGE_DECODE_OK;
            }
            else
            {
                _TIFFfree( pixels );
            }
        }

        return result;
    }

    static void free_image( TPImage* image )
    {
        g_assert( image );
        g_assert( image->pixels );

        _TIFFfree( image->pixels );
    }
};

class PNGDecoder : public Images::Decoder
{
public:

    virtual const char* name()
    {
        return "PNG Decoder";
    }

    virtual int decode( gpointer data, gsize size, TPImage* image )
    {
        PROFILER( "Images::PNG_decode/memory" , PROFILER_INTERNAL_CALLS );

        imstream stream( ( char* )data, size );

        return decode( stream, image );
    }

    virtual int decode( const char* filename, TPImage* image )
    {
        PROFILER( "Images::PNG_decode/file" , PROFILER_INTERNAL_CALLS );

        std::ifstream stream;

        stream.open( filename, std::ios_base::in | std::ios_base::binary );

        int result = decode( stream, image );

        stream.close();

        return result;
    }

private:

    int decode( std::istream& stream, TPImage* image )
    {
        // Check that the stream is in good shape

        if ( ! stream.good() )
        {
            return TP_IMAGE_DECODE_FAILED;
        }

        // Read the header

        char header[8];

        stream.read( header, 8 );

        size_t header_bytes = stream.gcount();

        if ( png_sig_cmp( ( png_bytep ) header, 0, header_bytes ) )
        {
            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        // Rewind the stream

        stream.seekg( 0 );

        // Get ready to read

        int result = TP_IMAGE_DECODE_FAILED;

        png_structp png_ptr = png_create_read_struct( PNG_LIBPNG_VER_STRING, NULL, NULL, NULL );
        png_infop info_ptr = NULL;
        png_infop end_info = NULL;

        if ( png_ptr )
        {
            info_ptr = png_create_info_struct( png_ptr );

            if ( info_ptr )
            {
                end_info = png_create_info_struct( png_ptr );

                if ( end_info )
                {
                    png_bytep pixels = NULL;

                    if ( setjmp( png_jmpbuf( png_ptr ) ) )
                    {
                        if ( pixels )
                        {
                            free( pixels );
                        }
                    }
                    else
                    {
                        png_set_read_fn( png_ptr, &stream, istream_png_read_data );

                        png_read_info( png_ptr, info_ptr );

                        png_uint_32 width = png_get_image_width( png_ptr, info_ptr );
                        png_uint_32 height = png_get_image_height( png_ptr, info_ptr );
                        png_uint_32 depth = png_get_channels( png_ptr, info_ptr );

                        png_byte color_type = png_get_color_type( png_ptr, info_ptr );
                        png_byte bit_depth = png_get_bit_depth( png_ptr, info_ptr );

                        if ( color_type == PNG_COLOR_TYPE_PALETTE )
                        {
                            png_set_palette_to_rgb( png_ptr );
                            depth = 3;
                            bit_depth = 8;
                        }

                        if ( color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8 )
                        {
                            png_set_expand_gray_1_2_4_to_8( png_ptr );
                            bit_depth = 8;
                        }

                        if ( bit_depth == 16 )
                        {
                            png_set_strip_16( png_ptr );
                            bit_depth = 8;
                        }

                        if ( color_type == PNG_COLOR_TYPE_GRAY )
                        {
                            png_set_gray_to_rgb( png_ptr );
                            depth = 3;
                        }
                        else if ( color_type == PNG_COLOR_TYPE_GRAY_ALPHA )
                        {
                            png_set_gray_to_rgb( png_ptr );
                            depth = 4;
                        }

                        if ( png_get_valid( png_ptr, info_ptr, PNG_INFO_tRNS ) )
                        {
                            png_set_tRNS_to_alpha( png_ptr );
                            depth += 1;
                        }

                        g_assert( bit_depth == 8 );
                        g_assert( depth == 3 || depth == 4 );

                        pixels = ( png_bytep )malloc( width * height * depth );

                        if ( pixels )
                        {
                            png_bytep rows[ height ];

                            for ( png_uint_32 row = 0; row < height; ++row )
                            {
                                rows[ row ] = pixels + row * ( width * depth );
                            }

                            png_read_image( png_ptr, rows );

                            image->pixels = pixels;
                            image->width = width;
                            image->height = height;
                            image->pitch = width * depth;
                            image->depth = depth;
                            image->bgr = 0;
                            image->free_image = 0;
                            image->pm_alpha = 0;

                            Image::premultiply_alpha( image );

                            result = TP_IMAGE_DECODE_OK;
                        }
                    }
                }
            }

            png_destroy_read_struct( &png_ptr, &info_ptr, &end_info );
        }

        return result;
    }

    static void istream_png_read_data( png_structp png_ptr, png_bytep data, png_size_t length )
    {
        if ( ! png_ptr )
        {
            return;
        }

        std::istream* stream = ( std::istream* )png_get_io_ptr( png_ptr );

        g_assert( stream );

        stream->read( ( char* )data, length );

        if ( stream->gcount() != std::streampos( length ) )
        {
            png_error( png_ptr, "Read Error" );
        }
    }
};

#ifdef TP_JPEG_FORCE_ALPHA
#define TP_JPEG_DEPTH           4
#else
#define TP_JPEG_DEPTH           3
#endif

class JPEGDecoder : public Images::Decoder
{
public:

    virtual const char* name()
    {
        return "JPEG Decoder";
    }

    virtual int decode( gpointer data, gsize size, TPImage* image )
    {
        PROFILER( "Images::JPEG_decode/memory" , PROFILER_INTERNAL_CALLS );

        if ( size < 2 )
        {
            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        guchar* header = ( guchar* )data;

        if ( !( header[0] == 0xFF && header[1] == 0xD8 ) )
        {
            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        jpeg_decompress_struct cinfo;
        jpeg_error_mgr jerr;

        cinfo.err = jpeg_std_error( &jerr );

        cinfo.err->error_exit = jpeg_error;

        jpeg_create_decompress( &cinfo );

        jpeg_source_mgr source;

        source.bytes_in_buffer = size;
        source.next_input_byte = ( JOCTET* ) data;
        source.fill_input_buffer = fill_input_buffer;
        source.init_source = init_source;
        source.resync_to_restart = jpeg_resync_to_restart;
        source.skip_input_data = skip_input_data;
        source.term_source = term_source;

        cinfo.src = &source;

        int orientation = JPEGUtils::get_exif_orientation( ( const unsigned char* ) data , size );

        int result = TP_IMAGE_DECODE_FAILED;

        try
        {
            result = decode( &cinfo , image , orientation );

            jpeg_finish_decompress( &cinfo );
        }
        catch ( ... )
        {
            result = TP_IMAGE_DECODE_FAILED;
        }

        jpeg_destroy_decompress( &cinfo );

        return result;
    }

    virtual int decode( const char* filename, TPImage* image )
    {
        PROFILER( "Images::JPEG_decode/file" , PROFILER_INTERNAL_CALLS );

        FILE* file = fopen( filename, "rb" );

        if ( ! file )
        {
            return TP_IMAGE_DECODE_FAILED;
        }

        guchar header[2];

        if ( fread( header, 1, 2, file ) != 2 )
        {
            fclose( file );
            return TP_IMAGE_DECODE_FAILED;
        }

        if ( !( header[0] == 0xFF && header[1] == 0xD8 ) )
        {
            fclose( file );
            return TP_IMAGE_UNSUPPORTED_FORMAT;
        }

        fseek( file, 0, SEEK_SET );

        int orientation = JPEGUtils::get_exif_orientation( filename );

        jpeg_decompress_struct cinfo;
        jpeg_error_mgr jerr;

        cinfo.err = jpeg_std_error( &jerr );
        cinfo.err->error_exit = jpeg_error;

        jpeg_create_decompress( &cinfo );

        int result = TP_IMAGE_DECODE_FAILED;

        try
        {
            jpeg_stdio_src( &cinfo, file );

            result = decode( &cinfo, image, orientation );

            jpeg_finish_decompress( &cinfo );
        }
        catch ( ... )
        {
            result = TP_IMAGE_DECODE_FAILED;
        }

        jpeg_destroy_decompress( &cinfo );

        fclose( file );

        return result;
    }

private:

    int decode( j_decompress_ptr cinfo, TPImage* image, int orientation )
    {
        jpeg_read_header( cinfo, TRUE );

        switch ( cinfo->jpeg_color_space )
        {
            case JCS_UNKNOWN:
                break;

            case JCS_GRAYSCALE:
                cinfo->out_color_space     = JCS_RGB;
                break;

            case JCS_RGB:
                cinfo->out_color_space     = JCS_RGB;
                break;

            case JCS_YCbCr:
                cinfo->out_color_space     = JCS_RGB;
                break;

            case JCS_CMYK:
            case JCS_YCCK:
                cinfo->out_color_space     = JCS_CMYK;
                break;

            default:
                g_warning( "JPEG HAS INVALID OUTPUT COLOR SPACE" );
                return TP_IMAGE_DECODE_FAILED;
        }


        jpeg_start_decompress( cinfo );

        if ( !( cinfo->output_components == 3 || cinfo->output_components == 1 || cinfo->output_components == 4 ) )
        {
            g_warning( "JPEG HAS INVALID # OF COMPONENTS (%d)" , cinfo->output_components );

            return TP_IMAGE_DECODE_FAILED;
        }

        JSAMPARRAY buffer = ( *cinfo->mem->alloc_sarray )( ( j_common_ptr ) cinfo, JPOOL_IMAGE, cinfo->output_width * cinfo->output_components, 1 );

        if ( ! buffer )
        {
            return TP_IMAGE_DECODE_FAILED;
        }

        guchar* pixels = ( guchar* )malloc( cinfo->output_width * cinfo->output_height * TP_JPEG_DEPTH );

        if ( ! pixels )
        {
            return TP_IMAGE_DECODE_FAILED;
        }

        try
        {
            JPEGUtils::Rotator rotator( orientation, cinfo->output_width, cinfo->output_height, TP_JPEG_DEPTH );

            if ( orientation > 1 )
            {
                tplog2( "ROTATING JPEG WITH ORIENTATION = %d", orientation );
            }

            guchar* p;

            unsigned int index;

            while ( cinfo->output_scanline < cinfo->output_height )
            {
                jpeg_read_scanlines( cinfo, buffer, 1 );

                index = 0;

                switch ( cinfo->output_components )
                {
                    case 1:

                        for ( unsigned int c = 0; c < cinfo->output_width; ++c, index += 1 )
                        {
                            p = pixels + rotator.get_transformed_location( c, cinfo->output_scanline - 1 );
                            *( p++ ) = ( *buffer )[ index ];
                            *( p++ ) = ( *buffer )[ index ];
                            *( p++ ) = ( *buffer )[ index ];
#ifdef TP_JPEG_FORCE_ALPHA
                            *( p++ ) = 255;
#endif
                        }

                        break;

                    case 3:

                        for ( unsigned int c = 0; c < cinfo->output_width; ++c, index += 3 )
                        {
                            p = pixels + rotator.get_transformed_location( c, cinfo->output_scanline - 1 );
                            *( p++ ) = ( *buffer )[ index ];
                            *( p++ ) = ( *buffer )[ index + 1 ];
                            *( p++ ) = ( *buffer )[ index + 2 ];
#ifdef TP_JPEG_FORCE_ALPHA
                            *( p++ ) = 255;
#endif
                        }

                        break;

                    case 4:

                        for ( unsigned int c = 0; c < cinfo->output_width; ++c, index += 4 )
                        {
                            p = pixels + rotator.get_transformed_location( c, cinfo->output_scanline - 1 );

                            int k = ( *buffer )[index + 3];

                            *( p++ ) = k * ( *buffer )[ index ] / 255;
                            *( p++ ) = k * ( *buffer )[ index + 1 ] / 255;
                            *( p++ ) = k * ( *buffer )[ index + 2 ] / 255;
#ifdef TP_JPEG_FORCE_ALPHA
                            *( p++ ) = 255;
#endif
                        }

                        break;
                }
            }

            image->pixels = pixels;
            image->width = rotator.get_transformed_width();
            image->height = rotator.get_transformed_height();
            image->depth = TP_JPEG_DEPTH;
            image->pitch = rotator.get_transformed_width() * image->depth;
            image->bgr = 0;
            image->free_image = 0;

            switch ( cinfo->output_components )
            {
                case 1:
                case 3:
                    image->pm_alpha = 1;
                    break;

                case 4:
                    image->pm_alpha = 0;
                    Image::premultiply_alpha( image );
                    break;
            }

        }
        catch ( ... )
        {
            free( pixels );

            throw;
        }

        return TP_IMAGE_DECODE_OK;
    }

    // This is our own error handler

    static void jpeg_error( j_common_ptr cinfo )
    {
        throw 1;
    }

    // These are the functions for the jpeg memory source manager

    static void init_source( j_decompress_ptr cinfo )
    {
    }

    static boolean fill_input_buffer( j_decompress_ptr cinfo )
    {
        return true;
    }

    static void skip_input_data( j_decompress_ptr cinfo, long num_bytes )
    {
        cinfo->src->bytes_in_buffer -= num_bytes;
        cinfo->src->next_input_byte += num_bytes;
    }

    static void term_source( j_decompress_ptr cinfo )
    {
    }
};

class GIFDecoder : public Images::Decoder
{
public:

    virtual const char* name()
    {
        return "GIF Decoder";
    }

    virtual int decode( gpointer data, gsize size, TPImage* image )
    {
        PROFILER( "Images::GIF_decode/memory" , PROFILER_INTERNAL_CALLS );

        UserData user_data = { ( guchar* ) data, size };

#if defined(GIFLIB_MAJOR) && (GIFLIB_MAJOR >= 5)
        int error;
        GifFileType* g = DGifOpen( & user_data , input_function , &error );
#else
        GifFileType* g = DGifOpen( &user_data, input_function );
#endif

        if ( ! g )
        {
            return TP_IMAGE_DECODE_FAILED;
        }

        int result = decode( g, image );

        DGifCloseFile( g );

        return result;
    }

    virtual int decode( const char* filename, TPImage* image )
    {
        PROFILER( "Images::GIF_decode/file" , PROFILER_INTERNAL_CALLS );

#if defined(GIFLIB_MAJOR) && (GIFLIB_MAJOR >= 5)
        int error;
        GifFileType* g = DGifOpenFileName( filename , &error );
#else
        GifFileType* g = DGifOpenFileName( filename );
#endif

        if ( ! g )
        {
            return TP_IMAGE_DECODE_FAILED;
        }

        int result = decode( g, image );

        DGifCloseFile( g );

        return result;
    }

private:

    struct UserData
    {
        guchar*     source;
        gssize      size;
    };

    static int input_function( GifFileType* g, GifByteType* buffer, int count )
    {
        UserData* user_data = ( UserData* ) g->UserData;

        if ( count > user_data->size )
        {
            count = user_data->size;
        }

        if ( count > 0 )
        {
            memcpy( buffer, user_data->source, count );

            user_data->source += count;
            user_data->size -= count;
        }

        return count;
    }

    int decode( GifFileType* g, TPImage* image )
    {
        g_assert( g );

        try
        {
            // Allocate and prepare the 'screen'

            failif( g->SWidth <= 0 || g->SHeight <= 0 , "INVALID SCREEN DIMENSIONS" );

            GifPixelType* screen = g_new( GifPixelType, g->SWidth * g->SHeight );

            failif( ! screen , "FAILED TO ALLOCATE SCREEN MEMORY" );

            FreeLater free_later( screen );

            // Fill it with the background color

            GifPixelType* last  = screen + ( g->SWidth * g->SHeight );

            for ( GifPixelType* pixel = screen ; pixel < last; ++pixel )
            {
                * pixel = g->SBackGroundColor;
            }

            // Store the screen's color map - each frame may have its own

            ColorMapObject* color_map = g->SColorMap;

            // No transparent color by default

            int transparent_color = -1;

            // Look at each record

            bool done = false;

            while ( ! done )
            {
                GifRecordType record_type;

                failif( GIF_ERROR == DGifGetRecordType( g, & record_type ), "FAILED TO GET RECORD TYPE" );

                switch ( record_type )
                {

                    case TERMINATE_RECORD_TYPE:

                        done = true;
                        break;

                    case EXTENSION_RECORD_TYPE:

                    {
                        int extension_code;

                        GifByteType* extension;

                        failif( GIF_ERROR == DGifGetExtension( g, & extension_code, & extension ), "FAILED TO GET EXTENSION" );

                        // Look for the transparent color in the graphics control extension

                        if ( extension_code == GRAPHICS_EXT_FUNC_CODE && extension[ 0 ] >= 4 && ( extension[ 1 ] & 1 ) )
                        {
                            transparent_color = extension[ 3 ];
                        }

                        while ( extension )
                        {
                            failif( GIF_ERROR == DGifGetExtensionNext( g, & extension ), "FAILED TO READ EXTENSION" );
                        }
                    }
                    break;

                    case IMAGE_DESC_RECORD_TYPE:

                    {
                        failif( GIF_ERROR == DGifGetImageDesc( g ), "FAILED TO READ IMAGE DESCRIPTION" );

                        int row = g->Image.Top;
                        int col = g->Image.Left;
                        int width = g->Image.Width;
                        int height = g->Image.Height;

                        failif( row < 0 || col < 0 || width < 0 || height < 0, "INVALID IMAGE DIMENSIONS" );
                        failif( col + width > g->SWidth || row + height > g->SHeight, "IMAGE DIMENSIONS OUTSIDE OF SCREEN" );

                        GifPixelType* destination;

                        if ( g->Image.Interlace )
                        {
                            static int interlaced_offset[ 4 ] = { 0, 4, 2, 1 };
                            static int interlaced_jumps[ 4] = { 8, 8, 4, 2 };

                            for ( int i = 0; i < 4; ++i )
                            {
                                for ( int j = row + interlaced_offset[i]; j < row + height; j += interlaced_jumps[i] )
                                {
                                    destination = screen + ( j * g->SWidth ) + col;

                                    failif( GIF_ERROR == DGifGetLine( g, destination, width ), "FAILED TO GET SCAN LINE" );
                                }
                            }
                        }
                        else
                        {
                            for ( int i = 0; i < height; ++i )
                            {
                                destination = screen + ( ( row + i ) * g->SWidth ) + col;

                                failif( GIF_ERROR == DGifGetLine( g, destination, width ), "FAILED TO GET SCAN LINE" );
                            }
                        }

                        if ( g->Image.ColorMap )
                        {
                            color_map = g->Image.ColorMap;
                        }

                        // We bail after we read the first frame

                        done = true;
                    }

                    break;

                    default:

                        break;
                }
            }

            failif( ! color_map, "MISSING COLOR MAP" );

            image->bgr = 0;
            image->width = g->SWidth;
            image->height = g->SHeight;
            image->depth = transparent_color >= 0 ? 4 : 3;
            image->pitch = g->SWidth * image->depth;
            image->pm_alpha = 0;

            image->pixels = malloc( image->height * image->width * image->depth );

            failif( ! image->pixels, "FAILED TO ALLOCATE PIXEL MEMORY" );

            guchar* destination = ( guchar* ) image->pixels;
            g_assert( destination );

            GifPixelType* source = screen;

            for ( unsigned int i = 0; i < image->width * image->height; ++source, ++i )
            {
                if ( * source < color_map->ColorCount )
                {
                    GifColorType* color = & color_map->Colors[ * source ];
                    g_assert( color );

                    *( destination++ ) = color->Red;
                    *( destination++ ) = color->Green;
                    *( destination++ ) = color->Blue;

                    if ( image->depth == 4 )
                    {
                        *( destination++ ) = ( * source == transparent_color ) ? 0 : 255;
                    }
                }
                else
                {
                    *( destination++ ) = 0;
                    *( destination++ ) = 0;
                    *( destination++ ) = 0;

                    if ( image->depth == 4 )
                    {
                        *( destination++ ) = 255;
                    }
                }
            }

            Image::premultiply_alpha( image );

            return TP_IMAGE_DECODE_OK;
        }
        catch ( const String& e )
        {
            g_warning( "FAILED TO DECODE GIF : %s", e.c_str() );

            return TP_IMAGE_DECODE_FAILED;
        }
    }
};

Images::Decoder* make_png_decoder()
{
    return new PNGDecoder();
}

Images::Decoder* make_jpeg_decoder()
{
    return new JPEGDecoder();
}

Images::Decoder* make_tiff_decoder()
{
    return new TIFFDecoder();
}

Images::Decoder* make_gif_decoder()
{
    return new GIFDecoder();
}
};
