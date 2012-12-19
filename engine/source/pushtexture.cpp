#include "pushtexture.h"

typedef PushTexture::PingMe PingMe;

PushTexture::~PushTexture()
{
    if ( texture ) cogl_handle_unref( texture );
}

void PushTexture::subscribe( PingMe * ping )
{
    pings.insert( ping );
    
    if ( all_pings_async && !ping->async )
    {
        all_pings_async = false;
        if ( texture ) on_sync_change();
    }
    
    if ( !texture ) make_texture();
    g_assert( texture );
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
        Action::post( new PushTexture::ReleaseLater( this ) );
        can_signal = false;
    }
}

void PushTexture::release_texture()
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
    static CoglHandle null_texture = cogl_texture_new_with_size( 1, 1, COGL_TEXTURE_NONE, COGL_PIXEL_FORMAT_A_8 );
    return texture ? texture : null_texture;
}

void PushTexture::set_texture( CoglHandle _texture )
{
    if ( texture ) cogl_handle_unref( texture );
    texture = _texture;
    if ( texture ) cogl_handle_ref( texture );
}

void PushTexture::ping_all()
{
    for ( std::set< PingMe * >::iterator it = pings.begin(); it != pings.end(); ++it )
    {
        (* it)->ping();
    }
}

/* PingMe */

void PingMe::set( PushTexture * _source, PingMe::Callback * _callback, void * _target, bool _async )
{
    if ( source ) source->unsubscribe( this );
    
    source = _source;
    callback = _callback;
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
    if ( callback ) callback( source, target );
}
