/*
 * http_server.cpp
 *
 *  Created on: Apr 1, 2011
 */

#include "http_server.h"
#include <sstream>

#include <string.h>

HttpServer::HttpServer( guint16 port ) : server( NULL )
{
	char port_str[10];
	sprintf(port_str, "%d", port);
	SoupServer * soup_server = soup_server_new( SOUP_SERVER_PORT, port_str );
	server.reset( soup_server );
}


void HttpServer::register_handler( const String & path, RequestHandler & handler )
{
	handler_map[ path ] =  &handler;

	soup_server_add_handler(
			server.get(),
			path.c_str(),
			soup_server_callback,
			this,
			NULL
			);
}

struct HttpMessageContext {
	SoupServer * server;
	SoupMessage * message;
	String path;
	GHashTable * query;
	SoupClientContext * client;

	HttpMessageContext( SoupServer * s, SoupMessage * msg, const char * p, GHashTable * q, SoupClientContext * c )
	: server(s), message(msg), path(p), query(q), client(c)
	{

	}
};

class HttpRequest : public HttpServer::Request {
private:
	HttpMessageContext * message_context;
public:
	HttpRequest( HttpMessageContext * ctx ) : message_context( ctx )
	{

	}

	~HttpRequest() {
		if (message_context) {
			delete message_context;
		}
	}

	guint16 get_server_port( ) const
	{
		return soup_server_get_port( message_context->server );
	}


	String get_request_uri( ) const
	{
		return soup_message_get_uri( message_context->message )->path;
	}

	String get_header( const String& name ) const
	{
		return NULL;
	}


	StringMap get_headers( ) const
	{
		StringMap header_map;
		return header_map;
	}


	StringList get_header_names( ) const
	{
		StringList header_names;
		return header_names;
	}


	StringMap get_parameters( ) const
	{
		GList* allkeys = g_hash_table_get_keys(message_context->query);

		StringMap result;
		GList* next = allkeys;
		while (next != NULL) {
			String key = ( const char * )next->data;
			String value = ( const char * ) g_hash_table_lookup( message_context->query, next->data);
			result[ key ] = value;
			next = next->next;
		}
		g_list_free(allkeys);
		return result;
	}


	StringList get_parameter_names( ) const
	{
		GList* allkeys = g_hash_table_get_keys ( message_context->query );

		StringList result;
		GList* next = allkeys;
		while( next != NULL ) {
			String data = ( const char * ) next->data;
			result.push_back(data);
			next = next->next;
		}
		g_list_free(allkeys);
		return result;
	}


	String get_parameter( const String& name ) const
	{
		String val = ( const char * ) g_hash_table_lookup( message_context->query, name.c_str());
		return val;
	}

};

void HttpServer::service_request( SoupMessage * msg,
		const char * path,
		GHashTable * query,
		SoupClientContext * client )
{
	String path_str = path;
	RequestHandlerMap::iterator it = handler_map.find( path_str );
	if ( it != handler_map.end() ) {

		RequestHandler * request_handler = it->second;
		// create a Request and Response objects
		Request * request = make_request( msg, path, query, client );
		Response * response = make_response( msg, path, query, client );

		if ( msg->method == SOUP_METHOD_GET )
		{
			request_handler->do_get( *request, *response );
		}
		else if ( msg->method == SOUP_METHOD_POST  )
		{
			request_handler->do_post( *request, *response );
		}
		else if ( msg->method == SOUP_METHOD_PUT  )
		{
			request_handler->do_put( *request, *response );
		}
		else if ( msg->method == SOUP_METHOD_DELETE  )
		{
			request_handler->do_delete( *request, *response );
		}
		else if ( msg->method == SOUP_METHOD_HEAD )
		{
			request_handler->do_head( *request, *response );
		}
	}
}

HttpServer::Request * HttpServer::make_request( SoupMessage * msg,
		const char * path,
		GHashTable * query,
		SoupClientContext * client )
{
	return new HttpRequest( new HttpMessageContext( server.get(), msg, path, query, client ) );
}


HttpServer::Response * HttpServer::make_response( SoupMessage *msg,
		const char * path,
		GHashTable *query,
		SoupClientContext *client )
{
	return NULL;
}

void HttpServer::soup_server_callback(
		SoupServer *server,
        SoupMessage *msg,
        const char *path,
        GHashTable *query,
        SoupClientContext *client,
        gpointer user_data
        )
{
	HttpServer* http_server = (HttpServer*) user_data;
	http_server->service_request( msg, path, query, client );
}
