#include "app.h"
#include "http_trickplay_api_support.h"
#include "util.h"
#include "sysdb.h"
#include "json.h"
#include "clutter_util.h"

//-----------------------------------------------------------------------------

class Handler : public HttpServer::RequestHandler
{
public:

    Handler( TPContext * _context , const String & path )
    :
    	HttpServer::RequestHandler( _context->get_http_server() , path ),
        context( _context )
    {
    }

protected:

    TPContext * context;

private:

    Handler() {}
    Handler( const Handler & ) {}
};

//-----------------------------------------------------------------------------

#ifndef TP_PRODUCTION

class DebugUIRequestHandler: public Handler
{
public:

	DebugUIRequestHandler( TPContext * ctx )
	:
	    Handler( ctx , "/debug/ui" )
	{
	}

	void handle_http_get( const HttpServer::Request& request, HttpServer::Response& response )
	{

	    using namespace JSON;

	    Object object;

	    dump_ui_actors( context->get_stage(), object );

	    response.set_status( HttpServer::HTTP_STATUS_OK );

	    String result( object.stringify() );

	    if ( ! result.empty() )
	    {
		    response.set_response( "application/json", result.data(), result.size() );
	    }
	    else
	    {
		    response.set_status(HttpServer::HTTP_STATUS_NOT_FOUND);
	    }
	}

	void handle_http_post( const HttpServer::Request & request, HttpServer::Response & response )
	{
		response.set_status( HttpServer::HTTP_STATUS_NOT_FOUND );

		using namespace JSON;

		const char * body = request.get_body().get_data();

		if ( ! body )
		{
			return;
		}

//		g_debug( "[%s]" , body );

		Value v = Parser::parse( body );

		if ( v.is<Null>() )
		{
			g_debug( "FAILED TO PARSE JSON" );
			return;
		}

		Object & o( v.as<Object>() );

        String gid_str = o["gid"].as<String>();
		ClutterActor * actor = (ClutterActor *) g_ascii_strtoull(gid_str.c_str(), NULL, 16);

		// Bug in Clutter 1.6.14 where free ids are set to this value

		if ( ! actor || actor == (gpointer) 0xdecafbad )
		{
			g_debug( "UI ELEMENT NOT FOUND" );
			return;
		}

		GObjectClass * klass = G_OBJECT_GET_CLASS( G_OBJECT( actor ) );

		Object & props( o[ "properties" ].as<Object>() );

		for( Object::Map::iterator it = props.begin(); it != props.end(); ++it )
		{
			GParamSpec * pspec = g_object_class_find_property( klass , it->first.c_str() );

			if ( ! pspec )
			{
				g_debug( "SKIPPING UNKNOWN PROPERTY '%s'" , it->first.c_str() );
				continue;
			}

//			g_debug( "'%s' : %s" , it->first.c_str() , g_type_name( pspec->value_type ) );

			GValue value = {0};

			g_value_init( & value , pspec->value_type );

			switch( pspec->value_type )
			{
			case G_TYPE_FLOAT:
				g_value_set_float( & value , it->second.as_number() );
				break;

			case G_TYPE_DOUBLE:
				g_value_set_double( & value , it->second.as_number() );
				break;

			case G_TYPE_BOOLEAN:
				g_value_set_boolean( & value , it->second.as<bool>() );
				break;

			case G_TYPE_INT:
				g_value_set_int( & value , it->second.as<long long>() );
				break;

			case G_TYPE_INT64:
				g_value_set_int64( & value , it->second.as<long long>() );
				break;

			case G_TYPE_LONG:
				g_value_set_long( & value , it->second.as<long long>() );
				break;

			case G_TYPE_UINT:
				g_value_set_uint( & value , it->second.as<long long>() );
				break;

			case G_TYPE_UINT64:
				g_value_set_uint64( & value , it->second.as<long long>() );
				break;

			case G_TYPE_ULONG:
				g_value_set_ulong( & value , it->second.as<long long>() );
				break;

			case G_TYPE_STRING:
				g_value_set_string( & value , it->second.as<String>().c_str() );
				break;

			default:
				{
					bool ok = false;

					if ( pspec->value_type == CLUTTER_TYPE_COLOR )
					{
						ClutterColor color;
						if ( clutter_color_from_string( & color , it->second.as<String>().c_str() ) )
						{
							ok = true;
							clutter_value_set_color( & value , & color );
						}
						else
						{
							g_debug( "FAILED TO PARSE COLOR '%s'" , it->second.as<String>().c_str() );
						}
					}

					if ( ! ok )
					{
						g_debug( "DON'T KNOW HOW TO SET '%s' OF TYPE %s" , it->first.c_str() , g_type_name( pspec->value_type ) );
						g_value_unset( & value );
						continue;
					}
				}
			}

			g_object_set_property( G_OBJECT( actor ) , it->first.c_str() , & value );
			g_value_unset( & value );
		}

		response.set_status( HttpServer::HTTP_STATUS_OK );
	}

private:

