
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

String Util::canonical_external_path( const char * path , bool abort_on_error )
{
	String result;

	if ( path )
	{
		GFile * file = g_file_new_for_commandline_arg( path );

		gchar * p = g_file_get_path( file );

		g_object_unref( file );

		if ( p )
		{
			result = p;
			g_free( p );
		}
	}

	if ( abort_on_error && result.empty() )
	{
		g_error( "INVALID PATH '%s'" , path ? path : "<null>" );
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

//-----------------------------------------------------------------------------

Util::Buffer::Buffer()
:
    bytes( 0 )
{}

Util::Buffer::Buffer( gconstpointer _data , guint _length )
:
	bytes( g_byte_array_sized_new( _length ) )
{
	g_byte_array_append( bytes , ( const guint8 * ) _data , _length );
}

Util::Buffer::Buffer( MemoryUse memory_use , gpointer _data , guint _length )
:
	bytes( g_byte_array_sized_new( _length ) )
{
	switch( memory_use )
	{
	case Util::Buffer::MEMORY_USE_TAKE:
		bytes->data = ( guint8 * ) _data;
		bytes->len = _length;
		break;
	case Util::Buffer::MEMORY_USE_COPY:
		g_byte_array_append( bytes , ( const guint8 * ) _data , _length );
		break;
	}
}

Util::Buffer::Buffer( GByteArray * _bytes )
:
    bytes( _bytes )
{
	if ( bytes )
	{
		g_byte_array_ref( bytes );
	}
}

Util::Buffer::Buffer( const Buffer & other )
:
    bytes( other.bytes )
{
	if ( bytes )
	{
		g_byte_array_ref( bytes );
	}
}

Util::Buffer::~Buffer()
{
	if ( bytes )
	{
		g_byte_array_unref( bytes );
	}
}

const Util::Buffer & Util::Buffer::operator = ( const Buffer & other )
{
	GByteArray * old = bytes;

	bytes = other.bytes;

	if ( bytes )
	{
		g_byte_array_ref( bytes );
	}

	if ( old )
	{
		g_byte_array_unref( old );
	}

	return * this;
}

bool Util::Buffer::good() const
{
	return bytes != 0;
}

Util::Buffer::operator bool () const
{
	return good();
}

const char * Util::Buffer::data() const
{
	return bytes ? ( const char * ) bytes->data : 0;
}

guint Util::Buffer::length() const
{
	return bytes ? bytes->len : 0;
}
