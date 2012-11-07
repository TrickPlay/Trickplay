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

SpriteSheet::SpriteSheet() :
    map( g_hash_table_new_full( g_str_hash, g_str_equal, g_free, g_free ) ),
    textures( g_ptr_array_new_with_free_func( (GDestroyNotify) cogl_handle_unref ) )
{
    init_extra( this );
}

SpriteSheet::SpriteSheet ( CoglHandle texture ) :
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

void SpriteSheet::set_texture( CoglHandle texture )
{
    if ( this->textures->len > 0 )
    {
        g_error( "SpriteSheet texture is already set." );
    }
    
    g_ptr_array_add( this->textures, texture );
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
    
    CoglHandle texture = (CoglHandle) g_ptr_array_index( this->textures, tex );
    if ( !texture )
        g_error( "Trying to map a subtexture to an unknown texture." );
    
    int x2 = x + w, tw = cogl_texture_get_width( TP_COGL_TEXTURE( texture ) );
    x = MAX( 0, x );
    w = MIN( w < 0 ? tw : x2, tw ) - x;
    
    int y2 = y + h, th = cogl_texture_get_height( TP_COGL_TEXTURE( texture ) );
    y = MAX( 0, y );
    h = MIN( h < 0 ? th : y2, th ) - y;
    
    CoglHandle subtexture = cogl_texture_new_from_sub_texture( TP_COGL_TEXTURE( texture ), x, y, w, h );

    // We don't need the extra reference taken by cogl_texture_new_from_sub_texture
    cogl_handle_unref( texture );

    if ( subtexture )
    {
        g_hash_table_insert( map, (gpointer) id, (gpointer) subtexture );

        return true;
    }

    return false;
}

CoglHandle SpriteSheet::get_subtexture( const gchar * id )
{
    check_initialized();
    return (CoglHandle) g_hash_table_lookup( map, id );
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