	static JSON::Object get_actor_color( const ClutterColor & c )
	{
		JSON::Object color;

		color["r"] = c.red;
		color["g"] = c.green;
		color["b"] = c.blue;
		color["a"] = c.alpha;

		return color;
	}

	static String safe_string( const gchar * s )
	{
		return s ? String( s ) : String();
	}

	static void dump_ui_actors( ClutterActor * actor, JSON::Object & object )
	{
		using namespace JSON;

	    if ( ! actor )
	    {
			return;
	    }

	    object["name"] = safe_string( clutter_actor_get_name( actor ) );

	    const gchar * type = ClutterUtil::get_actor_type( actor );

	    object[ "type" ] = type;

		// x, y, z
		gfloat x;
		gfloat y;
		gfloat z = clutter_actor_get_depth( actor );
		clutter_actor_get_position( actor, &x, &y );
	    Object position;
	    position["x"] = x;
	    position["y"] = y;
	    position["z"] = z;
	    object["position"] = position;

		// w, h
		gfloat w;
		gfloat h;
		clutter_actor_get_size( actor, &w, &h );
	    Object size;
	    size["w"] = w;
	    size["h"] = h;
	    object["size"] = size;

		// Scale
	    gdouble sx;
	    gdouble sy;
		clutter_actor_get_scale( actor, &sx, &sy );
		Object scale;
		scale["x"] = sx;
		scale["y"] = sy;
		object["scale"] = scale;

		// Anchor point
	    gfloat ax;
	    gfloat ay;
	    clutter_actor_get_anchor_point( actor, &ax, &ay );
		Object anchor_point;
		anchor_point["x"] = ax;
		anchor_point["y"] = ay;
		object[ "anchor_point"] = anchor_point;

		// GID
		char gid_str[32];
		snprintf(gid_str, 32, "%p", actor);
		object[ "gid" ] = gid_str;

		// Opacity
	    object[ "opacity" ] = clutter_actor_get_opacity( actor );


		// Visibility
		object[ "is_visible" ] = bool( CLUTTER_ACTOR_IS_VISIBLE( actor ) );

		// Clip
		if ( clutter_actor_has_clip( actor ) )
		{
	        gfloat cxoff;
	        gfloat cyoff;
	        gfloat cw;
	        gfloat ch;
	        clutter_actor_get_clip( actor, &cxoff, &cyoff, &cw, &ch );
	        Object clip;
	        clip["x"] = cxoff;
	        clip["y"] = cyoff;
	        clip["w"] = cw;
	        clip["h"] = ch;
	        object["clip"] = clip;
	    }

	    // Rotation
	    Object x_rotation;
	    Object y_rotation;
	    Object z_rotation;
	    gdouble angle;
	    gfloat rx;
	    gfloat ry;
	    gfloat rz;
	    angle = clutter_actor_get_rotation( actor , CLUTTER_X_AXIS , &rx, &ry, &rz );
	    x_rotation["angle"] = angle;
	    x_rotation["y center"] = ry;
	    x_rotation["z center"] = rz;
	    object["x_rotation"] = x_rotation;

	    angle = clutter_actor_get_rotation( actor , CLUTTER_Y_AXIS , &rx, &ry, &rz );
	    y_rotation["angle"] = angle;
	    y_rotation["x center"] = rx;
	    y_rotation["z center"] = rz;
	    object[ "y_rotation" ] = y_rotation;

	    angle = clutter_actor_get_rotation( actor , CLUTTER_Z_AXIS , &rx, &ry, &rz );
	    z_rotation["angle"] = angle;
	    z_rotation["x center"] = rx;
	    z_rotation["y center"] = ry;
	    object[ "z_rotation"] = z_rotation;

		if ( CLUTTER_IS_TEXT( actor ) )
	    {
			// Text
	        object["text"] = safe_string( clutter_text_get_text( CLUTTER_TEXT( actor ) ) ) ;

			// Color
	        ClutterColor c;
	        clutter_text_get_color( CLUTTER_TEXT( actor ), &c );
			object["color"] = get_actor_color( c );

	        // Font Name
	        object["font"] = safe_string( clutter_text_get_font_name( CLUTTER_TEXT( actor ) ) );
	    }
		else if ( CLUTTER_IS_RECTANGLE( actor ) )
		{
			// Color
			ClutterColor c;
			clutter_rectangle_get_color( CLUTTER_RECTANGLE( actor ), &c );
			object["color"] = get_actor_color( c );

			// Border color
			clutter_rectangle_get_border_color( CLUTTER_RECTANGLE( actor ), &c );
			object["border_color"] = get_actor_color( c );

			// Border width
			object["border_width"] = int( clutter_rectangle_get_border_width( CLUTTER_RECTANGLE( actor ) ) );
		}
		else if ( CLUTTER_IS_TEXTURE( actor ) )
		{
			// src
			object["src"] = safe_string( ( const gchar * ) g_object_get_data( G_OBJECT( actor ) , "tp-src" ) );

			// tile
			gboolean x;
			gboolean y;
			clutter_texture_get_repeat( CLUTTER_TEXTURE( actor ) , &x , &y );
			Object tile;
			tile["x"] = bool( x );
			tile["y"] = bool( y );
			object["tile"] = tile;
		}
		else if ( CLUTTER_IS_CLONE( actor ) )
		{
			ClutterActor * original = clutter_clone_get_source( CLUTTER_CLONE( actor ) );

			Object source;

			dump_ui_actors( original, source );

			object["source"] = source;
		}
	    else if ( CLUTTER_IS_CONTAINER( actor ) )
	    {
			Array & children( object[ "children" ].as<Array>() );

#ifdef CLUTTER_VERSION_1_10
            ClutterActorIter iter;
            ClutterActor *child;
            clutter_actor_iter_init( &iter, actor );
            while(clutter_actor_iter_next( &iter, &child ))
            {
 				Object & child_object( children.append().as<Object>() );

				dump_ui_actors( child , child_object );
           }
#else
			GList * list = clutter_container_get_children( CLUTTER_CONTAINER( actor ) );

			for( GList * item = g_list_first( list ); item ; item = g_list_next( item ) )
			{
				Object & child_object( children.append().as<Object>() );

				dump_ui_actors( CLUTTER_ACTOR( item->data ) , child_object );
			}

			g_list_free( list );
#endif
	    }
	}
};

