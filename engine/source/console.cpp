
#include "console.h"
#include "util.h"

Console::Console(lua_State*l)
:
    L(l),
    channel(g_io_channel_unix_new(0)),
    line(g_string_new(NULL))
{
    g_io_add_watch(channel,G_IO_IN,channel_watch,this);        
}

Console::~Console()
{
    g_io_channel_shutdown(channel,FALSE,NULL);
    g_io_channel_unref(channel);
    g_string_free(line,TRUE);
}

void Console::add_command_handler(ConsoleCommandHandler handler,void * data)
{
    handlers.push_back(CommandHandlerClosure(handler,data));
}


gboolean Console::read_data()
{
    GError * error=NULL;
    
    g_io_channel_read_line_string(channel,line,NULL,&error);
        
    if (error)
    {
        g_clear_error(&error);
        return FALSE;
    }
    
    // Removes leading and trailing white space in place
    
    g_strstrip(line->str);
    
    if (g_strstr_len(line->str,1,"/")==line->str)
    {
        // This is a console command. Skipping the initial
        // slash, we split it into at most 2 parts - the command
        // and the rest of the line
        
        gchar ** parts=g_strsplit(line->str+1," ",2);
        
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
    else if (strlen(line->str))
    {
        LSG;
        
        int n=lua_gettop(L);
        
        // This is plain lua
        if (luaL_loadstring(L,line->str)!=0)
        {
            g_message("%s",lua_tostring(L,-1));
            lua_pop(L,1);
        }
        else
        {
            if (lua_pcall(L,0,LUA_MULTRET,0)!=0)
            {
                g_message("%s",lua_tostring(L,-1));
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
        
        LSG_END(0);
    }
    
    return TRUE;
}

gboolean Console::channel_watch(GIOChannel * source,GIOCondition condition,gpointer data)
{
    return ((Console*)data)->read_data();    
}
