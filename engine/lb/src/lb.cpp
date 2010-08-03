
#include <cstring>

#include "lb.h"

//.........................................................................

static const char * TP_WEAK_REFS_TABLE = "__TP_WEAK_REFS__";

//.........................................................................
// Like luaL_ref - takes the item at the top of the stack and adds
// a weak ref to it. It pops the item and returns the ref.

int lb_weak_ref( lua_State * L )
{
    g_assert( L );

    LSG;

    lua_pushstring( L , TP_WEAK_REFS_TABLE );
    lua_rawget( L , LUA_REGISTRYINDEX );

    // The weak refs table does not yet exist, so we create it

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , 1 );

        // Create the table itself

        lua_newtable( L );

        // Create a metatable for it and set the mode

        lua_newtable( L );
        lua_pushstring( L , "__mode" );
        lua_pushstring( L , "v" );
        lua_rawset( L , -3 );

        // Set its metatable

        lua_setmetatable( L , -2 );

        // Put it in the registry

        lua_pushstring( L , TP_WEAK_REFS_TABLE );
        lua_pushvalue( L , -2 );
        lua_rawset( L , LUA_REGISTRYINDEX );
    }

    // At this point, we should have the thing to ref
    // at -2 and the weak refs table at -1

    LSG_CHECK(1);

    // Exchange the two items - weak refs table at -2 and thing at -1

    lua_insert( L , -2 );

    // Pops the thing and returns the ref

    int ref = luaL_ref( L , -2 );

    // Pop the table

    lua_pop( L , 1 );

    LSG_CHECK(-1);

    return ref;
}

//.........................................................................
// Like luaL_unref - takes the ref and removes it from the weak refs table.
// If the ref is not valid, it does nothing.

void lb_weak_unref( lua_State * L , int ref )
{
    g_assert( L );

    if ( ref == LUA_NOREF || ref == LUA_REFNIL )
    {
        return;
    }

    LSG;

    lua_pushstring( L , TP_WEAK_REFS_TABLE );
    lua_rawget( L , LUA_REGISTRYINDEX );

    g_assert( ! lua_isnil( L , -1 ) );

    luaL_unref( L , -1 , ref );

    lua_pop( L , 1 );

    LSG_CHECK(0);
}

//.........................................................................
// Pushes the value pointed to by the weak ref. If the ref is not valid, it
// will push a nil.

void lb_weak_deref( lua_State * L , int ref )
{
    g_assert( L );

    LSG;

    if ( ref == LUA_NOREF || ref == LUA_REFNIL )
    {
        lua_pushnil( L );
    }
    else
    {
        lua_pushstring( L , TP_WEAK_REFS_TABLE );
        lua_rawget( L , LUA_REGISTRYINDEX );

        g_assert( ! lua_isnil( L , -1 ) );

        // Get the value by index from the weak refs table

        lua_rawgeti( L , -1 , ref );

        // Get rid of the table

        lua_remove( L , -2 );
    }

    LSG_CHECK(1);
}

//.........................................................................
// Pushes the value pointed to by the strong ref. If the ref is not valid, it
// will push a nil.

void lb_strong_deref( lua_State * L , int ref )
{
    g_assert( L );

    LSG;

    if ( ref == LUA_NOREF || ref == LUA_REFNIL )
    {
        lua_pushnil( L );
    }
    else
    {
        // Get the value by index from the registry

        lua_rawgeti( L , LUA_REGISTRYINDEX , ref );
    }

    LSG_CHECK(1);
}

//.........................................................................

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

    if (lua_isnil(L,-1))
    {
        lua_pop(L,1);
        return LSG_END(0);
    }

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


#if 0

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

#endif

const char *lb_optlstring(lua_State *L,int narg,const char *def, size_t *len)
{
    if (lua_isstring(L,narg))
        return lua_tolstring(L,narg,len);
          
    if (len)
      *len = (def ? strlen(def) : 0);
    return def;
}

static const char * TP_ALLOWED_TABLE = "TP_ALLOWED";

