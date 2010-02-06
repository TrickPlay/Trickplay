#ifndef CONTEXT_H
#define CONTEXT_H

extern "C"
{
    #include "lua.h"
}

#include <map>
#include <string>
#include <set>

#include "glib.h"

#include "trickplay/trickplay.h"
#include "trickplay/mediaplayer.h"

//-----------------------------------------------------------------------------

typedef std::string String;
typedef std::map<String,String> StringMap;
typedef std::set<String> StringSet;

//-----------------------------------------------------------------------------
// Internal configuration keys

#define APP_NAME                "app.name"
#define APP_DESCRIPTION         "app.description"
#define APP_AUTHOR              "app.author"
#define APP_COPYRIGHT           "app.copyright"
#define APP_RELEASE             "app.release"
#define APP_VERSION             "app.version"
#define APP_DATA_PATH           "app.data.path"

#define PROFILE_ID              "profile.id"
#define PROFILE_NAME            "profile.name"

//-----------------------------------------------------------------------------
#define APP_METADATA_FILENAME   "app"
#define APP_TABLE_NAME          "app"
#define APP_FIELD_ID            "id"
#define APP_FIELD_NAME          "name"
#define APP_FIELD_DESCRIPTION   "description"
#define APP_FIELD_AUTHOR        "author"
#define APP_FIELD_COPYRIGHT     "copyright"
#define APP_FIELD_RELEASE       "release"
#define APP_FIELD_VERSION       "version"
//-----------------------------------------------------------------------------
// Default values

#define TP_SYSTEM_LANGUAGE_DEFAULT      "en"
#define TP_SYSTEM_COUNTRY_DEFAULT       "US"
#define TP_SYSTEM_NAME_DEFAULT          "Desktop"
#define TP_SYSTEM_VERSION_DEFAULT       "0.0.0"
#define TP_SCAN_APP_SOURCES_DEFAULT     false
#define TP_CONFIG_FROM_ENV_DEFAULT      true
#define TP_CONFIG_FROM_FILE_DEFAULT     "trickplay.cfg"
#define TP_CONSOLE_ENABLED_DEFAULT      true
#define TP_TELNET_CONSOLE_PORT_DEFAULT  8008
#define TP_CONTROLLERS_ENABLED_DEFAULT  false
#define TP_CONTROLLERS_PORT_DEFAULT     0
#define TP_SCREEN_WIDTH_DEFAULT         960
#define TP_SCREEN_HEIGHT_DEFAULT        540

//-----------------------------------------------------------------------------
// Forward declarations

class SystemDatabase;
class Controllers;

//-----------------------------------------------------------------------------

struct TPContext
{
public:
    
    TPContext();
    ~TPContext();
    
    //.........................................................................
    // Getting and setting context configuration variables
    
    void set(const char * key,const char * value);
    void set(const char * key,int value);
    void set(const char * key,const String & value);
    
    const char * get(const char * key,const char * def = NULL);
    bool get_bool(const char * key,bool def=false);
    int get_int(const char * key,int def=0);
        
    //.........................................................................
    // Running and quitting the context
    
    int run();    
    void quit();
    
    //.........................................................................
    // Console command handlers
    
    void add_console_command_handler(const char * command,TPConsoleCommandHandler handler,void * data);
    
    //.........................................................................
    // Log handler. This is what prints the messages in the outside world.
    
    void set_log_handler(TPLogHandler handler,void * data);
    
    // Our standard log handler if the one above is not set
    
    static void log_handler(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message,gpointer self);
    
    //.........................................................................
    // Notification handlers
    
    void add_notification_handler(const char * subject,TPNotificationHandler handler,void * data);

    //.........................................................................
    // Request handlers
    
    void set_request_handler(const char * subject,TPRequestHandler handler,void *data);
    
    //.........................................................................
    // Output handlers. They get everything before it is printed - so we can
    // support multiple consoles
    
    typedef void (*OutputHandler)(const gchar * output,gpointer data);
    void add_output_handler(OutputHandler handler,gpointer data);
    void remove_output_handler(OutputHandler handler,gpointer data);
    
    //.........................................................................
    // Media player constructor
    
    void set_media_player_constructor(TPMediaPlayerConstructor constructor);
    
