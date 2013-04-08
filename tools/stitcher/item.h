#ifndef __ITEM_H__
#define __ITEM_H__

/*

item.h

An Item represents a single sprite + id pair to be included in the spritesheet. Items can have hierarchical 'children', which define virtual duplicates or subimages of their parent Item, in which case only the topmost parent Item will take up real space in the spritesheet.

Items handle how they are converted to lines in the JSON result, but not how they are composited into the spritesheet textures (see state.c).

*/

#include <magick/MagickCore.h>
#include "options.h"

typedef struct Item
{
    unsigned w, h, area, x_offset, y_offset;
    const char* id;
    char* checksum;
    Image* source;
    GPtrArray* children;
} Item;

Item* item_new( const char* id );
void item_free( Item* item );
Item* item_new_with_source( const char* id, Image* source );
void item_add_child( Item* item, Item* child );
Item* item_add_child_new( Item* item, const char* id, unsigned x_offset, unsigned y_offset, unsigned w, unsigned h );
gint item_compare( gconstpointer a, gconstpointer b, gpointer user_data __attribute__( ( unused ) ) );
char* item_to_string( Item* item, int x, int y, unsigned indent );

#endif
