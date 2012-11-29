
#include <cstring>
#include <string>

#include "lb.h"

//.........................................................................
// Copied from lauxlib.c

#define abs_index(L, i) ((i) > 0 || (i) <= LUA_REGISTRYINDEX ? (i) : lua_gettop(L) + (i) + 1)

//.........................................................................

void lb_get_extras_table( lua_State * L , bool create );

void lb_get_weak_refs_table( lua_State * L , bool create );
void lb_get_weak_refs_free_list( lua_State * L );

//.........................................................................

#if 0

int dump_wr( lua_State * L )
{
    LSG;

    lua_getglobal(L,"dumptable");
    lua_pushvalue(L,-1);
    lb_get_weak_refs_table(L,false);
    lua_call(L,1,0);
    lb_get_weak_refs_free_list(L);
    lua_call(L,1,0);

    return LSG_END(0);
}

#endif

//.............................................................................
// The weak refs table has been split into two tables. One holds the weak refs
// and the other a free list. The gist of this is that we only re-use an index
// when it has been explicitly removed by lb_weak_unref. If an index was removed
// by the garbage collector, it will remain un-used (and nil) until the thing
// it points to is finalized. This guarantees that a weak ref you hold will either
// point to the thing you expect or nil; it won't point to something else that
// magically took the same index.
//.............................................................................
// Returns the free list table. It is always created and initialized if it
// doesn't already exist. The index 0 points to the next available index. So,
// the table always starts out with 0 = 1.

void lb_get_weak_refs_free_list( lua_State * L )
{
    static char TP_WEAK_REFS_FREE_LIST_TABLE = 0;

    LSG;

    lua_pushlightuserdata(L,&TP_WEAK_REFS_FREE_LIST_TABLE);
    lua_rawget(L,LUA_REGISTRYINDEX);

    if (lua_isnil(L,-1))
    {
        lua_pop(L,1);

        lua_createtable(L,100,0);
        lua_pushinteger(L,1);
        lua_rawseti(L,-2,0);

        lua_pushlightuserdata(L,&TP_WEAK_REFS_FREE_LIST_TABLE);
        lua_pushvalue(L,-2);
        lua_rawset(L,LUA_REGISTRYINDEX);
    }

    LSG_CHECK(1);
}

//.............................................................................

void lb_get_weak_refs_table( lua_State * L , bool create )
{
    static char TP_WEAK_REFS_TABLE = 0; // We only use the address

    LSG;

    lua_pushlightuserdata(L,&TP_WEAK_REFS_TABLE);
    lua_rawget(L,LUA_REGISTRYINDEX);

    if (lua_isnil(L,-1) && create)
    {
#if 0
        lua_pushcfunction(L,dump_wr);
        lua_setglobal(L,"wr");
#endif
        lua_pop(L,1);
        lua_createtable(L,100,0);

        lua_newtable(L);
        lua_pushstring(L,"__mode");
        lua_pushstring(L,"v");
        lua_rawset(L,-3);

        lua_setmetatable(L,-2);

        lua_pushlightuserdata(L,&TP_WEAK_REFS_TABLE);
        lua_pushvalue(L,-2);
        lua_rawset(L,LUA_REGISTRYINDEX);
    }

    LSG_CHECK(1);
}



//.........................................................................
// Like luaL_ref - takes the item at the top of the stack and adds
// a weak ref to it. It pops the item and returns the ref.

