
#ifdef TP_PROFILING

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

void Profiler::dump()
{
    unsigned int count = 0;
    double time = 0;

    for( EntryMap::const_iterator it = entries.begin(); it != entries.end(); ++it )
    {
        g_info( "%40s %6d %6.0f %6.0f", it->first.c_str(), it->second.first, it->second.second , it->second.second / it->second.first );

        count += it->second.first;
        time += it->second.second;
    }

    g_info( "%40s %6d %6.0f", String( 40, '-' ).c_str(), count, time );
}

#endif // TP_PROFILING
