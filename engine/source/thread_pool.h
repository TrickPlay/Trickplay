#ifndef _TRICKPLAY_THREAD_POOL_H
#define _TRICKPLAY_THREAD_POOL_H

#include "common.h"
#include "util.h"

#define TP_THREADPOOL_DEBUG 0

class ThreadPool
{
public:

    ThreadPool( guint max_threads );

    ~ThreadPool( );

    class Task
    {
    public:

        Task();

        virtual ~Task();

        virtual void process();

        virtual void process_main_thread();

    private:

        friend class ThreadPool;

        void do_process();

        void do_process_main_thread();

#if TP_THREADPOOL_DEBUG

        guint64         id;
        Util::GTimer    timer;
        gdouble         time_to_pool;
        gdouble         time_to_process;
        gdouble         time_to_main_thread;
        gdouble         end_time;

#endif

    };

    void push( Task* task );

    static void push_main_thread( Task* task );

private:

    static void thread_function( gpointer task, gpointer pool_data );

    static gboolean idle_function( gpointer task );

    static void destroy_task( gpointer task );

    GThreadPool* pool;
};



#endif // _TRICKPLAY_THREAD_POOL_H
