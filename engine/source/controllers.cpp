
#include <cstring>
#include <cstdio>
#include <cstdlib>

#include "clutter/clutter.h"

#include "controllers.h"
#include "util.h"

//-----------------------------------------------------------------------------

bool Controllers::ControllerInfo::has_accelerometer() const
{
    return caps.find(String("AX")) != caps.end();    
}

//-----------------------------------------------------------------------------

Controllers::Controllers(TPContext * ctx,const String & name,int port)
:
    mdns(NULL),
    server(NULL),
    context(ctx)
{
    GError * error=NULL;
    
    Server * new_server=new Server(port,this,'\n',&error);
    
    if (error)
    {
        delete new_server;
        g_warning("FAILED TO START CONTROLLERS LISTENER ON PORT %d : %s",port,error->message);
        g_clear_error(&error);
    }
    else
    {
        server.reset(new_server);
        
        g_info("CONTROLLERS LISTENER READY ON PORT %d",server->get_port());
        
        mdns.reset(new MDNS(name,server->get_port()));
    }
}

//-----------------------------------------------------------------------------

Controllers::~Controllers()
{
}

//-----------------------------------------------------------------------------

bool Controllers::is_ready() const
{
    if (!mdns.get())
        return false;
    
    return mdns->is_ready();
}


//-----------------------------------------------------------------------------

void Controllers::add_delegate(Controllers::Delegate * delegate)
{
    if (!delegate)
        return;
    
    delegates.insert(delegate);
}

//-----------------------------------------------------------------------------

void Controllers::remove_delegate(Controllers::Delegate * delegate)
{
    if (!delegate)
        return;
    
    delegates.erase(delegate);
}

//-----------------------------------------------------------------------------

Controllers::ControllerInfo * Controllers::find_controller(gpointer source)
{
    ConnectionInfo * ci=find_connection(source);
    
    return ci?&ci->controller:NULL;
}

//-----------------------------------------------------------------------------

bool Controllers::start_accelerometer(gpointer source,const char * filter,double interval)
{
    gchar * line=g_strdup_printf("START\tAX\t%s\t%f\n",filter,interval);
    Util::GFreeLater free_line(line);
    
    return write_line(source,line);
}

//-----------------------------------------------------------------------------

bool Controllers::stop_accelerometer(gpointer source)
{
    return write_line(source,"STOP\tAX\n");
}

//-----------------------------------------------------------------------------

bool Controllers::reset(gpointer source)
{
    return write_line(source,"RESET\n");
}

//-----------------------------------------------------------------------------

bool Controllers::ui_clear(gpointer source)
{
    return write_line(source,"UI\tCLEAR\n");
}

//-----------------------------------------------------------------------------

bool Controllers::ui_show_multiple_choice(gpointer source,const String & label,const StringPairList & choices)
{
    String line("UI\tMC\tMC_LABEL\t");
    
    line.append(label);
    
    for (StringPairList::const_iterator it=choices.begin();it!=choices.end();++it)
    {
        line.append("\t");
        line.append(it->first);
        line.append("\t");
        line.append(it->second);
    }
    
    line.append("\n");
    
    return write_line(source,line.c_str());
}

//-----------------------------------------------------------------------------

bool Controllers::ui_declare_resource(gpointer source,const String &label, const String &url)
{
    String line("RESOURCE\t");
    line.append(label);
    line.append("\t");
    line.append(url);
    line.append("\n");
    
    return write_line(source, line.c_str());
}

//-----------------------------------------------------------------------------

bool Controllers::ui_background_image(gpointer source,const String &resource_label)
{
    String line("BACKGROUND\t");
    line.append(resource_label);
    line.append("\n");
    
    return write_line(source, line.c_str());
}

//-----------------------------------------------------------------------------

bool Controllers::ui_play_sound(gpointer source,const String &resource_label, unsigned int loop)
{
    gchar * line=g_strdup_printf("PLAYSOUND\t%s\t%d\n",resource_label.c_str(),loop);
    Util::GFreeLater free_line(line);

    return write_line(source,line);
}

