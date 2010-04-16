
#include "lb.h"
#include "glib.h"
#include "string.h"

// Assuming user data is at -1

int lb_get_callback(lua_State*L,void*self,const char*name,int metatable_on_top)
{
    LSG;
    
    if(metatable_on_top)
    {
        // the metatable is at 1
        lua_pushstring(L,"__callbacks__");
        lua_rawget(L,-2);
        if (lua_isnil(L,-1))
            return LSG_END(1);
    }
    else
    {
        if(!luaL_getmetafield(L,-1,"__callbacks__"))
        {
            lua_pushnil(L);
            return LSG_END(1);
        }
    }

    // udata ... callbacks table
    
    lua_pushlightuserdata(L,self);
    lua_rawget(L,-2);
    lua_remove(L,-2);
    
    if(lua_isnil(L,-1))
        return LSG_END(1);
    
    lua_pushstring(L,name);
    lua_rawget(L,-2);
    lua_remove(L,-2);
    
    if (lua_isnil(L,-1))
        return LSG_END(1);
    
    if (metatable_on_top)
    {
        lua_rawgeti(L,-1,2);  // push the callback
        lua_rawgeti(L,-2,1);  // push the user data
        lua_remove(L,-3);
        return LSG_END(2);
    }

    // the second entry in this table is the callback
    lua_rawgeti(L,-1,2);    
    lua_remove(L,-2);
    return LSG_END(1);
}

// Assumes the user data is at -2 and the callback at -1

int lb_set_callback(lua_State*L,void*self,const char*name)
{
    LSG;
    
    int udata = lua_gettop(L)-1;
    int cb    = lua_gettop(L);
    
    int isnil = lua_isnil(L,cb);
    
    if (!isnil)
        luaL_checktype(L,cb,LUA_TFUNCTION);
        
    if(!lua_getmetatable(L,udata))
        luaL_error(L,"Missing metatable");
        
    lua_pushstring(L,"__callbacks__");
    lua_rawget(L,-2);
    
    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);
        lua_newtable(L);
        lua_pushstring(L,"__callbacks__");
        lua_pushvalue(L,-2);
        lua_rawset(L,-4);
    }
    
    // metatable : __callbacks__ table
    
    lua_pushlightuserdata(L,self);
    lua_rawget(L,-2);
    
    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);
        lua_newtable(L);
        lua_pushlightuserdata(L,self);
        lua_pushvalue(L,-2);
        lua_rawset(L,-4);
    }
    
    // metatable : __callbacks__ table : instance table
    
    lua_pushstring(L,name);
    
    if (isnil)
    {
        lua_pushnil(L);
    }
    else
    {
        lua_newtable(L);
        lua_pushvalue(L,udata); // push the user data
        lua_rawseti(L,-2,1);
        lua_pushvalue(L,cb); // push the function
        lua_rawseti(L,-2,2);
    }
    
    lua_rawset(L,-3);
    lua_pop(L,3);
    
    LSG_END(0);
    
    return isnil;
}

void lb_clear_callbacks(lua_State*L,void*self,const char*metatable)
{
    LSG;
    
    luaL_getmetatable(L,metatable);
    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);
        LSG_END(0);
        return;
    }
    
    lua_pushstring(L,"__callbacks__" );
    lua_rawget(L,-2);
    
    if(lua_isnil(L,-1))
    {
        lua_pop(L,2);
        LSG_END(0);
        return;
    }
    
    lua_pushlightuserdata(L,self);
    lua_pushnil(L);
    lua_rawset(L,-3);
    lua_pop(L,2);
    
    LSG_END(0);
}

// Assumes that nargs are already at the top of the stack. Returns 0 if the callback is not there
// or 1 otherwise. Upon return, it pops nargs from the stack and pushes nresults (like lua_call).

