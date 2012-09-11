/*

    nineslice.h

*/

#ifndef __TRICKPLAY_NINESLICE_H__
#define __TRICKPLAY_NINESLICE_H__

#include <clutter/clutter.h>

typedef struct SpriteSheet {
  CoglMaterial* *material;
  CoglHandle* *texture;
  gint *w;
  gint *h;
  gint n;
} SpriteSheet;

ClutterEffect* nineslice_effect_new_from_source(gchar* source[], gboolean tiled);
ClutterEffect* nineslice_effect_new_from_spritesheet(SpriteSheet *sheet, gint offset, gboolean tiled);

#endif
