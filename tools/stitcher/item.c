#include <string.h>
#include "item.h"

Item * item_new ( const char * id )
{
    id = strdup( id );

    Item * item = malloc( sizeof( Item ) );

    item->w = 0;
    item->h = 0;
    item->area = 0;

    item->id = id;
    item->source = NULL;

    return item;
}

void item_free ( Item * item )
{
    if ( item->source ) DestroyImage( item->source );
    if ( item->id     ) free( (char *) item->id );

    free( item );
}

Item * item_new_with_source( const char * id, Image * source, Options * options )
{
    Item * item = item_new( id );
    
    unsigned int bp = options->add_buffer_pixels ? 2 : 0;
    item->source = source;
    item->w = (unsigned int) source->columns + bp;
    item->h = (unsigned int) source->rows    + bp;
    item->area = item->w * item->h;
    
    return item;
}

gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) )
{
    Item * aa = (Item *) a, * bb = (Item *) b;
    unsigned  m = ( MAX( bb->w, bb->h ) - MAX( aa->w, aa->h ) );
    if ( !m ) m =   MIN( bb->w, bb->h ) - MIN( aa->w, aa->h );

    return m;
}
