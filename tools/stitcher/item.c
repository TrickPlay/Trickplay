#include <string.h>
#include "item.h"

Item * item_new ( const char * id )
{
    id = strdup( id );

    Item * item = malloc( sizeof( Item ) );

    item->w = 0;
    item->h = 0;
    item->area = 0;
    
    item->x_offset = 0;
    item->y_offset = 0;

    item->id = id;
    item->source = NULL;
    item->checksum = NULL;
    item->children = g_ptr_array_new_with_free_func( (GDestroyNotify) item_free );

    return item;
}

void item_free ( Item * item )
{
    g_ptr_array_free( item->children, TRUE );
    
    if ( item->source ) DestroyImage( item->source );
    if ( item->id     ) free( (char *) item->id );

    free( item );
}

Item * item_new_with_source( const char * id, Image * source )
{
    Item * item = item_new( id );
    
    item->source = source;
    item->w = (unsigned) source->columns;
    item->h = (unsigned) source->rows;
    item->area = item->w * item->h;
    
    size_t length;
    ImageInfo * info = AcquireImageInfo();
    ExceptionInfo * exception = AcquireExceptionInfo();
    unsigned char * data = ImageToBlob( info, source, &length, exception );
    
    item->checksum = g_compute_checksum_for_data( G_CHECKSUM_MD5, data, length );
    
    DestroyImageInfo( info );
    DestroyExceptionInfo( exception );
    free( data );
    
    return item;
}

void item_add_child( Item * item, Item * child )
{
    g_ptr_array_add( item->children, child );
}

gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) )
{
    Item * aa = (Item *) a, * bb = (Item *) b;
    unsigned  m = ( MAX( bb->w, bb->h ) - MAX( aa->w, aa->h ) );
    if ( !m ) m =   MIN( bb->w, bb->h ) - MIN( aa->w, aa->h );

    return m;
}

char * item_to_string( Item * item, int x, int y, unsigned indent )
{
    char ** strings = g_new0( char *, item->children->len + 2 );
    
    char * in = g_strnfill( indent * 2 + 4, ' ' );
    
    strings[0] = g_strdup_printf( "\n%s{ \"x\": %i, \"y\": %i, \"w\": %i, \"h\": %i, \"id\": \"%s\" }",
        in, x, y, item->w, item->h, item->id );
    free( in );
    
    for ( unsigned i = 0; i < item->children->len; ++i )
    {
        strings[i+1] = item_to_string( g_ptr_array_index( item->children, i ), x, y, indent + 1 );
    }
    
    char * string = g_strjoinv( NULL, strings );
    g_strfreev( strings );
    
    return string;
}

