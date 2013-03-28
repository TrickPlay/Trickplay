#ifndef _TRICKPLAY_HTTP_TRICKPLAY_API_SUPPORT_H
#define _TRICKPLAY_HTTP_TRICKPLAY_API_SUPPORT_H

#include "http_server.h"
#include "context.h"

class HttpTrickplayApiSupport
{
public:

    HttpTrickplayApiSupport( TPContext* context );

    ~HttpTrickplayApiSupport( );

private:

    HttpTrickplayApiSupport( const HttpTrickplayApiSupport& )
    {}

    TPContext* context;

    typedef std::list<  HttpServer::RequestHandler* > HandlerList;

    HandlerList handlers;

};

#endif // _TRICKPLAY_HTTP_TRICKPLAY_API_SUPPORT_H
