#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <sstream>
#include <memory>

#include "curl/curl.h"
#include "clutter/clutter.h"

#include "context.h"
#include "network.h"
#include "lb.h"
#include "util.h"
#include "console.h"

//-----------------------------------------------------------------------------
// Bindings
//-----------------------------------------------------------------------------

extern void luaopen_clutter(lua_State*L);
extern void luaopen_timer(lua_State*L);
extern void luaopen_url_request(lua_State*L);
extern void luaopen_storage(lua_State*L);
extern void luaopen_globals(lua_State*L);
extern void luaopen_app(lua_State*L);
extern void luaopen_system(lua_State*L);
extern void luaopen_settings(lua_State*L);

//-----------------------------------------------------------------------------
// Internal context
//-----------------------------------------------------------------------------

TPContext::TPContext()
:
    L(NULL),
    external_log_handler(NULL),
    external_log_handler_data(NULL)
{
}
    
//-----------------------------------------------------------------------------

TPContext::~TPContext()
{
}

//-----------------------------------------------------------------------------

void TPContext::set(const char * key,const char * value)
{
    g_assert(!running());
    
    config.insert(std::make_pair(String(key),String(value)));
}

//-----------------------------------------------------------------------------

void TPContext::set(const char * key,int value)
{
    std::stringstream str;
    str << value;
    set(key,str.str().c_str());
}

//-----------------------------------------------------------------------------

const char * TPContext::get(const char * key,const char * def)
{    
    StringMap::const_iterator it = config.find(String(key));
    
    if (it==config.end())
        return def;
    return it->second.c_str();
}

//-----------------------------------------------------------------------------

bool TPContext::get_bool(const char * key,bool def)
{
    const char * value=get(key);
    
    if(!value)
	return def;
    
    return (!strcmp(value,"1")||
	    !strcmp(value,"TRUE")||
	    !strcmp(value,"true")||
	    !strcmp(value,"YES")||
	    !strcmp(value,"yes")||
	    !strcmp(value,"Y")||
	    !strcmp(value,"y"));
}

//-----------------------------------------------------------------------------

int TPContext::get_int(const char * key,int def)
{
    const char * value=get(key);
    
    if (!value)
	return def;
    return atoi(value);
}

//-----------------------------------------------------------------------------

int TPContext::console_command_handler(const char * command,const char * parameters,void * self)
{
    TPContext * context = (TPContext*)self;
    
    if (!strcmp(command,"exit"))
    {
	context->quit();
	return TRUE;
    }
    
    std::pair<ConsoleCommandHandlerMultiMap::const_iterator,ConsoleCommandHandlerMultiMap::const_iterator>
	range=context->console_command_handlers.equal_range(String(command));
	
    for (ConsoleCommandHandlerMultiMap::const_iterator it=range.first;it!=range.second;++it)
	it->second.first(command,parameters,it->second.second);
    
    return range.first != range.second;
}

//-----------------------------------------------------------------------------

int TPContext::run()
{
    // So that run cannot be called while we are running
    g_assert(!running());
    
    // Set the external log handler, if any
    if (external_log_handler)
	g_log_set_default_handler(log_handler,this);
		
    // Validate our configuration
    validate_configuration();
    
    //.......................................................
    // The code below should execute each time we load an app
    
    // Get the base path for the app
    const char * app_path = get(TP_APP_PATH);
    
    // Load metadata    
    if (!load_app_metadata(app_path))
	return 1;
    
    // Prepare for the app
    if (!prepare_app())
	return 2;
    
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
    luaopen_app(L);
    luaopen_system(L);
    luaopen_settings(L);
    
    notify(TP_NOTIFICATION_APP_LOADING);
    
    // Run the script
    gchar * main_path=g_build_filename(app_path,"main.lua",NULL);
        
    int result = luaL_dofile(L,main_path);

    g_free(main_path);
    main_path=NULL;

    if (result)
    {
	notify(TP_NOTIFICATION_APP_LOAD_FAILED);
	
        g_error("%s",lua_tostring(L,-1));
    }
    else
    {
	notify(TP_NOTIFICATION_APP_LOADED);
	
#ifndef TP_PRODUCTION

	std::auto_ptr<Console> console;

	if (get_bool(TP_CONSOLE_ENABLED,true))
	{
	    console.reset(new Console(L));
	    console->add_command_handler(console_command_handler,this);
	}
#endif

	clutter_actor_show_all(clutter_stage_get_default());
	clutter_main();
    }
    
    clutter_group_remove_all(CLUTTER_GROUP(clutter_stage_get_default()));
    
    Network::shutdown();
    
    lua_close(L);
    
    L=NULL;

    notify(TP_NOTIFICATION_APP_CLOSED);
        
    return result;
}

