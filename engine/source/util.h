#ifndef _TRICKPLAY_UTIL_H
#define _TRICKPLAY_UTIL_H
//-----------------------------------------------------------------------------
#include <cstring>
#include <iostream>
//-----------------------------------------------------------------------------
#include "common.h"
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

protected:

    virtual ~RefCounted()
    {}

private:

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

class _Debug_ON
{
public:

    _Debug_ON( const char * _prefix = 0 )
    {
        prefix = _prefix ? g_strdup_printf( "[%s]" , _prefix ) : 0;
    }

    ~_Debug_ON()
    {
        g_free( prefix );
    }

    inline void operator()( const gchar * format, ...)
    {
        if ( prefix )
        {
            va_list args;
            va_start( args, format );
            gchar * message = g_strdup_vprintf( format , args );
            va_end( args );
            g_log( G_LOG_DOMAIN , G_LOG_LEVEL_DEBUG , "%s %s" , prefix , message );
            g_free( message );
        }
        else
        {
            va_list args;
            va_start( args, format );
            g_logv( G_LOG_DOMAIN , G_LOG_LEVEL_DEBUG , format , args );
            va_end( args );
        }
    }

    inline operator bool()
    {
        return true;
    }

private:

    gchar * prefix;
};

class _Debug_OFF
{
public:

    _Debug_OFF( const char * prefix = 0 )
    {
    }

    inline void operator()( const gchar * format, ...)
    {
    }

    inline operator bool()
    {
        return false;
    }
};

#ifdef TP_PRODUCTION
#define Debug_ON    _Debug_OFF
#define Debug_OFF   _Debug_OFF
#else
#define Debug_ON    _Debug_ON
#define Debug_OFF   _Debug_OFF
#endif


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

    Action( int interval = -1 );

    virtual ~Action();

    static void post( Action * action );

protected:

    virtual bool run() = 0;

private:

    static void destroy( Action * action );

    static gboolean run_internal( Action * action );

    int interval;
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

    inline gchar * rebase_path( const gchar * root, const gchar * path )
    {
        FreeLater free_later;

        if ( strstr( path, ".." ) )
        {
            g_error( "Invalid relative path '%s'", path );
        }

        gchar * p = path_to_native_path( g_strdup( path ) );
        free_later( p );

        const gchar * last = g_path_is_absolute( p ) ? g_path_skip_root( p ) : p;

        gchar * first = path_to_native_path( g_strdup( root ) );
        free_later( first );

        return g_build_filename( first, last, NULL );
    }

    //-----------------------------------------------------------------------------

    String make_v1_uuid();

    String make_v4_uuid();

}

#endif // _TRICKPLAY_UTIL_H
