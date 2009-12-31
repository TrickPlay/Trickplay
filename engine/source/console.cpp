
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

gboolean Console::read_data()
{
    GError * error=NULL;
    
    g_io_channel_read_line_string(channel,line,NULL,&error);
    
    g_debug("READ [%s]",line->str);
    
    if (error)
        return FALSE;
    
    return TRUE;
}

gboolean Console::channel_watch(GIOChannel * source,GIOCondition condition,gpointer data)
{
    return ((Console*)data)->read_data();    
}