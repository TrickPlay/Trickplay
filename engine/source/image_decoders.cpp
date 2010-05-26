
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

#include "image_decoders.h"
#include "common.h"
#include "profiler.h"

//=============================================================================
// An input stream that does not copy the buffer

class imstream : private std::streambuf, public std::istream
{

public:

    imstream( char * buf, size_t size )
    :
        std::istream( this )
    {
        setg( buf, buf, buf + size );
    }

protected:

    virtual std::streampos seekpos( std::streampos sp, std::ios_base::openmode which = ios_base::in | ios_base::out )
    {
        if ( which & std::ios_base::in )
        {
            char * b = eback();
            char * p = b + sp;

            if ( p >= b && p < egptr() )
            {
                setg( b, p, egptr() );
                return p - b;
            }
        }

        return -1;
    }

    virtual std::streampos seekoff( std::streamoff off, std::ios_base::seekdir way, std::ios_base::openmode which = std::ios_base::in | std::ios_base::out )
    {
        switch ( way )
        {
            case std::ios_base::beg: return seekpos( off, which );
            case std::ios_base::cur: return seekpos( gptr() + off - eback(), which );
            case std::ios_base::end: return seekpos( egptr() + off - eback(), which );
            default: return -1;
        }
    }
};

//=============================================================================


namespace ImageDecoders
{
    class TIFFDecoder : public Images::Decoder
    {
    public:

        virtual const char * name()
        {
            return "TIFF Decoder";
        }

        virtual int decode( gpointer data, gsize size, TPImage * image )
        {
            PROFILER( "Images::TIFF_decode/memory" );

            imstream stream( ( char * )data, size );

            TIFF * tiff = TIFFStreamOpen( "memory", &stream );

            if ( ! tiff )
            {
                return TP_IMAGE_UNSUPPORTED_FORMAT;
            }

            int result = decode( tiff, image );

            TIFFClose( tiff );

            return result;
        }

        virtual int decode( const char * filename, TPImage * image )
        {
            PROFILER( "Images::TIFF_decode/file" );

            TIFF * tiff = TIFFOpen( filename, "r" );

            if ( ! tiff )
            {
                return TP_IMAGE_UNSUPPORTED_FORMAT;
            }

            int result = decode( tiff, image );

            TIFFClose( tiff );

            return result;
        }

    private:

        int decode( TIFF * tiff, TPImage * image )
        {
            g_assert( tiff );
            g_assert( image );

            int result = TP_IMAGE_DECODE_FAILED;

            uint32 width;
            uint32 height;

            TIFFGetField( tiff, TIFFTAG_IMAGEWIDTH, &width );
            TIFFGetField( tiff, TIFFTAG_IMAGELENGTH, &height );

            uint32 * pixels = ( uint32 * )_TIFFmalloc( width * height * 4 );

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
                    image->free_pixels = _TIFFfree;

                    result = TP_IMAGE_DECODE_OK;
                }
                else
                {
                    _TIFFfree( pixels );
                }
            }