//-----------------------------------------------------------------------------

void TPContext::quit()
{
    g_assert(running());
    
    notify(TP_NOTIFICATION_APP_CLOSING);
    
    clutter_main_quit();
}
   
//-----------------------------------------------------------------------------

TPContext * TPContext::get_from_lua(lua_State * L)
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

bool TPContext::load_app_metadata(const char * app_path)
{
    g_assert(app_path);
    
    // Open a state with no libraries - not even the base one
    
    lua_State * L=lua_open();
    
    g_assert(L);
    
    try
    {
	// Build the path to the metadata file and test that it exists
	
	gchar * path = g_build_filename(app_path,APP_METADATA_FILENAME,NULL);
	
	Util::GFreeLater free_path(path);
	
	if (!g_file_test(path,G_FILE_TEST_IS_REGULAR))
	    throw String("App metadata file does not exist");
	
	// Now, run it with Lua
	
	int result = luaL_dofile(L,path);
	
	// Check that it ran OK
	
	if(result)
	    throw String("Failed to parse app metadata : ") + lua_tostring(L,-1);
	    
	// Look for the 'app' global
	
	lua_getglobal(L,APP_TABLE_NAME);	
	if (!lua_istable(L,-1))
	    throw String("Missing or invalid app table");
	    
	// Look for the id
	lua_getfield(L,-1,APP_FIELD_ID);
	if (lua_type(L,-1)!=LUA_TSTRING)
	    throw String("Missing or invalid app id");
	    
	// Validate the id
	
	size_t len;
	const char * s=lua_tolstring(L,-1,&len);
	
	if (len>64)
	    throw String("App id is too long");
	
	static const char * valid_id_characters = "_-.";
	
	for(const char * c=s;*c;++c)
	{
	    if (!g_ascii_isalnum(*c))
	    {
		if(!strchr(valid_id_characters,*c))
		    throw String("App id contains invalid characters");
	    }
	}
	
	if (strstr(s,".."))
	    throw String("App id contains two dots");

	if (strstr(s,"--"))
	    throw String("App id contains two dashes");
	    
	if (strstr(s,"__"))
	    throw String("App id contains two underscores");
	    
	
	// Store it
	set(APP_ID,s);
	lua_pop(L,1);

	// Look for the other fields
	lua_getfield(L,-1,APP_FIELD_NAME);
	if (lua_type(L,-1)!=LUA_TSTRING)
	    throw String("Missing or invalid app name");
	set(APP_NAME,lua_tostring(L,-1));
	lua_pop(L,1);
	
	lua_getfield(L,-1,APP_FIELD_RELEASE);
	if (lua_tointeger(L,-1)<=0)
	    throw String("Missing or invalid app release, it must be a number greater than 0");
	set(APP_RELEASE,lua_tointeger(L,-1));
	lua_pop(L,1);
	
	lua_getfield(L,-1,APP_FIELD_VERSION);
	if (lua_type(L,-1)!=LUA_TSTRING)
	    throw String("Missing or invalid app version");
	set(APP_VERSION,lua_tostring(L,-1));
	lua_pop(L,1);
	
	lua_getfield(L,-1,APP_FIELD_DESCRIPTION);
	if(lua_isstring(L,-1))
	    set(APP_DESCRIPTION,lua_tostring(L,-1));
	lua_pop(L,1);
	
	lua_getfield(L,-1,APP_FIELD_AUTHOR);
	if(lua_isstring(L,-1))
	    set(APP_AUTHOR,lua_tostring(L,-1));
	lua_pop(L,1);
	
	lua_getfield(L,-1,APP_FIELD_COPYRIGHT);
	if(lua_isstring(L,-1))
	    set(APP_COPYRIGHT,lua_tostring(L,-1));
	lua_pop(L,1);
	
	lua_close(L);
	return true;	
    }
    catch( const String & e)
    {
	lua_close(L);
	g_warning("Failed to load app metadata from '%s' : %s" , app_path , e.c_str() );
	return false;	
    }
}

//-----------------------------------------------------------------------------

