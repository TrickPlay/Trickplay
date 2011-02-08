#ifndef _TRICKPLAY_H
#define _TRICKPLAY_H
/*-----------------------------------------------------------------------------
    Symbol visibility
*/

#if defined _WIN32 || defined __CYGWIN__
  #define TP_API_IMPORT __declspec(dllimport)
  #define TP_API_EXPORT __declspec(dllexport)
  #define TP_API_LOCAL
#else
  #if __GNUC__ >= 4
    #define TP_API_IMPORT __attribute__ ((visibility("default")))
    #define TP_API_EXPORT __attribute__ ((visibility("default")))
    #define TP_API_LOCAL  __attribute__ ((visibility("hidden")))
  #else
    #define TP_API_IMPORT 
    #define TP_API_EXPORT 
    #define TP_API_LOCAL  
  #endif
#endif

/*-----------------------------------------------------------------------------
    C
*/

#ifdef __cplusplus
extern "C" {
#endif 

/*-----------------------------------------------------------------------------
    TrickPlay version
*/

#define TP_MAJOR_VERSION    1
#define TP_MINOR_VERSION    16
#define TP_PATCH_VERSION    1

/*-----------------------------------------------------------------------------
    File: TrickPlay Context
    
    A TrickPlay Context provides the means for your application to initialize,
    configure and drive TrickPlay. It also lets you receive notifications of
    important events. 
*/

/*-----------------------------------------------------------------------------
    Type: TPContext
    
    An opaque type that represents a TrickPlay context. It is returned
    by <tp_context_new> and destroyed by <tp_context_free>. 
*/

typedef struct TPContext TPContext;

/*-----------------------------------------------------------------------------
    Constants: Configuration Keys
    
    Context configuration keys to be used with <tp_context_set> and <tp_context_get>.
    
    TP_APP_SOURCES -        List of paths to applications. This is a semicolon (";")
                            delimited list of paths where applications can be sourced.
                            Defaults to "apps" (in the current working directory).
                        
    TP_SCAN_APP_SOURCES -   Scan app sources. If set to "TRUE" TrickPlay will scan the
                            paths listed in app sources for apps. If you attempt to
                            launch an app using an id (instead of a path) and the
                            TrickPlay database does not have any apps, TrickPlay will
                            scan all of the app sources regardless of the value of
                            this variable.
                            Defaults to "FALSE".
                            
    TP_APP_ID -             Initial app id. The id of the first application to launch.
                            Instead of specifying the id, you can set <TP_APP_PATH> to
                            open an application directly from a path. If you do set
                            <TP_APP_ID>, you should also set <TP_APP_SOURCES> so that
                            TrickPlay can find the app given its id.
                            Defaults to NULL.
                            
    TP_APP_PATH -           Path to the initial application. This is an alternative
                            way to specify the initial application, mostly for testing
                            purposes. In most cases, you should set <TP_APP_ID>.
                            Defaults to the current working directory.
                            
    TP_APP_ALLOWED -        Lets you configure the restricted objects that are available
                            to each app. This is a string of the form
                            <app id>=<object>,<object>:<app id>=<object>,<object>.
                            Each <object> is granted to each <app id> listed.
                            Defaults to "com.trickplay.launcher=apps:com.trickplay.store=apps".

    TP_SYSTEM_LANGUAGE -    System language. This must be a two character, lower case
                            ISO-639-1 code. See <http://www.loc.gov/standards/iso639-2/php/code_list.php>.
                            Defaults to "en".
                            
    TP_SYSTEM_COUNTRY -     System country. This must be a two character, upper case
                            ISO-3166-1-alpha-2 code. See <http://www.iso.org/iso/country_codes/iso_3166_code_lists/english_country_names_and_code_elements.htm>.
                            Defaults to "US".
                            
    TP_SYSTEM_NAME -        System name. This should be a short and simple name for
                            the platform with no special characters, such as "Acme TV".
                            Defaults to "Desktop".
                            
    TP_SYSTEM_VERSION -     System version. This should be a version string that
                            identifies this particular version of the system, such
                            as "1.3" or "2.0.1".
                            Defaults to "0.0.0".
                            
    TP_SYSTEM_SN -          System serial number. This should be the serial number of the
                            system and should never change.
                            Defaults to "SN".

    TP_DATA_PATH -          Data path. This must be a path where TrickPlay can create
                            files and directories. TrickPlay will create a sub-directory
                            called "trickplay" and keep all of its data there.
                            Defaults to a system temporary directory.
                            
    TP_SCREEN_WIDTH -       Screen width. Set this to the maximum width of the
                            graphics plane.
                            Defaults to "960".
                      
    TP_SCREEN_WIDTH -       Screen height. Set this to the maximum height of the
                            graphics plane. Defaults to "540".
                            
    TP_CONFIG_FROM_ENV -    Environment configuration. If set to "1", TrickPlay
                            will read additional configuration variables from the
                            environment. All environment variables that begin with
                            "TP_" will be read and the resulting variables
                            will be set in the context.
                            For example, the environment variable "TP_app_path"
                            will be read and set as "app_path". Defaults to "1".

    TP_CONFIG_FROM_FILE -   Configuration file. If set to the path of an existing
                            file, TrickPlay will read configuration variables from
                            the file. This file is a Lua file and has access to
                            TrickPlay's command line options.
                            Defaults to ".trickplay" in the current working directory
                            or the user's home directory.
                            
    TP_CONSOLE_ENABLED -    Console enabled. Set to "1" if you want to enable the
                            input console, or "0" otherwise. In production builds,
                            the console is always disabled.
                            Defaults to "1".
                            
    TP_TELNET_CONSOLE_PORT - Telnet console port. Set to a port for the telnet console.
                            If set to "0", the telnet console will be disabled. In
                            production builds, the telnet console is always disabled.
                            Defaults to "7777".
                            
    TP_CONTROLLERS_ENABLED - Controllers enabled. Set to "TRUE" if you wish to enable
                            support for remote controllers. This will create a
                            listener and establish an mDNS service for discovery.
                            Defaults to "FALSE".
                            
    TP_CONTROLLERS_PORT -   Controllers port. Set to non-zero to run the controllers
                            listener on a fixed port.
                            Defaults to "0".
                            
    TP_CONTROLLERS_NAME -   Service name for controllers. This is a string that is
                            shown to the user when controllers discover the mDNS
                            service.
                            Defaults to "TrickPlay".
                            
    TP_LOG_DEBUG -          Whether to log DEBUG messages. Set to "0" to prevent
                            DEBUG messages from being logged.
                            Defaults to "1".
                            
    TP_LOG_APP_ONLY -       Whether to log only MESSAGE messages (printed by apps).
                            Defaults to "0".

    TP_FONTS_PATH -         List of paths to directories containing fonts. If not set,
                            TrickPlay will use the systems fonts.  This is a semicolon (";")
                            delimited list of paths where fonts can be sourced.
                            Defaults to NULL.

    TP_DOWNLOADS_PATH -     Path to a directory that TrickPlay will use to download
                            files.
                            Defaults to "<TP_DATA_PATH>/downloads"

    TP_NETWORK_DEBUG -      Whether to show debug information for URL requests. Note
                            that this is always disabled on production builds.
                            Defaults to "0".

    TP_SSL_VERIFY_PEER -    Whether server certificates are verified for SSL connections.
                            Defaults to "1".

    TP_SSL_CA_CERT_FILE -   Path to a file that contains top level certificates for
                            certificate authorities in PEM format.
                            Defaults to empty, which implies use of system certificates.

    TP_LIRC_ENABLED -       Whether TrickPlay attempts to connect to a LIRC daemon.
                            Defaults to "true".

    TP_LIRC_UDS -           Path to the LIRC daemon Unix Doman Socket.
                            Defaults to "/var/run/lirc/lircd".

    TP_LIRC_REPEAT -            Minimum number of milliseconds between button presses. Any
                                presses that arrive within this time are ignored.
                                Defaults to 150.

    TP_MEDIAPLAYER_ENABLED -    Whether the media player is enabled. If set to false, apps
                                will behave as if there is no media player.
                                Defaults to "true".

    TP_IMAGE_DECODER_ENABLED -  Whether the external image decoder is enabled. If set to false,
                                only internal decoders will be used.
                                Defaults to "true".

    TP_RANDOM_SEED -            If set to a non-zero value, this will be the default random
                                seed for all apps and the 'math.randomseed' function will
                                become a no-op.
                                Defaults to 0.

    TP_PLUGINS_PATH -           Path to root directory of TrickPlay plugins.
                                Defaults to "plugins" (in the current working directory).

*/

#define TP_APP_SOURCES                  "app_sources"
#define TP_SCAN_APP_SOURCES             "app_scan"
#define TP_APP_ID                       "app_id"
#define TP_APP_PATH                     "app_path"
#define TP_APP_ALLOWED                  "app_allowed"
#define TP_SYSTEM_LANGUAGE              "system_language"
#define TP_SYSTEM_COUNTRY               "system_country"
#define TP_SYSTEM_NAME                  "system_name"
#define TP_SYSTEM_VERSION               "system_version"
#define TP_SYSTEM_SN                    "system_sn"
#define TP_DATA_PATH                    "data_path"
#define TP_SCREEN_WIDTH                 "screen_width"
#define TP_SCREEN_HEIGHT                "screen_height"
#define TP_CONFIG_FROM_ENV              "config_env"
#define TP_CONFIG_FROM_FILE             "config_file"
#define TP_CONSOLE_ENABLED              "console_enabled"
#define TP_TELNET_CONSOLE_PORT          "console_port"
#define TP_CONTROLLERS_ENABLED          "controllers_enabled"
#define TP_CONTROLLERS_PORT             "controllers_port"
#define TP_CONTROLLERS_NAME             "controllers_name"
#define TP_LOG_DEBUG                    "log_debug"
#define TP_LOG_APP_ONLY                 "log_app_only"
#define TP_FONTS_PATH                   "fonts_path"
#define TP_DOWNLOADS_PATH               "downloads_path"
#define TP_NETWORK_DEBUG                "network_debug"
#define TP_SSL_VERIFY_PEER              "ssl_verifypeer"
#define TP_SSL_CA_CERT_FILE             "ssl_cacertfile"
#define TP_LIRC_ENABLED                 "lirc_enabled"
#define TP_LIRC_UDS                     "lirc_uds"
#define TP_LIRC_REPEAT                  "lirc_repeat"
#define TP_APP_PUSH_ENABLED             "app_push_enabled"
#define TP_APP_PUSH_PORT                "app_push_port"
#define TP_MEDIAPLAYER_ENABLED          "mediaplayer_enabled"
#define TP_IMAGE_DECODER_ENABLED        "image_decoder_enabled"
#define TP_RANDOM_SEED                  "random_seed"
#define TP_PLUGINS_PATH                 "plugins_path"


/*-----------------------------------------------------------------------------
    Constants: Request Subjects
    
    Subjects to be used with <tp_context_set_request_handler>.

    TP_REQUEST_ACQUIRE_NUMERIC_KEYPAD -         The app wishes to use the numeric
                                                keypad to allow the user to input
                                                numbers directly. Return non-zero
                                                if the request can be satisfied.

    TP_REQUEST_ACQUIRE_TRANSPORT_CONTROL_KEYS - The app wishes to use transport
                                                control keys (play,pause,etc...).
                                                Return non-zero if the request
                                                can be satisfied.

    TP_REQUEST_ACQUIRE_KEYBOARD -               The app wishes to use a keyboard
                                                for direct input. If the system does
                                                not have a keyboard or it cannot be
                                                used by the app right now, return zero.
*/

#define TP_REQUEST_ACQUIRE_NUMERIC_KEYPAD               "acquire-numeric-keypad"
#define TP_REQUEST_ACQUIRE_TRANSPORT_CONTROL_KEYS       "acquire-transport-control-keys"
#define TP_REQUEST_ACQUIRE_KEYBOARD                     "acquire-keyboard"
    
/*-----------------------------------------------------------------------------
    Constants: Notification Subjects
    
    These subjects are used with <tp_context_add_notification_handler>.

    TP_NOTIFICATION_APP_LOADING -                       An application is about to be loaded.
    TP_NOTIFICATION_APP_LOAD_FAILED -                   An application failed to load.
    TP_NOTIFICATION_APP_LOADED -                        An application finished loading.
    TP_NOTIFICATION_APP_CLOSING -                       The current application is about to be closed.
    TP_NOTIFICATION_APP_CLOSED -                        The current application is finished.
    TP_NOTIFICATION_PROFILE_CHANGING -                  The current profile is about to change.
    TP_NOTIFICATION_PROFILE_CHANGE -                    Internal notification to get things ready for a profile change.
    TP_NOTIFICATION_PROFILE_CHANGED -                   The current profile changed.
    TP_NOTIFICATION_RELEASE_NUMERIC_KEYPAD -            The app no longer needs to use the numeric keypad.
    TP_NOTIFICATION_RELEASE_TRANSPORT_CONTROL_KEYS -    The app no longer needs the transport control keys.
    TP_NOTIFICATION_RELEASE_KEYBOARD -                  The app no longer needs the keyboard.
*/

#define TP_NOTIFICATION_APP_LOADING                     "app-loading"
#define TP_NOTIFICATION_APP_LOAD_FAILED                 "app-load-failed"
#define TP_NOTIFICATION_APP_LOADED                      "app-loaded"
#define TP_NOTIFICATION_APP_CLOSING                     "app-closing"
#define TP_NOTIFICATION_APP_CLOSED                      "app-closed"
#define TP_NOTIFICATION_PROFILE_CHANGING                "profile-changing"
#define TP_NOTIFICATION_PROFILE_CHANGE                  "profile-change"
#define TP_NOTIFICATION_PROFILE_CHANGED                 "profile-changed"

#define TP_NOTIFICATION_RELEASE_NUMERIC_KEYPAD          "release-numeric-keypad"
#define TP_NOTIFICATION_RELEASE_TRANSPORT_CONTROL_KEYS  "release-transport-control-keys"
#define TP_NOTIFICATION_RELEASE_KEYBOARD                "release-keyboard"


/*-----------------------------------------------------------------------------
    Constants: Run Error Codes
    
    Error codes returned by <tp_context_run>.

    TP_RUN_OK -                         All is well.                      

    TP_RUN_SYSTEM_DATABASE_CORRUPT -    There was a serious problem with the TrickPlay
                                        system database; the only way to correct this
                                        may be to do a factory reset.

    TP_RUN_APP_NOT_FOUND -              An attempt was made to launch an app using its
                                        id, but the id was not found in the system
                                        database. 

    TP_RUN_APP_CORRUPT -                There was a problem loading an app, it may
                                        not have correct metadata or its signature
                                        is invalid. You should not try to load
                                        this same app again.
                                        
    TP_RUN_APP_PREPARE_FAILED -         There was a problem getting things ready to
                                        load the app. This is usually due to serious
                                        errors creating files or databases and the
                                        problem may affect all apps loaded in the
                                        future...a factory reset may be the only
                                        recourse.

    TP_RUN_APP_ERROR -                  There was a problem running the application;
                                        it may have a syntax error or it crashed
                                        during the initial load.
                                        
    TP_RUN_ALREADY_RUNNING -            The context is already running.
*/

#define TP_RUN_OK                       0
#define TP_RUN_SYSTEM_DATABASE_CORRUPT  1
#define TP_RUN_APP_NOT_FOUND            2
#define TP_RUN_APP_CORRUPT              3
#define TP_RUN_APP_PREPARE_FAILED       4
#define TP_RUN_APP_ERROR                5
#define TP_RUN_ALREADY_RUNNING          6
    
/*-----------------------------------------------------------------------------
    Function: tp_init_version
    
    This function performs one-time initialization of TrickPlay. You should only
    call it once.
    
    Although this function accepts TrickPlay header version information as the
    last three parameters, there is a define for *tp_init* that includes those
    parameters automatically, so you should call it like this:
    
    > tp_init(&argc,&argv);    
    
    If there are any errors during a call to this function, TrickPlay will abort,
    since these errors are serious enough that it is unlikely TrickPlay will be
    able to function properly.
    
    Arguments:
    
        argc -  A pointer to the argument count, or NULL.

        argv -  A pointer to the application's arguments or NULL.
*/

    TP_API_EXPORT
    void
    tp_init_version(
                                
        int * argc,
        char *** argv,
        int major_version,
        int minor_version,
        int patch_version);


#define tp_init(argc,argv) \
    tp_init_version(argc,argv,TP_MAJOR_VERSION,TP_MINOR_VERSION,TP_PATCH_VERSION)

/*-----------------------------------------------------------------------------
    Function: tp_context_new
    
    Creates a new context. This function must be called after <tp_init_version>.
    
    Returns:
    
        context -   A pointer to a new <TPContext>.
*/
                
    TP_API_EXPORT
    TPContext *
    tp_context_new(void);

/*-----------------------------------------------------------------------------
    Function: tp_context_set
    
    Set a context configuration value.
    
    Arguments:
    
        context -   A pointer to a TPContext.

        key -       A configuration key.

        value -     The value for the key. Trickplay will make a copy.
*/
                
    TP_API_EXPORT
    void
    tp_context_set(
                    
        TPContext * context,
        const char * key,
        const char * value);

/*-----------------------------------------------------------------------------
    Function: tp_context_set_int
    
    Set a context configuration value.
    
    Arguments:
    
        context -   A pointer to a TPContext.

        key -       A configuration key.

        value -     The value for the key.
*/
                
    TP_API_EXPORT
    void
    tp_context_set_int(
                    
        TPContext * context,
        const char * key,
        int value);

/*-----------------------------------------------------------------------------
    Function: tp_context_get
    
    Get a context configuration value.
    
    Arguments:
    
        context -   A pointer to a TPContext.

        key -       A configuration key.
    
    Returns:
    
        value -     The value of the given key. You should make a copy.
    
        NULL -      If the given key does not exist.
*/    

    TP_API_EXPORT
    const char *
    tp_context_get(
    
        TPContext * context,
        const char * key);

/*-----------------------------------------------------------------------------
    Function: TPRequestHandler
    
    Function prototype for calls to <tp_context_set_request_handler>. To handle
    requests from TrickPlay, you implement a function with this prototype and
    set it to handle requests for a particular request subject.
    
    Arguments:
    
        subject -   A string describing the nature of the request.

        data -      User data passed to <tp_context_set_request_handler>.
    
    Returns:
    
        0 -         If the request is denied.

        other -     If the request is accepted.
*/

    typedef
    int
    (*TPRequestHandler)(
    
        const char * subject,
        void * data);

/*-----------------------------------------------------------------------------
    Function: tp_context_set_request_handler
    
    Set a request handler to respond to TrickPlay requests for a given subject.
    There can only be one request handler for each subject; if you set the same
    one twice, the previous one will be removed.

    Request handlers should return 0 if the request is denied, or non-zero otherwise.
    
    Arguments:
    
        context -   A pointer to a TPContext.

        subject -   A request subject.

        handler -   A <TPRequestHandler> function.

        data -      Opaque user data that is passed to the handler.
*/

    TP_API_EXPORT
    void
    tp_context_set_request_handler(
                    
        TPContext * context,
        const char * subject,
        TPRequestHandler handler,
        void * data);

/*-----------------------------------------------------------------------------
    Function: TPNotificationHandler
    
    Function prototype used in calls to <tp_context_add_notification_handler>.
    To receive TrickPlay notifications, you implement a function with this
    prototype and register it for certain notification subjects.
    
    Arguments:
    
        subject -   A string describing the specific notification.

        data -      Opaque user data passed to <tp_context_add_notification_handler>.
*/    

    typedef
    void
    (*TPNotificationHandler)(
                    
        const char * subject,
        void * data);

/*-----------------------------------------------------------------------------
    Function: tp_context_add_notification_handler
    
    Add a notification handler to receive TrickPlay notifications for a given
    subject.
    
    Arguments:
    
        context -   A pointer to a TPContext.

        subject -   A string describing the notification.

        handler -   A function with the <TPNotificationHandler> prototype.

        data -      A pointer to user data which is passed to the handler.
*/    

    TP_API_EXPORT
    void
    tp_context_add_notification_handler(
    
        TPContext * context,
        const char * subject,
        TPNotificationHandler handler,
        void * data);

/*-----------------------------------------------------------------------------
    Function: TPConsoleCommandHandler
    
    Function prototype used in calls to <tp_context_add_console_command_handler>.
    For debugging and testing purposes, you may register functions that handle
    commands typed at the TrickPlay console (local or Telnet).
    
    Commands always begin with / and the first white space delimits the actual
    command. Anything typed after the command is considered to be parameters.
    
    Arguments:
    
        command -       A string describing the command. It does not include the initial
                        / and will never be NULL.

        parameters -    A string containing everything else typed at the console after
                        the command and up to a new line, or NULL if there are no
                        parameters.

        data -          Opaque user data passed to <tp_context_add_console_command_handler>.
*/

    typedef
    void
    (*TPConsoleCommandHandler)(
                    
        const char * command,
        const char * parameters,
        void * data);

/*-----------------------------------------------------------------------------
    Function: tp_context_add_console_command_handler
    
    Add a command handler to respond to a specific command typed at the console. 
    
    NOTE:
    
    The console is disabled in production builds, so this call has no effect in
    that case.
    
    Arguments:
    
        context -   A pointer to a TPContext.

        command -   The specific command to handle, excluding the initial /.

        handler -   A function with the <TPConsoleCommandHandler> prototype.

        data -      Opaque user data passed to the handler.
*/    

    TP_API_EXPORT
    void
    tp_context_add_console_command_handler(
    
        TPContext * context,
        const char * command,
        TPConsoleCommandHandler handler,
        void * data);

/*-----------------------------------------------------------------------------
    Function: TPLogHandler
    
    Function prototype used in calls to <tp_context_set_log_handler>.
    
    Arguments:
    
        level -     An integer describing the information level of the log message,
                    such as DEBUG, INFO, WARNING, etc.

        domain -    A string describing the message domain.

        message -   The actual log message.

        data -      Opaque user data passed to <tp_context_set_log_handler>.
*/

    typedef
    void
    (*TPLogHandler)(
    
        unsigned int level,
        const char * domain,
        const char * message,
        void * data);

/*-----------------------------------------------------------------------------
    Function: tp_context_set_log_handler
    
    Sets a function to handle logging of messages. If you set a log handler,
    TrickPlay will no longer write messages to stderr.
    Log handlers do not affect the behavior of Telnet consoles.
    
    Arguments:
    
        context -   A pointer to a TPContext.

        handler -   A function with the <TPLogHandler> prototype.

        data -      Opaque user data passed to the handler.
*/    

    TP_API_EXPORT
    void
    tp_context_set_log_handler(
    
        TPContext * context,
        TPLogHandler handler,
        void * data);

/*-----------------------------------------------------------------------------
    Function: tp_context_run
    
    Run the context. This call only returns when TrickPlay exits. You may cause
    it to return early by calling <tp_context_quit> from another thread.
    
    Arguments:
    
        context -   A pointer to a TPContext.
    
    Returns:
    
        0 -         If everything is OK.

        other -     One of the run errors listed above.
*/    
               
    TP_API_EXPORT
    int
    tp_context_run(
    
        TPContext * context);

/*-----------------------------------------------------------------------------
    Function: tp_context_quit
    
    Terminates the context from another thread. This causes <tp_context_run> to
    return.
    
    Arguments:
    
        context -   A pointer to a TPContext.
*/
                
    TP_API_EXPORT
    void
    tp_context_quit(

        TPContext * context);

/*-----------------------------------------------------------------------------
    Function: tp_context_free
    
    Destroys a TPContext.

    Arguments:
    
        context -   A pointer to a TPContext.
*/    

    TP_API_EXPORT
    void
    tp_context_free(
                    
        TPContext * context);

/*-----------------------------------------------------------------------------
*/

#ifdef __cplusplus
}
#endif 

#endif  /* _TRICKPLAY_H */
