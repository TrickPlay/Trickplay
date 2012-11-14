#include "spritesheet.h"
#include <string.h>
#include <stdio.h>

#include "log.h"

typedef SpriteSheet::Source Source;
typedef SpriteSheet::Sprite Sprite;

CoglHandle Sprite::get_subtexture()
{
    if ( init )
    {
        init = false;
        int tw, th;
        source->get_dimensions( &tw, &th );
        
        x = MAX( x, 0 );
        y = MAX( y, 0 );
        w = MIN( w < 0 ? tw : x + w, tw ) - x;
        h = MIN( h < 0 ? th : y + h, th ) - y;
    }
    
    return source->get_subtexture( x, y, w, h );
}

Source::~Source()
{
    if ( texture ) cogl_handle_unref( texture );
}

void Source::load_image( Image * image )
{
    g_message( "Source::load" );
    
    ClutterActor * actor = clutter_texture_new();
    Images::load_texture( CLUTTER_TEXTURE( actor ), image );
    texture = TP_COGL_TEXTURE( clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) ) );
    
    cogl_handle_ref( texture );
    
    clutter_actor_destroy( actor );
}

void Source::deref()
{
    refs--;
    
    g_message( "Deref'ed, now %i", refs );
    
    if ( !refs )
    {
        // do some kind of release
        
    }
}

void Source::ensure()
{
    if ( !texture )
    {
        g_error( "Source image has not been loaded." );
        
        if ( sheet->async )
        {
            // error
        }
        
        // load image
    }
}

void async_img_callback( Image * image, Source * source )
{
    source->load_image( image );
    source->sheet->emit_signal( image ? NULL : "FAILED_IMG_LOAD" );
}

void Source::set_source( const char * path )
{
    if ( sheet->async )
    {
        sheet->app->load_image_async( path, false, (Image::DecodeAsyncCallback) async_img_callback, this, 0 );
    }
    else
    {
        load_image( sheet->app->load_image( path, false ) );
    }
}

void Source::set_source( Bitmap * bitmap )
{
    load_image( bitmap->get_image() );
}

void Source::get_dimensions( int * w, int * h )
{
    ensure();
    * w = cogl_texture_get_width ( texture );
    * h = cogl_texture_get_height( texture );
}

CoglHandle Source::get_subtexture( int x, int y, int w, int h )
{
    ensure();
    refs++;
    g_message( "Ref'ed, now %i", refs );
    return cogl_texture_new_from_sub_texture( texture, x, y, w, h );
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

CoglHandle SpriteSheet::get_subtexture( const char * id )
{
    Sprite * sprite = & sprites[ std::string( id ) ];
    
    if ( ! sprite->id )
    {
        g_warning( "Trying to use unknown sprite id '%s'.", id );
        return NULL;
    }
    
    return sprite->get_subtexture();
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
