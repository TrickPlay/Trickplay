
#include "event_group.h"

class EventGroup::IdleClosure
{
public:

    static guint add_idle( EventGroup * eg, gint priority, GSourceFunc f, gpointer d, GDestroyNotify dn )
    {
        return g_idle_add_full( priority, idle_callback, new IdleClosure( eg, f, d, dn ), destroy_callback );
    }

private:

    IdleClosure( EventGroup * eg, GSourceFunc f, gpointer d, GDestroyNotify dn )
        :
        event_group( eg ),
        function( f ),
        data( d ),
        destroy_notify( dn )
    {
        event_group->ref();
    }

    ~IdleClosure()
    {
        event_group->unref();
    }

    static gboolean idle_callback( gpointer ic )
    {
        IdleClosure * closure = ( IdleClosure * )ic;

        GSource * source = g_main_current_source();

        guint id = g_source_get_id( source );

        if ( !g_source_is_destroyed( source ) )
        {
            closure->function( closure->data );
        }
        else
        {
            g_debug( "NOT FIRING SOURCE %d", id );
        }

        closure->event_group->remove( id );

        return FALSE;
    }

    static void destroy_callback( gpointer ic )
    {
        IdleClosure * closure = ( IdleClosure * )ic;

        if ( closure->destroy_notify )
        {
            closure->destroy_notify( closure->data );
        }

        delete closure;
    }

private:

    EventGroup *    event_group;
    GSourceFunc     function;
    gpointer        data;
    GDestroyNotify  destroy_notify;
};

EventGroup::EventGroup()
    :
#ifndef GLIB_VERSION_2_32
    mutex( g_mutex_new() )
#else
    mutex( new GMutex )
#endif
{
#ifdef GLIB_VERSION_2_32
    g_mutex_init(mutex);
#endif
}

EventGroup::~EventGroup()
{
    cancel_all();
#ifndef GLIB_VERSION_2_32
    g_mutex_free( mutex );
#else
    g_mutex_clear(mutex);
    delete mutex;
#endif
}

guint EventGroup::add_idle( gint priority, GSourceFunc function, gpointer data, GDestroyNotify notify )
{
    Util::GMutexLock lock( mutex );
    g_assert( function );

    guint id = IdleClosure::add_idle( this, priority, function, data, notify );

    source_ids.insert( id );

    return id;
}

void EventGroup::cancel( guint id )
{
    Util::GMutexLock lock( mutex );
    std::set<guint>::iterator it = source_ids.find( id );

    if ( it == source_ids.end() )
    {
        g_debug( "CANNOT CANCEL SOURCE %d", id );
    }
    else
    {
        g_debug( "CANCELLING SOURCE %d", id );

        source_ids.erase( it );

        g_source_remove( id );
    }
}

void EventGroup::cancel_all()
{
    Util::GMutexLock lock( mutex );

    if ( !source_ids.empty() )
    {
        g_debug( "CANCELLING %" G_GSIZE_FORMAT " SOURCE(S)", source_ids.size() );

        for ( std::set<guint>::iterator it = source_ids.begin(); it != source_ids.end(); ++it )
        {
            g_source_remove( ( *it ) );
        }

        source_ids.clear();
    }
}

void EventGroup::remove( guint id )
{
    Util::GMutexLock lock( mutex );
    source_ids.erase( id );
}