bool TPContext::prepare_app()
{
    // Get its data directory ready
    
    gchar * id_hash=g_compute_checksum_for_string(G_CHECKSUM_SHA1,get(APP_ID),-1);
    
    Util::GFreeLater free_id_hash(id_hash);    
    
    gchar * app_data_path=g_build_filename(get(TP_DATA_PATH),"apps",id_hash,NULL);
    
    Util::GFreeLater free_app_data_path(app_data_path);
    
    if (!g_file_test(app_data_path,G_FILE_TEST_EXISTS))
    {
	if (g_mkdir_with_parents(app_data_path,0700)!=0)
	{
	    g_warning("Failed to create app data path '%s'",app_data_path);
	    return false;
	}
    }
    
    set(APP_DATA_PATH,app_data_path);
    
    return true;
}

//-----------------------------------------------------------------------------

void TPContext::add_console_command_handler(const char * command,TPConsoleCommandHandler handler,void * data)
{
    console_command_handlers.insert(std::make_pair(String(command),ConsoleCommandHandlerClosure(handler,data)));
}

//-----------------------------------------------------------------------------

void TPContext::log_handler(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message,gpointer self)
{
    TPContext * context=(TPContext*)self;
    
    context->external_log_handler(log_level,log_domain,message,context->external_log_handler_data);
}

//-----------------------------------------------------------------------------

void TPContext::set_log_handler(TPLogHandler handler,void * data)
{
    g_assert(!running());
    
    external_log_handler = handler;
    external_log_handler_data = data;
}

//-----------------------------------------------------------------------------

void TPContext::add_notification_handler(const char * subject,TPNotificationHandler handler,void * data)
{
    notification_handlers.insert(std::make_pair(String(subject),NotificationHandlerClosure(handler,data)));
}

//-----------------------------------------------------------------------------

void TPContext::set_request_handler(const char * subject,TPRequestHandler handler,void * data)
{
    request_handlers.insert(std::make_pair(String(subject),RequestHandlerClosure(handler,data)));
}

//-----------------------------------------------------------------------------

void TPContext::notify(const char * subject)
{
    std::pair<NotificationHandlerMultiMap::const_iterator,NotificationHandlerMultiMap::const_iterator>
	range=notification_handlers.equal_range(String(subject));
	
    for (NotificationHandlerMultiMap::const_iterator it=range.first;it!=range.second;++it)
	it->second.first(subject,it->second.second);
}
    
//-----------------------------------------------------------------------------

int TPContext::request(const char * subject)
{
    RequestHandlerMap::const_iterator it=request_handlers.find(String(subject));
    
    return it==request_handlers.end() ? 1 : it->second.first(subject,it->second.second);
}

//-----------------------------------------------------------------------------

String TPContext::normalize_app_path(const gchar * path_or_uri,bool * is_uri)
{
    if (is_uri)
	*is_uri=false;
	
    const char * app_path=get(TP_APP_PATH);
	
    gchar * result=NULL;
    
    // First, see if there is a scheme
    
    gchar ** parts=g_strsplit(path_or_uri,":",2);
    
    guint count=g_strv_length(parts);
    
    if (count==0)
    {
	// What do we do? This is clearly not a good path
	
	g_error("Invalid empty path or uri");
    }
    
    if (count==1)
    {
	// There is no scheme, so this is a simple path
	
	result=Util::rebase_path(app_path,path_or_uri);
    }
    else
    {
	// There is a scheme
	
	gchar * scheme=parts[0];
	gchar * uri=parts[1];
	
	// The scheme is only one character long - assume it
	// is a windows drive letter
	
	if (strlen(scheme)==1)
	{
	    result=Util::rebase_path(app_path,path_or_uri);
	}
	else
	{
	    // If it is HTTP or HTTPS, we just return the whole thing passed in
	    
	    if (!strcmp(scheme,"http")||!strcmp(scheme,"https"))
	    {
		if (is_uri)
		    *is_uri=true;
		    
		result = g_strdup(path_or_uri);
	    }

	    // file scheme
	    
	    else if (!strcmp(scheme,"file"))
	    {
		if (g_strstr_len(uri,2,"//")==uri)
		    result = Util::rebase_path(app_path,uri+2);
		else
		    result = Util::rebase_path(app_path,uri);
	    }
	    	    
	    // Localized file
	    
	    else if (!strcmp(scheme,"localized"))
	    {
		const char * language=get(TP_SYSTEM_LANGUAGE,"en");
		const char * country=get(TP_SYSTEM_COUNTRY,"US");

		gchar * try_path=NULL;
		
		// Try <app>/localized/en/US/<path>
		
		try_path=g_build_filename(app_path,"localized",language,country,NULL);
		
		result=Util::rebase_path(try_path,uri);
		
		g_free(try_path);
		
		if (!g_file_test(result,G_FILE_TEST_EXISTS))
		{
		    // Try <app>/localized/en/<path>
		    
		    try_path=g_build_filename(app_path,"localized",language,NULL);
		    
		    result=Util::rebase_path(try_path,uri);
		    
		    g_free(try_path);
		    
		    if (!g_file_test(result,G_FILE_TEST_EXISTS))
		    {
			// Try <app>/localized/<path>
			
			try_path=g_build_filename(app_path,"localized",NULL);
			
			result=Util::rebase_path(try_path,uri);
			
			g_free(try_path);
			
			if (!g_file_test(result,G_FILE_TEST_EXISTS))
			{
			    // End up with <app>/<path>
			    
			    result=Util::rebase_path(app_path,uri);
			}
		    }
		}
	    }
	    else
	    {
		g_error("Invalid scheme in '%s'",path_or_uri);
	    }
	}
    }
    
    g_strfreev(parts);
    
    g_assert(result);
    
    Util::GFreeLater free_result(result);
    
    return String(result);
}

