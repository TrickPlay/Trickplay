
#include <iostream>

#include "lb.h"
#include "network.h"

#include "clutter/clutter.h"
#include "glib.h"

extern void luaopen_clutter(lua_State*L);
extern void luaopen_timer(lua_State*L);
extern void luaopen_url_request(lua_State*L);
    
void ncb(const Network::Response & r , gpointer data )
{
    g_debug("GOT NETWORK RESPONSE CALLBACK");
    g_debug("  %d '%s' %s",r.code,r.status.c_str(),r.failed?"FAILED":"SUCCEEDED");
    
    for(Network::StringMultiMap::const_iterator it=r.headers.begin();it != r.headers.end(); ++it)
	g_debug("  '%s' : '%s'" ,it->first.c_str() , it->second.c_str() );
    g_debug("BODY %d BYTES",r.body->len);
	
}

int main( int argc , char * argv[] )
{
    if(!g_thread_supported())
	g_thread_init(NULL);

    clutter_init(&argc,&argv);
    
    lua_State * L = lua_open();
    
    luaL_openlibs(L);
    
    luaopen_clutter(L);
    luaopen_timer(L);
    luaopen_url_request(L);
    
    int result = luaL_dofile(L,"tp.lua");

    if (result)
    {
        std::cerr << lua_tostring(L,-1) << std::endl;
    }
    else
    {
        clutter_actor_show_all(clutter_stage_get_default());
        clutter_main();
    }
    
    clutter_group_remove_all(CLUTTER_GROUP(clutter_stage_get_default()));
    
    Network::shutdown();
    
    lua_close( L );

    return result;
}






#if 0

#include "tp.h"

void notify( what )
{
    sfsdhf   
}

main()
{
    tp_context * tpc = tp_open();
    
    tp_configure( tpc , "CAMERA" , "0" );
    tp_configure( tpc , "VERSION" , "1.7" );

    tp_add_module( tpc , foo );
    
    tp_set_notify( tpc , notify );
    
    tp_event( tpc , "KEYPRESS" , "DOWN" );
    
    
    tp_run( tpc );
}

#endif







