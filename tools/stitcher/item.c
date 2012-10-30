#include "item.h"
#include <string.h>

int gcf( int a, int b )
{
    int t;
    if ( b > a )
    {
        t = b;
        b = a;
        a = t;
    }
    while ( b != 0 )
    {
        t = b;
        b = a % b;
        a = t;
    }
    return a;
}

Item * item_new ( char * id )
{
    id = strdup( id );

    Item * item = malloc( sizeof( Item ) );

    item->x = 0;
    item->y = 0;
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

Item * item_new_from_file ( char * id, char * base_path, GFile * file, gboolean add_buffer_pixels, Page *minimum, Page *smallest, unsigned int *output_size_step, GHashTable * input_ids )
{
    if ( g_hash_table_lookup( input_ids, id ) )
        return NULL;
    
    g_hash_table_insert( input_ids, id, id );
    Item * item = item_new( id );
    if ( item == NULL )
        return NULL;

    char * path = base_path ? g_build_filename( base_path, item->id, NULL ) : item->id;

    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo * input_info = AcquireImageInfo();
    CopyMagickString( input_info->filename, path, MaxTextExtent );
    Image * temp_image = PingImage( input_info, exception );

    if ( exception->severity != UndefinedException )
    {
        free( item );
        return NULL;
    }

    item->path = path;
    item->file = file;
    item->w = (unsigned int) temp_image->columns + ( add_buffer_pixels ? 2 : 0 );
    item->h = (unsigned int) temp_image->rows    + ( add_buffer_pixels ? 2 : 0 );
    item->area = item->w * item->h;

    minimum->area   += item->area;
    minimum->width   = MAX( minimum->width,   item->w );
    minimum->height  = MAX( minimum->height,  item->h );
    smallest->width  = MIN( smallest->width,  item->w );
    smallest->height = MIN( smallest->height, item->w );

    if ( *output_size_step == 0 )
      *output_size_step = item->w;
    else
      *output_size_step = gcf( item->w, *output_size_step );

    DestroyImage( temp_image );
    DestroyExceptionInfo( exception );

    return item;
}

void item_set_source( Item * item, Image * source, gboolean add_buffer_pixels, Page *minimum, Page *smallest, unsigned int *output_size_step )
{
    item->source = source;
    item->w = (unsigned int) source->columns + ( add_buffer_pixels ? 2 : 0 );
    item->h = (unsigned int) source->rows    + ( add_buffer_pixels ? 2 : 0 );
    item->area = item->w * item->h;

    minimum->area += item->area;
    minimum->width   = MAX( minimum->width,   item->w );
    minimum->height  = MAX( minimum->height,  item->h );
    smallest->width  = MIN( smallest->width,  item->w );
    smallest->height = MIN( smallest->height, item->w );

    if ( *output_size_step == 0 )
      *output_size_step = item->w;
    else
      *output_size_step = gcf( item->w, *output_size_step );
}

gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) )
{
    Item * aa = (Item *) a, * bb = (Item *) b;
    unsigned int m = MAX( bb->w, bb->h ) - MAX( aa->w, aa->h );
    return m != 0 ? m : MIN( bb->w, bb->h ) - MIN( aa->w, aa->h );
}

void item_add_to_items ( Item * item, GSequence *items, unsigned int input_size_limit, unsigned int output_size_limit, gboolean copy_large_images, GPtrArray  * large_images, gboolean allow_multiple_sheets )
{
    if ( item != NULL )
    {
        if ( item->w <= input_size_limit && item->h <= input_size_limit )
            g_sequence_insert_sorted( items, item, item_compare, NULL );
        else if ( copy_large_images && allow_multiple_sheets &&
                  item->w <= output_size_limit && item->h <= output_size_limit )
            g_ptr_array_add( large_images, item );
    }
}

void item_load ( GFile * file, GFile * base, char * base_path, GPtrArray * input_patterns, gboolean recursive, gboolean add_buffer_pixels, Page *minimum, Page *smallest, unsigned int *output_size_step, GSequence *items, unsigned int input_size_limit, unsigned int output_size_limit, gboolean copy_large_images, GPtrArray  * large_images, gboolean allow_multiple_sheets, GHashTable * input_ids )
{
    GFileInfo * info = g_file_query_info( file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
    GFileType type = g_file_info_get_file_type( info );

    if ( type == G_FILE_TYPE_DIRECTORY )
    {
        if ( file != base && !recursive )
            return;

        GFileEnumerator * children = g_file_enumerate_children( file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
        GFileInfo * child_info;
        GFile * child;

        while ( ( child_info = g_file_enumerator_next_file( children, NULL, NULL ) ) != NULL )
        {
            child = g_file_get_child( file, g_file_info_get_name( child_info ) );
            item_load( child, base, base_path, input_patterns, recursive, add_buffer_pixels, minimum, smallest, output_size_step, items, input_size_limit, output_size_limit, copy_large_images, large_images, allow_multiple_sheets, input_ids );
            g_object_unref( child_info );
        }

        g_file_enumerator_close( children, NULL, NULL );
        g_object_unref( children );

    }
    else if ( type == G_FILE_TYPE_REGULAR )
    {
        char * path = ( file == base ) ? base_path : g_file_get_relative_path( base, file );
        unsigned int i;
        for ( i = 0; i < input_patterns->len; i++ )
            if ( g_pattern_match_string( g_ptr_array_index( input_patterns, i ), path ) )
                break;

        if ( i == 0 || i < input_patterns->len || file == base)
            item_add_to_items( item_new_from_file( path, ( file == base ) ? NULL : base_path, file, add_buffer_pixels, minimum, smallest, output_size_step, input_ids ), items, input_size_limit, output_size_limit, copy_large_images, large_images, allow_multiple_sheets );
    }

    g_object_unref( info );
}
