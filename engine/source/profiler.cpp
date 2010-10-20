
#ifdef TP_PROFILING

#include <algorithm>

#include "profiler.h"
#include "util.h"

// Returns the queue of profiler items for the current thread

GQueue * Profiler::get_queue()
{
    static GStaticPrivate current_queue = G_STATIC_PRIVATE_INIT;

    GQueue * queue = ( GQueue * ) g_static_private_get( & current_queue );

    if ( ! queue )
    {
        queue = g_queue_new();

        g_static_private_set( & current_queue, queue, ( GDestroyNotify ) g_queue_free );
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

Profiler::Profiler( const char * _name )
{

    name = _name;

    timer = g_timer_new();

    GQueue * queue = get_queue();

    if ( Profiler * previous = ( Profiler * )g_queue_peek_tail( queue ) )
    {
        g_timer_stop( previous->timer );
    }

    g_queue_push_tail( queue, this );
}

Profiler::Profiler( const Profiler & )
{
    g_assert( false );
}


Profiler::~Profiler()
{
    GQueue * queue = get_queue();

    g_assert( this == g_queue_peek_tail( queue ) );

    double elapsed = ( g_timer_elapsed( timer, NULL ) * 1000 );

    g_queue_pop_tail( queue );

    if ( Profiler * previous = ( Profiler * )g_queue_peek_tail( queue ) )
    {
        g_timer_continue( previous->timer );
    }

    g_timer_destroy( timer );

    lock( true );

    Entry & entry( entries[ name ] );

    entry.first += 1;
    entry.second += elapsed;

    lock( false );
}

bool Profiler::compare( std::pair< String, Entry > a, std::pair< String, Entry > b )
{
    return a.second.second > b.second.second;
}

void Profiler::dump( EntryVector & v )
{
    // Sorts the vector in descending order by time taken

    std::sort( v.begin(), v.end(), compare );

    // Calculate totals

    double time = 0;

    std::vector< std::pair< String, Entry > >::const_iterator it;

    for( it = v.begin(); it != v.end(); ++it )
    {
        time += it->second.second;
    }

    for( it = v.begin(); it != v.end(); ++it )
    {
        g_info( "%40s %8d %8.1f %6.1f %6.1f %%",
                it->first.c_str(),
                it->second.first,
                it->second.second,
                it->second.second / it->second.first,
                time ? it->second.second / time * 100.0 : 0.0 );
    }

    g_info( "%40s          %8.1f", String( 40, '-' ).c_str(), time );
}

void Profiler::dump()
{
    lock( true );

    // Creates a vector from the entries

    EntryVector v( entries.begin(), entries.end() );

    lock( false );

    EntryVector from_lua;
    EntryVector to_lua;

    for ( EntryVector::iterator it = v.begin(); it != v.end(); ++it )
    {
        if ( ! strncmp( it->first.c_str() , "on_" , 3 ) )
        {
            to_lua.push_back( *it );
        }
        else
        {
            from_lua.push_back( *it );
        }
    }

    g_info( "CALLS FROM APP:" );

    dump( from_lua );

    g_info( "" );
    g_info( "CALLS TO APP (CALLBACKS):" );

    dump( to_lua );
}

void Profiler::reset()
{
    lock( true );

    entries.clear();

    lock( false );
}

void Profiler::created( const char * name, gpointer p )
{
    objects[ name ].created += 1;
}

void Profiler::destroyed( const char * name, gpointer p )
{
    objects[ name ].destroyed += 1;
}

void Profiler::dump_objects()
{
    for( ObjectMap::const_iterator it = objects.begin(); it != objects.end(); ++it )
    {
        g_info( "%24s  %5d %5d %5d",
                it->first.c_str(),
                it->second.created,
                it->second.destroyed,
                it->second.created - it->second.destroyed );
    }
}

#endif // TP_PROFILING
