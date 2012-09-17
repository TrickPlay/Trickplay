/*

    spritesheet.cpp.h

*/

#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include <clutter/clutter.h>
#include <stdlib.h>

enum SpriteSheetFlags {
  SPRITESHEET_NONE    = 0,
  SPRITESHEET_NEAREST  = 1 << 0,
};

class SpriteSheet {
  public:
    SpriteSheet(guint w, guint h, const guchar* pixels, gchar* names[], gint data[], gint n, SpriteSheetFlags flags);
    void get_sprite(gchar *name, CoglMaterial **material, gint *w, gint *h);
    ~SpriteSheet();
    
  private:
    gint num_sprites;
    GHashTable *map;
    CoglMaterial **material;
    CoglHandle **texture;
    gint *width;
    gint *height;
};

#endif