int lb_invoke_callback(lua_State*L,void*self,const char*metatable,const char*name,int nargs,int nresults)
{
    LSG;
    
    luaL_getmetatable(L,metatable);
    if (lua_isnil(L,-1))
    {
        lua_pop(L,nargs+1);
        LSG_END(-nargs);
        return 0;
    }

    if (lb_get_callback(L,self,name,1)==1)
    {
        lua_pop(L,nargs+2);
        LSG_END(-nargs);
        return 0;
    }

    // Get rid of the metatable
    lua_remove(L,-3);

    // Move the user data before the args
    lua_insert(L,lua_gettop(L)-(nargs+1));
    // Move the callback before the args
    lua_insert(L,lua_gettop(L)-(nargs+1));
    
    lua_call(L,nargs+1,nresults);
    
    LSG_END(nresults-nargs);
    
    return 1;
}

// Assuming udata is at index

int lb_callback_attached(lua_State*L,void*self,const char*name,int index)
{
    LSG;
    
    int extra = 0;
    
    if(index!=-1&&index!=lua_gettop(L))
    {
        lua_pushvalue(L,index);
        extra = 1;
    }
    
    lb_get_callback(L,self,name,0);
    int result = !lua_isnil(L,-1);
    lua_pop(L,1+extra);
    
    LSG_END(0);
    
    return result;
}


int lb_index(lua_State*L)
{
    LSG;
    
    if(!lua_getmetatable(L,1))      // get mt for user data
        return LSG_END(0);
    lua_pushvalue(L,2);             // push the key
    lua_rawget(L,-2);               // get the value for that key from the mt
    if (!lua_isnil(L,-1))           // if it is not nil, return it
    {
        lua_replace(L,-2);          // replace mt with value
        return LSG_END(1);
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
    return LSG_END(1);
}

int lb_newindex(lua_State*L)
{
    LSG;
    
    if(!lua_getmetatable(L,1))      // get the mt
        return LSG_END(0);
    lua_pushstring(L,"__setters__");// push "_setters_"
    lua_rawget(L,-2);               // get the setters table from the mt
    lua_replace(L,-2);              // get rid of the metatable
    lua_pushvalue(L,2);             // push the original key
    lua_rawget(L,-2);               // get the setter function for this key
    lua_replace(L,-2);              // get rid of the setters table
    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);               // if the setter function is not found, do nothing
        return LSG_END(0);
    }
    lua_pushvalue(L,1);             // push the original user data
    lua_pushvalue(L,3);             // push the new value to set
    lua_call(L,2,0);                // call the setter
    return LSG_END(0);
}

int lb_copy_table(lua_State*L,int target,int source)
{
    if (lua_isnil(L,source))
        return 0;
    
    LSG;
    
    int result = 0;
    lua_pushnil(L);
    while(lua_next(L,source))           // pops old key, pushes new key and value
    {
        // If the key is not a string or it is a string that does not start
        // with two underscores, copy it        
        if(!lua_isstring(L,-2)||(lua_isstring(L,-2)&&strncmp(lua_tostring(L,-2),"__",2)))
        {
            // See if the key already exists in the target
            // If so, skip it
            lua_pushvalue(L,-2);
            lua_rawget(L,target);
            if(lua_isnil(L,-1))
            {
                lua_pop(L,1);
                lua_pushvalue(L,-2);    // push the key again
                lua_insert(L,-2);       // move the second key before the value
                lua_rawset(L,target);   // pops the second key and the value
                if(!result)
                    result = 1;
            }
            else
            {
                lua_pop(L,2);
            }
        }
        else
        {
            lua_pop(L,1);           // pop the value
        }
    }
    
    LSG_END(0);
    
    return result;
}

// Assuming there is a metatable at the top of the stack,
// this function copies the stuff from the source metatable
// into this one

