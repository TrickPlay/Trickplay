#include "pushtexture.h"

typedef PushTexture::PingMe PingMe;

PushTexture::~PushTexture()
{
    if ( texture )
    {
        cogl_handle_unref( texture );
        texture = NULL;
    }

    failed = false;
    real = false;

    if ( !pings.empty() ) pings.clear();
}

void PushTexture::subscribe( PingMe * ping, bool preload )
{
    pings.insert( ping );

    if ( !failed && !real && preload )
    {
        make_texture( true ); // Will update real and failed
        //g_assert( texture );
        g_assert( real || failed );
    }
    else if ( !failed && !texture )
    {
        make_texture( false ); // Will update real and failed
        //g_assert( texture );
    }
    else
    {
        ping->ping();
    }
}

void PushTexture::release_texture()
{
    if ( texture && pings.empty() )
    {
        cogl_handle_unref( texture );

        failed = false;
        real = false;
        texture = NULL;
        
        lost_texture();
    }
}

void PushTexture::get_dimensions( int * w, int * h )
{
    * w = texture ? cogl_texture_get_width ( (TP_CoglTexture) texture ) : 1;
    * h = texture ? cogl_texture_get_height( (TP_CoglTexture) texture ) : 1;
}

CoglHandle PushTexture::get_texture()
{
    return texture;
}

void PushTexture::set_texture( CoglHandle _texture, bool _real )
{
    // failed and real are updated in Sprite and Source instances

    if ( texture ) cogl_handle_unref( texture );
    texture = _texture;
    // Skip cogl_handle_ref as it is done before calling set_texture
    
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

void PingMe::assign( PushTexture * _instance, PingMe::Callback * _callback, void * _target, bool preload )
{
    if ( instance == _instance )
    {
        callback = _callback;
        target = _target;
        return;
    }

    // Sprite instances will always have texture released immediately
    // Source instances will have it released later when the app is running
    if ( instance ) instance->unsubscribe( this, false );

    callback = _callback;
    target = _target;
    instance = _instance;

    if ( instance ) instance->subscribe( this, preload );
}

PingMe::~PingMe()
{
    if ( instance ) instance->unsubscribe( this, true ); // Sprite release reference to Source

    instance = NULL;
    callback = NULL;
    target = NULL;
}


void PingMe::ping()
{
    if ( callback ) callback( instance, target );
}
