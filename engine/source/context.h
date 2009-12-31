#ifndef CONTEXT_H
#define CONTEXT_H

extern "C"
{
    #include "lua.h"
}

#include <map>
#include <string>

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
    const char * get(const char * key,const char * def = NULL);
    
    int run();    
    void quit();
    
    static TPContext * get_from_lua(lua_State * L);
    
protected:
    
    bool load_app_metadata(const char * app_path);
    
private:
    
    TPContext(const TPContext&);
    
    StringMap   config;
    lua_State * L;
};




#endif