void lb_inherit(lua_State*L,const char*metatable)
{
    LSG;
    
    int target=lua_gettop(L);
    
    luaL_getmetatable(L,metatable);     // pushes the source metatable
    if(lua_isnil(L,-1))
        luaL_error(L,"Missing %s",metatable);
    int source=lua_gettop(L);
    lb_copy_table(L,target,source);
    
    static const char * subs[2] = { "__getters__" , "__setters__" };    
    int i=0;
    
    for(i=0;i<2;++i)
    {
        lua_pushstring(L,subs[i]);
        lua_rawget(L,target);           // get the sub table from the target mt
        int isnew=lua_isnil(L,-1);
        if(isnew)                       // the target table did not have a sub
        {                               // table with this name, so we create a
            lua_pop(L,1);               // new one
            lua_newtable(L);
        }
        int n=lua_gettop(L);
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
    
    LSG_END(0);
}

// Assumes that there is a user data at -2 and a table at -1. It then
// iterates over the table's keys and sets them as properties in the
// user data.

void lb_set_props_from_table(lua_State*L)
{
    LSG;
    
    luaL_checktype(L,-1,LUA_TTABLE);
    int source_table=lua_gettop(L);
    int udata=source_table-1;
    
    // Get the table of setters
    if (!luaL_getmetafield(L,udata,"__setters__"))
    {
        LSG_END(0);
        return;
    }
    
    int setters=lua_gettop(L);
    
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
    
    LSG_END(0);
}

// This maps the underlying user data pointers to instances of user
// datas in Lua. It keeps a table with weak user datas as the values

void lb_store_weak_ref(lua_State*L,int udata,void*self)
{
    LSG;
    
    // Get the metatable for the user data
    
    if(!lua_getmetatable(L,udata))
        return;
    
    // Get the instances table
    
    lua_pushstring(L,"__instances__");
    lua_rawget(L,-2);
    
    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);
        // If it doesn't exist yet, we need to create it
        
        lua_newtable(L);
        
        // Create a metatable for it and set the mode
        lua_newtable(L);
        lua_pushstring(L,"__mode");
        lua_pushstring(L,"v");
        lua_rawset(L,-3);
        
        // Set its metatable
        lua_setmetatable(L,-2);
        
        // Set it as __instances__ on the metatable
        
        lua_pushstring(L,"__instances__");
        lua_pushvalue(L,-2);
        lua_rawset(L,-4);
    }
    
    lua_pushlightuserdata(L,self);
    lua_pushvalue(L,udata);
    lua_rawset(L,-3);
    lua_pop(L,2);
    
    LSG_END(0);    
}

// Given a user data pointer, this looks to see if there is
// and existing instance in the __instances__ table of the
// metatable. If one exists, it pushes it.
// Otherwise, it creates a new user data to wrap the pointer
// passed in.

int lb_wrap(lua_State*L,void*self,const char*metatable)
{
    LSG;
    
    if (!self)
    {
        lua_pushnil(L);
        LSG_END(1);
        return 0;
    }
    
    luaL_getmetatable(L,metatable);
    assert(!lua_isnil(L,-1));
    
    lua_pushstring(L,"__instances__");
    lua_rawget(L,-2);
    
    if (!lua_isnil(L,-1))
    {
        lua_pushlightuserdata(L,self);
        lua_rawget(L,-2);
        
        if(!lua_isnil(L,-1))
        {
            lua_replace(L,-3);
            lua_pop(L,1);
            
            LSG_END(1);
            return 0;
        }
        
        lua_pop(L,1);
    }
    
    lua_pop(L,1);
    
    void**new_self=(void**)lua_newuserdata(L,sizeof(void**));
    
    *new_self=self;
    // push the metatable again
    lua_pushvalue(L,-2);
    // set the metatable, pops it
    lua_setmetatable(L,-2);
    // Get rid of the original metatable - user data is left on top
    lua_remove(L,-2);
    
    lb_store_weak_ref(L,lua_gettop(L),self);
    
    LSG_END(1);
    
    return 1;
}

const char *lb_optlstring(lua_State *L,int narg,const char *def, size_t *len)
{
    if (lua_isstring(L,narg))
        return lua_tolstring(L,narg,len);
          
    if (len)
      *len = (def ? strlen(def) : 0);
    return def;
}