//-----------------------------------------------------------------------------

#if 0

class StartDebuggerRequestHandler: public Handler
{
public:

    StartDebuggerRequestHandler( TPContext * ctx )
	:
	    Handler( ctx , "/debug/start" )
	{
	}

	void handle_http_get( const HttpServer::Request& request, HttpServer::Response& response )
	{
		response.set_status( HttpServer::HTTP_STATUS_OK );

		String result = JSON::Object().stringify();

		App * current_app = context->get_current_app();

        {
		    using namespace JSON;

            if( current_app )
            {
                if ( Debugger * debugger = current_app->get_debugger() )
                {
                	// This makes sure the debugger is up and running and will
                	// not break on the next line for the current app.

                	debugger->install( false );

                    Object object;

                    object[ "port" ] = debugger->get_server_port();

                    result = object.stringify();
                }
            }
        }

		if ( ! result.empty() )
		{
			response.set_response( "application/json", result );
		}
		else
		{
			response.set_status( HttpServer::HTTP_STATUS_NOT_FOUND );
		}
	}

};

#endif

#endif // TP_PRODUCTION

//-----------------------------------------------------------------------------

class ListAppsRequestHandler : public Handler
{
public:
	ListAppsRequestHandler( TPContext * ctx )
	:
	    Handler( ctx , "/api/apps" )
	{
	}

	void handle_http_get( const HttpServer::Request& request, HttpServer::Response& response )
	{
	    response.set_status( HttpServer::HTTP_STATUS_OK );

		String result;

		if ( SystemDatabase * db = context->get_db() )
		{

	        StringMap params( request.get_parameters() );

	        String sort_param = params[ "sort" ];

	        SystemDatabase::AppSort sort = SystemDatabase::BY_NAME;

	        if ( sort_param == "date" )
	        {
	            sort = SystemDatabase::BY_DATE_USED;
	        }
	        else if ( sort_param == "count" )
	        {
	            sort = SystemDatabase::BY_TIMES_USED;
	        }

	        bool reverse = params.find( "reverse" ) != params.end();


		    SystemDatabase::AppInfo::List apps = db->get_apps_for_current_profile( sort , reverse );

			{
	            using namespace JSON;

	            Array array;

                SystemDatabase::AppInfo::List::const_iterator it;

                for( it = apps.begin(); it != apps.end(); ++it )
                {
                    Object & object( array.append().as< Object> () );

                    object[ "name"          ] = it->name;
                    object[ "id"            ] = it->id;
                    object[ "version"       ] = it->version;
                    object[ "release"       ] = it->release;
                    object[ "badge_style"   ] = it->badge_style;
                    object[ "badge_text"    ] = it->badge_text;
                }

                result = array.stringify();
			}
		}

		if ( ! result.empty() )
		{
			response.set_response( "application/json", result );
		}
		else
		{
			response.set_status( HttpServer::HTTP_STATUS_NOT_FOUND );
		}
	}

};
//-----------------------------------------------------------------------------


