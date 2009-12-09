
#include "lb.h"
#include <cstring>

int lb_index(lua_State*L)
{
    if(!lua_getmetatable(L,1))      // get mt for user data
        return 0;
    lua_pushvalue(L,2);             // push the key
    lua_rawget(L,-2);               // get the value for that key from the mt
    if (!lua_isnil(L,-1))           // if it is not nil, return it
    {
        lua_replace(L,-2);          // replace mt with value
        return 1;
    }
    lua_pop(L,1);                   // pop nil
    lua_pushstring(L,"__getters__");// push "_getters_"
    lua_rawget(L,-2);               // get the getters table from the mt
    lua_replace(L,-2);              // replace mt with getters table
    lua_pushvalue(L,2);             // push the key
    lua_rawget(L,-2);               // get the value for that key from the getters table
    lua_replace(L,-2);              // get rid of the getters table
    if(!lua_isnil(L,-1))
    {
        lua_pushvalue(L,1);         // push the user data
        lua_call(L,1,1);            // call the value as a function
    }
    return 1;
}

int lb_newindex(lua_State*L)
{
    if(!lua_getmetatable(L,1))      // get the mt
        return 0;
    lua_pushstring(L,"__setters__");// push "_setters_"
    lua_rawget(L,-2);               // get the setters table from the mt
    lua_replace(L,-2);              // get rid of the metatable
    lua_pushvalue(L,2);             // push the original key
    lua_rawget(L,-2);               // get the setter function for this key
    lua_replace(L,-2);              // get rid of the setters table
    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);               // if the setter function is not found, do nothing
        return 0;
    }
    lua_pushvalue(L,1);             // push the original user data
    lua_pushvalue(L,3);             // push the new value to set
    lua_call(L,2,0);                // call the setter
    return 0;
}

bool lb_copy_table(lua_State*L,int target,int source)
{
    if (lua_isnil(L,source))
        return false;
    bool result(false);
    lua_pushnil(L);
    while(lua_next(L,source))           // pops old key, pushes new key and value
    {
        // If the key is not a string or it is a string that does not start
        // with two underscores, copy it        
        if(!lua_isstring(L,-2)||(lua_isstring(L,-2)&&strncmp(lua_tostring(L,-2),"__",2)))
        {
            lua_pushvalue(L,-2);    // push the key again
            lua_insert(L,-2);       // move the second key before the value
            lua_rawset(L,target);   // pops the second key and the value
            if(!result)
                result = true;
        }
        else
        {
            lua_pop(L,1);           // pop the value
        }
    }
    return result;
}

// Assuming there is a metatable at the top of the stack,
// this function copies the stuff from the source metatable
// into this one

void lb_inherit(lua_State*L,const char*metatable)
{
    int target(lua_gettop(L));
    
    luaL_getmetatable(L,metatable);     // pushes the source metatable
    if(lua_isnil(L,-1))
        luaL_error(L,"Missing %s",metatable);
    int source(lua_gettop(L));
    lb_copy_table(L,target,source);
    
    static const char * subs[2] = { "__getters__" , "__setters__" };
    
    for(int i=0;i<2;++i)
    {
        lua_pushstring(L,subs[i]);
        lua_rawget(L,target);           // get the sub table from the target mt
        bool isnew(lua_isnil(L,-1));
        if(isnew)                       // the target table did not have a sub
        {                               // table with this name, so we create a
            lua_pop(L,1);               // new one
            lua_newtable(L);
        }
        int n(lua_gettop(L));
        lua_pushstring(L,subs[i]);
        lua_rawget(L,source);
        if (lb_copy_table(L,n,lua_gettop(L))&&isnew)
        {
            lua_pushstring(L,subs[i]);
            lua_pushvalue(L,-3);
            lua_rawset(L,target);
        }
        lua_pop(L,2);                   // pop the two sub tables
    }
    lua_pop(L,1);                       // pop the source metatable
}

// Assumes that there is a user data at -2 and a table at -1. It then
// iterates over the table's keys and sets them as properties in the
// user data.

void lb_set_props_from_table(lua_State*L)
{
    luaL_checktype(L,-1,LUA_TTABLE);
    int source_table(lua_gettop(L));
    int udata(source_table-1);
    
    // Get the table of setters
    if (!luaL_getmetafield(L,udata,"__setters__")) 
        return;
    int setters(lua_gettop(L));
    
    lua_pushnil(L);
    while(lua_next(L,source_table))     // pops old key, pushes next key and value
    {
        lua_pushvalue(L,-2);            // push the key again
        lua_rawget(L,setters);          // pops the key, pushes the value of that key in the setters table
        if (lua_isnil(L,-1))
        {
            lua_pop(L,1);
        }
        else
        {
            lua_pushvalue(L,udata);     // push the original udata
            lua_pushvalue(L,-3);        // push the value from the source table
            lua_call(L,2,0);            // pops the setter function, the udata and the value
        }
        lua_pop(L,1);                   // pop the value pushed by lua_next
    }
    lua_pop(L,1);                       // pop the setters table
}
