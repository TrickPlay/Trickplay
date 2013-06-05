#include <magick/MagickCore.h>
#include <glib.h>
#include <gio/gio.h>
#include <string.h>

#define LEGAL_FILENAME_CHARS "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ1234567890_.-"

void usage( const char* appname )
{
    printf( "Usage: %s intpufile.psd [outputdirectory]\n"
            " - Will read inputfile.psd and write out each layer in the file into a separate PNG in\n"
            "outputdirectory (or $CWD if outputdirectory not specified).  Each PNG will be named\n"
            "with the layername from the PSD; in the case of duplicate layer names, a numeric suffix\n"
            "will be added to the filename, e.g. layer-1.png, layer-2.png, etc\n", appname );
}

int main( int argc, char** argv )
{
    g_type_init();

    if ( argc < 2 || argc > 3 )
    {
        usage( argv[0] );
        return 1;
    }

    GFile* input_file = g_file_new_for_commandline_arg( argv[1] );
    char* inputfile_path = g_file_get_path( input_file );

    if ( !g_file_query_exists( input_file, NULL ) )
    {
        fprintf( stderr, "Input file %s does not exist\n", inputfile_path );
        usage( argv[0] );
        g_free( inputfile_path );
        g_object_unref( input_file );
        return 1;
    }

    if ( G_FILE_TYPE_REGULAR != g_file_query_file_type( input_file, G_FILE_QUERY_INFO_NONE, NULL ) )
    {
        fprintf( stderr, "Input path %s does not refer to a file\n", inputfile_path );
        usage( argv[0] );
        g_free( inputfile_path );
        g_object_unref( input_file );
        return 1;
    }

    GFile* output_directory;

    if ( 2 == argc )
    {
        output_directory = g_file_new_for_commandline_arg( argv[2] );
    }
    else
    {
        output_directory = g_file_new_for_commandline_arg( "." );
    }

    char* output_path = g_file_get_path( output_directory );

    if ( !g_file_query_exists( output_directory, NULL ) )
    {
        fprintf( stderr, "Output directory %s does not exist\n", output_path );
        usage( argv[0] );
        g_free( output_path );
        g_object_unref( output_directory );
        g_free( inputfile_path );
        g_object_unref( input_file );
        return 1;
    }

    if ( G_FILE_TYPE_DIRECTORY != g_file_query_file_type( output_directory, G_FILE_QUERY_INFO_NONE, NULL ) )
    {
        fprintf( stderr, "Output path %s does not refer to a directory\n", output_path );
        usage( argv[0] );
        g_free( output_path );
        g_object_unref( output_directory );
        g_free( inputfile_path );
        g_object_unref( input_file );
        return 1;
    }

    MagickCoreGenesis( *argv, MagickTrue );

    ExceptionInfo* exception;

    Image* image, *images;

    ImageInfo* image_info;

    image_info = AcquireImageInfo();
    CopyMagickString( image_info->filename, inputfile_path, MaxTextExtent );
    exception = AcquireExceptionInfo();
    images = ReadImage( image_info, exception );

    if ( exception->severity != UndefinedException )
    {
        CatchException( exception );
    }

    if ( images == ( Image* ) NULL )
    {
        exit( 1 );
    }

    while ( ( image = RemoveFirstImageFromList( &images ) ) != ( Image* ) NULL )
    {
        const char* prop = GetImageProperty( image, "label" );

        if ( prop )
        {
            // Copy string so we can modify it
            gchar* mod_prop = g_strdup( prop );
            GString* new_file_name = g_string_sized_new( strlen( g_strcanon( mod_prop, LEGAL_FILENAME_CHARS, '_' ) ) + 6 );

            // Build the filename
            g_string_sprintf( new_file_name, "%s.png", mod_prop );
            GFile* new_image_file = g_file_get_child( output_directory, new_file_name->str );
            unsigned i = 0;

            // Ensure that we have a file that doesn't already exist
            while ( g_file_query_exists( new_image_file, NULL ) )
            {
                g_string_sprintf( new_file_name, "%s-%d.png", mod_prop, ++i );
                g_object_unref( new_image_file );
                new_image_file = g_file_get_child( output_directory, new_file_name->str );
            }

            printf( "Image (%s): %lu x %lu @ (%lu,%lu) - %s\n", new_file_name->str, image->page.width, image->page.height, image->page.x, image->page.y, ( NoCompositeOp == image->compose ) ? "HIDDEN" : "SHOWN" );
            g_free( mod_prop );
            g_string_free( new_file_name, TRUE );

            char* new_file_path = g_file_get_path( new_image_file );
            CopyMagickString( image->filename, new_file_path, MaxTextExtent );
            g_free( new_file_path );

            ImageInfo* output_info = AcquireImageInfo();
            CopyMagickString( output_info->filename, image->filename, MaxTextExtent );
            // Set the file-type, just in case
            CopyMagickString( output_info->magick, "png", MaxTextExtent );

            if ( !WriteImage( output_info, image ) )
            {
                printf( "WRITE FAILED FOR %s", output_info->filename );
            }

            DestroyImageInfo( output_info );
            g_object_unref( new_image_file );
        }

        DestroyImage( image );
    }

    exception = DestroyExceptionInfo( exception );
    image_info = DestroyImageInfo( image_info );
    MagickCoreTerminus();

    g_free( output_path );
    g_object_unref( output_directory );
    g_free( inputfile_path );
    g_object_unref( input_file );

    return 0;
}
