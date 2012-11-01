#ifndef __ITEM_H__
#define __ITEM_H__

#include "main.h"

typedef struct Item {
  unsigned int w, h, area;
  char  * id,
        * path;
  GFile * file;
  Image * source;
  gboolean placed;
} Item;

Item * item_new ( char * id );
void item_free ( Item * item );
void item_set_source( Item * item, Image * source, Options * options );
Item * item_new_from_file ( char * id, char * directory, GFile * file, Options * options );
gint item_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__((unused)) );

#endif
