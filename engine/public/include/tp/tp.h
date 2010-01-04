#ifndef TP_H
#define TP_H

#ifdef __cplusplus
extern "C" {
#endif 

//-----------------------------------------------------------------------------
// One-time initialization
// NOTE: You may pass NULL for argc and argv

void            tp_init(
    
                    int * argc,
                    char *** argv);

//-----------------------------------------------------------------------------
// Opaque type for a context

typedef         struct TPContext
                    
                    TPContext;

//-----------------------------------------------------------------------------
// Create a new context
                
TPContext *     tp_context_new();

//-----------------------------------------------------------------------------
// Context configuration keys to be used with tp_context_set and tp_context_get

    // Path to an application
    // Defaults to the current working directory

    #define TP_APP_PATH             "app.path"

    // System language
    // This must be a two character, lower case ISO-639-1 code
    // See http://www.loc.gov/standards/iso639-2/php/code_list.php
    // Defaults to "en"
    
    #define TP_SYSTEM_LANGUAGE      "system.language"
    
    // System country
    // This must be a two character, upper case ISO-3166-1-alpha-2 code
    // See http://www.iso.org/iso/country_codes/iso_3166_code_lists/english_country_names_and_code_elements.htm
    // Defaults to "US"
    
    #define TP_SYSTEM_COUNTRY       "system.country"
    
    // Console enabled
    // Set to "1" if you want to enable the input console, or "0" otherwise
    // Defaults to "1"
    
    #define TP_CONSOLE_ENABLED      "console.enabled"


//-----------------------------------------------------------------------------
// Set a context configuration value
                
void            tp_context_set(
                    
                    TPContext * context,
                    const char * key,
                    const char * value);

//-----------------------------------------------------------------------------
// Get a context configuration value.
// The result should be copied if you wish to keep it

const char *    tp_context_get(
    
                    TPContext * context,
                    const char * key);

//-----------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------
// Run the context - only returns when it is finished
                
int             tp_context_run(
    
                    TPContext * context);

//-----------------------------------------------------------------------------
// Terminate the context from another thread
// Run will return after this is called
                
void            tp_context_quit(
    
                    TPContext * context);

//-----------------------------------------------------------------------------
// Free a context

void            tp_context_free(
                    
                    TPContext * context);

//-----------------------------------------------------------------------------

#ifdef __cplusplus
}
#endif 

#endif