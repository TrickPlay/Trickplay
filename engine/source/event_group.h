
#ifndef _TRICKPLAY_EVENT_GROUP_H
#define _TRICKPLAY_EVENT_GROUP_H

#include "common.h"
#include "util.h"

//-----------------------------------------------------------------------------
// An event group lets us track idle sources, so we can neuter them when an
// app is closed (so that they won't fire once the lua state is gone).

class EventGroup : public RefCounted
{
public:

    EventGroup();

    guint add_idle( gint priority, GSourceFunc function, gpointer data, GDestroyNotify notify );

    void cancel( guint id );

    void cancel_all();

    void remove( guint id );

protected:

    ~EventGroup();

private:

    class IdleClosure;

    GMutex*         mutex;
    std::set<guint> source_ids;
};


#endif  // _TRICKPLAY_EVENT_GROUP_H
