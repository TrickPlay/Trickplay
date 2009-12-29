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

struct TPContext
{
public:
    
    TPContext();
    ~TPContext();
    
    void set(const char * key,const char * value);
    const char * get(const char * key);
    
    int run();    
    void quit();
    
    static TPContext * get_from_lua(lua_State * L);
    
private:
    
    TPContext(const TPContext&);
    
    StringMap config;
    lua_State * L;
};




#endif