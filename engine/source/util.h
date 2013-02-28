#ifndef _TRICKPLAY_UTIL_H
#define _TRICKPLAY_UTIL_H
//-----------------------------------------------------------------------------
#include <cstring>
#include <iostream>
//-----------------------------------------------------------------------------
#include "common.h"
//-----------------------------------------------------------------------------

//.............................................................................
// Copied from lauxlib.c

#define abs_index(L, i) ((i) > 0 || (i) <= LUA_REGISTRYINDEX ? (i) : lua_gettop(L) + (i) + 1)

//.............................................................................

// Returns ms

inline double timestamp()
{
    static GTimer * timer = 0;

    if ( ! timer )
    {
        timer = g_timer_new();
    }

    return g_timer_elapsed( timer , 0 ) * 1000;
}

//-----------------------------------------------------------------------------

inline void g_info( const gchar * format, ... )
{
    va_list args;
    va_start( args, format );
    g_logv( G_LOG_DOMAIN, G_LOG_LEVEL_INFO, format, args );
    va_end( args );
}

//-----------------------------------------------------------------------------
// If the expression is true, this throws a string exception
#ifndef CLANG_ANALYZER_NORETURN
#ifndef __has_feature         // Optional of course.
  #define __has_feature(x) 0  // Compatibility with non-clang compilers.
#endif
#if __has_feature(attribute_analyzer_noreturn)
#define CLANG_ANALYZER_NORETURN __attribute__((analyzer_noreturn))
#else
#define CLANG_ANALYZER_NORETURN
#endif
#endif
void failif( bool expression, const gchar * format, ... ) CLANG_ANALYZER_NORETURN;

inline void failif( bool expression, const gchar * format, ... )
{
    if ( expression )
    {
        va_list args;
        va_start( args, format );
        gchar * s = g_strdup_vprintf( format, args );
        va_end( args );

        String result( s );
        g_free( s );

        throw result;
    }
}

//-----------------------------------------------------------------------------

inline StringVector split_string( const gchar * source , const gchar * delimiter , gint max_tokens = 0 )
{
    StringVector result;

    if ( ! source || ! delimiter )
    {
        return result;
    }

    if ( strlen( source ) == 0 || strlen( delimiter ) == 0 )
    {
        return result;
    }

    gchar * * parts = g_strsplit( source , delimiter , max_tokens );

    for ( gchar * * part = parts; * part; ++part )
    {
        result.push_back( * part );
    }

    g_strfreev( parts );

    return result;
}

inline StringVector split_string( const String & source , const gchar * delimiter , gint max_tokens = 0 )
{
    return split_string( source.c_str() , delimiter , max_tokens );
}

//-----------------------------------------------------------------------------

#define lua_really_isstring(L,i) (lua_type(L,i)==LUA_TSTRING)

//-----------------------------------------------------------------------------

class RefCounted
{
public:

    RefCounted()
        :
        ref_count( 1 )
    {}

    inline void ref()
    {
        g_atomic_int_inc( &ref_count );
    }

    inline void unref()
    {
        if ( g_atomic_int_dec_and_test( &ref_count ) )
        {
            delete this;
        }
    }

    static RefCounted * ref( RefCounted * rc )
    {
        if ( rc )
        {
            rc->ref();
        }
        return rc;
    }

    static RefCounted * unref( RefCounted * rc )
    {
        if ( rc )
        {
            rc->unref();
        }
        return NULL;
    }

    static void ref_counted_destroy( gpointer rc )
    {
        RefCounted::unref( ( RefCounted * ) rc );
    }

protected:

    virtual ~RefCounted()
    {}

private:

    RefCounted( const RefCounted & )
    {}

    gint ref_count;
};

//=============================================================================
// An input stream that does not copy the buffer

class imstream : private std::streambuf, public std::istream
{

public:

    imstream( char * buf, size_t size )
    :
        std::istream( this )
    {
        setg( buf, buf, buf + size );
    }

protected:

    virtual std::streampos seekpos( std::streampos sp, std::ios_base::openmode which = ios_base::in | ios_base::out )
    {
        if ( which & std::ios_base::in )
        {
            char * b = eback();
            char * p = b + sp;

            if ( p >= b && p < egptr() )
            {
                setg( b, p, egptr() );
                return p - b;
            }
        }

        return -1;
    }

    virtual std::streampos seekoff( std::streamoff off, std::ios_base::seekdir way, std::ios_base::openmode which = std::ios_base::in | std::ios_base::out )
    {
        switch ( way )
        {
            case std::ios_base::beg: return seekpos( off, which );
            case std::ios_base::cur: return seekpos( gptr() + off - eback(), which );
            case std::ios_base::end: return seekpos( egptr() + off - eback(), which );
            default: return -1;
        }
    }
};

//-----------------------------------------------------------------------------
// This class lets you push things to free into it - when this instance is
// destroyed, it frees all the things you pushed into it. Makes it easier
// to deal with cleaning up multiple allocations across early returns and
// when exceptions are thrown.

class FreeLater
{
public:

    FreeLater( gpointer data = NULL, GDestroyNotify destroy = g_free )
    {
        (*this)( data, destroy );
    }

    ~FreeLater()
    {
        for( FreeList::reverse_iterator it = list.rbegin(); it != list.rend(); ++it )
        {
            it->second( it->first );
        }
    }

    inline void operator()( gpointer data, GDestroyNotify destroy = g_free )
    {
        if ( data && destroy )
        {
            list.push_back( FreePair( data, destroy ) );
        }
    }

