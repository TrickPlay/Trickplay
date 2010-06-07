#ifndef _TRICKPLAY_PROFILER_H
#define _TRICKPLAY_PROFILER_H

#ifdef TP_PROFILING

#define PROFILER(name)  Profiler _profiler(name)
#define PROFILER_DUMP   Profiler::dump()
#define PROFILER_RESET  Profiler::reset()

#include "common.h"

//-----------------------------------------------------------------------------
// This class lets us gather profiling information on blocks of code. You
// simply create a Profiler instance at the top of the block you want to
// profile - this starts a timer and increases the invocation count for the
// given name. When the profiler instance is destroyed (when the block of code
// is done), it determines the elapsed time between invocations and stores
// the information. Nesting is OK too; it is handled correctly.
//-----------------------------------------------------------------------------

class Profiler
{

public:

    Profiler( const char * name );

    ~Profiler();

    static void dump();

    static void reset();

private:

    static GQueue * get_queue();

    static void lock( bool _lock );

    Profiler( const Profiler & );

    const char *    name;
    GTimer *        timer;

    typedef std::pair< unsigned int , double > Entry;
    typedef std::map< String , Entry > EntryMap;

    static bool compare( std::pair< String, Entry > a, std::pair< String, Entry > b );

    static EntryMap entries;
};

#else

#define PROFILER(name)  while(0){}
#define PROFILER_DUMP   g_info( "Profiling is disabled. Build with TP_PROFILING defined." )
#define PROFILER_RESET  while(0){}

#endif // TP_PROFILING

#endif // _TRICKPLAY_PROFILER_H
