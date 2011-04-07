/*
 * app_resource_request_handler.h
 *
 *  Created on: Apr 5, 2011
 */

#ifndef APP_RESOURCE_REQUEST_HANDLER_H_
#define APP_RESOURCE_REQUEST_HANDLER_H_

#include "http_server.h"
#include "context.h"

class AppResourceRequestHandler : public HttpServer::RequestHandler
{
public:


	AppResourceRequestHandler( TPContext * context );

	~AppResourceRequestHandler( );

    void do_get( const HttpServer::Request& request, HttpServer::Response& response );

	String serve_path( const String & group, const String & path );

	void drop_web_server_group( const String & group );

private:
	TPContext * context;

    // The key is a hash we generate, the first string is the real path
    // and the second string is the group.

    typedef std::map<String, StringPair> WebServerPathMap;

    WebServerPathMap    path_map;

    static bool write_file( const String& filepath, HttpServer::Response& response );


};
#endif /* APP_RESOURCE_REQUEST_HANDLER_H_ */
