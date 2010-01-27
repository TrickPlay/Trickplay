
#include <cstring>
#include <cstdio>
#include <cstdlib>

#include "clutter/clutter.h"

#include "controllers.h"
#include "util.h"

//-----------------------------------------------------------------------------

bool Controllers::ControllerInfo::has_accelerometer() const
{
    return caps.find(String("AX")) != caps.end();    
}

//-----------------------------------------------------------------------------

Controllers::Controllers(int port)
:
    mdns(NULL),
    delegate(NULL)
{
#if GLIB_CHECK_VERSION(2,22,0)

    listener=g_socket_listener_new();
    
    GInetAddress * ia=g_inet_address_new_any(G_SOCKET_FAMILY_IPV4);
    
    GSocketAddress * address=g_inet_socket_address_new(ia,port);
    
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
        
        g_info("CONTROLLER LISTENER READY ON PORT %d",port);
        
        mdns.reset(new MDNS(port));
    }
    
    g_object_unref(G_OBJECT(ea));    
    
#else
#warning GLib 2.22 or later is required to support controllers
#endif
}

//-----------------------------------------------------------------------------

Controllers::~Controllers()
{
#if GLIB_CHECK_VERSION(2,22,0)
    
    if (listener)
    {
        g_socket_listener_close(listener);
        g_object_unref(G_OBJECT(listener));
    }
    
#endif
}

//-----------------------------------------------------------------------------

bool Controllers::is_ready() const
{
    if (!mdns.get())
        return false;
    
    return mdns->is_ready();
}


//-----------------------------------------------------------------------------

void Controllers::set_delegate(Controllers::Delegate * d)
{
    delegate=d;
}

//-----------------------------------------------------------------------------

Controllers::ControllerInfo * Controllers::find_controller(gpointer source)
{
#if GLIB_CHECK_VERSION(2,22,0)

    ConnectionInfo * ci=find_connection((GSocketConnection*)source);
    
    return ci?&ci->controller:NULL;

#else

    return NULL;

#endif
}

//-----------------------------------------------------------------------------

bool Controllers::start_accelerometer(gpointer source,const char * filter,double interval)
{
    gchar * line=g_strdup_printf("START\tAX\t%s\t%f\n",filter,interval);
    Util::GFreeLater free_line(line);
    
    return write_line(source,line);
}

//-----------------------------------------------------------------------------

bool Controllers::stop_accelerometer(gpointer source)
{
    return write_line(source,"STOP\tAX\n");
}

//-----------------------------------------------------------------------------

bool Controllers::reset(gpointer source)
{
    return write_line(source,"RESET\n");
}

//-----------------------------------------------------------------------------

bool Controllers::ui_clear(gpointer source)
{
    return write_line(source,"UI\tCLEAR\n");
}

//-----------------------------------------------------------------------------

bool Controllers::ui_show_multiple_choice(gpointer source,const StringPairList & choices)
{
    String line("UI\tMC");
    
    for (StringPairList::const_iterator it=choices.begin();it!=choices.end();++it)
    {
        line.append("\t");
        line.append(it->first);
        line.append("\t");
        line.append(it->second);
    }
    
    line.append("\n");
    
    return write_line(source,line.c_str());
}

//-----------------------------------------------------------------------------

bool Controllers::write_line(gpointer source,const gchar * line)
{
#if GLIB_CHECK_VERSION(2,22,0)

    GSocketConnection * connection=(GSocketConnection*)source;
    
    if (!find_connection(connection))
        return false;
    
    g_debug("WRITING %p [%s]",source,line);
       
    return g_output_stream_write_all(g_io_stream_get_output_stream(G_IO_STREAM(connection)),line,strlen(line),NULL,NULL,NULL);

#else

    return false;

#endif
}

//-----------------------------------------------------------------------------

#if GLIB_CHECK_VERSION(2,22,0)

//-----------------------------------------------------------------------------

