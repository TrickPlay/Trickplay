#ifndef _TRICKPLAY_PROFILER_H
#define _TRICKPLAY_PROFILER_H

#include "common.h"

class Profiler
{

public:

    class Block
    {
    public:

        Block( const char * name );

        ~Block();

    private:

        Block( const Block & );

        const char *    name;
        GTimer *        timer;
    };

    friend class Block;

    static void dump();

private:

    Profiler();

    Profiler( const Profiler & );

    ~Profiler();

    static GQueue   queue;

    typedef std::pair< unsigned int , double > Entry;
    typedef std::map< String , Entry > EntryMap;

    static EntryMap entries;
};

#endif // _TRICKPLAY_PROFILER_H
