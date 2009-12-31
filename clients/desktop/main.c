
#include <string.h>

#include "tp/tp.h"

//-----------------------------------------------------------------------------
// Example of a console command handler

int console_command_handler(const char * command,const char * parameters,void * data)
{
    if (!strcmp(command,"test"))
    {
        // Do something
        return 1;
    }
    return 0;    
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
    
    int result = tp_context_run(context);
    
    tp_context_free(context);
    
    return result;
}
