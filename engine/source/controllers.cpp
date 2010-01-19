
#include "controllers.h"

Controllers::Controllers()
:
    mdns(NULL)
{
#if GLIB_CHECK_VERSION(2,22,0)

    listener=g_socket_listener_new();
    
    GInetAddress * ia=g_inet_address_new_any(G_SOCKET_FAMILY_IPV4);
    
    GSocketAddress * address=g_inet_socket_address_new(ia,0);
    
    g_object_unref(G_OBJECT(ia));
    
    
    GSocketAddress * ea=NULL;
    GError * error=NULL;
    
    g_socket_listener_add_address(listener,address,G_SOCKET_TYPE_STREAM,G_SOCKET_PROTOCOL_TCP,NULL,&ea,&error);
    
    g_object_unref(G_OBJECT(address));
    
    if (error)
    {
        g_warning("FAILED TO INITIALIZE CONTROLLER LISTENER : %s",error->message);
        g_clear_error(&error);
    }
    else
    {
        port=g_inet_socket_address_get_port(G_INET_SOCKET_ADDRESS(ea));
        
        g_socket_listener_accept_async(listener,NULL,accept_callback,this);
        
        g_debug("CONTROLLER LISTENER READY ON PORT %d",port);
        
        mdns=new MDNS(port);
    }
    
    g_object_unref(G_OBJECT(ea));    
    
#else
#warning GLib 2.22 or later is required to support remote controllers
#endif
}

Controllers::~Controllers()
{
#if GLIB_CHECK_VERSION(2,22,0)
    
    if (listener)
    {
        g_socket_listener_close(listener);
        g_object_unref(G_OBJECT(listener));
    }
    
#endif

    if (mdns)
    {
        delete mdns;
    }
}

#if GLIB_CHECK_VERSION(2,22,0)

void Controllers::connection_accepted(GSocketConnection * connection)
{
    // Get and print the address
    
    gchar * remote_address=g_inet_address_to_string(g_inet_socket_address_get_address(G_INET_SOCKET_ADDRESS(g_socket_connection_get_remote_address(connection,NULL))));

    g_debug("ACCEPTED CONTROLLER CONNECTION FROM %p %s",connection,remote_address);
    
    // This adds the connection to the map and sets its address at the same time
    
    connections[connection].address=remote_address;

    g_free(remote_address);
    
    // Now, we attach us to the connection
    
    g_object_set_data(G_OBJECT(connection),"tp-controllers",this);
    
    // Get the input stream for the connection
    
    GInputStream * input_stream=g_io_stream_get_input_stream(G_IO_STREAM(connection));
    
    // Allocate an input buffer and stick it to the input stream
    
    gpointer buffer=g_malloc(256);
    
    g_object_set_data_full(G_OBJECT(input_stream),"tp-buffer",buffer,g_free);
    
    // Start reading from the input stream
    
    g_input_stream_read_async(input_stream,buffer,255,G_PRIORITY_DEFAULT,NULL,data_read_callback,connection);
    
    // Hook up a weak ref callback so we know when the connection is destroyed 
    
    g_object_weak_ref(G_OBJECT(connection),connection_destroyed,this);
}

void Controllers::connection_closed(GObject * connection)
{
    connections.erase((GSocketConnection*)connection);
    
    g_debug("CONNECTION GONE %p",connection);
}

void Controllers::connection_data_received(GSocketConnection * connection,gchar * buffer)
{
    g_debug("GOT DATA %p [%s]",connection,g_strstrip(buffer));
}


void Controllers::accept_callback(GObject * source,GAsyncResult * result,gpointer data)
{
    GSocketConnection * connection=g_socket_listener_accept_finish(G_SOCKET_LISTENER(source),result,NULL,NULL);

    if (connection)
    {
        ((Controllers*)data)->connection_accepted(connection);
    }
    
    g_socket_listener_accept_async(G_SOCKET_LISTENER(source),NULL,accept_callback,data);        
}

void Controllers::data_read_callback(GObject * source,GAsyncResult * result,gpointer data)
{    
    GInputStream * input_stream=G_INPUT_STREAM(source);
    
    GSocketConnection * connection=G_SOCKET_CONNECTION(data);
        
    // Finish the async read
    
    gsize bytes_read=g_input_stream_read_finish(input_stream,result,NULL);
    
    if (bytes_read > 0)
    {
        // We have some data - get the buffer from the input stream, append a
        // NULL and process it
        
        gchar * buffer=(gchar*)g_object_get_data(G_OBJECT(input_stream),"tp-buffer");
        
        buffer[bytes_read]=0;
        
        Controllers * self=(Controllers*)g_object_get_data(G_OBJECT(connection),"tp-controllers");
        
        self->connection_data_received(connection,buffer);
        
        // Read again
        
        g_input_stream_read_async(input_stream,buffer,255,G_PRIORITY_DEFAULT,NULL,data_read_callback,data);
    }
    else
    {
        g_io_stream_close(G_IO_STREAM(connection),NULL,NULL);
        g_object_unref(G_OBJECT(connection));                
    }
}

void Controllers::connection_destroyed(gpointer data,GObject*connection)
{
    ((Controllers*)data)->connection_closed(connection);
}

#endif