int lb_weak_ref( lua_State * L )
{
    g_assert( L );

    LSG;

    // First, we have to get an index for the new ref from the
    // free list.

    lb_get_weak_refs_free_list( L );

    int t=lua_gettop(L);

    lua_rawgeti(L,t,0);

    g_assert(!lua_isnil(L,-1));

    int ref = lua_tointeger(L,-1);

    lua_pop(L,1);
    lua_rawgeti(L,t,ref);

    if (!lua_isnil(L,-1))
    {
        lua_rawseti(L,t,0);
    }
    else
    {
        lua_pop(L,1);
        lua_pushinteger(L,ref+1);
        lua_rawseti(L,t,0);
    }

    lua_pop(L,1);

    LSG_CHECK(0);

    // Now that we have index, we can use it in the weak refs table

    lb_get_weak_refs_table( L , true );

    // At this point, we should have the thing to ref
    // at -2 and the weak refs table at -1

    LSG_CHECK(1);

    // Exchange the two items - weak refs table at -2 and thing at -1

    lua_insert( L , -2 );

    // Pops the thing and sticks it in the table

    lua_rawseti(L,-2,ref);

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

    // Add this index to the free list

    lb_get_weak_refs_free_list(L);

    g_assert( ! lua_isnil( L , -1 ) );

    lua_rawgeti(L,-1,0);    // Get the value at 0
    lua_rawseti(L,-2,ref);  // Set the value at ref to the value at 0
    lua_pushinteger(L,ref); // Set the value at 0 to ref
    lua_rawseti(L,-2,0);

    lua_pop( L , 1 );

    // Now clear it in the weak refs table

    lb_get_weak_refs_table( L , false );

    lua_pushnil(L);
    lua_rawseti(L,-2,ref);
    lua_pop(L,1);

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
        lb_get_weak_refs_table( L , false );

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
        lua_remove(L,-2);          // replace mt with value
        return LSG_END(1);
    }
    lua_pop(L,1);                   // pop nil
    lua_pushliteral(L,"__getters__");// push "_getters_"
    lua_rawget(L,-2);               // get the getters table from the mt
    lua_remove(L,-2);              // replace mt with getters table

    if (lua_type(L,-1)!=LUA_TTABLE)
    {
        lua_pop(L,1);
        lua_pushnil(L);
        return LSG_END(1);
    }

    lua_pushvalue(L,2);             // push the key
    lua_rawget(L,-2);               // get the value for that key from the getters table
    lua_remove(L,-2);              // get rid of the getters table
    if(!lua_isnil(L,-1))
    {
        lua_pushvalue(L,1);         // push the user data
        lua_call(L,1,1);            // call the value as a function
    }
    else
    {
        lua_pop(L,1);                               // pop nil
        lb_get_extras_table( L , false );

        if (!lua_isnil(L,-1))
        {
            lua_pushvalue(L,1);                     // Get the table for this usedata
            lua_rawget(L,-2);
            lua_remove(L,-2);                       // Drop the extra table

            if (!lua_isnil(L,-1))
            {
                lua_pushvalue(L,2);                 // Push the key
                lua_gettable(L,-2);                 // Get the value for the key
                lua_remove(L,-2);                   // Drop the table - leaving the value
            }
        }
    }
    return LSG_END(1);
}

int lb_newindex(lua_State*L)
{
    LSG;

    if(!lua_getmetatable(L,1))      // get the mt
        return LSG_END(0);
    lua_pushliteral(L,"__setters__");// push "_setters_"
    lua_rawget(L,-2);               // get the setters table from the mt
    lua_remove(L,-2);              // get rid of the metatable

    if (lua_isnil(L,-1))
    {
        lua_pop(L,1);
        return LSG_END(0);
    }

    lua_pushvalue(L,2);             // push the original key
    lua_rawget(L,-2);               // get the setter function for this key
    lua_remove(L,-2);              // get rid of the setters table
    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);               // if the setter function is not found, look in the extra table

        lb_get_extra(L);            // pushes the extra table, creating it if needed
        lua_pushvalue(L,2);         // push the key
        lua_pushvalue(L,3);         // push the value
        lua_settable(L,-3);         // set it - using metamethods
        lua_pop(L,1);               // pop the table

        return LSG_END(0);
    }
    lua_pushvalue(L,1);             // push the original user data
    lua_pushvalue(L,3);             // push the new value to set
    if (lua_pcall(L,2,0,0))        // call the setter
    {
        luaL_error(L,"Failed to set '%s' : %s" , lua_tostring(L,2),lua_tostring(L,-1));
    }
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
        bool copy_it = true;
        if ( lua_type( L , -2 ) == LUA_TSTRING )
        {
            copy_it = strncmp( lua_tostring(L,-2),"__",2);
        }

        if(copy_it)
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
// into this one. If you pass NULL for metatable, it assumes
// that the source metatable is at on the top of the stack and
// the target is just below it.

