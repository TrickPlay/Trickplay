/*
 * api_request_handler.h
 *
 *  Created on: Apr 5, 2011
 */

#ifndef HTTP_TRICKPLAY_API_SUPPORT_H_
#define HTTP_TRICKPLAY_API_SUPPORT_H_

#include "http_server.h"
#include "context.h"

class HttpTrickplayApiSupport
{
public:

	HttpTrickplayApiSupport( TPContext * context );

	~HttpTrickplayApiSupport( );

private:

	HttpTrickplayApiSupport( const HttpTrickplayApiSupport& )
	{ }

	TPContext * context;

	typedef std::list<HttpServer::RequestHandler *> HttpTrickplayApiRequestHandlerList;

	HttpTrickplayApiRequestHandlerList request_handlers_list;

};
#endif /* HTTP_TRICKPLAY_API_SUPPORT_H_ */
