/*
 * http_server.cpp
 *
 *  Created on: Apr 1, 2011
 */

#include <sstream>
#include <string.h>
#include <iostream>
#include <cstdlib>
#include "http_server.h"
#include "util.h"

HttpServer::HttpServer( guint16 port ) : server( NULL )
{
	g_assert(port >= 0);
	char port_str[10];
	sprintf( port_str, "%d", port );
	std::cout << "starting soup server on port " << port_str << std::endl;
	SoupServer * soup_server = soup_server_new( SOUP_SERVER_PORT, port );
	server.reset( soup_server );
	std::cout << "started soup server on port " << port_str << std::endl;
	soup_server_run_async ( soup_server );
}

HttpServer::~HttpServer() {
	if ( server.get( ) ) {
		soup_server_quit( server.get( ) );
	}
}

guint16 HttpServer::get_port( ) const
{
	return soup_server_get_port( server.get( ) );
}

struct UserData {
	const String registered_path;
	HttpServer * http_server;

	UserData(const String& p, HttpServer * server) : registered_path(p), http_server(server)
	{

	}
};

static gpointer new_user_data(const String& p, HttpServer * server) {
	return new UserData(p, server);
}

static void delete_user_data(gpointer user_data) {
	if (user_data!=NULL) {
		delete (UserData*)user_data;
	}
}
void HttpServer::register_handler( const String & path, RequestHandler & handler )
{
	handler_map[ path ] =  &handler;

	soup_server_add_handler(
			server.get(),
			path.c_str(),
			soup_server_callback,
			new_user_data(path, this),
			delete_user_data
			);
}


void HttpServer::service_request( SoupMessage * msg,
		const char * registered_path,
		const char * request_uri_path,
		GHashTable * query,
		SoupClientContext * client )
{
	if ( msg->method != SOUP_METHOD_GET && msg->method != SOUP_METHOD_POST )
	{
		soup_message_set_status (msg, SOUP_STATUS_NOT_IMPLEMENTED);
		return;
	}
	/*
	String info = " Inside service request for method = ";
	info += msg->method;
	info += ". path = ";
	info += request_uri_path;
	g_info( info.c_str() );
	*/
	String path_str = registered_path;
	RequestHandlerMap::iterator it = handler_map.find( path_str );
	if ( it != handler_map.end() ) {

		RequestHandler * request_handler = it->second;
		// create a Request and Response objects
		std::auto_ptr<HttpServer::Request> request( make_request( msg, request_uri_path, query, client ) );
		std::auto_ptr<HttpServer::Response> response( make_response( msg, request_uri_path, query, client ) );

		if ( msg->method == SOUP_METHOD_GET )
		{
			request_handler->do_get( *request, *response );
		}
		else if ( msg->method == SOUP_METHOD_POST  )
		{
			request_handler->do_post( *request, *response );
		}
		else
		{
			return;
		}
			/*

		if ( msg->method == SOUP_METHOD_PUT  )
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
		*/
	}
}



void HttpServer::soup_server_callback(
		SoupServer *server,
        SoupMessage *msg,
        const char *request_uri_path,
        GHashTable *query,
        SoupClientContext *client,
        gpointer user_data
        )
{
	UserData* ud = ( UserData* ) user_data;
	ud->http_server->service_request( msg, ud->registered_path.c_str( ), request_uri_path, query, client );
}

struct HttpMessageContext {
	SoupServer * server;
	SoupMessage * message;
	String path;
	GHashTable * query;
	SoupClientContext * client;

	HttpMessageContext( SoupServer * s, SoupMessage * msg, const char * p, GHashTable * q, SoupClientContext * c )
	: server( s ), message( msg ), path( p ), query( q ), client( c )
	{

	}
};

class HttpRequest : public HttpServer::Request {
private:
	std::auto_ptr<HttpMessageContext> message_context;
public:
	HttpRequest( HttpMessageContext * ctx ) : message_context( NULL )
	{
		message_context.reset(ctx);
	}

	~HttpRequest() {

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
		String val = soup_message_headers_get_one( message_context->message->request_headers, name.c_str() );
		return val;
	}


	StringMap get_headers( ) const
	{
		StringMap header_map;
		SoupMessageHeadersIter iter;
		soup_message_headers_iter_init ( &iter, message_context->message->request_headers );
		const char* name;
		const char* val;
		while( soup_message_headers_iter_next(&iter, &name, &val )) {
			header_map [ name ] = val;
		}
		return header_map;
	}


	StringList get_header_names( ) const
	{
		StringList header_names;
		SoupMessageHeadersIter iter;
		soup_message_headers_iter_init( &iter, message_context->message->request_headers );
		const char* name;
		const char* val;
		while (soup_message_headers_iter_next(&iter, &name, &val)) {
			header_names.push_back( name );
		}

		return header_names;
	}


	StringMap get_parameters( ) const
	{
		StringMap result;
		if ( message_context->query == NULL ) {
			return result;
		}
		GList* allkeys = g_hash_table_get_keys( message_context->query );

		GList* next = allkeys;
		while (next != NULL) {
			String key = ( const char * )next->data;
			String value = ( const char * ) g_hash_table_lookup( message_context->query, next->data );
			result[ key ] = value;
			next = next->next;
		}
		g_list_free( allkeys );
		return result;
	}


	StringList get_parameter_names( ) const
	{
		StringList result;
		if ( message_context->query == NULL ) {
			return result;
		}
		GList* allkeys = g_hash_table_get_keys ( message_context->query );

		GList* next = allkeys;
		while( next != NULL ) {
			String data = ( const char * ) next->data;
			result.push_back( data );
			next = next->next;
		}
		g_list_free( allkeys );
		return result;
	}


	String get_parameter( const String& name ) const
	{
		if ( message_context->query == NULL ) {
			return String();
		}
		String val = ( const char * ) g_hash_table_lookup( message_context->query, name.c_str() );
		return val;
	}

	int get_body_size( ) const
	{
		return message_context->message->request_body->length;
	}

	const char * get_body_data( ) const
	{
		return message_context->message->request_body->data;
	}

	String get_content_type( ) const
	{
		return get_header("Content-Type");
	}

	unsigned int get_content_length( ) const
	{
		String length = get_header("Content-Length");
		return atoi( length.c_str( ) );
	}

};


class HttpResponse : public HttpServer::Response {
private:
	std::auto_ptr<HttpMessageContext> message_context;
public:
	HttpResponse( HttpMessageContext * ctx ) : message_context( NULL )
	{
		message_context.reset(ctx);
	}

	~HttpResponse()
	{

	}

	void set_header( const String& name, const String& value )
	{
		soup_message_headers_replace( message_context->message->response_headers, name.c_str(), value.c_str() );
	}

	virtual void set_response( const String& mime_type, const char * data, unsigned int size )
	{
		g_assert( size >= 0 );
		if ( size > 0 ) {
			g_assert( data );
		}
		 soup_message_set_response( message_context->message, mime_type.c_str(), SOUP_MEMORY_COPY, data, size );
	}

    void setStatus( int sc )
    {
    	soup_message_set_status ( message_context->message, sc );
    }

    virtual void sendError( int sc )
    {
    	soup_message_set_status ( message_context->message, sc );
    }

    virtual void sendError( int sc, const String& msg )
    {
    	soup_message_set_status_full ( message_context->message, sc, msg.c_str() );
    }
};

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
	return new HttpResponse( new HttpMessageContext( server.get(), msg, path, query, client ) );
}

