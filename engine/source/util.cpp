
// This has to be the first include or it will conflict with
// unistd.h

#include "ossp/uuid.h"

#include "util.h"

//.............................................................................

#define TP_LOG_DOMAIN   "ACTION"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//.............................................................................

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


String Util::random_string( guint length )
{
    String result;

    if ( length > 0 )
    {
        static const char * pieces = "0123456789ABCDEF";

        gint32 end = strlen( pieces );

        char buffer[ length ];

        for ( guint i = 0; i < length ; ++i )
        {
            buffer[ i ] = pieces[ g_random_int_range( 0 , end ) ];
        }

        result = String( buffer , length );
    }

    return result;
}

//-----------------------------------------------------------------------------

Action::~Action()
{
    tplog( "DESTROYING ACTION %p" , this );
}

void Action::destroy( gpointer action )
{
    g_assert( action );

    delete ( Action * ) action;
}

guint Action::post( Action * action , int interval_ms )
{
    g_assert( action );

    if ( interval_ms < 0 )
    {
        tplog( "POSTING IDLE ACTION %p" , action );

        return g_idle_add_full( TRICKPLAY_PRIORITY , ( GSourceFunc ) run_internal , action , destroy );
    }

    tplog( "POSTING TIMEOUT ACTION %p EVERY %d ms" , action , interval_ms );

    return g_timeout_add_full( TRICKPLAY_PRIORITY , guint( interval_ms ) , ( GSourceFunc ) run_internal , action , destroy );
}

void Action::push( GAsyncQueue * queue , Action * action )
{
    g_assert( queue );
    g_assert( action );

    tplog( "QUEUEING ACTION %p IN QUEUE %p" , action , queue );

    g_async_queue_push( queue , action );
}

bool Action::run_one( GAsyncQueue * queue , gulong wait_ms )
{
    g_assert( queue );

    g_async_queue_ref( queue );

    Action * action = 0;

    if ( wait_ms == 0 )
    {
        action = ( Action * ) g_async_queue_try_pop( queue );
    }
    else
    {
        GTimeVal t;

        g_get_current_time( & t );
        g_time_val_add( & t , wait_ms * 1000 );

        action = ( Action * ) g_async_queue_timed_pop( queue , & t );
    }

    g_async_queue_unref( queue );

    if ( action )
    {
        run_internal( action );

        delete action;

        return true;
    }

    return false;
}

int Action::run_all( GAsyncQueue * queue )
{
    g_assert( queue );

    int result = 0;

    g_async_queue_ref( queue );

    while ( Action * action = ( Action * ) g_async_queue_try_pop( queue ) )
    {
        run_internal( action );

        delete action;

        ++result;
    }

    g_async_queue_unref( queue );

    return result;
}

class QueueRunAllAction : public Action
{
public:

    QueueRunAllAction( GAsyncQueue * _queue ) : queue( g_async_queue_ref( _queue ) ) {}
    ~QueueRunAllAction() { g_async_queue_unref( queue ); }

protected:

    virtual bool run() { Action::run_all( queue ); return false; }

private:

    GAsyncQueue * queue;
};

void Action::post_run_all( GAsyncQueue * queue )
{
    g_assert( queue );

    Action::post( new QueueRunAllAction( queue ) );
}


gboolean Action::run_internal( Action * action )
{
    tplog( "RUNNING ACTION %p" , action );

    return action->run() ? TRUE : FALSE;
}
