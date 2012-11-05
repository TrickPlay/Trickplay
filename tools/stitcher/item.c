#include "item.h"

Item * item_new ( const char * id )
{
    id = strdup( id );

    Item * item = malloc( sizeof( Item ) );

    item->w = 0;
    item->h = 0;
    item->area = 0;

    item->id = id;
    item->path = NULL;
    item->file = NULL;
    item->source = NULL;
    item->placed = FALSE;

    return item;
}

void item_free ( Item * item )
{
    if ( item->file )
        g_object_unref( item->file );
    if ( item->source )
        DestroyImage( item->source );
    free( (char *) item->id );
    free( (char *) item->path );
        
    free( item );
}

Item * item_new_from_file ( const char * id, const char * directory, GFile * file, Options * options )
{
    Item * item = item_new( id );

    const char * path = directory ? g_build_filename( directory, item->id, NULL ) : item->id;

    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo * input_info = AcquireImageInfo();
    CopyMagickString( input_info->filename, path, MaxTextExtent );
    Image * temp_image = PingImage( input_info, exception );

    if ( exception->severity != UndefinedException )
    {
        free( item );
        return NULL;
    }

    unsigned int bp = options->add_buffer_pixels ? 2 : 0;
    item->path = path;
    item->file = file;
    item->w = (unsigned int) temp_image->columns + bp;
    item->h = (unsigned int) temp_image->rows    + bp;
    item->area = item->w * item->h;

    DestroyImage( temp_image );
    DestroyExceptionInfo( exception );

    return item;
}

void item_set_source( Item * item, Image * source, Options * options )
{
    unsigned int bp = options->add_buffer_pixels ? 2 : 0;
    item->source = source;
    item->w = (unsigned int) source->columns + bp;
    item->h = (unsigned int) source->rows    + bp;
    item->area = item->w * item->h;
}

gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) )
{
    Item * aa = (Item *) a, * bb = (Item *) b;
    unsigned int m = MAX( bb->w, bb->h ) - MAX( aa->w, aa->h );
    return m != 0 ? m : MIN( bb->w, bb->h ) - MIN( aa->w, aa->h );
}
