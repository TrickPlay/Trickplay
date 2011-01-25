
#include "bitmap.h"
#include "network.h"
#include "user_data.h"
#include "lb.h"

//.............................................................................

static Debug_ON log( "BITMAP" );

//.............................................................................

Bitmap::Bitmap( lua_State * L , const char * _src , bool _async )
:
    src( _src ),
    image( 0 ),
    lsp( 0 )
{
    App * app = App::get( L );

    g_assert( app );

    lsp = app->ref_lua_state_proxy();

    if ( ! _async )
    {
        image = app->load_image( _src );
    }
    else
    {
        log( "LOADING ASYNC '%s'" , _src );

        RefCounted::ref( this );

        if ( ! app->load_image_async( _src , callback , this , destroy_notify ) )
        {
            RefCounted::unref( this );
        }
    }
}

//.............................................................................

Bitmap::~Bitmap()
{
    log( "DESTROYING BITMAP %p" , this );

    if ( image )
    {
        delete image;
    }

    lsp->unref();
}

//.............................................................................

guint Bitmap::width() const
{
    return image ? image->width() : 0;
}

//.............................................................................

guint Bitmap::height() const
{
    return image ? image->height() : 0;
}

//.............................................................................

bool Bitmap::loaded() const
{
    return image ? true : false;
}

//.............................................................................

void Bitmap::callback( Image * image , gpointer me )
{
    log( "  ASYNC DECODE COMPLETED FOR %p : %s" , me , image ? "SUCCESS" : "FAILED" );

    Bitmap * self = ( Bitmap * ) me;

    // Image will be null when it failed, otherwise, we take ownership of it

    self->image = image;

    if ( lua_State * L = self->lsp->get_lua_state() )
    {
        lua_pushboolean( L , image ? false : true );
        UserData::invoke_callback( self , "on_loaded" , 1 , 0 , L );
    }
}

//.............................................................................

void Bitmap::destroy_notify( gpointer me )
{
    log( "  UNREF %p" , me );

    RefCounted::unref( ( RefCounted * ) me );
}

//.............................................................................

Image * Bitmap::get_image( lua_State * L , int index )
{
    if ( ! lb_check_udata_type( L , index , "Bitmap" ) )
    {
        return 0;
    }

    Bitmap * b = ( Bitmap * ) UserData::get_client( L , index );

    return b ? b->image : 0;
}
