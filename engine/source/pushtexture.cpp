#include "pushtexture.h"

typedef PushTexture::Signal Signal;
typedef PushTexture::PingMe PingMe;

PushTexture::~PushTexture()
{
    if ( texture ) cogl_handle_unref( texture );
}

void PushTexture::subscribe( PingMe * ping )
{
    if ( !texture ) make_texture();
    g_assert( texture );
    
    if ( all_pings_async && !ping->async )
    {
        all_pings_async = false;
        on_sync_change();
    }
    
    pings.insert( ping );
}

void PushTexture::unsubscribe( PingMe * ping )
{
    pings.erase( ping );
    
    if ( !all_pings_async && !ping->async )
    {
        all_pings_async = true;
        for ( std::set< PingMe * >::iterator it = pings.begin(); it != pings.end(); ++it )
        {
            if ( !(* it)->async )
            {
                all_pings_async = false;
                on_sync_change();
                break;
            }
        }
    }
    
    if ( can_signal && !cache && pings.empty() )
    {
        Action::post( new Signal( this ) );
        can_signal = false;
    }
}

void PushTexture::unsubscribe_signal()
{
    if ( texture && !cache && pings.empty() )
    {
        cogl_handle_unref( texture );
        texture = NULL;
        
        lost_texture();
    }
    
    can_signal = true;
}

void PushTexture::get_dimensions( int * w, int * h )
{
    * w = texture ? cogl_texture_get_width ( (TP_CoglTexture) texture ) : 1;
    * h = texture ? cogl_texture_get_height( (TP_CoglTexture) texture ) : 1;
}

CoglHandle PushTexture::get_texture()
{
    g_message( "get_texture" );
    static CoglHandle null_texture = cogl_texture_new_with_size( 1, 1, COGL_TEXTURE_NONE, COGL_PIXEL_FORMAT_A_8 );
    return texture ? texture : null_texture;
}

void PushTexture::set_texture( CoglHandle _texture )
{
    if ( texture ) cogl_handle_unref( texture );
    texture = _texture;
    if ( texture ) cogl_handle_ref( texture );
    ping_all();
}

void PushTexture::ping_all()
{
    g_message( "ping all" );
    for ( std::set< PingMe * >::iterator it = pings.begin(); it != pings.end(); ++it )
    {
        (* it)->ping();
    }
}

/* PingMe */

void PingMe::set( PushTexture * _source, Callback * _callback, void * _target, bool _async )
{
    g_message( "PingMe::Set %p %p", source, _source );
    if ( source ) source->unsubscribe( this );
    
    callback = _callback;
    source = _source;
    target = _target;
    async = _async;
    
    if ( source ) source->subscribe( this );
}

PingMe::~PingMe()
{
    if ( source ) source->unsubscribe( this );
}


void PingMe::ping()
{
    g_message( "PingMe::ping" );
    if ( callback ) callback( source, target );
}
