/*
 * api_request_handler.h
 *
 *  Created on: Apr 5, 2011
 */

#ifndef API_REQUEST_HANDLER_H_
#define API_REQUEST_HANDLER_H_

#include "http_server.h"
#include "context.h"

class APIRequestHandler : public HttpServer::RequestHandler
{
public:

	APIRequestHandler( TPContext * context );

	~APIRequestHandler( );

    void handle_http_request( const HttpServer::Request& request, HttpServer::Response& response );

private:
	TPContext * context;

};
#endif /* API_REQUEST_HANDLER_H_ */