    TPMediaPlayerConstructor get_media_player_constructor() const;
    
    //.........................................................................
    // Get the context from Lua
    
    static TPContext * get_from_lua(lua_State * L);
        
    //.........................................................................
    // Processes paths to ensure they are either URIs or valid paths within the
    // app bundle. Also checks for links and handles custom schemes such as
    // 'localized:'
    //
    // May return NULL if the path is invalid.
    //
    // CALLER HAS TO FREE RESULT
 
    char * normalize_app_path(const gchar * path_or_uri,bool * is_uri=NULL,const StringSet & additional_uri_schemes=StringSet());
    
    //.........................................................................
    // Sends a notification to the outside world
    
    void notify(const char * subject);
    
    //.........................................................................
    // Sends a request to the outside world
    
    int request(const char * subject);
    
    //.........................................................................

    inline bool running() const { return is_running; }
    
    //.........................................................................
    // The system database - only valid while an app is running
    
    SystemDatabase * get_db() const;
    
    //.........................................................................
    // The controllers system
    
    Controllers * get_controllers() const;
    
    //.........................................................................
    // Experimental - injects a key (by name) into Clutter
    // TODO
    
    void key_event(const char * key);
    
    //.........................................................................
    // Switches profiles and handles all the associated notifications
    
    bool profile_switch(int id);
    
    //.........................................................................
    // Structure to hold app metadata
    
    struct AppMetadata
    {
        AppMetadata() : release(0) {}
        
        String path;
        String id;
        String name;
        int release;
        String version;
        String description;
        String author;
        String copyright;
    };
    
protected:
    
    //.........................................................................
    // Loads configuration variables from the environment or a file
    
    void load_external_configuration();
    
    //.........................................................................
    // Ensures that all the required config variables are set and sets defaults
    // if they are not.
    
    void validate_configuration();
    
    //.........................................................................
    // Scans application source directories for apps and adds them to the
    // database.
    
    void scan_app_sources();
    
    //.........................................................................
    // Loads metadata for an app
    
    bool load_app_metadata(const char * app_path,AppMetadata & md);
    
    //.........................................................................
    // Ensures that everything is ready to run the app. Creates its data
    // directory, etc.
    
    bool prepare_app(const AppMetadata & md);
    
    //.........................................................................
    // Loads the app and dips into the clutter main loop
    
    int load_app();
    
    //.........................................................................
    // Returns the file name for the current's app coookie jar, taking into
    // account the current profile.
    
    String get_cookie_jar_file_name();
    
    //.........................................................................
    // A command handler to handle basic commands
    
    static int console_command_handler(const char * command,const char * parameters,void * self);
       
    //.........................................................................
    // Formats a log line
    
    static gchar * format_log_line(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message);
    
private:
    
    TPContext(const TPContext&);

    bool                        is_running;
    
    StringMap                   config;
    
    SystemDatabase *            sysdb;
    
    Controllers *               controllers;
    
    TPMediaPlayerConstructor    mp_constructor;
    
    TPLogHandler                external_log_handler;
    void *                      external_log_handler_data;

    typedef std::pair<TPConsoleCommandHandler,void*>            ConsoleCommandHandlerClosure;
    typedef std::multimap<String,ConsoleCommandHandlerClosure>  ConsoleCommandHandlerMultiMap;
    
    ConsoleCommandHandlerMultiMap                               console_command_handlers;
    
    typedef std::pair<TPNotificationHandler,void*>              NotificationHandlerClosure;
    typedef std::multimap<String,NotificationHandlerClosure>    NotificationHandlerMultiMap;
    
    NotificationHandlerMultiMap                                 notification_handlers;
    
    typedef std::pair<TPRequestHandler,void*>                   RequestHandlerClosure;
    typedef std::map<String,RequestHandlerClosure>              RequestHandlerMap;
    
    RequestHandlerMap                                           request_handlers;
    
    typedef std::pair<OutputHandler,void*>                      OutputHandlerClosure;
    typedef std::set<OutputHandlerClosure>                      OutputHandlerSet;
    
    OutputHandlerSet                                            output_handlers;
    
    typedef std::map<String,guint>                              KeyMap;
    
    KeyMap                                                      key_map;
};




#endif