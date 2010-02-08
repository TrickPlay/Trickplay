
#include "console.h"
#include "util.h"
#include "context.h"
#include "app.h"

Console::Console(lua_State*l,int port)
:
    L(l),
    channel(g_io_channel_unix_new(fileno(stdin))),
    stdin_buffer(g_string_new(NULL))
{
    g_io_add_watch(channel,G_IO_IN,channel_watch,this);
    
#if GLIB_CHECK_VERSION(2,22,0)
    
    if (port)
    {
        listener=g_socket_listener_new();
        if(g_socket_listener_add_inet_port(listener,port,NULL,NULL))
        {
            g_socket_listener_accept_async(listener,NULL,accept_callback,this);
            g_info("TELNET CONSOLE LISTENING ON PORT %d",port);
        }
    }
    else
    {
        listener=NULL;
    }
    
#endif    
}

Console::~Console()
{
    g_io_channel_shutdown(channel,FALSE,NULL);
    g_io_channel_unref(channel);
    g_string_free(stdin_buffer,TRUE);
    
#if GLIB_CHECK_VERSION(2,22,0)

    if (listener)
    {
        g_socket_listener_close(listener);
        g_object_unref(G_OBJECT(listener));
    }
    
#endif    
}

void Console::add_command_handler(CommandHandler handler,void * data)
{
    handlers.push_back(CommandHandlerClosure(handler,data));
}


gboolean Console::read_data()
{
    GError * error=NULL;
    
    g_io_channel_read_line_string(channel,stdin_buffer,NULL,&error);
        
    if (error)
    {
        g_clear_error(&error);
        return FALSE;
    }
    
    process_line(stdin_buffer->str);
    
    return TRUE;
}
 
void Console::process_line(gchar * line)
{
    // Removes leading and trailing white space in place
    
    g_strstrip(line);
    
    if (g_strstr_len(line,1,"/")==line)
    {
        // This is a console command. Skipping the initial
        // slash, we split it into at most 2 parts - the command
        // and the rest of the line
        
        gchar ** parts=g_strsplit(line+1," ",2);
        
        if (g_strv_length(parts) >= 1)
        {
            for(CommandHandlerList::iterator it=handlers.begin();it!=handlers.end();++it)
            {
                if (it->first(parts[0],parts[1],it->second))
                    break;
            }
        }
        
        g_strfreev(parts);
    }
    else if (strlen(line))
    {
        int n=lua_gettop(L);
        
        // This is plain lua
        if (luaL_loadstring(L,line)!=0)
        {
            g_warning("%s",lua_tostring(L,-1));
            lua_pop(L,1);
        }
        else
        {
            if (lua_pcall(L,0,LUA_MULTRET,0)!=0)
            {
                g_warning("%s",lua_tostring(L,-1));
                lua_pop(L,1);
            }
            else
            {
                // We have the results from the call
                int nargs=lua_gettop(L)-n;
                
                if (nargs)
                {
                    // Get the global print function
                    lua_getglobal(L,"print");
                    // Move it before the results 
                    lua_insert(L,lua_gettop(L)-nargs);
                    // Call it
                    if (lua_pcall(L,nargs,0,0)!=0)
                        lua_pop(L,1);
                }
            }
        }
    }
}

gboolean Console::channel_watch(GIOChannel * source,GIOCondition condition,gpointer data)
{
    return ((Console*)data)->read_data();    
}

#if GLIB_CHECK_VERSION(2,22,0)

void Console::accept_callback(GObject * source,GAsyncResult * result,gpointer data)
{
    GSocketListener * listener=G_SOCKET_LISTENER(source);
    
    GSocketConnection * connection=g_socket_listener_accept_finish(listener,result,NULL,NULL);

    if (connection)
    {
        // Print the address
        
        gchar * remote_address=g_inet_address_to_string(g_inet_socket_address_get_address(G_INET_SOCKET_ADDRESS(g_socket_connection_get_remote_address(connection,NULL))));

        g_debug("ACCEPTED CONSOLE CONNECTION FROM %s",remote_address);
        
        g_free(remote_address);
        
        // Get the input stream for the connection
        
        GInputStream * input_stream=g_io_stream_get_input_stream(G_IO_STREAM(connection));
        
        // Allocate an input buffer and stick it to the input stream
        
        gpointer buffer=g_malloc(256);
        
        g_object_set_data_full(G_OBJECT(input_stream),"tp-buffer",buffer,g_free);
        
        // Start reading from the input stream
        
        g_input_stream_read_async(input_stream,buffer,255,G_PRIORITY_DEFAULT,NULL,data_read_callback,data);
        
        // Add an output handler to the context, so that this connection will
        // get output. Also, hook up a weak ref callback so we know when the
        // connection is destroyed and we can remove its output handler.
        
        lua_State * L =((Console*)data)->L;
        
        App::get(L)->get_context()->add_output_handler(output_handler,connection);
        
        g_object_weak_ref(G_OBJECT(connection),connection_destroyed,L);
    }       
    
    g_socket_listener_accept_async(listener,NULL,accept_callback,data);    
}

void Console::data_read_callback(GObject * source,GAsyncResult * result,gpointer data)
{
    GInputStream * input_stream=G_INPUT_STREAM(source);
    
    // Finish the async read
    
    gsize bytes_read=g_input_stream_read_finish(input_stream,result,NULL);
    
    if (bytes_read > 0)
    {
        // We have some data - get the buffer from the input stream, append a
        // NULL and process it
        
        gchar * buffer=(gchar*)g_object_get_data(G_OBJECT(input_stream),"tp-buffer");
        
        buffer[bytes_read]=0;
        
        ((Console*)data)->process_line(buffer);
        
        // Read again
        
        g_input_stream_read_async(input_stream,buffer,255,G_PRIORITY_DEFAULT,NULL,data_read_callback,data);
    }
}

void Console::output_handler(const gchar * line,gpointer data)
{
    GOutputStream * output_stream=g_io_stream_get_output_stream(G_IO_STREAM(data));
    
    // Try to write - if we fail, we close the stream and unref the connection
    // which will end up calling the weak ref callback
    
    if (!g_output_stream_write_all(output_stream,line,strlen(line),NULL,NULL,NULL))
    {
        g_io_stream_close(G_IO_STREAM(data),NULL,NULL);
        g_object_unref(G_OBJECT(data));
    }
}

void Console::connection_destroyed(gpointer data,GObject*connection)
{
    // The connection has been destroyed, we remove its output handler
    
    App::get((lua_State*)data)->get_context()->remove_output_handler(Console::output_handler,connection);    
}

#endif