int lb_is_allowed(lua_State*L,const char*name)
{
    int result=0;

    LSG;

    lua_pushstring(L,TP_ALLOWED_TABLE);
    lua_rawget(L,LUA_REGISTRYINDEX);
    if (lua_type(L,-1)==LUA_TTABLE)
    {
        lua_pushstring(L,name);
        lua_rawget(L,-2);
        result=lua_isboolean(L,-1)&&lua_toboolean(L,-1);
        lua_pop(L,1);
    }
    lua_pop(L,1);

    LSG_END(0);

    return result;
}

void lb_allow(lua_State*L,const char*name)
{
    LSG;

    lua_pushstring(L,TP_ALLOWED_TABLE);
    lua_rawget(L,LUA_REGISTRYINDEX);

    if (lua_isnil(L,-1))
    {
        lua_pop(L,1);
        lua_newtable(L);
        lua_pushstring(L,TP_ALLOWED_TABLE);
        lua_pushvalue(L,-2);
        lua_rawset(L,LUA_REGISTRYINDEX);
    }

    lua_pushstring(L,name);
    lua_pushboolean(L,1);
    lua_rawset(L,-3);

    lua_pop(L,1);

    LSG_END(0);
}

//.........................................................................

static int lb_lazy_globals_index( lua_State * L )
{
    LSG;

    if ( lua_type( L , 2 ) == LUA_TSTRING )
    {
        // Duplicate the key we were called with and get its loader from
        // our first upvalue (the table of mappings from name to loader).

        lua_pushvalue( L , 2 );
        lua_rawget( L , lua_upvalueindex( 1 ) );

        if ( ! lua_isnil( L , -1 ) )
        {
            g_debug( "LAZY LOADING '%s'" , lua_tostring( L , 2 ) );

            lua_call( L , 0 , 0 );

            // That function should have installed the named global into
            // the globals table.

            // We can now get rid of the function from the mapping table.

            lua_pushvalue( L , 2 );
            lua_pushnil( L );
            lua_rawset( L , lua_upvalueindex( 1 ) );

            // The function should have installed the global, so we fetch it.

            lua_pushvalue( L , 2 );
            lua_rawget( L , 1 );

            if ( lua_isnil( L , -1 ) )
            {
                g_warning( "LAZY LOADER FOR '%s' DID NOT WORK - GLOBAL IS NOT THERE"  , lua_tostring( L , 2 ) );
            }
        }

        return LSG_END(1);
    }

    return LSG_END(0);
}


void lb_set_lazy_loader(lua_State * L, const char * name , lua_CFunction loader )
{
    LSG;

    lua_pushvalue( L , LUA_GLOBALSINDEX );

    // There is no metatable on the globals table, so we create it and plug in
    // our own index function.

    if ( 0 == lua_getmetatable( L , -1 ) )
    {
        g_debug( "INSTALLING LAZY LOADER" );
//        g_debug( "ADDING LAZY LOAD ENTRY FOR %s" , name );

        // Create the metatable

        lua_newtable( L );
        lua_pushstring( L , "__index" );

        // Create a new table mapping name to loader which will be stored as
        // an upvalue for the index function

        lua_newtable( L );
        lua_pushstring( L , name );
        lua_pushcfunction( L , loader );
        lua_rawset( L , -3 );

        // Push the index function with its upvalue

        lua_pushcclosure( L , lb_lazy_globals_index , 1 );

        // Set it as _index on the metatable

        lua_rawset( L , -3 );

        // Set the metatable on the global table

        lua_setmetatable( L , -2 );

        // Pop the global table

        lua_pop( L , 1 );
    }
    else
    {
//        g_debug( "ADDING LAZY LOAD ENTRY FOR %s" , name );

        // Get the lazy load function from the global metatable

        lua_pushstring( L , "__index" );
        lua_rawget( L , -2 );

        // Get its mapping table from the upvalue

        lua_getupvalue( L , -1 , 1 );

        g_assert( lua_type( L , -1 ) == LUA_TTABLE );

        // Set the new name and loader function

        lua_pushstring( L , name );
        lua_pushcfunction( L , loader );
        lua_rawset( L , -3 );

        // Pop the globals table, its metatable, the index function and its upvalue table

        lua_pop( L , 4 );
    }

    LSG_CHECK(0);
}

//.........................................................................