Controllers::ConnectionInfo * Controllers::find_connection(GSocketConnection * connection)
{
    ConnectionMap::iterator it=connections.find(connection);
    
    return it==connections.end()?NULL:&it->second;
}

//-----------------------------------------------------------------------------

void Controllers::connection_accepted(GSocketConnection * connection)
{
    // Get and print the address
    
    gchar * remote_address=g_inet_address_to_string(g_inet_socket_address_get_address(G_INET_SOCKET_ADDRESS(g_socket_connection_get_remote_address(connection,NULL))));

    g_debug("ACCEPTED CONTROLLER CONNECTION %p FROM %s",connection,remote_address);
    
    // This adds the connection to the map and sets its address at the same time
    
    ConnectionInfo & info=connections[connection];
    
    info.controller.address=remote_address;

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
    
#if 0
    // TURN THIS OFF UNTIL THE iPHONE APP IS UPDATED
    
    // Now, set a timer to disconnect the connection if it has not identified
    // itself within a few seconds
    
    GSource * source=g_timeout_source_new( 10 * 1000 ); // 10 seconds	    
    g_source_set_callback(source,timed_disconnect_callback,new TimerClosure(connection,this),NULL);
    g_source_attach(source,g_main_context_default());
    g_source_unref(source);
    
#endif
    
}

//-----------------------------------------------------------------------------

gboolean Controllers::timed_disconnect_callback(gpointer data)
{
    g_debug("TIMED DISCONNECT");
    
    // Check to see that the controller has reported a version
    
    TimerClosure * tc=(TimerClosure*)data;
    
    ConnectionInfo * ci=tc->self->find_connection(tc->connection);
    
    if (ci && !ci->controller.version)
    {
        g_debug("DROPPING UNIDENTIFIED CONNECTION %p",tc->connection);
        
        g_io_stream_close(G_IO_STREAM(tc->connection),NULL,NULL);
    }
    
    delete tc;
    
    return FALSE;
}

//-----------------------------------------------------------------------------

void Controllers::connection_closed(GObject * connection)
{
    connections.erase((GSocketConnection*)connection);
    
    g_debug("CONTROLLER CONNECTION CLOSED %p",connection);
    
    if (delegate)
    {
        delegate->disconnected(connection);    
    }
}

//-----------------------------------------------------------------------------

void Controllers::connection_data_received(GSocketConnection * connection,gchar * buffer)
{
    ConnectionMap::iterator it=connections.find(connection);
    
    if (it==connections.end())
        return;

    // Get the input buffer for the connection and append the new data to it
    
    String & input_buffer=it->second.input_buffer;
    
    input_buffer.append(buffer);
    
    // Now, split it into lines
    
    gchar * b=g_strdup(input_buffer.c_str());
    
    gchar * s=b;
    gchar * e=NULL;
    
    while((e=strchr(s,'\n')))
    {
        *e=0;
        s=g_strstrip(s);
        
        if (strlen(s))
        {
            g_debug("GOT DATA %p [%s]",connection,s);
            
            gchar ** parts=g_strsplit(s,"\t",0);
            
            process_command(connection,it->second.controller,parts);
            
            g_strfreev(parts);
        }
        
        s=e+1;
    }
    
    // Put the left overs back into the input buffer
    
    if (s!=b)
    {
        input_buffer=s;
    }
    
    g_free(b);
}

//-----------------------------------------------------------------------------

