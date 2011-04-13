#include "app.h"
#include "http_trickplay_api_support.h"
#include "util.h"
#include "sysdb.h"
#include "json.h"

//-----------------------------------------------------------------------------

class Handler : public HttpServer::RequestHandler
{
public:

    Handler( TPContext * _context , const String & _path )
    :
        context( _context ),
        path( _path )
    {
        g_assert( context );

        context->get_http_server()->register_handler( path , this );
    }

    virtual ~Handler()
    {
        context->get_http_server()->unregister_handler( path );
    }

protected:

    TPContext * context;
    String      path;

private:

    Handler() {}
    Handler( const Handler & ) {}
};

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
			SystemDatabase::AppInfo::List apps = db->get_apps_for_current_profile();

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

//-----------------------------------------------------------------------------

HttpTrickplayApiSupport::HttpTrickplayApiSupport( TPContext * ctx )
    :
    context( ctx )
{
    handlers.push_back( new ListAppsRequestHandler( context ) );
	handlers.push_back( new LaunchAppRequestHandler( context ) );
	handlers.push_back( new CurrentAppRequestHandler( context ) );
}

//-----------------------------------------------------------------------------

HttpTrickplayApiSupport::~HttpTrickplayApiSupport( )
{
    for( HandlerList::iterator it = handlers.begin(); it != handlers.end(); ++it )
    {
        delete * it;
    }
}
