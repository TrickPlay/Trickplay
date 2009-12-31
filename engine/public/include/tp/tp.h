#ifndef TP_H
#define TP_H

#ifdef __cplusplus
extern "C" {
#endif 

//.............................................................................
// One-time initialization
// NOTE: You may pass NULL for argc and argv

void            tp_init(
    
                    int * argc,
                    char *** argv);

//.............................................................................
// Opaque type for a context

typedef         struct TPContext
                    
                    TPContext;

//.............................................................................
// Create a new context
                
TPContext *     tp_context_new();

//.............................................................................
// Free a context

void            tp_context_free(
                    
                    TPContext * context);

//.............................................................................
// Set a context configuration value
                
void            tp_context_set(
                    
                    TPContext * context,
                    const char * key,
                    const char * value);

//.............................................................................
// Get a context configuration value.
// The result should be copied if you wish to keep it

const char *    tp_context_get(
    
                    TPContext * context,
                    const char * key);

//.............................................................................
// Set a command handler to respond to commands typed at the console. The
// handler should return non-zero if it handled the command.
//
// NOTE: parameters will be NULL if the command has no parameters
// NOTE: the console is disabled in production builds, so this call has no
//       effect in that case

typedef         int (*TPConsoleCommandHandler)(
                    
                    const char * command,
                    const char * parameters,
                    void * data);

void            tp_context_set_console_command_handler(
    
                    TPContext * context,
                    TPConsoleCommandHandler handler,
                    void * data);

//.............................................................................
// Set a handler for log messages.

typedef         void (*TPLogHandler)(
    
                    unsigned int level,
                    const char * domain,
                    const char * message,
                    void * data);

void            tp_context_set_log_handler(
    
                    TPContext * context,
                    TPLogHandler handler,
                    void * data);

//.............................................................................
// Run the context - only returns when it is finished
                
int             tp_context_run(
    
                    TPContext * context);

//.............................................................................
// Terminate the context from another thread
// Run will return after this is called
                
void            tp_context_quit(
    
                    TPContext * context);

//.............................................................................

#ifdef __cplusplus
}
#endif 

#endif