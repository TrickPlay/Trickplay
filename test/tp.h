#ifndef TP_H
#define TP_H

extern "C"
{
    
typedef struct TPContext TPContext;

                // One-time initialization, will return 0 if everything is OK

int             tp_init(int * argc,char *** argv);

                // Create a new context
                
TPContext *     tp_context_new();

                // Free a context

void            tp_context_free(TPContext * context);

                // Set a context configuration value
                
void            tp_context_set(TPContext * context,const char * key,const char * value);

                // Get a context configuration value.
                // The result should be copied if you wish to keep it

const char *    tp_context_get(TPContext * context,const char * key);

                // Run the context - only returns when it is finished
                
int             tp_context_run(TPContext * context);

                // Terminate the context from another thread
                // Run will return after this is called
                
void            tp_context_quit(TPContext * context);

}

#endif