//-----------------------------------------------------------------------------

bool Controllers::ui_stop_sound(gpointer source)
{
    return write_line(source, "STOPSOUND\n");
}

//-----------------------------------------------------------------------------

bool Controllers::write_line(gpointer source,const gchar * line)
{
    if (!server.get())
        return false;
    
    if (!find_connection(source))
        return false;
    
    return server->write(source,line);
}

//-----------------------------------------------------------------------------

Controllers::ConnectionInfo * Controllers::find_connection(gpointer connection)
{
    ConnectionMap::iterator it=connections.find(connection);
    
    return it==connections.end()?NULL:&it->second;
}

//-----------------------------------------------------------------------------

void Controllers::connection_accepted(gpointer connection,const char * remote_address)
{
    g_debug("ACCEPTED CONTROLLER CONNECTION %p FROM %s",connection,remote_address);
    
    // This adds the connection to the map and sets its address at the same time
    
    ConnectionInfo & info=connections[connection];
    
    info.controller.address=remote_address;
    
    // Now, set a timer to disconnect the connection if it has not identified
    // itself within a few seconds
    
    GSource * source=g_timeout_source_new( 10 * 1000 ); // 10 seconds	    
    g_source_set_callback(source,timed_disconnect_callback,new TimerClosure(connection,this),NULL);
    g_source_attach(source,g_main_context_default());
    g_source_unref(source);    
}

//-----------------------------------------------------------------------------

gboolean Controllers::timed_disconnect_callback(gpointer data)
{
    g_debug("TIMED DISCONNECT");
    
    // Check to see that the controller has reported a version
    
    TimerClosure * tc=(TimerClosure*)data;
    
    ConnectionInfo * ci=tc->self->find_connection(tc->connection);
    
    if (ci && ci->disconnect && !ci->controller.version)
    {
        g_debug("DROPPING UNIDENTIFIED CONNECTION %p",tc->connection);
        
        if (tc->self->server.get())
        {
            tc->self->server->close_connection(tc->connection);
        }
    }
    
    delete tc;
    
    return FALSE;
}

//-----------------------------------------------------------------------------

void Controllers::connection_closed(gpointer connection)
{
    connections.erase(connection);
    
    g_debug("CONTROLLER CONNECTION CLOSED %p",connection);
    
    for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
    {
        (*it)->disconnected(connection);    
    }
}

//-----------------------------------------------------------------------------

void Controllers::connection_data_received(gpointer connection,const char * line)
{
    ConnectionMap::iterator it=connections.find(connection);
    
    if (it==connections.end())
        return;
    
    if (it->second.http.is_http)
    {
        handle_http_line(connection,it->second,line);        
    }
    else
    {
        if (!strlen(line))
            return;
    
        gchar ** parts=g_strsplit(line,"\t",0);
                
        process_command(connection,it->second.controller,parts);
                
        g_strfreev(parts);
    }
}

//-----------------------------------------------------------------------------

