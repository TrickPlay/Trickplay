/*

    nineslice.h

*/

#ifndef __TRICKPLAY_NINESLICE_H__
#define __TRICKPLAY_NINESLICE_H__

#include <clutter/clutter.h>

typedef struct SpriteSheet {
  GHashTable *map;
  CoglMaterial **material;
  CoglHandle **texture;
  gint *w;
  gint *h;
  gint n;
} SpriteSheet;

static void spritesheet_get_sprite(SpriteSheet *sheet, gchar *name, CoglMaterial **material, CoglHandle **texture, gint *w, gint *h);

static void spritesheet_get_sprite(SpriteSheet *sheet, gchar *name, CoglMaterial **material, CoglHandle **texture, gint *w, gint *h) {
  gpointer p = g_hash_table_lookup(sheet->map, name);
  if (p != NULL) {
    gint i = GPOINTER_TO_INT(p) - 1;
    if (material != NULL) *material = sheet->material[i];
    if (texture != NULL) *texture = sheet->texture[i];
    if (w != NULL) *w = sheet->w[i];
    if (h != NULL) *h = sheet->h[i];
  }
}

ClutterEffect* nineslice_effect_new_from_names(gchar* names[], SpriteSheet *sheet, gboolean tiled);

#endif
