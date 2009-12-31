
#include "tp/tp.h"

int main(int argc,char * argv[])
{
    tp_init(&argc,&argv);
    
    TPContext * context = tp_context_new();
    
    if (argc>1)
        tp_context_set(context,"app.path",argv[1]);
    
    int result = tp_context_run(context);
    
    tp_context_free(context);
    
    return result;
}
