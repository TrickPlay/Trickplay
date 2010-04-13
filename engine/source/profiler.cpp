
#ifdef TP_PROFILING

#include <algorithm>

#include "profiler.h"
#include "util.h"

GQueue Profiler::queue = G_QUEUE_INIT;

Profiler::EntryMap Profiler::entries;

Profiler::Profiler( const char * _name )
{

    name = _name;

    timer = g_timer_new();

    if ( Profiler * previous = ( Profiler * )g_queue_peek_tail( &queue ) )
    {
        g_timer_stop( previous->timer );
    }

    g_queue_push_tail( &queue, this );
}

Profiler::Profiler( const Profiler & )
{
    g_assert( false );
}


Profiler::~Profiler()
{
    g_assert( this == g_queue_peek_tail( &queue ) );

    double elapsed = ( g_timer_elapsed( timer, NULL ) * 1000 );

    g_queue_pop_tail( &queue );

    if ( Profiler * previous = ( Profiler * )g_queue_peek_tail( &queue ) )
    {
        g_timer_continue( previous->timer );
    }

    Entry & entry( entries[ name ] );

    entry.first += 1;
    entry.second += elapsed;

    g_timer_destroy( timer );
}

bool Profiler::compare( std::pair< String, Entry > a, std::pair< String, Entry > b )
{
    return a.second.second > b.second.second;
}

void Profiler::dump()
{
    // Creates a vector from the entries

    std::vector< std::pair< String, Entry > > v( entries.begin(), entries.end() );

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
        g_info( "%40s %6d %6.1f %6.1f %6.1f %%",
                it->first.c_str(),
                it->second.first,
                it->second.second,
                it->second.second / it->second.first,
                time ? it->second.second / time * 100.0 : 0.0 );
    }

    g_info( "%40s        %6.1f", String( 40, '-' ).c_str(), time );
}

void Profiler::reset()
{
    entries.clear();
}

#endif // TP_PROFILING
