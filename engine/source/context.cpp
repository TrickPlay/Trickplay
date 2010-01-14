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
#include "sysdb.h"

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
extern void luaopen_profile(lua_State*L);
extern void luaopen_xml(lua_State*L);
extern void luaopen_restricted(lua_State*L);

//-----------------------------------------------------------------------------
// Internal context
//-----------------------------------------------------------------------------

TPContext::TPContext()
:
    is_running(false),
    sysdb(NULL),
    external_log_handler(NULL),
    external_log_handler_data(NULL)
{
    g_log_set_default_handler(TPContext::log_handler,this);            
}
    
//-----------------------------------------------------------------------------

TPContext::~TPContext()
{
}

//-----------------------------------------------------------------------------

void TPContext::set(const char * key,const char * value)
{
    set(key,String(value));
}

//-----------------------------------------------------------------------------

void TPContext::set(const char * key,int value)
{
    std::stringstream str;
    str << value;
    set(key,str.str());
}

//-----------------------------------------------------------------------------

void TPContext::set(const char * key,const String & value)
{
    config[String(key)]=value;    
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
    
    if (!strcmp(command,"exit") || !strcmp(command,"quit"))
    {
	context->quit();
	return TRUE;
    }
    else if (!strcmp(command,"config"))
    {
	for(StringMap::const_iterator it=context->config.begin();it!=context->config.end();++it)
	    g_debug("%-15.15s %s",it->first.c_str(),it->second.c_str());
    }
    else if (!strcmp(command,"profile"))
    {
	if (!parameters)
	{
	    SystemDatabase::Profile p=context->get_db()->get_current_profile();
	    g_debug("%d '%s' '%s'",p.id,p.name.c_str(),p.pin.c_str());
	}
	else
	{
	    gchar ** parts=g_strsplit(parameters," ",2);
	    guint count=g_strv_length(parts);
	    if (count==2 && !strcmp(parts[0],"new"))
	    {
		int id=context->get_db()->create_profile(parts[1],"");
		g_debug("Created profile %d",id);
	    }
	    else if (count==2 && !strcmp(parts[0],"switch"))
	    {
		int id=atoi(parts[1]);
		if (context->profile_switch(id))
		{
		    g_debug("Switched to profile %d",id);
		}
		else
		{
		    g_debug("No such profile");		    
		}
	    }
	    else
	    {
		g_debug("Usage: '/profile new <name>' or '/profile switch <id>'");
	    }
	    g_strfreev(parts);	    
	}
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
    
    if (is_running)
	return TP_RUN_ALREADY_RUNNING;
       
    is_running=true;
    
    int result=TP_RUN_OK;

    // Validate our configuration
    // Any problem here will just abort - these are likely programming errors.
    
    validate_configuration();
    
    // Open the system database
    
    sysdb=SystemDatabase::open(get(TP_DATA_PATH));
    
    if (!sysdb)
    {
	result=TP_RUN_SYSTEM_DATABASE_CORRUPT;
    }
    else
    {
	// Get the current profile from the database and set it into our
	// configuration
	
	SystemDatabase::Profile profile=sysdb->get_current_profile();
	set(PROFILE_ID,profile.id);
	set(PROFILE_NAME,profile.name);
	
	// Let the world know that the profile has changed
	
	notify(TP_NOTIFICATION_PROFILE_CHANGED);
	
	// Load the app
	
	result=load_app();
	
	// Get rid of the system database
	
	delete sysdb;
	sysdb=NULL;
    }
        
    is_running = false;
    
    return result;
}

//-----------------------------------------------------------------------------

int TPContext::load_app()
{
    int result=TP_RUN_OK;
    
    // Get the base path for the app
    const char * app_path = get(TP_APP_PATH);
    
    // Load metadata    
    if (!load_app_metadata(app_path))
	return TP_RUN_APP_CORRUPT;
    
    // Prepare for the app
    if (!prepare_app())
	return TP_RUN_APP_PREPARE_FAILED;
    
    // Start up a lua state
    lua_State * L = lua_open();
    g_assert(L);
    
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
    luaopen_profile(L);
    luaopen_xml(L);
    
    // This should not be opened for all apps - only trusted ones. Since we
    // don't have a mechanism for determining trustworthiness yet...
    
    luaopen_restricted(L);
    
    // Start the console

#ifndef TP_PRODUCTION

    std::auto_ptr<Console> console;

    if (get_bool(TP_CONSOLE_ENABLED,true))
    {
	console.reset(new Console(L,get_int(TP_TELNET_CONSOLE_PORT,8008)));
	console->add_command_handler(console_command_handler,this);
    }
    
#endif

    // Load the app
    
    notify(TP_NOTIFICATION_APP_LOADING);
    
    // Run the script
    gchar * main_path=g_build_filename(app_path,"main.lua",NULL);
    Util::GFreeLater free_main_path(main_path);
        
    if (luaL_dofile(L,main_path))
    {
	notify(TP_NOTIFICATION_APP_LOAD_FAILED);
	
        g_warning("%s",lua_tostring(L,-1));
	
	result=TP_RUN_APP_ERROR;
    }
    else
    {
	notify(TP_NOTIFICATION_APP_LOADED);
		
	clutter_main();
    
	notify(TP_NOTIFICATION_APP_CLOSING);
    }
    
    clutter_group_remove_all(CLUTTER_GROUP(clutter_stage_get_default()));
    
    Network::shutdown();
    
    lua_close(L);
    
    notify(TP_NOTIFICATION_APP_CLOSED);
        
    return result;
}

//-----------------------------------------------------------------------------

void TPContext::quit()
{
    if (!is_running)
	return;
       
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
    gchar * line=NULL;
	
    // This is before a context is created, so we just print out the message
    
    if (!self)
    {
	line=format_log_line(log_domain,log_level,message);
	fprintf(stderr,"%s",line);
    }
    
    // Otherwise, we have a context and more choices as to what we can do with
    // the log messages
    
    else
    {
	TPContext * context=(TPContext*)self;
	
	if (context->external_log_handler)
	{
	    context->external_log_handler(log_level,log_domain,message,context->external_log_handler_data);
	}
	else
	{
	    line=format_log_line(log_domain,log_level,message);
	    fprintf(stderr,"%s",line);
	}
	
	if (context->output_handlers.size())
	{
	    if (!line)
		line=format_log_line(log_domain,log_level,message);
		
	    for (OutputHandlerSet::const_iterator it=context->output_handlers.begin();
		 it!=context->output_handlers.end();++it)
		it->first(line,it->second);
	}	
    }
    
    g_free(line);
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
    request_handlers[String(subject)]=RequestHandlerClosure(handler,data);
}

//-----------------------------------------------------------------------------

void TPContext::add_output_handler(OutputHandler handler,gpointer data)
{
    output_handlers.insert(OutputHandlerClosure(handler,data));
}

//-----------------------------------------------------------------------------

void TPContext::remove_output_handler(OutputHandler handler,gpointer data)
{
    output_handlers.erase(OutputHandlerClosure(handler,data));    
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
    bool it_is_a_uri=false;
    
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
		it_is_a_uri=true;
		    
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
		    
		    g_free(result);
		    
		    try_path=g_build_filename(app_path,"localized",language,NULL);
		    
		    result=Util::rebase_path(try_path,uri);
		    
		    g_free(try_path);
		    
		    if (!g_file_test(result,G_FILE_TEST_EXISTS))
		    {
			// Try <app>/localized/<path>
			
			g_free(result);
			
			try_path=g_build_filename(app_path,"localized",NULL);
			
			result=Util::rebase_path(try_path,uri);
			
			g_free(try_path);
			
			if (!g_file_test(result,G_FILE_TEST_EXISTS))
			{
			    // End up with <app>/<path>
			    
			    g_free(result);
			    
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
    
    if (is_uri)
	*is_uri=it_is_a_uri;
	
#ifdef TP_PRODUCTION

    // Check for links
    
    if (!it_is_a_uri && g_file_test(result,G_FILE_TEST_IS_SYMLINK))
    {
	g_error("SYMBOLIC LINKS NOT ALLOWED : %s",result );
    }
    
#endif

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

gchar * TPContext::format_log_line(const gchar * log_domain,GLogLevelFlags log_level,const gchar * message)
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
    
    return g_strdup_printf("%p %2.2d:%2.2d:%2.2d:%3.3lu %s %s %s\n" ,
            g_thread_self() ,
            hour , min , sec , ms , level , log_domain , message );    
}

//-----------------------------------------------------------------------------

SystemDatabase * TPContext::get_db() const
{
    g_assert(sysdb);
    return sysdb;
}

//-----------------------------------------------------------------------------

void TPContext::key_event(const char * key)
{
    if (key_map.empty())
    {
	key_map["UP"	]=CLUTTER_Up;
	key_map["DOWN"	]=CLUTTER_Down;
	key_map["LEFT"	]=CLUTTER_Left;
	key_map["RIGHT"	]=CLUTTER_Right;
	key_map["OK"	]=CLUTTER_Return;
    }
    
    KeyMap::const_iterator it=key_map.find(String(key));
    
    if (it==key_map.end())
	return;
    
    clutter_threads_enter();
    
    ClutterEvent * event=clutter_event_new(CLUTTER_KEY_PRESS);
    event->any.stage=CLUTTER_STAGE(clutter_stage_get_default());
    event->any.time=clutter_get_timestamp();
    event->any.flags=CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->key.keyval=it->second;
    
    clutter_event_put(event);
    
    event->type=CLUTTER_KEY_RELEASE;
    event->any.time=clutter_get_timestamp();
    
    clutter_event_put(event);
    
    clutter_event_free(event);
    
    clutter_threads_leave();
}

//-----------------------------------------------------------------------------

bool TPContext::profile_switch(int id)
{
    SystemDatabase::Profile profile=get_db()->get_profile(id);
    
    if (profile.id==0)
    {
	return false;
    }
    
    notify(TP_NOTIFICATION_PROFILE_CHANGING);
    
    get_db()->set(TP_DB_CURRENT_PROFILE_ID,id);
    set(PROFILE_ID,id);
    set(PROFILE_NAME,profile.name);
    
    notify(TP_NOTIFICATION_PROFILE_CHANGED);

    return true;    
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
    
    g_log_set_default_handler(TPContext::log_handler,NULL);        
}

//-----------------------------------------------------------------------------

TPContext * tp_context_new()
{
    return new TPContext();    
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

void tp_context_key_event(TPContext * context,const char * key)
{
    context->key_event(key);
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
