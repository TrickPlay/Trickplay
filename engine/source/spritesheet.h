#ifndef __TRICKPLAY_SPRITESHEET_H__
#define __TRICKPLAY_SPRITESHEET_H__

#include <clutter/clutter.h>
#include <stdlib.h>
#include "util.h"

class SpriteSheet : public RefCounted
{
public:
    static bool class_initialized;
    inline static void unref( SpriteSheet * sheet ) { RefCounted::unref( sheet ); }

    SpriteSheet();
    SpriteSheet ( CoglHandle texture );
    ~SpriteSheet();

    void set_texture( CoglHandle texture );
    int add_texture( CoglHandle texture );
    bool is_initialized(); 

    bool map_subtexture( const gchar * id, int tex, int x, int y, int w, int h );
    CoglHandle get_subtexture( const gchar * id );
    GList * get_ids();
    void dump();
    void make_material_from_subtexture( const gchar * id, CoglMaterial ** material, int * w, int * h );

    GObject * extra;

private:
    GHashTable * map;
    GPtrArray  * textures;

    inline void check_initialized() { if ( ! g_ptr_array_index( this->textures, 0 ) ) g_error( "SpriteSheet not initialized" ); }
};

#endif