void Controllers::process_command(GSocketConnection * connection,ControllerInfo & info,gchar ** parts)
{
    guint count=g_strv_length(parts);
    
    if (count<1)
        return;
    
    switch(*(parts[0]))
    {
        // Identification line
        // DEVICE   <version>   <name>  <cap1>  <cap2>
        
        case 'D':
        {
            // Not enough parts - bad command
            if (count<3)
                return;
            
            // Already have device info 
            if (info.version)
                return;
            
            info.version=atoi(parts[1]);
            
            // Version 0?
            if (!info.version)
                return;
            
            info.name=g_strstrip(parts[2]);
            
            // Capability entries
            for (guint i=3;i<count;++i)
            {
                gchar * cap=g_strstrip(parts[i]);
                if (strlen(cap))
                    info.caps.insert(cap);
            }
            
            if (delegate)
            {
                delegate->connected(connection,info);
            }
            
            break;   
        }
            
        
        // key input
        
        case 'K':
        {
            if (count>1)
            {
                unsigned long int k=0;
                if (sscanf(parts[1],"%lx",&k)==1)
                {
                    g_debug("GOT KEY %ld",k);
                    
                    ClutterEvent * event=clutter_event_new(CLUTTER_KEY_PRESS);
                    event->any.stage=CLUTTER_STAGE(clutter_stage_get_default());
                    event->any.time=clutter_get_timestamp();
                    event->any.flags=CLUTTER_EVENT_FLAG_SYNTHETIC;
                    event->key.keyval=k;
                    
                    clutter_event_put(event);
                    
                    event->type=CLUTTER_KEY_RELEASE;
                    event->any.time=clutter_get_timestamp();
                    
                    clutter_event_put(event);
                    
                    clutter_event_free(event);
                }
            }
            break;    
        }
        
        // accelerometer data
        
        case 'A':
        {
            // AX   x   y   z
            
            if (count<4)
                return;
            
            double x=atof(parts[1]);
            double y=atof(parts[2]);
            double z=atof(parts[3]);
            
            if (delegate)
            {
                delegate->accelerometer(connection,x,y,z);
            }
            
            break;
        }
        
        // ui event
        
        case 'U':
        {
            // UI   <event>
            
            if (count<2)
                return;
            
            if (delegate)
                delegate->ui_event(connection,parts[1]);
            break;
        }        
    }
}

//-----------------------------------------------------------------------------

void Controllers::accept_callback(GObject * source,GAsyncResult * result,gpointer data)
{
    GSocketConnection * connection=g_socket_listener_accept_finish(G_SOCKET_LISTENER(source),result,NULL,NULL);

    if (connection)
    {
        ((Controllers*)data)->connection_accepted(connection);
    }
    
    g_socket_listener_accept_async(G_SOCKET_LISTENER(source),NULL,accept_callback,data);        
}

//-----------------------------------------------------------------------------

void Controllers::data_read_callback(GObject * source,GAsyncResult * result,gpointer data)
{
    GInputStream * input_stream=G_INPUT_STREAM(source);
    
    GSocketConnection * connection=G_SOCKET_CONNECTION(data);
        
    // Finish the async read
    
    GError * error=NULL;
    
    gsize bytes_read=g_input_stream_read_finish(input_stream,result,&error);
    
    if (error || bytes_read <= 0)
    {
        g_debug("CONNECTION READ ERROR %p : %s",connection,error?error->message:"NO DATA");
        g_clear_error(&error);

        g_io_stream_close(G_IO_STREAM(connection),NULL,NULL);
        g_object_unref(G_OBJECT(connection));                
    }
    else
    {
        // We have some data - get the buffer from the input stream, append a
        // NULL and process it
        
        gchar * buffer=(gchar*)g_object_get_data(G_OBJECT(input_stream),"tp-buffer");
        
        buffer[bytes_read>255?255:bytes_read]=0;
        
        Controllers * self=(Controllers*)g_object_get_data(G_OBJECT(connection),"tp-controllers");
        
        self->connection_data_received(connection,buffer);
        
        // Read again
        
        g_input_stream_read_async(input_stream,buffer,255,G_PRIORITY_DEFAULT,NULL,data_read_callback,data);
    }
}

//-----------------------------------------------------------------------------

void Controllers::connection_destroyed(gpointer data,GObject*connection)
{
    Controllers * self=(Controllers*)data;
    
    g_debug("CONNECTION DESTROYED %p",connection);
    
    self->connection_closed(connection);
}

//-----------------------------------------------------------------------------

#endif
