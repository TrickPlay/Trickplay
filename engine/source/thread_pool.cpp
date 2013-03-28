#include "thread_pool.h"

//=============================================================================

ThreadPool::Task::Task()
{
#if TP_THREADPOOL_DEBUG

    static guint64 next_id = 1;

    id = next_id++;

#endif
}


ThreadPool::Task::~Task()
{
#if TP_THREADPOOL_DEBUG

    g_debug( "TASK %4.4" G_GUINT64_FORMAT " : %7.3f : %7.3f : %7.3f : %7.3f : TOTAL %8.3f",
            id,
            time_to_pool * 1000,
            time_to_process * 1000,
            time_to_main_thread * 1000,
            end_time * 1000,
            ( time_to_pool + time_to_process + time_to_main_thread + end_time ) * 1000 );
#endif
}

//.............................................................................

void ThreadPool::Task::process()
{
}

//.............................................................................

void ThreadPool::Task::process_main_thread()
{
}

//.............................................................................

void ThreadPool::Task::do_process()
{
#if TP_THREADPOOL_DEBUG

    time_to_pool = timer.elapsed();

    timer.reset();

#endif

    process();

#if TP_THREADPOOL_DEBUG

    time_to_process = timer.elapsed();

    timer.reset();

#endif
}

//.............................................................................

void ThreadPool::Task::do_process_main_thread()
{
#if TP_THREADPOOL_DEBUG

    time_to_main_thread = timer.elapsed();

    timer.reset();

#endif

    process_main_thread();

#if TP_THREADPOOL_DEBUG

    end_time = timer.elapsed();

#endif
}

//=============================================================================

ThreadPool::ThreadPool( guint max_threads )
{
    pool = g_thread_pool_new( thread_function, this, max_threads, FALSE, NULL );

    g_thread_pool_set_max_unused_threads( -1 );

    // After 30 seconds of idle time, unused threads are stopped

    g_thread_pool_set_max_idle_time( 30000 );
}

//.............................................................................

ThreadPool::~ThreadPool()
{
    g_thread_pool_free( pool, TRUE, TRUE );
}

//.............................................................................

void ThreadPool::thread_function( gpointer _task, gpointer )
{
    Task* task = ( Task* ) _task;

    task->do_process();

    push_main_thread( task );
}

//.............................................................................

gboolean ThreadPool::idle_function( gpointer _task )
{
    Task* task = ( Task* ) _task;

    task->do_process_main_thread();

    return FALSE;
}

//.............................................................................

void ThreadPool::push_main_thread( Task* task )
{
    g_idle_add_full( TRICKPLAY_PRIORITY, idle_function, task, destroy_task );
}

//.............................................................................

void ThreadPool::push( Task* task )
{
    g_assert( task );

#if TP_THREADPOOL_DEBUG

    task->timer.reset();

#endif

    g_thread_pool_push( pool, task, NULL );
}

//.............................................................................

void ThreadPool::destroy_task( gpointer task )
{
    delete( Task* ) task;
}