class LaunchAppRequestHandler: public Handler
{
public:

	LaunchAppRequestHandler( TPContext * ctx )
	:
	    Handler( ctx , "/api/launch" )
	{
	}

	void handle_http_get( const HttpServer::Request& request, HttpServer::Response& response )
	{
	    response.set_status( HttpServer::HTTP_STATUS_OK );

		String result;

		String app_id = request.get_parameter( "id" );

		if ( ! app_id.empty() )
		{
			if ( SystemDatabase * db = context->get_db() )
			{
				if ( db->is_app_in_current_profile( app_id ) )
				{
					App::LaunchInfo launch_info;

					// TODO: We could populate the launch info with stuff that may
					// be interesting to the app.

					// TODO: Not very well protected - could launch the app that is
					// running now.

					if ( TP_RUN_OK == context->launch_app( app_id.c_str() , launch_info ) )
					{
					    using namespace JSON;

					    Object object;
					    object[ "result" ] = 0;

						result = object.stringify();
					}
				}
			}
		}


		if ( ! result.empty() )
		{
			response.set_response( "application/json", result.data(), result.size() );
		}
		else
		{
			response.set_status(HttpServer::HTTP_STATUS_NOT_FOUND);
		}
	}
};

//-----------------------------------------------------------------------------

class CurrentAppRequestHandler: public Handler
{
public:

    CurrentAppRequestHandler( TPContext * ctx )
	:
	    Handler( ctx , "/api/current_app" )
	{
	}

	void handle_http_get( const HttpServer::Request& request, HttpServer::Response& response )
	{
		response.set_status( HttpServer::HTTP_STATUS_OK );

		String result;

		App *current_app = context->get_current_app();

        {
		    using namespace JSON;


            if( NULL != current_app )
            {

                const App::Metadata & md( current_app->get_metadata() );

                Object object;

                object[ "name"    ] = md.name;
                object[ "id"      ] = md.id;
                object[ "version" ] = md.version;
                object[ "release" ] = md.release;

                result = object.stringify();
            }
            else
            {
                result = Object().stringify();
            }
        }

		if ( ! result.empty() )
		{
			response.set_response( "application/json", result );
		}
		else
		{
			response.set_status(HttpServer::HTTP_STATUS_NOT_FOUND);
		}
	}
};

#ifndef TP_PRODUCTION

class ControlInfoRequestHandler : public Handler
{
public:

    ControlInfoRequestHandler( TPContext * ctx )
	:
	    Handler( ctx , "/api/control" )
	{
	}

	void handle_http_get( const HttpServer::Request& request, HttpServer::Response& response )
	{
		response.set_status( HttpServer::HTTP_STATUS_OK );

		String result = context->get_control_message();

		if ( ! result.empty() )
		{
			response.set_response( "application/json", result );
		}
		else
		{
			response.set_status( HttpServer::HTTP_STATUS_NOT_FOUND );
		}
	}
};

#endif

//-----------------------------------------------------------------------------

HttpTrickplayApiSupport::HttpTrickplayApiSupport( TPContext * ctx )
    :
    context( ctx )
{
    handlers.push_back( new ListAppsRequestHandler( context ) );
	handlers.push_back( new LaunchAppRequestHandler( context ) );
	handlers.push_back( new CurrentAppRequestHandler( context ) );

#ifndef TP_PRODUCTION

	handlers.push_back( new DebugUIRequestHandler( context ) );
#if 0
	handlers.push_back( new StartDebuggerRequestHandler( context ) );
#endif
	handlers.push_back( new ControlInfoRequestHandler( context ) );

#endif
}

//-----------------------------------------------------------------------------

HttpTrickplayApiSupport::~HttpTrickplayApiSupport( )
{
    for( HandlerList::iterator it = handlers.begin(); it != handlers.end(); ++it )
    {
        delete * it;
    }
}
