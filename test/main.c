
#include "tp.h"

int main(int argc,char * argv[])
{
    tp_init(&argc,&argv);
    
    TPContext * context = tp_context_new();
    
    int result = tp_context_run(context);
    
    tp_context_free(context);
    
    return result;
}
