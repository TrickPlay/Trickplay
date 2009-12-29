#include "tp.h"
#include "context.h"
#include "network.h"
#include "lb.h"

#include <cstdio>

#include "glib.h"
#include "curl/curl.h"
#include "clutter/clutter.h"

//-----------------------------------------------------------------------------
// Bindings
//-----------------------------------------------------------------------------

extern void luaopen_clutter(lua_State*L);
extern void luaopen_timer(lua_State*L);
extern void luaopen_url_request(lua_State*L);
extern void luaopen_storage(lua_State*L);
extern void luaopen_globals(lua_State*L);

//-----------------------------------------------------------------------------
// Internal context
//-----------------------------------------------------------------------------

TPContext::TPContext()
:
    L(NULL)
{
}
    
TPContext::~TPContext()
{
}

void TPContext::set(const char * key,const char * value)
{
    // Should not be called while we are running
    
    g_assert(!L);
    
    config.insert(std::make_pair(String(key),String(value)));
}

const char * TPContext::get(const char * key)
{    
    StringMap::const_iterator it = config.find(String(key));
    
    if (it==config.end())
        return NULL;
    return it->second.c_str();
}

int TPContext::run()
{    
    // So that run cannot be called while we are running
    g_assert(!L);
    
    // Start up a lua state
    L = lua_open();
    
    // Put a pointer to us in Lua so bindings can get to it
    lua_pushstring(L,"tp_context");
    lua_pushlightuserdata(L,this);
    lua_rawset(L,LUA_REGISTRYINDEX);
    
    // Open standard libs
    luaL_openlibs(L);
    
    // Open our stuff
    luaopen_clutter(L);
    luaopen_timer(L);
    luaopen_url_request(L);
    luaopen_storage(L);
    luaopen_globals(L);
    
    // Run the script
    int result = luaL_dofile(L,"tp.lua");

    if (result)
    {
        g_error("%s",lua_tostring(L,-1));
    }
    else
    {
        clutter_actor_show_all(clutter_stage_get_default());
        clutter_main();
    }
    
    clutter_group_remove_all(CLUTTER_GROUP(clutter_stage_get_default()));
    
    Network::shutdown();
    
    lua_close(L);
    
    L=NULL;
    
    return result;
}

void TPContext::quit()
{
    clutter_main_quit();
}
   
TPContext * get_from_lua(lua_State * L)
{
    g_assert(L);
    lua_pushstring(L,"tp_context");
    lua_rawget(L,LUA_REGISTRYINDEX);
    TPContext * result = (TPContext*)lua_touserdata(L,-1);
    lua_pop(L,1);
    g_assert(result);
    return result;
}
//-----------------------------------------------------------------------------

void log_handler(const gchar * log_domain,GLogLevelFlags log_level,const gchar *message,gpointer user_data)
{
    gulong ms = clutter_get_timestamp() / 1000;
    
    int sec = 0;
    int min = 0;
    int hour = 0;

    if (ms >= 1000)
    {
        sec = ms / 1000;
        ms %= 1000;

        if (sec >= 60)
        {
            min = sec / 60;
            sec %= 60;

            if (min >= 60)
            {
                hour = min / 60;
                min %= 60;
            }
        }
    }

    const char * level = "OTHER";
    
    if (log_level&G_LOG_LEVEL_ERROR)
        level = "ERROR";
    else if (log_level&G_LOG_LEVEL_CRITICAL)
        level = "CRITICAL";
    else if (log_level&G_LOG_LEVEL_WARNING)
        level = "WARNING";
    else if (log_level&G_LOG_LEVEL_MESSAGE)
        level = "MESSAGE";
    else if (log_level&G_LOG_LEVEL_INFO)
        level = "INFO";
    else if (log_level&G_LOG_LEVEL_DEBUG)
        level = "DEBUG";
    
    fprintf(stderr,"%p %2.2d:%2.2d:%2.2d:%3.3lu %s %s %s\n" ,
            g_thread_self() ,
            hour , min , sec , ms , level , log_domain , message );
}

//-----------------------------------------------------------------------------
// External-facing functions
//-----------------------------------------------------------------------------

void tp_init(int * argc,char *** argv)
{
    if(!g_thread_supported())
	g_thread_init(NULL);
        
    ClutterInitError ce = clutter_init(argc,argv);
    
    if (ce != CLUTTER_INIT_SUCCESS)
	g_error("Failed to initialize Clutter : %d",ce);
    
    CURLcode co = curl_global_init(CURL_GLOBAL_ALL);
    
    if (co != CURLE_OK)
	g_error("Failed to initialize cURL : %s" , curl_easy_strerror(co));
    
    g_log_set_default_handler(log_handler,NULL);        
}

//-----------------------------------------------------------------------------

TPContext * tp_context_new()
{
    return new TPContext;    
}

//-----------------------------------------------------------------------------

void tp_context_free(TPContext * context)
{
    delete context;    
}

//-----------------------------------------------------------------------------

void tp_context_set(TPContext * context,const char * key,const char * value)
{
    context->set(key,value);    
}

//-----------------------------------------------------------------------------

const char * tp_context_get(TPContext * context,const char * key)
{
    return context->get(key);
}

//-----------------------------------------------------------------------------

int tp_context_run(TPContext * context)
{
    return context->run();
}

//-----------------------------------------------------------------------------

void tp_context_quit(TPContext * context)
{
    context->quit();    
}

//-----------------------------------------------------------------------------
