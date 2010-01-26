#ifndef TP_H
#define TP_H

#ifdef __cplusplus
extern "C" {
#endif 

//-----------------------------------------------------------------------------

#define TP_MAJOR_VERSION    0
#define TP_MINOR_VERSION    0
#define TP_PATCH_VERSION    1

//-----------------------------------------------------------------------------
// One-time initialization
// NOTE: You may pass NULL for argc and argv

void            tp_init_version(
    
                    int * argc,
                    char *** argv,
                    int major_version,
                    int minor_version,
                    int patch_version);

#define tp_init(argc,argv) tp_init_version(argc,argv,TP_MAJOR_VERSION,TP_MINOR_VERSION,TP_PATCH_VERSION)

//-----------------------------------------------------------------------------
// Opaque type for a context

typedef         struct TPContext
                    
                    TPContext;

//-----------------------------------------------------------------------------
// Create a new context
                
TPContext *     tp_context_new();

//-----------------------------------------------------------------------------
// Context configuration keys to be used with tp_context_set and tp_context_get


// List of paths to applications
// This is a semicolon (";") delimited list of paths where applications can be
// sourced from.
// Defaults to "apps" (in the current working directory)

#define TP_APP_SOURCES          "app.sources"


// Scan app sources
// If set to "1" TrickPlay will scan the paths listed in app sources for
// apps. If you attempt to launch an app using an id (instead of a path)
// and the TrickPlay database does not have any apps, TrickPlay will scan
// all of the app sources regardless of the value of this variable.
// Defaults to "0"

#define TP_SCAN_APP_SOURCES     "app.scan"


// App id
// The id of the first application to launch. Instead of specifying the id, you
// can set TP_APP_PATH to open an application directly from a path. If you do
// set TP_APP_ID, you should also set TP_APP_SOURCES so that TrickPlay can
// find the app given its id.
// Defaults to NULL

#define TP_APP_ID               "app.id"


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


// System name
// This should be a short and simple name for the platform with no special
// characters, such as "AcmeTV"
// Defaults to "Desktop"

#define TP_SYSTEM_NAME          "system.name"


// System version
// This should be a version string that identifies this particular version of the
// system, such as "1.3" or "2.0.1"
// Defaults to "0.0.0"

#define TP_SYSTEM_VERSION       "system.version"


// Data path
// This must be a path where TrickPlay can create files and directories. TrickPlay
// will create a subdirectory called "trickplay" and keep all of its data there.
// Defaults to a system temporary directory 

#define TP_DATA_PATH            "data.path"


// Environment configuration
// If set to "1", TrickPlay will read additional configuration variables
// from the environment. All environment variables that begin with "TP_" will
// be read, all underscores will be changed to "." and the resulting variables
// will be set in the context. For example, the environment variable
// "TP_app_path" will be read and set as "app.path"
// Defaults to "1"

#define TP_CONFIG_FROM_ENV      "config.env"


// File configuration
// If set to the path of an existing file, TrickPlay will read configuration
// variables from the file. The file should have one entry per line, with the
// configuration variable followed by "=" and its value. Lines that start with
// "#" are ignored. For example: app.path=/foo/bar
// Defaults to "trickplay.cfg" (in the current working directory)

#define TP_CONFIG_FROM_FILE     "config.file"


// Console enabled
// Set to "1" if you want to enable the input console, or "0" otherwise
// Defaults to "1"

#define TP_CONSOLE_ENABLED      "console.enabled"


// Telnet console port
// Set to a port for the telnet console. If set to "0", the telnet console
// will be disabled.
// Defaults to "8008"

#define TP_TELNET_CONSOLE_PORT  "console.port"


// Controllers enabled
// Set to "1" if you wish to enable support for remote controllers - this will
// create a listener and establish an mDNS service for discovery.
// Defaults to "0"

#define TP_CONTROLLERS_ENABLED  "controllers.enabled"


// Controllers port
// Set to non-zero to run the controllers listener on a fixed port.
// Defaults to "0"

#define TP_CONTROLLERS_PORT     "controllers.port"



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
// Request subjects 

// The app wishes to use the numeric keypad to allow the user to input
// numbers directly. Return non-zero if the request can be satisfied.
    
#define TP_REQUEST_ACQUIRE_NUMERIC_KEYPAD               "acquire-numeric-keypad"


// The app wishes to use transport control keys (play,pause,etc...)
// Return non-zero if the request can be satisfied

#define TP_REQUEST_ACQUIRE_TRANSPORT_CONTROL_KEYS       "acquire-transport-control-keys"


// The app wishes to use a keyboard for direct input. If the system does
// not have a keyboard or it cannot be used by the app right now, return zero

#define TP_REQUEST_ACQUIRE_KEYBOARD                     "acquire-keyboard"
    
//-----------------------------------------------------------------------------
// Set a request handler to respond to TrickPlay requests for a given subject.
// There can only be one request handler for each subject; if you set the same
// one twice, the previous one will be removed.
//
// Request handlers should return 0 if the request is denied, or non-zero
// otherwise.

typedef         int (*TPRequestHandler)(
    
                    const char * subject,
                    void * data);

void            tp_context_set_request_handler(
                    
                    TPContext * context,
                    const char * subject,
                    TPRequestHandler handler,
                    void * data);

//-----------------------------------------------------------------------------
// Notification subjects 


// An application is about to be loaded

#define TP_NOTIFICATION_APP_LOADING                     "app-loading"


// An application failed to load

#define TP_NOTIFICATION_APP_LOAD_FAILED                 "app-load-failed"


// An application finished loading

#define TP_NOTIFICATION_APP_LOADED                      "app-loaded"


// The current application is about to be closed

#define TP_NOTIFICATION_APP_CLOSING                     "app-closing"


// The current application is finished

#define TP_NOTIFICATION_APP_CLOSED                      "app-closed"


// The current profile is about to change

#define TP_NOTIFICATION_PROFILE_CHANGING                "profile-changing"


// Internal notification to get things ready for the profile change

#define TP_NOTIFICATION_PROFILE_CHANGE                  "profile-change"


// The current profile changed

#define TP_NOTIFICATION_PROFILE_CHANGED                 "profile-changed"


// The app no longer needs to use the numeric keypad

#define TP_NOTIFICATION_RELEASE_NUMERIC_KEYPAD          "release-numeric-keypad"


// The app no longer needs the transport control keys

#define TP_NOTIFICATION_RELEASE_TRANSPORT_CONTROL_KEYS  "release-transport-control-keys"


// The app no longer needs the keyboard

#define TP_NOTIFICATION_RELEASE_KEYBOARD                "release-keyboard"
    
//-----------------------------------------------------------------------------
// Add a notification handler to receive TrickPlay notifications for a given
// subject.

typedef         void (*TPNotificationHandler)(
                    
                    const char * subject,
                    void * data);

void            tp_context_add_notification_handler(
    
                    TPContext * context,
                    const char * subject,
                    TPNotificationHandler handler,
                    void * data);

//-----------------------------------------------------------------------------
// Add a command handler to respond to a specific command typed at the console. 
//
// NOTE: parameters will be NULL if the command has no parameters
// NOTE: the console is disabled in production builds, so this call has no
//       effect in that case

typedef         void (*TPConsoleCommandHandler)(
                    
                    const char * command,
                    const char * parameters,
                    void * data);

void            tp_context_add_console_command_handler(
    
                    TPContext * context,
                    const char * command,
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

// Error codes for tp_context_run

#define TP_RUN_OK                       0

// There was a serious problem with the TrickPlay system database - the only
// way to correct this may be to do a factory reset

#define TP_RUN_SYSTEM_DATABASE_CORRUPT  1


// An attempt was made to launch an app using its id, but the id was not
// found in the system database. 

#define TP_RUN_APP_NOT_FOUND            2


// There was a problem loading an app, it may not have correct metadata or its
// signature is invalid. You should not try to load this same app again.

#define TP_RUN_APP_CORRUPT              3


// There was a problem getting things ready to load the app. This is usually due
// to serious errors creating files or databases and the problem may affect
// all apps loaded in the future...a factory reset may be the only recourse.

#define TP_RUN_APP_PREPARE_FAILED       4


// There was a problem running the application - it may have a syntax error or
// it crashed during the initial load.

#define TP_RUN_APP_ERROR                5


// The context is already running

#define TP_RUN_ALREADY_RUNNING          6

//-----------------------------------------------------------------------------
// Experimental

void            tp_context_key_event(
    
                    TPContext * context,
                    const char * key);

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