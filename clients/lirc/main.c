
#include <string.h>
#include <stdio.h>

#include "trickplay/trickplay.h"
#include "glib.h"

#include "lirc/lirc_client.h"

//-----------------------------------------------------------------------------
// Gets called when the lirc IO channel has data to be read. We read the data
// and pick out the 3rd piece, which is a string describing the key pressed

gboolean lirc_channel_watch(GIOChannel * channel,GIOCondition condition,gpointer data)
{
    GError * error=NULL;
    GString * line=g_string_new(NULL);
    
    g_io_channel_read_line_string(channel,line,NULL,&error);
        
    if (error)
    {
        g_clear_error(&error);
        g_string_free(line,TRUE);
        return FALSE;
    }
    
    // Remove leading and trailing white space in place
    
    g_strstrip(line->str);
    
    // Split it into 4 pieces
    
    gchar ** parts=g_strsplit(line->str," ",4);
    
    if (g_strv_length(parts) != 4)
    {
        g_warning("FAILED TO SPLIT LIRC MESSAGE INTO 4 PARTS");
    }
    else
    {
        tp_context_key_event((TPContext*)data,parts[2]);
    }
    
    g_strfreev(parts);
    
    g_string_free(line,TRUE);
    
    return TRUE;
}

//-----------------------------------------------------------------------------
// Get the FD for lircd from its client library. If it is ok, create an IO
// channel and watch for reads. The channel will leak, but that is OK since
// we will keep it until the app exits.

void start_lirc(TPContext * context)
{
    int fd=lirc_init("trickplay",0); 
    
    if (fd==-1)
    {
        g_warning("FAILED TO INITIALIZE LIRC");
    }
    else
    {
        GIOChannel * channel=g_io_channel_unix_new(fd);
        g_io_add_watch(channel,G_IO_IN,lirc_channel_watch,context);        
        g_info("LISTENING TO LIRC");
    }    
}

//-----------------------------------------------------------------------------

int main(int argc,char * argv[])
{
    tp_init(&argc,&argv);
    
    TPContext * context = tp_context_new();
    
    if (argc>1)
        tp_context_set(context,"app.path",argv[1]);
        
    start_lirc(context);
    
    int result = tp_context_run(context);
    
    tp_context_free(context);
    
    return result;
}
