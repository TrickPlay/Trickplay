#include "thread_pool.h"

//=============================================================================

ThreadPool::Task::~Task()
{
}

//.............................................................................

void ThreadPool::Task::process()
{
}

//.............................................................................

void ThreadPool::Task::process_main_thread()
{
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

void ThreadPool::thread_function( gpointer task, gpointer )
{
    ( ( ThreadPool::Task * ) task )->process();

    g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, idle_function, task, destroy_task );
}

//.............................................................................

gboolean ThreadPool::idle_function( gpointer task )
{
    ( ( ThreadPool::Task * ) task )->process_main_thread();

    return FALSE;
}

//.............................................................................

void ThreadPool::push( Task * task )
{
    g_assert( task );

    g_thread_pool_push( pool, task, NULL );
}

//.............................................................................

void ThreadPool::destroy_task( gpointer task )
{
    delete ( Task * ) task;
}

