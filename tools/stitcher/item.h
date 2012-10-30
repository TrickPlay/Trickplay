#ifndef __ITEM_H__
#define __ITEM_H__

#include <gio/gio.h>
#include <glib.h>
#include <magick/MagickCore.h>

#include "main.h"

typedef struct Item {
  unsigned int x, y, w, h, area;
  char  * id,
        * path;
  GFile * file;
  Image * source;
  gboolean placed;
} Item;


Item * item_new ( char * id );
void item_set_source( Item * item, Image * source, gboolean add_buffer_pixels, Page *minimum, Page *smallest, unsigned int *output_size_step );
void item_add_to_items ( Item * item, GSequence *items, unsigned int input_size_limit, unsigned int output_size_limit, gboolean copy_large_images, GPtrArray  * large_images, gboolean allow_multiple_sheets );
void item_load ( GFile * file, GFile * base, char * base_path, GPtrArray * input_patterns, gboolean recursive, gboolean add_buffer_pixels, Page *minimum, Page *smallest, unsigned int *output_size_step, GSequence *items, unsigned int input_size_limit, unsigned int output_size_limit, gboolean copy_large_images, GPtrArray  * large_images, gboolean allow_multiple_sheets, GHashTable * input_ids );

#endif
