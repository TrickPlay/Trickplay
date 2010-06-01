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

namespace Util
{
    //-----------------------------------------------------------------------------
    // This is like an auto_ptr that uses g_free and cannot be copied

    class GFreeLater
    {
    public:

        GFreeLater( gpointer pointer ) : p( pointer ) {}
        ~GFreeLater()
        {
            g_free( p );
        }

    private:

        GFreeLater() {}
        GFreeLater( const GFreeLater & ) {}

        gpointer p;
    };

    //-----------------------------------------------------------------------------

    class GStrFreevLater
    {
    public:

        GStrFreevLater( gchar ** pointer ) : p( pointer ) {}
        ~GStrFreevLater()
        {
            g_strfreev( p );
        }

    private:

        GStrFreevLater() {}
        GStrFreevLater( const GStrFreevLater & ) {}

        gchar ** p;
    };

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
        if ( strstr( path, ".." ) )
        {
            g_error( "Invalid relative path '%s'", path );
        }

        gchar * p = path_to_native_path( g_strdup( path ) );
        GFreeLater free_p( p );

        const gchar * last = g_path_is_absolute( p ) ? g_path_skip_root( p ) : p;

        gchar * first = path_to_native_path( g_strdup( root ) );
        GFreeLater free_first( first );

        return g_build_filename( first, last, NULL );
    }

}

#endif // _TRICKPLAY_UTIL_H
