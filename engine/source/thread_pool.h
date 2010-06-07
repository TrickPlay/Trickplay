#ifndef _TRICKPLAY_THREAD_POOL_H
#define _TRICKPLAY_THREAD_POOL_H

#include "common.h"

class ThreadPool
{
public:

    ThreadPool( guint max_threads );

    ~ThreadPool( );

    class Task
    {
    public:

        virtual ~Task();

        virtual void process();

        virtual void process_main_thread();
    };

    void push( Task * task );

private:

    static void thread_function( gpointer task, gpointer pool_data );

    static gboolean idle_function( gpointer task );

    static void destroy_task( gpointer task );

    GThreadPool * pool;
};



#endif // _TRICKPLAY_THREAD_POOL_H
