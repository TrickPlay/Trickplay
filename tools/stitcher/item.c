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
    
    g_assert( source );
    SignatureImage( source );
    item->checksum = strdup( GetImageProperty( source, "signature" ) );
    
    return item;
}

// items can be given children which describe duplicates and subsets of them, saving space

void item_add_child( Item * item, Item * child )
{
    g_ptr_array_add( item->children, child );
}

Item * item_add_child_new( Item * item, const char * id, unsigned x_offset, unsigned y_offset, unsigned w, unsigned h )
{
    Item * child = item_new( id );
    item_add_child( item, child );
    
    child->x_offset = x_offset;
    child->y_offset = y_offset;
    child->w = w;
    child->h = h;
    
    return child;
}

// comparison first by the longer dimension, then the shorter dimension

gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) )
{
    Item * aa = (Item *) a, * bb = (Item *) b;
    unsigned  m = ( MAX( bb->w, bb->h ) - MAX( aa->w, aa->h ) );
    if ( !m ) m =   MIN( bb->w, bb->h ) - MIN( aa->w, aa->h );

    return m;
}

// generate the JSON row for this item, but also the rows of its children, and their children, etc

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
    
    char * string = g_strjoinv( ",", strings );
    g_strfreev( strings );
    
    return string;
}

