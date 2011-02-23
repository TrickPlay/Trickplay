
// This has to be the first include or it will conflict with
// unistd.h

#include "ossp/uuid.h"

#include "util.h"

static String make_uuid( unsigned int mode )
{
    String result;

    uuid_t * u = 0;

    if ( UUID_RC_OK == uuid_create( & u ) )
    {
        if ( UUID_RC_OK == uuid_make( u , mode ) )
        {
            char buffer[ UUID_LEN_STR + 1 ];

            size_t len = UUID_LEN_STR + 1;

            void * up = & buffer[0];

            if ( UUID_RC_OK == uuid_export( u , UUID_FMT_STR , & up , & len ) )
            {
                result = buffer;
            }
        }

        uuid_destroy( u );
    }

    return result;
}

String Util::make_v1_uuid()
{
    return make_uuid( UUID_MAKE_V1 );
}

String Util::make_v4_uuid()
{
    return make_uuid( UUID_MAKE_V4 );
}

//-----------------------------------------------------------------------------

static Debug_OFF al( "ACTION" );

Action::Action( int _interval )
:
    interval( _interval )
{
}

Action::~Action()
{
    al( "DESTROYING ACTION %p" , this );
}

guint Action::post( Action * action )
{
    g_assert( action );

    guint result = 0;

    if ( action->interval < 0 )
    {
        al( "POSTING IDLE ACTION %p" , action );

        result = g_idle_add_full( TRICKPLAY_PRIORITY , ( GSourceFunc ) run_internal , action , ( GDestroyNotify ) destroy );
    }
    else
    {
        al( "POSTING TIMEOUT ACTION %p EVERY %d s" , action , action->interval );

        result = g_timeout_add_full( TRICKPLAY_PRIORITY , guint( action->interval ) , ( GSourceFunc ) run_internal , action , ( GDestroyNotify ) destroy );
    }

    return result;
}

void Action::destroy( Action * action )
{
    g_assert( action );

    delete action;
}

gboolean Action::run_internal( Action * action )
{
    al( "RUNNING ACTION %p" , action );

    return action->run() ? TRUE : FALSE;
}
