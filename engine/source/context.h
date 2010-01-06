#ifndef CONTEXT_H
#define CONTEXT_H

extern "C"
{
    #include "lua.h"
}

#include <map>
#include <string>

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
    
    void set_command_handler(TPConsoleCommandHandler handler,void * data);
    void set_log_handler(TPLogHandler handler,void * data);
    void set_notification_handler(TPNotificationHandler handler,void * data);
    void set_request_handler(TPRequestHandler handler,void *data);
    
    static TPContext * get_from_lua(lua_State * L);
    
    inline bool running() const
    {
        return L;
    }
    
    String normalize_app_path(const gchar * path_or_uri,bool * is_uri=NULL);
    
    void notify(const char * subject);
    
    int request(const char * subject);
    
protected:
    
    bool load_app_metadata(const char * app_path);
    
    bool prepare_app();
    
    static int console_command_handler(const char * command,const char * parameters,void * self);
    
    static void log_handler(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message,gpointer self);
    
    void validate_configuration();
    
private:
    
    TPContext(const TPContext&);
    
    StringMap               config;
    lua_State *             L;
    
    TPConsoleCommandHandler external_console_handler;
    void *                  external_console_handler_data;
    
    TPLogHandler            external_log_handler;
    void *                  external_log_handler_data;
    
    TPNotificationHandler   external_notification_handler;
    void *                  external_notification_handler_data;
    
    TPRequestHandler        external_request_handler;
    void *                  external_request_handler_data;
};




#endif