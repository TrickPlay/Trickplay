/*

    spritesheet.h

*/

#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include <clutter/clutter.h>
#include <stdlib.h>

typedef struct SpriteSheet {
  GHashTable *map;
  CoglMaterial **material;
  CoglHandle **texture;
  gint *w;
  gint *h;
  gint n;
} SpriteSheet;

SpriteSheet* spritesheet_new(CoglHandle *texture, gchar* names[], gint data[], gint n, gint filter);

void spritesheet_get_sprite(SpriteSheet *sheet, gchar *name, CoglMaterial **material, CoglHandle **texture, gint *w, gint *h);

void spritesheet_free(SpriteSheet *sheet);

#endif