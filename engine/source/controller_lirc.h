#ifndef _TRICKPLAY_CONTROLLER_LIRC_H
#define _TRICKPLAY_CONTROLLER_LIRC_H

#include "gio/gio.h"

#include "trickplay/controller.h"
#include "common.h"

class ControllerLIRC
{
public:

    static ControllerLIRC* make( TPContext* context );

    ~ControllerLIRC();

private:

    ControllerLIRC( TPContext* context , const char* uds , guint repeat );

    static void line_read( GObject* stream , GAsyncResult* result , gpointer me );

    void line_read( GObject* stream , GAsyncResult* result );

    typedef std::map< String , int > KeyMap;

    KeyMap              key_map;

    GSocketConnection* connection;

    TPController*       controller;

    GTimer*             timer;

    gdouble             repeat;
};


#endif // _TRICKPLAY_CONTROLLER_LIRC_H
