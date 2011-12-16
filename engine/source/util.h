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

    virtual ~Action();

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

        GSRMutexLock( GStaticRecMutex * mutex ) : m( mutex )
        {
            g_static_rec_mutex_lock( m );
        }
        ~GSRMutexLock()
        {
            g_static_rec_mutex_unlock( m );
        }

    private:

        GSRMutexLock() {}
        GSRMutexLock( const GSRMutexLock & ) {}

        GStaticRecMutex * m;
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
    // Converts a path using / to a platform path in place - modifies the string
    // passed in.

    inline gchar * path_to_native_path( gchar * path )
    {
        if ( G_DIR_SEPARATOR == '/' )
        {
            return path;
        }
        return g_strdelimit( path, "/", G_DIR_SEPARATOR );
    }

    //-----------------------------------------------------------------------------
    // Given a root path and some other path, it makes the path relative and
    // appends it to the root. Return value must be destroyed with g_free.
    // Both root and path are converted to native paths.
    //
    // NOTE: if path contains any .. elements, this will abort. The assumption
    // is that root is trusted and path came from Lua - and cannot be trusted

    inline gchar * rebase_path( const gchar * root, const gchar * path , bool abort = true )
    {
        FreeLater free_later;

        if ( strstr( path, ".." ) )
        {
            if ( abort )
            {
                g_error( "Invalid relative path '%s'", path );
            }
            else
            {
                return 0;
            }
        }

        gchar * p = path_to_native_path( g_strdup( path ) );
        free_later( p );

        const gchar * last = g_path_is_absolute( p ) ? g_path_skip_root( p ) : p;

        gchar * first = path_to_native_path( g_strdup( root ) );
        free_later( first );

        return g_build_filename( first, last, ( gpointer ) 0 );
    }

    //-----------------------------------------------------------------------------

    String make_v1_uuid();

    String make_v4_uuid();

    //-----------------------------------------------------------------------------

    class Buffer
    {
    public:

    	enum MemoryUse { MEMORY_USE_TAKE , MEMORY_USE_COPY };

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
}

#endif // _TRICKPLAY_UTIL_H
