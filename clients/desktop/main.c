
#include <string.h>
#include <stdio.h>

#include "tp/tp.h"

//-----------------------------------------------------------------------------
// Example of a console command handler. It will be invoked when you type /test
// at the console.

void test_console_command_handler(const char * command,const char * parameters,void * data)
{
    printf("This is the test command\n");
}

//-----------------------------------------------------------------------------
// Example notification handler

void app_notification_handler(const char * subject,void * data)
{
    printf("Got app notification '%s'\n",subject);
}

//-----------------------------------------------------------------------------
// Example request handler

int keyboard_request_handler(const char * subject,void * data)
{
    printf("Got request '%s'\n",subject);
    
    // Grant the request
    return 1;
}
//-----------------------------------------------------------------------------

int main(int argc,char * argv[])
{
    tp_init(&argc,&argv);
    
    TPContext * context = tp_context_new();
    
    if (argc>1)
        tp_context_set(context,"app.path",argv[1]);
    
    // This is completely optional
    
    tp_context_add_console_command_handler(context,"test",test_console_command_handler,0);
    
    tp_context_add_notification_handler(context,TP_NOTIFICATION_APP_LOADING,app_notification_handler,0);
    tp_context_add_notification_handler(context,TP_NOTIFICATION_APP_LOAD_FAILED,app_notification_handler,0);
    tp_context_add_notification_handler(context,TP_NOTIFICATION_APP_LOADED,app_notification_handler,0);
    tp_context_add_notification_handler(context,TP_NOTIFICATION_APP_CLOSING,app_notification_handler,0);
    tp_context_add_notification_handler(context,TP_NOTIFICATION_APP_CLOSED,app_notification_handler,0);
    
    tp_context_set_request_handler(context,TP_REQUEST_ACQUIRE_KEYBOARD,keyboard_request_handler,0);
    
    int result = tp_context_run(context);
    
    tp_context_free(context);
    
    return result;
}
