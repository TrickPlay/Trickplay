#ifndef __ITEM_H__
#define __ITEM_H__

#include <magick/MagickCore.h>
#include "options.h"

typedef struct Item {
  unsigned int w, h, area;
  const char * id;
  Image * source;
  gboolean placed;
} Item;

Item * item_new ( const char * id );
void item_free ( Item * item );
Item * item_new_with_source( const char * id, Image * source, Options * options );
gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) );

#endif
