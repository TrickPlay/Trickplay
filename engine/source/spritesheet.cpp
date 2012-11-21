#include "spritesheet.h"
#include <string.h>
#include <stdio.h>

#include "log.h"

typedef SpriteSheet::RefTexture RefTexture;
typedef RefTexture::Signal Signal;
typedef SpriteSheet::Source Source;
typedef SpriteSheet::Sprite Sprite;

RefTexture::~RefTexture()
{
    if ( texture ) cogl_handle_unref( texture );
}

CoglHandle RefTexture::ref_texture()
{
    refs++;
    if ( !texture ) texture = get_texture();
    return texture;
}

void RefTexture::deref_texture()
{
    refs = MAX( 0, refs - 1 );
    
    if ( !refs && can_signal )
    {
        Action::post( new Signal( this ) );
        can_signal = false;
    }
}

void RefTexture::deref_signal()
{
    if ( !refs && texture )
    {
        before_deref_signal();
        
        cogl_handle_unref( texture );
        texture = NULL;
    }
    can_signal = true;
}

/* Source */

CoglHandle Source::get_texture()
{
    if ( !image || !image->width() )
    {
        g_error( "Source image has not been loaded." );
    }
    
    ClutterActor * actor = clutter_texture_new();
    Images::load_texture( CLUTTER_TEXTURE( actor ), image );
    
    CoglHandle texture = (CoglHandle) clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) );
    cogl_handle_ref( texture );
    
    clutter_actor_destroy( actor );
    
    return texture;
}

void Source::load( Image * _image )
{
    if ( image )
    {
        delete image;
    }
    
    image = _image->make_copy();
}

void Source::get_dimensions( int * w, int * h )
{
    TP_CoglTexture texture = TP_COGL_TEXTURE( ref_texture() );
    * w = cogl_texture_get_width ( texture );
    * h = cogl_texture_get_height( texture );
    deref_texture();
}

CoglHandle Source::ref_subtexture( int x, int y, int w, int h )
{
    return cogl_texture_new_from_sub_texture( TP_COGL_TEXTURE( ref_texture() ), x, y, w, h );
}

/* Sprite */

CoglHandle Sprite::get_texture()
{
    int tw, th;
    source->get_dimensions( &tw, &th );
    
    x = MAX( x, 0 );
    y = MAX( y, 0 );
    w = MIN( w < 0 ? tw : x + w, tw ) - x;
    h = MIN( h < 0 ? th : y + h, th ) - y;
    
    return cogl_handle_ref( source->ref_subtexture( x, y, w, h ) );
}

/* SpriteSheet */

SpriteSheet::SpriteSheet() :
    extra( G_OBJECT( g_object_new( G_TYPE_OBJECT, NULL ) ) )
{
    g_object_set_data( extra, "tp-sheet", this );

    static bool init( true );
    if ( init )
    {
        init = false;
        g_signal_new( "load-finished", G_TYPE_OBJECT, G_SIGNAL_RUN_FIRST,
            0, 0, 0, 0, G_TYPE_NONE, 1, G_TYPE_POINTER );
    }
}

SpriteSheet::~SpriteSheet()
{
    g_free( extra );
}

void SpriteSheet::emit_signal( const char * msg )
{
    g_signal_emit_by_name( extra, "load-finished", msg );
}

Source * SpriteSheet::add_source()
{
    sources.push_back( Source( this ) );
    return & sources.back();
}

void SpriteSheet::map_subtexture( const char * id, int x, int y, int w, int h )
{
    if ( sources.empty() )
    {
        g_error( "Trying to map sprite id '%s' before any source textures have been added.", id );
    }
    
    sprites[ std::string( id ) ].set( id, & sources.back(), x, y, w, h );
}

Sprite * SpriteSheet::get_sprite( const char * id )
{
    if ( !id || !sprites.count( id ) )
    {
        //g_warning( "Trying to use unknown sprite id '%s'.", id );
        return NULL;
    }
    
    return & sprites[ std::string( id ) ];
}

std::list< const char * > * SpriteSheet::get_ids() // untested
{
    std::list< const char * > * ids = new std::list< const char * >;
    for ( std::map< std::string, Sprite >::iterator it = sprites.begin(); it != sprites.end(); ++it )
    {
        ids->push_back( it->first.c_str() );
    }
    
    return ids;
}
