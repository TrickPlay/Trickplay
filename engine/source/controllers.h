#ifndef _TP_CONTROLLERS_H
#define _TP_CONTROLLERS_H

#include <string>
#include <map>
#include <memory>

#include "glib.h"
#include "gio/gio.h"

#include "mdns.h"

typedef std::string String;

class Controllers
{
public:
    
    Controllers();
    ~Controllers();
    
    struct ConnectionInfo
    {
        ConnectionInfo() {}
        
        String  address;
        String  name;
        String  capabilities;
        String  input_buffer;
    };
    
private:
    
    Controllers(const Controllers &) {}
    
    std::auto_ptr<MDNS> mdns;
        
#if GLIB_CHECK_VERSION(2,22,0)

    static void accept_callback(GObject * source,GAsyncResult * result,gpointer data);
    static void data_read_callback(GObject * source,GAsyncResult * result,gpointer data);
    
    static void connection_destroyed(gpointer data,GObject*connection);
    
    void connection_accepted(GSocketConnection * connection);
    void connection_closed(GObject * connection);
    void connection_data_received(GSocketConnection * connection,gchar * buffer);
    void process_command(GSocketConnection * connection,gchar ** parts);
    
    typedef std::map<GSocketConnection*,ConnectionInfo> ConnectionMap;
    
    ConnectionMap       connections;
    
    GSocketListener *   listener;
    guint16             port;
    
#endif    

};


#endif