    inline void operator()( gchar ** data )
    {
        if ( data )
        {
            list.push_back( FreePair( data, ( GDestroyNotify ) g_strfreev ) );
        }
    }

private:

    FreeLater( const FreeLater & ) {}

    const FreeLater & operator = ( const FreeLater & ) { return * this; }

    typedef std::pair< gpointer, GDestroyNotify > FreePair;

    typedef std::list< FreePair > FreeList;

    FreeList list;
};

//-----------------------------------------------------------------------------
// Lets you run something as an idle or a timeout in the main thread. Derive
// from this, implement run and call post with an instance.

class Action
{
public:

    Action(): cancel_handle(0) {}
    virtual ~Action();

    // Cancel this action if it was posted

    static void cancel( Action * action ) { if ( action->cancel_handle ) g_source_remove( action->cancel_handle ); }

    static void destroy( gpointer action );

    // Posts this action to run as an idle, or a timeout if interval_ms > -1
    // Returns the source tag.

    static guint post( Action * action , int interval_ms = -1 );

    // Pushes the action into the queue

    static void push( GAsyncQueue * queue , Action * action );

    // Tries to pop and run one from the queue, waiting if wait_ms > 0.
    // Returns true if one ran.

    static bool run_one( GAsyncQueue * queue , gulong wait_ms );

    // Tries to run as many as it can pop from the queue, without
    // waiting. Returns how many ran.

    static int run_all( GAsyncQueue * queue );

    // Posts an idle action that will call run_all from the given
    // queue when it executes. Refs the queue and then unrefs it.

    static void post_run_all( GAsyncQueue * queue );

protected:

    // You implement this. In the case of idle or timeout actions,
    // returning true will let them run again. Returning false
    // will take them out and destroy them. For queue actions,
    // the return value is ignored.

    virtual bool run() = 0;

private:

    static gboolean run_internal( Action * action );

    guint cancel_handle;
};

//-----------------------------------------------------------------------------

namespace Util
{
	inline String format( const gchar * format, ... )
    {
        va_list args;
        va_start( args, format );
        gchar * s = g_strdup_vprintf( format, args );
        va_end( args );

        String result( s );
        g_free( s );
        return result;
    }

    String random_string( guint length );

    gpointer g_async_queue_timeout_pop( GAsyncQueue * queue , guint64 timeout );

    String where_am_i_lua( lua_State *L );

    //-----------------------------------------------------------------------------

    class GMutexLock
    {
    public:

        GMutexLock( GMutex * mutex ) : m( mutex )
        {
            g_mutex_lock( m );
        }
        ~GMutexLock()
        {
            g_mutex_unlock( m );
        }

    private:

        GMutexLock() {}
        GMutexLock( const GMutexLock & ) {}

        GMutex * m;
    };

    //-----------------------------------------------------------------------------

    class GSRMutexLock
    {
    public:

#ifndef GLIB_VERSION_2_32
        GSRMutexLock( GStaticRecMutex * mutex ) : m( mutex )
#else
        GSRMutexLock( GRecMutex * mutex ) : m( mutex )
#endif
        {
#ifndef GLIB_VERSION_2_32
            g_static_rec_mutex_lock( m );
#else
            g_rec_mutex_lock( m );
#endif
        }
        ~GSRMutexLock()
        {
#ifndef GLIB_VERSION_2_32
            g_static_rec_mutex_unlock( m );
#else
            g_rec_mutex_unlock( m );
#endif
        }

    private:

        GSRMutexLock() {}
        GSRMutexLock( const GSRMutexLock & ) {}

#ifndef GLIB_VERSION_2_32
        GStaticRecMutex * m;
#else
        GRecMutex * m;
#endif
    };

    //-----------------------------------------------------------------------------

    class GTimer
    {
    public:

        GTimer()
        :
            timer( g_timer_new() )
        {}

        ~GTimer()
        {
            g_timer_destroy( timer );
        }

        gdouble elapsed() const
        {
            return g_timer_elapsed( timer, NULL );
        }

        void stop()
        {
            g_timer_stop( timer );
        }

        void go()
        {
            g_timer_continue( timer );
        }

        void reset()
        {
            g_timer_start( timer );
        }

    private:

        GTimer( const GTimer & )
        {}

        ::GTimer *  timer;
    };

    //-------------------------------------------------------------------------
    // This takes a path that came from a configuration file or command line
    // and ensures that it is an absolute, canonical path. It accepts file:
    // URIs. If the path is relative, it will be made absolute with respect
    // to the current working directory.
    //
    // This should NOT be used for paths that come from Lua apps.
    //
    // If there is an error, it will return an empty string, unless
    // abort_on_error is true, in which case it will abort.

    String canonical_external_path( const char * path , bool abort_on_error = true );

    //-----------------------------------------------------------------------------

    String make_v1_uuid();

    String make_v4_uuid();

    //-----------------------------------------------------------------------------

    class Buffer
    {
    public:

    	typedef enum { MEMORY_USE_TAKE , MEMORY_USE_COPY } MemoryUse;

    	Buffer();

    	Buffer( gconstpointer data , guint length );

    	Buffer( MemoryUse memory_use , gpointer data , guint length );

    	Buffer( GByteArray * _bytes );

    	Buffer( const Buffer & other );

    	virtual ~Buffer();

    	const Buffer & operator = ( const Buffer & other );

    	bool good() const;

    	operator bool () const;

    	const char * data() const;

    	guint length() const;

    private:

    	GByteArray * bytes;
    };


	String describe_lua_value( lua_State * L , int index );

    void convert_bitmask_to_table( lua_State * L );
}

#endif // _TRICKPLAY_UTIL_H
