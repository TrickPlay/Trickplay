/*
 * api_request_handler.cpp
 *
 *  Created on: Apr 5, 2011
 */

#include "app.h"
#include "api_request_handler.h"
#include "util.h"
#include "sysdb.h"
APIRequestHandler::APIRequestHandler( TPContext * ctx )
    :
    context( ctx )
{
	context->get_http_server()->register_handler( "/api" , this );
}

APIRequestHandler::~APIRequestHandler( )
{
	context->get_http_server()->unregister_handler( "/api" );
}

//-----------------------------------------------------------------------------

void APIRequestHandler::handle_http_request( const HttpServer::Request& request, HttpServer::Response& response )
{

	if ( request.get_method() != HttpServer::Request::HTTP_GET )
	{
		response.set_status( HttpServer::HTTP_STATUS_METHOD_NOT_ALLOWED );
		return;
	}
	else
	{
		response.set_status( HttpServer::HTTP_STATUS_OK );
	}
    //.........................................................................

    String result;
    String path = request.get_request_uri( );

    if ( path == "/api/apps" )
    {
        if ( SystemDatabase * db = context->get_db() )
        {
            SystemDatabase::AppInfo::List apps = db->get_apps_for_current_profile();

            JsonArray * array = json_array_new();

            SystemDatabase::AppInfo::List::const_iterator it;

            for( it = apps.begin(); it != apps.end(); ++it )
            {
                JsonObject * o = json_object_new();

                json_object_set_string_member( o , "name" , it->name.c_str() );
                json_object_set_string_member( o , "id" , it->id.c_str() );
                json_object_set_string_member( o , "version" , it->version.c_str() );
                json_object_set_int_member( o , "release" , it->release );
                json_object_set_string_member( o , "badge_style" , it->badge_style.c_str() );
                json_object_set_string_member( o , "badge_text" , it->badge_text.c_str() );

                json_array_add_object_element( array , o );
            }

            JsonNode * node = json_node_new( JSON_NODE_ARRAY );

            json_node_set_array( node , array );

            json_array_unref( array );

            JsonGenerator * gen = json_generator_new();

            json_generator_set_root( gen , node );

            gsize length = 0;

            gchar * json = json_generator_to_data( gen , & length );

            result = String( json , length );

            g_free( json );

            g_object_unref( gen );
        }
    }
    else if ( path == "/api/launch" )
    {
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
                        result = "{'result':0}";
                    }
                }
            }
        }
    }
    else if ( path == "/api/current_app" )
    {
        App *current_app = context->get_current_app();
        if(NULL != current_app)
        {
            JsonObject * o = json_object_new();

            json_object_set_string_member( o, "name", current_app->get_metadata().name.c_str() );
            json_object_set_string_member( o, "id", current_app->get_id().c_str() );
            json_object_set_string_member( o, "version", current_app->get_metadata().version.c_str() );
            json_object_set_int_member( o, "release", current_app->get_metadata().release );

            JsonNode * node = json_node_new ( JSON_NODE_OBJECT );

            json_node_set_object( node, o );

            json_object_unref( o );

            JsonGenerator * gen  = json_generator_new();

            json_generator_set_root( gen, node );

            gsize length = 0;

            gchar * json = json_generator_to_data( gen, &length );

            result = String( json, length );

            g_free( json );

            g_object_unref( gen );
        } else {
            result = "{}";
        }
    }

    if ( ! result.empty() )
    {
    	response.set_response( "application/json", result.data(), result.size() );
        g_debug( "  API RESPONSE" );
    } else {
    	response.set_status(HttpServer::HTTP_STATUS_NOT_FOUND);
		g_debug( "  NOT FOUND" );
    }

}

//-----------------------------------------------------------------------------
