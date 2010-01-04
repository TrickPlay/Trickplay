
#include <string.h>
#include <stdio.h>

#include "tp/tp.h"

//-----------------------------------------------------------------------------
// Example of a console command handler

int console_command_handler(const char * command,const char * parameters,void * data)
{
    if (!strcmp(command,"test"))
    {
        printf("this is the test command\n");
        return 1;
    }
    return 0;    
}

//-----------------------------------------------------------------------------
// Example of a request handler

int request_handler(const char * subject,void * data)
{
    printf("got request for '%s'\n",subject);
    return 1;
}

//-----------------------------------------------------------------------------
// Notification handler

void notification_handler(const char * subject,void * data)
{
    printf("got notification for '%s'\n",subject);
}

//-----------------------------------------------------------------------------

int main(int argc,char * argv[])
{
    tp_init(&argc,&argv);
    
    TPContext * context = tp_context_new();
    
    if (argc>1)
        tp_context_set(context,"app.path",argv[1]);
    
    // This is completely optional
    
    tp_context_set_console_command_handler(context,console_command_handler,0);
    
    tp_context_set_request_handler(context,request_handler,0);
    
    tp_context_set_notification_handler(context,notification_handler,0);
    
    int result = tp_context_run(context);
    
    tp_context_free(context);
    
    return result;
}