            return result;
        }
    };

    class PNGDecoder : public Images::Decoder
    {
    public:

        virtual const char * name()
        {
            return "PNG Decoder";
        }

        virtual int decode( gpointer data, gsize size, TPImage * image )
        {
            PROFILER( "Images::PNG_decode/memory" );

            imstream stream( ( char * )data, size );

            return decode( stream, image );
        }

        virtual int decode( const char * filename, TPImage * image )
        {
            PROFILER( "Images::PNG_decode/file" );

            std::ifstream stream;

            stream.open( filename, std::ios_base::in | std::ios_base::binary );

            int result = decode( stream, image );

            stream.close();

            return result;
        }

    private:

        int decode( std::istream & stream, TPImage * image )
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
                                png_set_gray_to_rgb(png_ptr);
                                depth = 3;
                            }
                            else if ( color_type == PNG_COLOR_TYPE_GRAY_ALPHA )
                            {
                                png_set_gray_to_rgb(png_ptr);
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

                                for( png_uint_32 row = 0; row < height; ++row )
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
                                image->free_pixels = NULL;

                                result = TP_IMAGE_DECODE_OK;
                            }
                        }
                    }
                }

                png_destroy_read_struct( &png_ptr, &info_ptr, &end_info );
            }

            return result;
        }

        static void istream_png_read_data(png_structp png_ptr, png_bytep data, png_size_t length)
        {
            if ( ! png_ptr )
            {
                return;
            }

            std::istream * stream = ( std::istream * )png_get_io_ptr( png_ptr );

            g_assert( stream );

            stream->read( ( char * )data, length );

            if ( stream->gcount() != std::streampos( length ) )
            {
                png_error( png_ptr, "Read Error" );
            }
        }
    };

    class JPEGDecoder : public Images::Decoder
    {
    public:

        virtual const char * name()
        {
            return "JPEG Decoder";
        }

        virtual int decode( gpointer data, gsize size, TPImage * image )
        {
            PROFILER( "Images::JPEG_decode/memory" );

            if ( size < 2 )
            {
                return TP_IMAGE_UNSUPPORTED_FORMAT;
            }

            guchar * header = ( guchar * )data;

            if ( ! ( header[0] == 0xFF && header[1] == 0xD8 ) )
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
            source.next_input_byte = ( JOCTET * ) data;
            source.fill_input_buffer = fill_input_buffer;
            source.init_source = init_source;
            source.resync_to_restart = jpeg_resync_to_restart;
            source.skip_input_data = skip_input_data;
            source.term_source = term_source;

            cinfo.src = &source;

            int result = TP_IMAGE_DECODE_FAILED;

            try
            {
                result = decode( &cinfo, image );

                jpeg_finish_decompress( &cinfo );
            }
            catch( ... )
            {
                result = TP_IMAGE_DECODE_FAILED;
            }

            jpeg_destroy_decompress( &cinfo );

            return result;
        }

        virtual int decode( const char * filename, TPImage * image )
        {
            PROFILER( "Images::JPEG_decode/file" );

            FILE * file = fopen( filename, "rb" );

            if ( ! file )
            {
                return TP_IMAGE_DECODE_FAILED;
            }

            guchar header[2];

            if ( fread(header, 1, 2, file ) != 2 )
            {
                fclose( file );
                return TP_IMAGE_DECODE_FAILED;
            }

            if ( ! ( header[0] == 0xFF && header[1] == 0xD8 ) )
            {
                fclose( file );
                return TP_IMAGE_UNSUPPORTED_FORMAT;
            }

            fseek( file, 0, SEEK_SET );

            jpeg_decompress_struct cinfo;
            jpeg_error_mgr jerr;

            cinfo.err = jpeg_std_error( &jerr );
            cinfo.err->error_exit = jpeg_error;

            jpeg_create_decompress( &cinfo );

            int result = TP_IMAGE_DECODE_FAILED;

            try
            {
                jpeg_stdio_src( &cinfo, file );

                result = decode( &cinfo, image );

                jpeg_finish_decompress( &cinfo );
            }
            catch( ... )
            {
                result = TP_IMAGE_DECODE_FAILED;
            }

            jpeg_destroy_decompress( &cinfo );

            fclose( file );

            return result;
        }

    private:

        int decode( j_decompress_ptr cinfo, TPImage * image )
        {
            jpeg_read_header( cinfo, TRUE );

            jpeg_start_decompress( cinfo );

            g_assert( cinfo->output_components == 3 || cinfo->output_components == 1 );

            JSAMPARRAY buffer = (*cinfo->mem->alloc_sarray)( ( j_common_ptr ) cinfo, JPOOL_IMAGE, cinfo->output_width * cinfo->output_components, 1 );

            if ( ! buffer )
            {
                return TP_IMAGE_DECODE_FAILED;
            }

            guchar * pixels = ( guchar * )malloc( cinfo->output_width * cinfo->output_height * 3 );

            if ( ! pixels )
            {
                return TP_IMAGE_DECODE_FAILED;
            }

            try
            {
                guchar * p = pixels;

                while( cinfo->output_scanline < cinfo->output_height )
                {
                    jpeg_read_scanlines( cinfo, buffer, 1 );

                    if ( cinfo->output_components == 3 )
                    {
                        unsigned int index = 0;

                        for( unsigned int c = 0; c < cinfo->output_width; ++c, index += 3 )
                        {
                            *(p++) = (*buffer)[ index ];
                            *(p++) = (*buffer)[ index + 1 ];
                            *(p++) = (*buffer)[ index + 2 ];
                        }
                    }
                    else if ( cinfo->output_components == 1 )
                    {
                        unsigned int index = 0;

                        for( unsigned int c = 0; c < cinfo->output_width; ++c, index += 1 )
                        {
                            *(p++) = (*buffer)[ index ];
                            *(p++) = (*buffer)[ index ];
                            *(p++) = (*buffer)[ index ];
                        }
                    }
                }

                image->pixels = pixels;
                image->width = cinfo->output_width;
                image->height = cinfo->output_height;
                image->depth = 3;
                image->pitch = cinfo->output_width * 3;
                image->bgr = 0;
                image->free_pixels = NULL;
            }
            catch( ... )
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

    Images::Decoder * make_png_decoder()
    {
        return new PNGDecoder();
    }

    Images::Decoder * make_jpeg_decoder()
    {
        return new JPEGDecoder();
    }

    Images::Decoder * make_tiff_decoder()
    {
        return new TIFFDecoder();
    }

};
