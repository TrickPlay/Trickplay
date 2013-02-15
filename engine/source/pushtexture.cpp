#include "pushtexture.h"

typedef PushTexture::PingMe PingMe;

PushTexture::~PushTexture()
{
    if ( texture ) cogl_handle_unref( texture );
    if ( !pings.empty() ) pings.clear();
}

// Only called by Source instances
void PushTexture::subscribe( PingMe * ping, bool preload )
{
    pings.insert( ping );

    if ( !failed && !real && preload )
    {
        make_texture( true ); // Will update real and failed
        g_assert( texture );
        g_assert( real || failed );
    }
    else if ( !failed && !texture )
    {
        make_texture( false ); // Will update real and failed
        g_assert( texture );
    }
    else
    {
        ping->ping();
    }
}

// Only called by Source instances
void PushTexture::unsubscribe( PingMe * ping )
{
    pings.erase( ping );
    
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
        failed = false;
        real = false;
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

void PushTexture::set_texture( CoglHandle _texture, bool _real )
{
    if ( texture == _texture ) return;

    if ( texture ) cogl_handle_unref( texture );
    texture = _texture;
    if ( texture ) cogl_handle_ref( texture );
    
    real = texture && _real;
    ping_all();
}

void PushTexture::ping_all()
{
    for ( std::set< PingMe * >::iterator it = pings.begin(); it != pings.end(); ++it )
    {
        (* it)->ping();
    }
}

/* PingMe */

// Only called by Sprite instances
void PingMe::assign( PushTexture * _source, PingMe::Callback * _callback, void * _target, bool preload )
{
    if ( source == _source ) return;

    if ( source ) source->unsubscribe( this );

    source = _source;
    callback = _callback;
    target = _target;

    if ( source ) source->subscribe( this, preload );
}

PingMe::~PingMe()
{
    if ( source ) source->unsubscribe( this ); // Sprite release reference to source
}


void PingMe::ping()
{
    if ( callback ) callback( source, target );
}
