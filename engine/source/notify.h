#ifndef _TRICKPLAY_NOTIFY_H
#define _TRICKPLAY_NOTIFY_H

#include "common.h"

class Notify
{
public:

    void add_notification_handler( const char* subject, TPNotificationHandler handler, void* data );
    void remove_notification_handler( const char* subject, TPNotificationHandler handler, void* data );

    void notify( TPContext* context , const char* subject );

private:

    typedef std::pair<TPNotificationHandler, void*>  HandlerClosure;
    typedef std::multimap<String, HandlerClosure>   HandlerMultiMap;

    HandlerMultiMap handlers;
};


#endif // _TRICKPLAY_NOTIFY_H
