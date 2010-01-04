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
// Configuration variable names

#define APP_PATH                "app.path"
#define APP_ID                  "app.id"
#define APP_NAME                "app.name"
#define APP_DESCRIPTION         "app.description"
#define APP_AUTHOR              "app.author"
#define APP_COPYRIGHT           "app.copyright"
#define APP_RELEASE             "app.release"
#define APP_VERSION             "app.version"

#define SYSTEM_LANGUAGE         "system.language"   // ISO-639-2 http://www.loc.gov/standards/iso639-2/php/code_list.php
#define SYSTEM_COUNTRY          "system.country"    // ISO-3166-1-alpha-2 http://www.iso.org/iso/country_codes/iso_3166_code_lists/english_country_names_and_code_elements.htm


#define CONSOLE_ENABLED         "console.enabled"
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
    
    int run();    
    void quit();
    
    void set_command_handler(TPConsoleCommandHandler handler,void * data);
    void set_log_handler(TPLogHandler handler,void * data);
    
    static TPContext * get_from_lua(lua_State * L);
    
    inline bool running() const
    {
        return L;
    }
    
    String normalize_app_path(const gchar * path_or_uri,bool * is_uri=NULL);
    
protected:
    
    bool load_app_metadata(const char * app_path);
    
    static int console_command_handler(const char * command,const char * parameters,void * self);
    
    static void log_handler(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message,gpointer self);
    
private:
    
    TPContext(const TPContext&);
    
    StringMap               config;
    lua_State *             L;
    
    TPConsoleCommandHandler external_console_handler;
    void *                  external_console_handler_data;
    
    TPLogHandler            external_log_handler;
    void *                  external_log_handler_data;
};




#endif