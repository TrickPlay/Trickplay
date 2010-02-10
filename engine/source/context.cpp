#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <sstream>

#include "clutter/clutter.h"
#include "curl/curl.h"

#include "context.h"
#include "app.h"
#include "network.h"
#include "util.h"
#include "console.h"
#include "sysdb.h"
#include "controllers.h"
#include "mediaplayers.h"

//-----------------------------------------------------------------------------
// Internal context
//-----------------------------------------------------------------------------

TPContext::TPContext()
:
    is_running(false),
    sysdb(NULL),
    controllers(NULL),
    console(NULL),
    current_app(NULL),
    media_player_constructor(NULL),
    media_player(NULL),
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
	    g_info("%-15.15s %s",it->first.c_str(),it->second.c_str());
    }
    else if (!strcmp(command,"profile"))
    {
	if (!parameters)
	{
	    SystemDatabase::Profile p=context->get_db()->get_current_profile();
	    g_info("%d '%s' '%s'",p.id,p.name.c_str(),p.pin.c_str());
	}
	else
	{
	    gchar ** parts=g_strsplit(parameters," ",2);
	    guint count=g_strv_length(parts);
	    if (count==2 && !strcmp(parts[0],"new"))
	    {
		int id=context->get_db()->create_profile(parts[1],"");
		g_info("Created profile %d",id);
	    }
	    else if (count==2 && !strcmp(parts[0],"switch"))
	    {
		int id=atoi(parts[1]);
		if (context->profile_switch(id))
		{
		    g_info("Switched to profile %d",id);
		}
		else
		{
		    g_info("No such profile");		    
		}
	    }
	    else
	    {
		g_info("Usage: '/profile new <name>' or '/profile switch <id>'");
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
    //.........................................................................
    // So that run cannot be called while we are running
    
    if (is_running)
	return TP_RUN_ALREADY_RUNNING;
       
    is_running=true;
    
    int result=TP_RUN_OK;
    
    //.........................................................................
    // Load external configuration variables (from the environment or a file)

    load_external_configuration();

    //.........................................................................
    // Validate our configuration
    // Any problem here will just abort - these are likely programming errors.
    
    validate_configuration();
    
    //.........................................................................
    // Open the system database
    
    sysdb=SystemDatabase::open(get(TP_DATA_PATH));
    
    if (!sysdb)
    {
	is_running=false;
	return TP_RUN_SYSTEM_DATABASE_CORRUPT;
    }

    //.........................................................................
    // Scan for apps
    
    {
	bool force=get_bool(TP_SCAN_APP_SOURCES,TP_SCAN_APP_SOURCES_DEFAULT);
	const char * app_sources=get(TP_APP_SOURCES);
	gchar * installed_root=g_build_filename(get(TP_DATA_PATH),"apps",NULL);
    
	if (force||get(TP_APP_ID))
	    App::scan_app_sources(sysdb,app_sources,installed_root,force);
	
	g_free(installed_root);
    }
    
    //.........................................................................
    // Get the current profile from the database and set it into our
    // configuration
    
    SystemDatabase::Profile profile=sysdb->get_current_profile();
    set(PROFILE_ID,profile.id);
    set(PROFILE_NAME,profile.name);
    
    //.........................................................................
    // Let the world know that the profile has changed
    
    notify(TP_NOTIFICATION_PROFILE_CHANGED);
    
    //.........................................................................
    // Create the controllers listener
    
    if (get_bool(TP_CONTROLLERS_ENABLED,TP_CONTROLLERS_ENABLED_DEFAULT))
    {
	// Figure out the name for the controllers service. If one is passed
	// in to the context, we use it. Otherwise, we look in the database.
	// If the name is new, we store it in the database.
	
	String name;
	String stored_name=sysdb->get_string(TP_CONTROLLERS_NAME);
	
	const char * new_name=get(TP_CONTROLLERS_NAME);
	
	if (new_name)
	{
	    name=new_name;
	}	    
	else
	{
	    if (!stored_name.empty())
	    {
		name=stored_name;
	    }
	    else
	    {
		name=TP_CONTROLLERS_NAME_DEFAULT;
	    }
	}
	
	if (name!=stored_name)
	{
	    sysdb->set(TP_CONTROLLERS_NAME,name);
	}
	
	controllers=new Controllers(name,get_int(TP_CONTROLLERS_PORT,TP_CONTROLLERS_PORT_DEFAULT));
    }
    
    //.........................................................................
    // Start the console

#ifndef TP_PRODUCTION

    if (get_bool(TP_CONSOLE_ENABLED,TP_CONSOLE_ENABLED_DEFAULT))
    {
	console=new Console(this,get_int(TP_TELNET_CONSOLE_PORT,TP_TELNET_CONSOLE_PORT_DEFAULT));
	console->add_command_handler(console_command_handler,this);
    }

#endif

    //.........................................................................
    // Set default size and color for the stage
    
    ClutterActor * stage=clutter_stage_get_default();
    
    clutter_actor_set_width(stage,get_int(TP_SCREEN_WIDTH));
    clutter_actor_set_height(stage,get_int(TP_SCREEN_HEIGHT));
    
    ClutterColor color;
    color.red=0;
    color.green=0;
    color.blue=0;
    color.alpha=0;
    
    clutter_stage_set_color(CLUTTER_STAGE(stage),&color);
    
    //.........................................................................
    // Create the default media player. This may come back NULL.
    
    media_player=MediaPlayer::make(media_player_constructor);
    
    //.........................................................................
    // Load the app
    
    notify(TP_NOTIFICATION_APP_LOADING);
    
    result=load_app(&current_app);

    if (!current_app)
    {
	notify(TP_NOTIFICATION_APP_LOAD_FAILED);	
    }
    else
    {
	//.....................................................................
	// Execute the app's script
	
	result=current_app->run();
	
	if (result!=TP_RUN_OK)
	{
	    notify(TP_NOTIFICATION_APP_LOAD_FAILED);
	}
	else
	{
	    notify(TP_NOTIFICATION_APP_LOADED);

	    //.................................................................
	    // Attach the console to the app
	    
	    if (console)
	    {
		console->attach_to_lua(current_app->get_lua_state());
	    }
		    
	    //.................................................................
	    // Dip into the loop
	    
	    clutter_main();
	
	    notify(TP_NOTIFICATION_APP_CLOSING);
			
	    notify(TP_NOTIFICATION_APP_CLOSED);        		
	}
	
	//.....................................................................
	// Clean up the stage
	
	clutter_group_remove_all(CLUTTER_GROUP(clutter_stage_get_default()));
	
	//.....................................................................
	// Kill the network thread
	
	Network::shutdown();
	
	//.....................................................................
	// Detach the console
	
	if (console)
	{
	    console->attach_to_lua(NULL);
	}

	//.....................................................................
	// Reset the media player, just in case
	
	if (media_player)
	{
	    media_player->reset();
	}
    
	//.....................................................................
	// Shutdown the app
		
	delete current_app;
	current_app=NULL;

	//.....................................................................
	// Kill the media player
	
	if (media_player)
	{
	    delete media_player;
	    media_player=NULL;
	}
    }
    
    //........................................................................
    // Delete the console
    
    if (console)
    {
	delete console;
	console=NULL;
    }

    //.........................................................................
    // Get rid of the controllers
    
    if (controllers)
    {
	delete controllers;
	controllers=NULL;
    }
    
    //.........................................................................
    // Get rid of the system database
    
    delete sysdb;
    sysdb=NULL;
        
    //.........................................................................
    // Not running any more
    
    is_running = false;
    
    return result;
}

//-----------------------------------------------------------------------------

int TPContext::load_app(App ** app)
{
    String app_path;
    
    // If an app id was specified, we will try to find the app by id, in the
    // system database
    
    const char * app_id=get(TP_APP_ID);
    
    if(app_id)
    {
	app_path=sysdb->get_app_path(app_id);
	if (app_path.empty())
	{
	    g_warning("FAILED TO FIND %s IN THE SYSTEM DATABASE",app_id);
	    return TP_RUN_APP_NOT_FOUND;
	}
	set(TP_APP_PATH,app_path);
    }
    else
    {
	// Get the base path for the app
	app_path=get(TP_APP_PATH);
    }
    
    // Load metadata
    
    App::Metadata md;
    
    if (!App::load_metadata(app_path.c_str(),md))
    {
	return TP_RUN_APP_CORRUPT;
    }
    
    // Load the app
    
    *app=App::load(this,md);
    
    if (!*app)
    {
	return TP_RUN_APP_PREPARE_FAILED;
    }
    
    return TP_RUN_OK;
}

//-----------------------------------------------------------------------------

int TPContext::launch_app(const char * app_id)
{
    String app_path=get_db()->get_app_path(app_id);
    
    if (app_path.empty())
    {
	return TP_RUN_APP_NOT_FOUND;
    }
    
    App::Metadata md;
    
    if (!App::load_metadata(app_path.c_str(),md))
    {
	return TP_RUN_APP_CORRUPT;
    }
    
    App * new_app=App::load(this,md);
    
    if (!new_app)
    {
	return TP_RUN_APP_PREPARE_FAILED;	
    }
    
    int result=new_app->run();
    
    if (result!=TP_RUN_OK)
    {
	delete new_app;
	return result;
    }
    
    g_idle_add_full(G_PRIORITY_HIGH,launch_app_callback,new_app,NULL);
    
    return 0;
}

//-----------------------------------------------------------------------------

gboolean TPContext::launch_app_callback(gpointer app)
{
    App * new_app=(App*)app;
    TPContext * context=new_app->get_context();
    
    if (context->console)
    {
	context->console->attach_to_lua(new_app->get_lua_state());
    }

    Network::shutdown();
    
    // TODO
    // We should also reset the controllers
    
    delete context->current_app;
    
    context->current_app=new_app;
    
    return FALSE;
}

//-----------------------------------------------------------------------------

void TPContext::quit()
{
    if (!is_running)
	return;
       
    clutter_main_quit();
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
	
	if (!context->output_handlers.empty())
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

int TPContext::request(const char * subject)
{
    RequestHandlerMap::const_iterator it=request_handlers.find(String(subject));
    
    return it==request_handlers.end() ? 1 : it->second.first(subject,it->second.second);
}

//-----------------------------------------------------------------------------
// Load configuration variables from the environment or a file

void TPContext::load_external_configuration()
{
    if (get_bool(TP_CONFIG_FROM_ENV,TP_CONFIG_FROM_ENV_DEFAULT))
    {
	gchar ** env=g_listenv();
	
	for(gchar ** e=env;*e;++e)
	{
	    if (g_str_has_prefix(*e,"TP_"))
	    {
		if(const gchar * v=g_getenv(*e))
		{
		    gchar * k=g_strstrip(g_strdelimit((*e)+3,"_",'.'));
		    
		    g_info("ENV:%s=%s",k,v);
		    set(k,v);
		}
	    }
	}
	
	g_strfreev(env);
    }
    
    const char * file_name=get(TP_CONFIG_FROM_FILE,TP_CONFIG_FROM_FILE_DEFAULT);
    
    gchar * contents=NULL;
    
    if (g_file_get_contents(file_name,&contents,NULL,NULL))
    {
	gchar ** lines=g_strsplit(contents,"\n",0);
	
	for(gchar ** l=lines;*l;++l)
	{
	    gchar * line=g_strstrip(*l);

	    if (g_str_has_prefix(line,"#"))
		continue;
	    
	    gchar ** parts=g_strsplit(line,"=",2);
	    
	    if (g_strv_length(parts)==2)
	    {
		gchar * k=g_strstrip(parts[0]);
		gchar * v=g_strstrip(parts[1]);
		
		g_info("FILE:%s:%s=%s",file_name,k,v);
		set(k,v);
	    }
	    
	    g_strfreev(parts);
	}
	
	g_strfreev(lines);
	g_free(contents);
    }
}


//-----------------------------------------------------------------------------

void TPContext::validate_configuration()
{
    // TP_APP_SOURCES
    
    const char * app_sources=get(TP_APP_SOURCES);
    
    if (!app_sources)
    {
	gchar * s=g_build_filename(g_get_current_dir(),"apps",NULL);
	set(TP_APP_SOURCES,s);
	g_warning("DEFAULT:%s=%s",TP_APP_SOURCES,s);
	g_free(s);
    }
    
    // TP_APP_PATH
    
    const char * app_path=get(TP_APP_PATH);
    
    if (!app_path && !get(TP_APP_ID))
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
	set(TP_SYSTEM_LANGUAGE,TP_SYSTEM_LANGUAGE_DEFAULT);
	g_warning("DEFAULT:%s=%s",TP_SYSTEM_LANGUAGE,TP_SYSTEM_LANGUAGE_DEFAULT);
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
	set(TP_SYSTEM_COUNTRY,TP_SYSTEM_COUNTRY_DEFAULT);
	g_warning("DEFAULT:%s=%s",TP_SYSTEM_COUNTRY,TP_SYSTEM_COUNTRY_DEFAULT);
    }
    else if (strlen(country)!=2)
    {
	g_error("Country must be a 2 character, upper case, ISO-3166-1-alpha-2 code : '%s' is too long",country);
    }
    else if (!g_ascii_isupper(country[0])||!g_ascii_isupper(country[1]))
    {
	g_error("Country must be a 2 character, upper case, ISO-3166-1-alpha-2 code : '%s' is invalid",country);
    }
    
    // SYSTEM NAME
    
    if (!get(TP_SYSTEM_NAME))
    {
	set(TP_SYSTEM_NAME,TP_SYSTEM_NAME_DEFAULT);
	g_warning("DEFAULT:%s=%s",TP_SYSTEM_NAME,TP_SYSTEM_NAME_DEFAULT);
    }
    
    // SYSTEM VERSION

    if (!get(TP_SYSTEM_VERSION))
    {
	set(TP_SYSTEM_VERSION,TP_SYSTEM_VERSION_DEFAULT);
	g_warning("DEFAULT:%s=%s",TP_SYSTEM_VERSION,TP_SYSTEM_VERSION_DEFAULT);
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
    
    // SCREEN WIDTH AND HEIGHT
    
    if (!get(TP_SCREEN_WIDTH))
	set(TP_SCREEN_WIDTH,TP_SCREEN_WIDTH_DEFAULT);
	
    if (!get(TP_SCREEN_HEIGHT))
	set(TP_SCREEN_HEIGHT,TP_SCREEN_HEIGHT_DEFAULT);
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

Controllers * TPContext::get_controllers() const
{
    return controllers;
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
    
    notify(TP_NOTIFICATION_PROFILE_CHANGE);
    
    notify(TP_NOTIFICATION_PROFILE_CHANGED);

    return true;    
}

//-----------------------------------------------------------------------------

MediaPlayer * TPContext::get_default_media_player()
{
    return media_player;
}

MediaPlayer * TPContext::create_new_media_player(MediaPlayer::Delegate * delegate)
{
    return MediaPlayer::make(media_player_constructor,delegate);
}

//-----------------------------------------------------------------------------
// External-facing functions
//-----------------------------------------------------------------------------

void tp_init_version(int * argc,char *** argv,int major_version,int minor_version,int patch_version)
{
    if(!g_thread_supported())
	g_thread_init(NULL);
	
    if (!(major_version==TP_MAJOR_VERSION &&
	  minor_version==TP_MINOR_VERSION &&
	  patch_version==TP_PATCH_VERSION))
    {
	g_warning("TRICKPLAY VERSION MISMATCH : HOST (%d.%d.%d) : LIBRARY (%d.%d.%d)",
		  major_version,minor_version,patch_version,
		  TP_MAJOR_VERSION,TP_MINOR_VERSION,TP_PATCH_VERSION);
    }
    
        
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
// Media player
//-----------------------------------------------------------------------------

void tp_context_set_media_player_constructor(TPContext * context,TPMediaPlayerConstructor constructor)
{
    context->media_player_constructor=constructor;
}

