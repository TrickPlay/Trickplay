
#include "bitmap.h"
#include "network.h"
#include "user_data.h"
#include "lb.h"

//.............................................................................

#define TP_LOG_DOMAIN   "BITMAP"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//.............................................................................

Bitmap::Bitmap( lua_State * L , const char * _src , bool _async , bool read_tags )
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
        if ( strlen( _src ) > 0 )
        {
            image = app->load_image( _src , read_tags );
        }
    }
    else
    {
        tplog( "LOADING ASYNC '%s'" , _src );

        RefCounted::ref( this );

        app->load_image_async( _src , read_tags , callback , this , destroy_notify );
    }
}

//.............................................................................

Bitmap::~Bitmap()
{
    tplog( "DESTROYING BITMAP %p" , this );

    if ( image )
    {
        delete image;
    }

    lsp->unref();
}


//.............................................................................

Bitmap * Bitmap::get( lua_State * L , int index )
{
    if ( ! lb_check_udata_type( L , index , "Bitmap" ) )
    {
        return 0;
    }

    return ( Bitmap * ) UserData::get_client( L , index );
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

guint Bitmap::depth() const
{
    return image ? image->depth() : 0;
}

//.............................................................................

bool Bitmap::loaded() const
{
    return image ? true : false;
}

//.............................................................................

void Bitmap::callback( Image * image , gpointer me )
{
    tplog( "  ASYNC DECODE COMPLETED FOR %p : %s" , me , image ? "SUCCESS" : "FAILED" );

    Bitmap * self = ( Bitmap * ) me;

    // Image will be null when it failed, otherwise, we take ownership of it

    self->image = image;

    if ( lua_State * L = self->lsp->get_lua_state() )
    {
        lua_pushboolean( L , image ? false : true );
        UserData::invoke_callbacks( self , "on_loaded" , 1 , 0 , L );
    }
}

//.............................................................................

void Bitmap::destroy_notify( gpointer me )
{
    tplog( "  UNREF %p" , me );

    RefCounted::unref( ( RefCounted * ) me );
}

//.............................................................................

Image * Bitmap::get_image( lua_State * L , int index )
{
    if ( Bitmap * bitmap = Bitmap::get( L , index ) )
    {
        return bitmap->image;
    }
    return 0;
}

//.............................................................................

Image * Bitmap::get_image()
{
    return image;
}

//.............................................................................

void Bitmap::set_image( Image * _image )
{
    if ( image )
    {
        delete image;
    }

    image = _image;
}
