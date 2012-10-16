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
    SpriteSheet(CoglHandle texture, const gchar **names, gint *data, gint n, SpriteSheetFlags flags);
    void get_sprite(const gchar *name, CoglMaterial **material, CoglHandle *texture, gint *w, gint *h);
    
    ~SpriteSheet();
    
    CoglHandle get_subtexture( const gchar * id );
    
  private:
    gint num_sprites;
    GHashTable *map;
    CoglMaterial **material;
    CoglHandle *texture;
    gint *width;
    gint *height;
};

#endif