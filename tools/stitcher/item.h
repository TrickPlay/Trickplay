#ifndef __ITEM_H__
#define __ITEM_H__

#include <magick/MagickCore.h>
#include "options.h"

typedef struct Item {
  unsigned w, h, area, x_offset, y_offset;
  const char * id;
  char * checksum;
  Image * source;
  GPtrArray * children;
} Item;

Item * item_new ( const char * id );
void item_free ( Item * item );
Item * item_new_with_source( const char * id, Image * source );
void item_add_child( Item * item, Item * child );
gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) );
char * item_to_string( Item * item, int x, int y, unsigned indent );

#endif