void lb_inherit(lua_State*L,const char*metatable)
{
    LSG;

    int target=lua_gettop(L);

    if (!metatable)
    {
        --target;
    }
    else
    {
        luaL_getmetatable(L,metatable);     // pushes the source metatable
        if(lua_isnil(L,-1))
            luaL_error(L,"Missing %s",metatable);
    }

    int source=lua_gettop(L);

    lb_copy_table(L,target,source);

    static const char * subs[3] = { "__getters__" , "__setters__" , "__types__" };
    int i=0;

    for(i=0;i<3;++i)
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

    if (metatable)
    {
        lua_pop(L,1);                       // pop the source metatable
    }
    LSG_END(0);
}

// Expects a user data at index. This will create a new metatable for
// that user data that includes everything from the new metatable
// and everything from its old metatable. __gc will be taken from
// the old metatable.

void lb_chain(lua_State*L,int index,const char * metatable )
{
    g_assert( lua_isuserdata( L , index ) );

    LSG;
    lua_newtable( L );
    int t = lua_gettop( L );

    if ( metatable )
    {
    	lb_inherit( L , metatable );
    }

    lua_getmetatable( L , index );
    lb_inherit( L , 0 );
    lua_pushstring( L , "__gc" );
    lua_pushvalue( L , -1 );
    lua_rawget( L , -3 );  // Get __gc from the old metatable
    lua_rawset( L , t );   // Set it in the new metatable
    lua_pop( L , 1 );      // Pop the old metatable

    lua_pushstring( L , "__index" );
    lua_pushcfunction( L , lb_index );
    lua_rawset( L , t );

    lua_pushstring( L , "__newindex" );
    lua_pushcfunction( L , lb_newindex );
    lua_rawset( L , t );

    lua_setmetatable( L , index );

    LSG_CHECK(0);
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
            if(lua_pcall(L,2,0,0))      // pops the setter function, the udata and the value
            {
                luaL_error(L,"Failed to set '%s' : %s" , lua_tostring(L,-3),lua_tostring(L,-1));
            }
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

void lb_get_allowed_table( lua_State * L , bool create )
{
    static char TP_ALLOWED_TABLE = 0; // We only use the address

    LSG;

    lua_pushlightuserdata( L , & TP_ALLOWED_TABLE );
    lua_rawget( L , LUA_REGISTRYINDEX );

    if (lua_isnil( L , -1 ) && create )
    {
        lua_pop(L,1);
        lua_newtable(L);
        lua_pushlightuserdata(L,&TP_ALLOWED_TABLE);
        lua_pushvalue(L,-2);
        lua_rawset(L,LUA_REGISTRYINDEX);
    }

    LSG_CHECK(1);
}


int lb_is_allowed(lua_State*L,const char*name)
{
    int result=0;

    LSG;

    lb_get_allowed_table( L , false );

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

    lb_get_allowed_table( L , true );

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
            //g_debug( "LAZY LOADING '%s'" , lua_tostring( L , 2 ) );

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

#if 0

// This function adds anything the app tries to add as a global, to
// a new table called newglobals. So we can easily see all the globals
// set by an app (as opposed to set by us).

static int lb_global_newindex( lua_State * L )
{
    // 1 - globals table
    // 2 - new key
    // 3 - new value

    // Get the metatable for the globals table
    lua_getmetatable( L , 1 );

    // Get the index function from the metatable
    lua_pushstring( L , "__index" );
    lua_rawget( L , -2 );

    // Get rid of the metatable
    lua_remove( L , -2 );

    // Get the first upvalue for the index function
    // This is the table of lazy loaders
    lua_getupvalue( L , -1 , 1 );

    // Remove the function
    lua_remove( L , -2 );

    // Push the new key and get its value from the lazy loaders table
    lua_pushvalue( L , 2 );
    lua_rawget( L , -2 );

    // Remove the lazy loaders table
    lua_remove( L , -2 );

    // If there is no value for this key in the lazy loaders table, it
    // must be a user value.

    if ( lua_isnil( L , -1 ) )
    {
        // Pop the nil

        lua_pop( L , 1 );

        // Get the global table 'newglobals'

        lua_pushstring( L , "newglobals" );
        lua_rawget( L , 1 );

        // If it doesn't exist, we create it, set it as a globale
        // and leave it on top of the stack

        if ( lua_isnil( L , -1 ) )
        {
            // Pop nil
            lua_pop( L , 1 );

            // Create the table
            lua_newtable( L );

            // Push the key
            lua_pushstring( L , "newglobals" );

            // Push the table again
            lua_pushvalue( L , -2 );

            // Set it - leaves the first ref to the table on the stack
            lua_rawset( L , 1 );
        }

        // Now, we use the global key that was passed in and add it to the
        // the newglobals table with a value of true.

        lua_pushvalue( L , 2 );
        lua_pushboolean( L , true );
        lua_rawset( L , -3 );

        // Get rid of the newglobals table

        lua_pop( L , 1 );
    }
    else
    {
        // Get rid of the lazy loader entry

        lua_pop( L , 1 );
    }

    // We should be left with the original 3 arguments to this function

    g_assert( lua_gettop( L ) == 3 );

    // Now do the set

    lua_rawset( L , -3 );

    return 0;
}

#endif

void lb_set_lazy_loader(lua_State * L, const char * name , lua_CFunction loader )
{
    LSG;

    lua_rawgeti( L , LUA_REGISTRYINDEX , LUA_RIDX_GLOBALS );

    // There is no metatable on the globals table, so we create it and plug in
    // our own index function.

    if ( 0 == lua_getmetatable( L , -1 ) )
    {
//        g_debug( "INSTALLING LAZY LOADER" );
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

#if 0
        // This sets a newindex metamethod on globals so
        // we can track anything added by the app

        lua_pushstring( L , "__newindex" );
        lua_pushcfunction( L , lb_global_newindex );
        lua_rawset( L , -3 );
#endif

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
// The extras table is in the registry and uses the user data as a weak
// key to point to the user supplied extra table. We create this table
// if it doesn't already exist.
//
// REGISTRY
// --------
// TP_EXTRA_TABLE = { <user data> (weak) = <user supplied table> }

void lb_get_extras_table( lua_State * L , bool create )
{
    static char TP_EXTRA_TABLE=0; // We only use the address of this

    LSG;

    lua_pushlightuserdata(L,&TP_EXTRA_TABLE);   // get the extra table
    lua_rawget(L,LUA_REGISTRYINDEX);

    if (lua_isnil(L,-1) && create)
    {
        lua_pop(L,1);
        lua_newtable(L);

        lua_newtable(L);
        lua_pushstring(L,"__mode");
        lua_pushstring(L,"k");
        lua_rawset(L,-3);

        lua_setmetatable(L,-2);

        lua_pushlightuserdata(L,&TP_EXTRA_TABLE);   // get the extra table
        lua_pushvalue(L,-2);
        lua_rawset(L,LUA_REGISTRYINDEX);
    }

    LSG_CHECK(1);
}


int lb_get_extra(lua_State * L)
{
    LSG;

    lb_get_extras_table( L , true );

    // table is on top

    lua_pushvalue(L,1);
    lua_rawget(L,-2);

    if(lua_isnil(L,-1))
    {
        lua_pop(L,1);

        lua_newtable(L);
        lua_pushvalue(L,1);
        lua_pushvalue(L,-2);
        lua_rawset(L,-4);
    }

    lua_remove(L,-2);

    g_assert(lua_type(L,-1)==LUA_TTABLE);

    return LSG_END(1);
}

//-----------------------------------------------------------------------------
// This one expects the user data at 1 and the table (or nil) at 2 - it sets the new
// table as the extra table for this user data.

int lb_set_extra(lua_State * L)
{
    if (!lua_isnil(L,2))
    {
        (void)lb_checktable(L,2);
    }

    LSG;

    lb_get_extras_table( L , true );

    lua_pushvalue(L,1);
    lua_pushvalue(L,2);
    lua_rawset(L,-3);

    lua_pop(L,1);

    return LSG_END(0);
}

//-----------------------------------------------------------------------------
// Table dumping functions

std::string lb_value_desc( lua_State * L , int index )
{
    LSG;

    lua_getglobal(L,"tostring");
    lua_pushvalue(L,index);
    lua_call(L,1,1);
    std::string result = lua_tostring(L,-1);
    lua_pop(L,1);

    bool add_type = false;

    switch(lua_type(L,index))
    {
        case LUA_TSTRING:
            result = "\"" + result + "\"";
            break;

        case LUA_TUSERDATA:
        	if ( lua_rawlen( L , index ) == sizeof( UserData ) )
        	{
        		result = result + " (" + UserData::get(L,index)->get_type() + ")";
        	}
            break;
    }

    if ( add_type )
    {
        result = result + " (" + lua_typename(L,lua_type(L,index)) + ")";
    }

    LSG_CHECK(0);

    return result;
}


void lb_dump_table_recurse( lua_State * L , int visited , int depth , int filter )
{
    LSG;

    int t = lua_gettop( L );

    (void)lb_checktable(L,t);

    lb_strong_deref(L,visited);
    lua_pushvalue(L,t);
    lua_pushboolean(L,true);
    lua_rawset(L,-3);
    lua_pop(L,1);

    std::string indent( 2 * depth , ' ' );

    g_message("%s{",indent.c_str());

    lua_pushnil(L);

    while(lua_next(L,t))
    {
        if (filter)
        {
            lua_pushvalue(L,filter);
            lua_pushvalue(L,-3);
            lua_pushvalue(L,-3);
            lua_pushinteger(L,depth+1);
            lua_call(L,3,1);
            bool skip=!lua_toboolean(L,-1);
            lua_pop(L,1);

            if (skip)
            {
                lua_pop(L,1);
                continue;
            }
        }

        std::string k = lb_value_desc(L,lua_gettop(L)-1);
        std::string v = lb_value_desc(L,lua_gettop(L));

        g_message( "%s  %s = %s",indent.c_str(),k.c_str(),v.c_str());

        if (lua_type(L,-1)==LUA_TTABLE)
        {
            lb_strong_deref(L,visited);
            lua_pushvalue(L,-2);
            lua_rawget(L,-2);
            if (lua_toboolean(L,-1))
            {
                g_message("%s  { *CYCLE* }",indent.c_str() );
                lua_pop(L,2); // the boolean and the visited table
            }
            else
            {
                lua_pop(L,2); // the nil and the visited table
                lb_dump_table_recurse(L,visited,depth+1,filter);
            }
        }

        lua_pop(L,1); // the value
    }

    g_message("%s}",indent.c_str());

    LSG_END(0);
}

void lb_dump_table( lua_State * L )
{
    LSG;

    (void)lb_checktable(L,1);

    int filter = 0;

    if (lua_gettop(L)>1&&lua_type(L,2)==LUA_TFUNCTION)
    {
        filter = 2;
    }

    lua_getglobal(L,"tostring");
    lua_pushvalue(L,1);
    lua_call(L,1,1);
    g_message("%s",lua_tostring(L,-1));
    lua_pop(L,1);

    lua_newtable(L);
    int visited = lb_strong_ref(L);

    lua_pushvalue(L,1);
    lb_dump_table_recurse(L,visited,0,filter);
    lua_pop(L,1);

    lb_strong_unref(L,visited);

    LSG_CHECK(0);
}

bool lb_check_udata_type( lua_State * L , int index , const char * type , bool fail )
{
    LSG;

    bool result = false;

    if ( lua_isuserdata( L , index ) )
    {
        if ( lua_getmetatable( L , index ) )
        {
        	lua_pushliteral( L , "__types__" );
            lua_rawget( L , -2 );

            if ( lua_type( L , -1 ) == LUA_TTABLE )
            {
                lua_getfield( L , -1 , type );
                result = lua_toboolean( L , -1 );
                lua_pop( L , 1 );
            }

            lua_pop( L , 2 );
        }
    }

    if ( ! result && fail )
    {
        luaL_error( L , "Incorrect type" );
    }

    LSG_CHECK(0);

    return result;
}


void * lb_get_udata_check( lua_State * L , int index , const char * type )
{
    assert( L );
    assert( type );

    if ( index )
    {
        index = abs_index( L , index );

        if ( lb_check_udata_type( L , index , type , false ) )
        {
            return UserData::get_client_check( L , index );
        }
    }
    return 0;
}


void lb_setglobal( lua_State * L , const char * name )
{
	lua_rawgeti( L , LUA_REGISTRYINDEX , LUA_RIDX_GLOBALS );
	lua_pushstring( L , name );
	lua_pushvalue( L , -3 );
	lua_rawset( L , -3 );
	lua_pop( L , 2 );
}