void Controllers::process_command(gpointer connection,ControllerInfo & info,gchar ** parts)
{
    guint count=g_strv_length(parts);
    
    if (count<1)
        return;
    
    switch(*(parts[0]))
    {
        // Identification line
        // DEVICE   <version>   <name>  <cap1>  <cap2>
        
        case 'D':
        {
            // Not enough parts - bad command
            if (count<3)
                return;
            
            // Already have device info 
            if (info.version)
                return;
            
            info.version=atoi(parts[1]);
            
            // Version 0?
            if (!info.version)
                return;
            
            info.name=g_strstrip(parts[2]);
            
            // Capability entries
            for (guint i=3;i<count;++i)
            {
                gchar * cap=g_strstrip(parts[i]);
                if (strlen(cap))
                    info.caps.insert(cap);
            }
            
            for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
            {
                (*it)->connected(connection,info);
            }
            
            break;   
        }
            
        
        // key input
        
        case 'K':
        {
            if (count>1)
            {
                unsigned long int k=0;
                if (sscanf(parts[1],"%lx",&k)==1)
                {
                    g_debug("GOT KEY %ld",k);
                    
                    context->key_event_keysym(k);                    
                }
            }
            break;    
        }
        

		// clicks

        case 'C':
        {
			// CLICK	x	y
			if (count < 3) return;
			
			double x = atof(parts[1]);
			double y = atof(parts[2]);
			
			for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
			{
				(*it)->click(connection, x, y);
			}
        }

        // accelerometer data
        
        case 'A':
        {
            // AX   x   y   z
            
            if (count<4)
                return;
            
            double x=atof(parts[1]);
            double y=atof(parts[2]);
            double z=atof(parts[3]);
            
            for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
            {
                (*it)->accelerometer(connection,x,y,z);
            }
            
            break;
        }
        
        // ui event
        
        case 'U':
        {
            // UI   <event>
            
            if (count<2)
                return;
            
            for(DelegateSet::iterator it=delegates.begin();it!=delegates.end();++it)
            {
                (*it)->ui_event(connection,parts[1]);
            }
            break;
        }
        
        // http get?
        
        case 'G':
        {
            handle_http_get(connection,parts[0]);
            break;
        }
    }
}

//-----------------------------------------------------------------------------

void Controllers::handle_http_get(gpointer connection,const gchar * line)
{
    ConnectionInfo * info=find_connection(connection);
    
    if (!info)
    {
        return;
    }
    
    gchar ** parts=g_strsplit(line," ",3);

    if (g_strv_length(parts)==3)
    {
        info->disconnect=false;
        info->http.is_http=true;
        info->http.method=parts[0];
        info->http.url=parts[1];
        info->http.version=parts[2];        
    }
    
    g_strfreev(parts);
}

//-----------------------------------------------------------------------------

void Controllers::handle_http_line(gpointer connection,ConnectionInfo & info,const gchar * line)
{
    HTTPInfo & hi=info.http;
    
    if (!hi.headers_done)
    {
        if (strlen(line))
        {
// We are not using the headers yet
#if 0
            
            hi.headers.push_back(line);
            
            // Protect against too many headers
            
            if (hi.headers.size()>256)
            {
                server->close_connection(connection);
            }
#endif            
        }
        else
        {
            // We have received all the headers
            
#if 0
            for(StringList::const_iterator it=hi.headers.begin();it!=hi.headers.end();++it)
            {
                g_debug("[%s]",it->c_str());    
            }
#endif            
            
            g_debug("PROCESSING %s '%s'",hi.method.c_str(),hi.url.c_str());
            
            bool found=false;
            
            if (hi.url.size()>1)
            {
                String id(hi.url.substr(1));
                
                WebServerPathMap::const_iterator it=path_map.find(id);
                
                if (it!=path_map.end())
                {
                    String path(it->second.first);
                                        
                    found=server->write_file(connection,path.c_str(),true);
                    
                    g_debug("  SERVED '%s'",path.c_str());
                }
            }
            
            if (!found)
            {
                server->write_printf(connection,"%s 404 Not found\r\nContent-Length: 0\r\n\r\n",hi.version.c_str());
                
                g_debug("  NOT FOUND");
            }
            
            hi.reset();
        }
    }
}

//-----------------------------------------------------------------------------

String Controllers::serve_path(const String & group,const String & path)
{
    String s=group+":"+path;
    
    gchar * id=g_compute_checksum_for_string(G_CHECKSUM_SHA1,s.c_str(),-1);
    String result(id);
    g_free(id);
    
    if (path_map.find(result)==path_map.end())
    {
        g_debug("SERVING %s : %s",result.c_str(),path.c_str());
        
        path_map[result]=StringPair(path,group);
    }
    
    return result;
}
    
//-----------------------------------------------------------------------------

void Controllers::drop_web_server_group(const String & group)
{
    for(WebServerPathMap::iterator it=path_map.begin();it!=path_map.end();)
    {
        if (it->second.second==group)
        {
            g_debug("DROPPING %s : %s",it->first.c_str(),it->second.first.c_str());
            
            path_map.erase(it++);
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------
