
#ifdef TP_PROFILING

#include <algorithm>

#include "profiler.h"
#include "util.h"

// Returns the queue of profiler items for the current thread

GQueue* Profiler::get_queue()
{
#ifndef GLIB_VERSION_2_32
    static GStaticPrivate current_queue = G_STATIC_PRIVATE_INIT;

    GQueue* queue = ( GQueue* ) g_static_private_get( & current_queue );
#else
    static GPrivate current_queue = G_PRIVATE_INIT( ( GDestroyNotify ) g_queue_free );

    GQueue* queue = ( GQueue* ) g_private_get( & current_queue );
#endif

    if ( ! queue )
    {
        queue = g_queue_new();

#ifndef GLIB_VERSION_2_32
        g_static_private_set( & current_queue, queue, ( GDestroyNotify ) g_queue_free );
#else
        g_private_set( & current_queue, queue );
#endif
    }

    return queue;
}

void Profiler::lock( bool _lock )
{
    static GStaticMutex mutex = G_STATIC_MUTEX_INIT;

    if ( _lock )
    {
        g_static_mutex_lock( & mutex );
    }
    else
    {
        g_static_mutex_unlock( & mutex );
    }
}


Profiler::EntryMap Profiler::entries;

Profiler::ObjectMap Profiler::objects;

Profiler::Profiler( const char* _name , int _type )
{
    name = _name;

    type = _type;

    GQueue* queue = get_queue();

    if ( Profiler* previous = ( Profiler* )g_queue_peek_tail( queue ) )
    {
        g_timer_stop( previous->timer );
    }

    timer = g_timer_new();

    g_queue_push_tail( queue, this );
}

Profiler::Profiler( const Profiler& )
{
    g_assert( false );
}


Profiler::~Profiler()
{
    g_timer_stop( timer );

    GQueue* queue = get_queue();

    g_assert( this == g_queue_pop_tail( queue ) );

    double elapsed = ( g_timer_elapsed( timer, NULL ) * 1000 );

    if ( Profiler* previous = ( Profiler* )g_queue_peek_tail( queue ) )
    {
        g_timer_continue( previous->timer );
    }

    g_timer_destroy( timer );

    lock( true );

    Entry& entry( entries[ name ] );

    entry.count += 1;
    entry.time += elapsed;
    entry.type = type;

    lock( false );
}

bool Profiler::compare( std::pair< String, Entry > a, std::pair< String, Entry > b )
{
    return a.second.time > b.second.time;
}

void Profiler::dump( EntryVector& v )
{
    // Sorts the vector in descending order by time taken

    std::sort( v.begin(), v.end(), compare );

    // Calculate totals

    double time = 0;

    std::vector< std::pair< String, Entry > >::const_iterator it;

    for ( it = v.begin(); it != v.end(); ++it )
    {
        time += it->second.time;
    }

    for ( it = v.begin(); it != v.end(); ++it )
    {
        g_info( "%40s %8d %8.1f %6.1f %6.1f %%",
                it->first.c_str(),
                it->second.count,
                it->second.time,
                it->second.time / it->second.count,
                time ? it->second.time / time * 100.0 : 0.0 );
    }

    g_info( "%40s          %8.1f", String( 40, '-' ).c_str(), time );
}

void Profiler::dump()
{
    lock( true );

    // Creates a vector from the entries

    EntryVector v( entries.begin(), entries.end() );

    lock( false );

    typedef std::map< int , EntryVector > EntryTypeMap;

    EntryTypeMap entries_by_type;

    // Now separate them by type

    for ( EntryVector::iterator it = v.begin(); it != v.end(); ++it )
    {
        entries_by_type[ it->second.type ].push_back( *it );
    }

    // Dump stats for each type

    for ( EntryTypeMap::iterator it = entries_by_type.begin(); it != entries_by_type.end(); ++it )
    {
        const char* t = "OTHER";

        switch ( it->first )
        {
            case PROFILER_CALLS_FROM_LUA:   t = "CALLS FROM APP:"; break;

            case PROFILER_CALLS_TO_LUA:     t = "CALLS TO APP (CALLBACKS):"; break;

            case PROFILER_INTERNAL_CALLS:   t = "INTERNAL CALLS"; break;
        }

        g_info( "" );
        g_info( "%s"  , t );

        dump( it->second );
    }
}

void Profiler::reset()
{
    lock( true );

    entries.clear();

    lock( false );
}

void Profiler::created( const char* name, gpointer p )
{
    objects[ name ].created += 1;
}

void Profiler::destroyed( const char* name, gpointer p )
{
    objects[ name ].destroyed += 1;
}

void Profiler::dump_objects()
{
    g_info( "%24s  %9s %9s %9s" , "type" , "created" , "destroyed" , "alive" );
    g_info( "%24s--%9s-%9s-%9s" , "--------------------" , "---------" , "---------" , "---------" );

    for ( ObjectMap::const_iterator it = objects.begin(); it != objects.end(); ++it )
    {
        g_info( "%24s  %9d %9d %9d",
                it->first.c_str(),
                it->second.created,
                it->second.destroyed,
                it->second.created - it->second.destroyed );
    }
}

#endif // TP_PROFILING
