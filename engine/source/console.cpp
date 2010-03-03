
#include "console.h"
#include "util.h"
#include "context.h"

Console::Console(TPContext * ctx,int port)
:
    context(ctx),
    L(NULL),
    channel(g_io_channel_unix_new(fileno(stdin))),
    stdin_buffer(g_string_new(NULL)),
    server(NULL)
{
    g_io_add_watch(channel,G_IO_IN,channel_watch,this);

    if (port)
    {
        GError * error=NULL;
        
        Server * new_server=new Server(port,this,'\n',&error);
        
        if (error)
        {
            delete new_server;
            g_warning("FAILED TO START TELNET CONSOLE ON PORT %d : %s",port,error->message);
            g_clear_error(&error);
        }
        else
        {
            server.reset(new_server);
            g_info("TELNET CONSOLE LISTENING ON PORT %d",server->get_port());            
        }
    }

    context->add_output_handler(output_handler,this);
}

Console::~Console()
{
    g_io_channel_shutdown(channel,FALSE,NULL);
    g_io_channel_unref(channel);
    g_string_free(stdin_buffer,TRUE);
    
    context->remove_output_handler(output_handler,this);        
}

void Console::add_command_handler(CommandHandler handler,void * data)
{
    handlers.push_back(CommandHandlerClosure(handler,data));
}

void Console::attach_to_lua(lua_State * l)
{
    L=l;
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
    else if (strlen(line) && L)
    {
        // This is plain lua

        int n=lua_gettop(L);
        
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

void Console::connection_accepted(gpointer connection,const char * remote_address)
{
    server->write_printf(connection,"WELCOME TO TrickPlay %d.%d.%d\n",TP_MAJOR_VERSION,TP_MINOR_VERSION,TP_PATCH_VERSION);
    g_debug("ACCEPTED CONSOLE CONNECTION FROM %s",remote_address);    
}

void Console::connection_data_received(gpointer connection,const char * data)
{
    gchar * line=g_strdup(data);
    process_line(line);
    g_free(line);
}

void Console::output_handler(const gchar * line,gpointer data)
{
    Console * console=(Console*)data;
    
    if (console->server.get())
    {
        console->server->write_to_all(line);
    }
}
