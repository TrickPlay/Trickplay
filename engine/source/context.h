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

#include "tp/tp.h"

//-----------------------------------------------------------------------------

typedef std::string String;
typedef std::map<String,String> StringMap;

//-----------------------------------------------------------------------------
// Internal configuration keys

#define APP_ID                  "app.id"
#define APP_NAME                "app.name"
#define APP_DESCRIPTION         "app.description"
#define APP_AUTHOR              "app.author"
#define APP_COPYRIGHT           "app.copyright"
#define APP_RELEASE             "app.release"
#define APP_VERSION             "app.version"
#define APP_DATA_PATH           "app.data.path"
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

class SystemDatabase;

struct TPContext
{
public:
    
    TPContext();
    ~TPContext();
    
    void set(const char * key,const char * value);
    void set(const char * key,int value);
    
    const char * get(const char * key,const char * def = NULL);
    bool get_bool(const char * key,bool def=false);
    int get_int(const char * key,int def=0);
    
    int run();    
    void quit();
    
    void add_console_command_handler(const char * command,TPConsoleCommandHandler handler,void * data);
    void set_log_handler(TPLogHandler handler,void * data);
    void add_notification_handler(const char * subject,TPNotificationHandler handler,void * data);
    void set_request_handler(const char * subject,TPRequestHandler handler,void *data);
    
    typedef void (*OutputHandler)(const gchar * output,gpointer data);
    void add_output_handler(OutputHandler handler,gpointer data);
    void remove_output_handler(OutputHandler handler,gpointer data);
    
    static TPContext * get_from_lua(lua_State * L);
        
    String normalize_app_path(const gchar * path_or_uri,bool * is_uri=NULL);
    
    void notify(const char * subject);
    
    int request(const char * subject);
    
    static void log_handler(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message,gpointer self);
    
    inline bool running() const { return is_running; }
    
protected:
    
    void validate_configuration();
    
    bool load_app_metadata(const char * app_path);
    
    bool prepare_app();
    
    int load_app();
    
    static int console_command_handler(const char * command,const char * parameters,void * self);
       
    static gchar * format_log_line(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message);
    
private:
    
    TPContext(const TPContext&);

    bool                    is_running;
    
    StringMap               config;
    
    SystemDatabase *        sysdb;
    
    TPLogHandler            external_log_handler;
    void *                  external_log_handler_data;

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
};




#endif