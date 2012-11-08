#include "spritesheet.h"
#include <glib.h>
#include <string.h>
#include <stdio.h>

#include "log.h"


#ifdef CLUTTER_VERSION_1_10
#define TP_COGL_TEXTURE(t) (COGL_TEXTURE(t))
#define TP_CoglTexture CoglTexture *
#else
#define TP_COGL_TEXTURE(t) (t)
#define TP_CoglTexture CoglHandle
#endif
 

void log_subtexture( gpointer id_ptr, gpointer subtexture_ptr, gpointer none );
void init_extra( SpriteSheet * sheet );

bool SpriteSheet::class_initialized = false;

class Sprite
{
public:
    Sprite( unsigned tex, unsigned x, unsigned y, int w, int h )
      : tex( tex ), x( x ), y( y ), w( w ), h( h ), dirty( true );
      
    void fit( int tw, int th )
    {   
        w = MIN( w < 0 ? tw : x + w, tw ) - x;
        h = MIN( h < 0 ? th : y + h, th ) - y;
        dirty = false;
    }
    
    unsigned x, y, tex;
    int w, h;
    bool dirty;
}

SpriteSheet::SpriteSheet() :
    map( g_hash_table_new_full( g_str_hash, g_str_equal, g_free, g_free ) ),
    textures( g_ptr_array_new_with_free_func( (GDestroyNotify) cogl_handle_unref ) )
{
    init_extra( this );
}

SpriteSheet::~SpriteSheet()
{
    g_hash_table_destroy( map );
    g_ptr_array_free( textures, TRUE );
    g_free( extra );
}

int SpriteSheet::add_texture( CoglHandle texture )
{
    g_ptr_array_add( this->textures, texture );
    return this->textures->len - 1;
}

bool SpriteSheet::is_initialized()
{
    return g_ptr_array_index( this->textures, 0 ) ? true : false;
}

bool SpriteSheet::map_subtexture( const gchar * id, int tex, int x, int y, int w, int h )
{
    if ( tex == -1 )
        tex = this->textures->len - 1;
        
    g_hash_table_insert( map, id, new Sprite( tex, x, y, w, h ) );
    
    return true;
}

CoglHandle SpriteSheet::get_subtexture( const gchar * id )
{
    Sprite * sprite = g_hash_table_lookup( map, id );
    CoglHandle texture = (CoglHandle) g_ptr_array_index( textures, sprite->tex );
    
    if ( !texture )
    {
        g_error( "Trying to use sprite id '%s' before its source texture has been loaded.", id );
        return NULL;
    }
        
    if ( sprite->dirty )
    {
        sprite->fit( cogl_texture_get_width(  TP_COGL_TEXTURE( texture ) ),
                     cogl_texture_get_height( TP_COGL_TEXTURE( texture ) ) );
    }
    
    return cogl_texture_new_from_sub_texture( TP_COGL_TEXTURE( texture ), 
        sprite->x, sprite->y, sprite->w, sprite->h );
}

GList * SpriteSheet::get_ids()
{
    return g_hash_table_get_keys( map );
}

void SpriteSheet::dump()
{
    tpinfo( "{" );
    g_hash_table_foreach( map, (GHFunc) log_subtexture, NULL );
    tpinfo( "}" );
}

/*
void SpriteSheet::make_material_from_subtexture( const gchar * id, CoglMaterial ** material, int * w, int * h )
{
    check_initialized();

    CoglHandle subtexture_handle = (CoglHandle) g_hash_table_lookup( map, id );

    if ( ! subtexture_handle )
    {
        g_error( "No subtexture with id '%s' found in this SpriteSheet!", id );
        return;
    }

    TP_CoglTexture subtexture = TP_COGL_TEXTURE( subtexture_handle );

    CoglMaterial * new_material = cogl_material_new();
    cogl_material_set_layer( new_material, 0, subtexture );

    * material = new_material;
    * w = cogl_texture_get_width( subtexture );
    * h = cogl_texture_get_height( subtexture );
}

void log_subtexture( gpointer id_ptr, gpointer subtexture_ptr, gpointer none )
{
    TP_CoglTexture subtexture = TP_COGL_TEXTURE( (CoglHandle) subtexture_ptr );

    gchar * id = (gchar*) id_ptr;
    int     w = cogl_texture_get_width( subtexture );
    int     h = cogl_texture_get_height( subtexture );

    tplog( "\t%15s : %10dx%-10d", id, w, h );
}
*/

void init_extra( SpriteSheet * sheet )
{
    sheet->extra = G_OBJECT(g_object_new( G_TYPE_OBJECT, NULL ));
    g_object_set_data( sheet->extra, "tp-sheet", sheet );

    if ( ! SpriteSheet::class_initialized )
    {
        g_signal_new(
            "load-finished",
            G_TYPE_OBJECT,
            G_SIGNAL_RUN_FIRST,
            0, 0, 0, 0,
            G_TYPE_NONE,
            1,
            G_TYPE_POINTER
        );

        SpriteSheet::class_initialized = true;
    }
}