//-----------------------------------------------------------------------------

void TPContext::validate_configuration()
{
    // TP_APP_PATH
    
    const char * app_path=get(TP_APP_PATH);
    
    if (!app_path)
    {
	gchar * c=g_get_current_dir();
	set(TP_APP_PATH,c);
	g_warning("DEFAULT:%s=%s",TP_APP_PATH,c);
	g_free(c);
    }
    
    // TP_SYSTEM_LANGUAGE
    
    const char * language=get(TP_SYSTEM_LANGUAGE);
    
    if (!language)
    {
	set(TP_SYSTEM_LANGUAGE,"en");
	g_warning("DEFAULT:%s=en",TP_SYSTEM_LANGUAGE);
    }
    else if (strlen(language)!=2)
    {
	g_error("Language must be a 2 character, lower case, ISO-639-1 code : '%s' is too long",language);
    }
    else if (!g_ascii_islower(language[0])||!g_ascii_islower(language[1]))
    {
	g_error("Language must be a 2 character, lower case, ISO-639-1 code : '%s' is invalid",language);
    }
    
    // SYSTEM COUNTRY
    
    const char * country=get(TP_SYSTEM_COUNTRY);
    
    if (!country)
    {
	set(TP_SYSTEM_COUNTRY,"US");
	g_warning("DEFAULT:%s=US",TP_SYSTEM_COUNTRY);
    }
    else if (strlen(country)!=2)
    {
	g_error("Country must be a 2 character, upper case, ISO-3166-1-alpha-2 code : '%s' is too long",country);
    }
    else if (!g_ascii_isupper(country[0])||!g_ascii_isupper(country[1]))
    {
	g_error("Country must be a 2 character, upper case, ISO-3166-1-alpha-2 code : '%s' is invalid",country);
    }
    
    // DATA PATH
    
    const char * data_path=get(TP_DATA_PATH);
    
    if (!data_path)
    {
	data_path=g_get_tmp_dir();
	g_assert(data_path);
	g_warning("DEFAULT:%s=%s",TP_DATA_PATH,data_path);
    }
    
    gchar * full_data_path=g_build_filename(data_path,"trickplay",NULL);
    
    if (g_mkdir_with_parents(full_data_path,0700)!=0)
	g_error("Data path '%s' does not exist and could not be created",full_data_path);
    
    set(TP_DATA_PATH,full_data_path);
    
    g_free(full_data_path);
}

//-----------------------------------------------------------------------------
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
	g_error("Failed to initialize cURL : %s",curl_easy_strerror(co));
    
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
    g_assert(context);
    g_assert(!context->running());
    
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

void tp_context_add_notification_handler(TPContext * context,const char * subject,TPNotificationHandler handler,void * data)
{
    context->add_notification_handler(subject,handler,data);
}

//-----------------------------------------------------------------------------

void tp_context_set_request_handler(TPContext * context,const char * subject,TPRequestHandler handler,void * data)
{
    context->set_request_handler(subject,handler,data);
}

//-----------------------------------------------------------------------------

void tp_context_add_console_command_handler(TPContext * context,const char * command,TPConsoleCommandHandler handler,void * data)
{
    context->add_console_command_handler(command,handler,data);    
}

//-----------------------------------------------------------------------------

void tp_context_set_log_handler(TPContext * context,TPLogHandler handler,void * data)
{
    context->set_log_handler(handler,data);
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
