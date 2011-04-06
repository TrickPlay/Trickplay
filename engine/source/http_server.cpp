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

Debug_ON log( "HTTP-SERVER" );

HttpServer::HttpServer( guint16 port ) : server( NULL )
{
	g_assert( port >= 0 );
	server = soup_server_new( SOUP_SERVER_PORT, port , NULL );
	log( "READY ON PORT %u" , soup_server_get_port( server ) );
	soup_server_run_async ( server );
}

HttpServer::~HttpServer()
{
	if ( server )
	{
		soup_server_quit( server );

		g_object_unref( server );
	}
}

guint16 HttpServer::get_port( ) const
{
	return soup_server_get_port( server );
}

void HttpServer::register_handler( const String & path , RequestHandler * handler )
{
    g_assert( handler );

    soup_server_add_handler(
			server,
			path.c_str(),
			soup_server_callback,
			new HandlerUserData( this , handler ),
			( GDestroyNotify) HandlerUserData::destroy );
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

class HttpRequest : public HttpServer::Request
{
private:

	HttpMessageContext & message_context;

public:

	HttpRequest( HttpMessageContext & ctx )
	:
	    message_context( ctx )
	{
	}

	guint16 get_server_port( ) const
	{
		return soup_server_get_port( message_context.server );
	}


	String get_request_uri( ) const
	{
		return soup_message_get_uri( message_context.message )->path;
	}

	String get_header( const String& name ) const
	{
		String val = soup_message_headers_get_one( message_context.message->request_headers, name.c_str() );
		return val;
	}


	StringMap get_headers( ) const
	{
		StringMap header_map;
		SoupMessageHeadersIter iter;
		soup_message_headers_iter_init ( &iter, message_context.message->request_headers );
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
		soup_message_headers_iter_init( &iter, message_context.message->request_headers );
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
		if ( message_context.query == NULL ) {
			return result;
		}
		GList* allkeys = g_hash_table_get_keys( message_context.query );

		GList* next = allkeys;
		while (next != NULL) {
			String key = ( const char * )next->data;
			String value = ( const char * ) g_hash_table_lookup( message_context.query, next->data );
			result[ key ] = value;
			next = next->next;
		}
		g_list_free( allkeys );
		return result;
	}


	StringList get_parameter_names( ) const
	{
		StringList result;
		if ( message_context.query == NULL ) {
			return result;
		}
		GList* allkeys = g_hash_table_get_keys ( message_context.query );

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
		if ( message_context.query == NULL ) {
			return String();
		}
		String val = ( const char * ) g_hash_table_lookup( message_context.query, name.c_str() );
		return val;
	}

	int get_body_size( ) const
	{
		return message_context.message->request_body->length;
	}

	const char * get_body_data( ) const
	{
		return message_context.message->request_body->data;
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


class HttpResponse : public HttpServer::Response
{
private:
	HttpMessageContext & message_context;

public:

	HttpResponse( HttpMessageContext & ctx )
	:
	    message_context( ctx )
	{
	}

	void set_header( const String& name, const String& value )
	{
		soup_message_headers_replace( message_context.message->response_headers, name.c_str(), value.c_str() );
	}

	virtual void set_response( const String& mime_type, const char * data, unsigned int size )
	{
		g_assert( size >= 0 );
		if ( size > 0 ) {
			g_assert( data );
		}
		 soup_message_set_response( message_context.message, mime_type.c_str(), SOUP_MEMORY_COPY, data, size );
	}

    void set_status( int sc , const String & msg )
    {
        if ( msg.empty() )
        {
            soup_message_set_status ( message_context.message, sc );
        }
        else
        {
            soup_message_set_status_full ( message_context.message, sc, msg.c_str() );
        }
    }
};


void HttpServer::soup_server_callback(
        SoupServer *server,
        SoupMessage *msg,
        const char * path,
        GHashTable *query,
        SoupClientContext *client,
        gpointer user_data
        )
{
    HandlerUserData * ud = ( HandlerUserData * ) user_data;

    HttpMessageContext message_context( server , msg , path , query , client );

    HttpRequest request( message_context );
    HttpResponse response( message_context );

    if ( msg->method == SOUP_METHOD_GET )
    {
        ud->handler->do_get( request , response );
    }
    else if ( msg->method == SOUP_METHOD_POST )
    {
        ud->handler->do_post( request , response );
    }
    else if ( msg->method == SOUP_METHOD_PUT )
    {
        ud->handler->do_put( request , response );
    }
    else if ( msg->method ==  SOUP_METHOD_HEAD )
    {
        ud->handler->do_head( request , response );
    }
    else if ( msg->method ==  SOUP_METHOD_DELETE )
    {
        ud->handler->do_delete( request , response );
    }
}
