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

//=============================================================================

HttpServer::HttpServer( guint16 port ) : server( NULL )
{
	g_assert( port >= 0 );

	server = soup_server_new( SOUP_SERVER_PORT, port , NULL );

	log( "READY ON PORT %u" , soup_server_get_port( server ) );

	soup_server_run_async( server );
}

//-----------------------------------------------------------------------------

HttpServer::~HttpServer()
{
	if ( server )
	{
		soup_server_quit( server );

		g_object_unref( server );
	}
}

//-----------------------------------------------------------------------------

guint16 HttpServer::get_port( ) const
{
	return soup_server_get_port( server );
}

//-----------------------------------------------------------------------------

void HttpServer::register_handler( const String & path , RequestHandler * handler )
{
    g_assert( handler );

    soup_server_add_handler(
			server,
			path.c_str(),
			soup_server_callback,
			new HandlerUserData( this , handler ),
			( GDestroyNotify ) HandlerUserData::destroy );
}

//=============================================================================

struct HttpMessageContext
{
	SoupServer * server;
	SoupMessage * message;
	String path;
	GHashTable * query;
	SoupClientContext * client;

	HttpMessageContext( SoupServer * s, SoupMessage * msg, const char * p, GHashTable * q, SoupClientContext * c )
	:
	    server( s ),
	    message( msg ),
	    path( p ),
	    query( q ),
	    client( c )
	{

	}
};

//=============================================================================

class SoupBufferBody : public HttpServer::Body
{
public:

    SoupBufferBody( SoupMessageBody * body )
    {
        buffer = body ? soup_message_body_flatten( body ) : 0;
    }

    virtual ~SoupBufferBody()
    {
        if ( buffer )
        {
            soup_buffer_free( buffer );
        }
    }

    const char * get_data() const
    {
        return buffer ? buffer->data : 0;
    }

    gsize get_length() const
    {
        return buffer ? buffer->length : 0;
    }

private:

    SoupBuffer * buffer;
};

//=============================================================================

class HttpRequest : public HttpServer::Request
{
private:

	HttpMessageContext & message_context;
	SoupBufferBody       body;

public:

	HttpRequest( HttpMessageContext & ctx )
	:
	    message_context( ctx ),
	    body( ctx.message->request_body )
	{
	}

	Method get_method( ) const
	{
	    const char * m( message_context.message->method );

	    if ( m == SOUP_METHOD_GET )
	    {
	        return HTTP_GET;
	    }
        if ( m == SOUP_METHOD_POST )
        {
            return HTTP_POST;
        }
        if ( m == SOUP_METHOD_PUT )
        {
            return HTTP_PUT;
        }
        if ( m == SOUP_METHOD_DELETE )
        {
            return HTTP_DELETE;
        }
        if ( m == SOUP_METHOD_HEAD )
        {
            return HTTP_HEAD;
        }
        return HttpRequest::OTHER;
	}

	guint16 get_server_port( ) const
	{
		return soup_server_get_port( message_context.server );
	}

	String get_request_uri( ) const
	{
		return soup_message_get_uri( message_context.message )->path;
	}

	String get_header( const String & name ) const
	{
	    String result;

	    if ( const char * h = soup_message_headers_get_one( message_context.message->request_headers, name.c_str() ) )
	    {
	        result = h;
	    }

	    return result;
	}

	StringMultiMap get_headers( ) const
	{
		StringMultiMap header_map;
		SoupMessageHeadersIter iter;
		soup_message_headers_iter_init ( & iter , message_context.message->request_headers );
		const char * name;
		const char * val;
		while( soup_message_headers_iter_next( & iter , & name , & val ) )
		{
			header_map.insert( StringPair( name , val ) );
		}
		return header_map;
	}

	StringList get_header_names( ) const
	{
		StringList header_names;
		SoupMessageHeadersIter iter;
		soup_message_headers_iter_init( & iter , message_context.message->request_headers );
		const char * name;
		const char * val;
		while ( soup_message_headers_iter_next( & iter , & name , & val ) )
		{
			header_names.push_back( name );
		}

		return header_names;
	}


	StringMap get_parameters( ) const
	{
		StringMap result;

		if ( message_context.query )
		{
		    GHashTableIter it;

		    gpointer key;
		    gpointer value;

		    g_hash_table_iter_init( & it , message_context.query );

            while ( g_hash_table_iter_next( & it , & key , & value ) )
            {
                result[ ( const char * ) key ] = ( const char * ) value;
            }
		}
		return result;
	}


	StringList get_parameter_names( ) const
	{
		StringList result;

		if ( message_context.query )
        {
            GHashTableIter it;

            gpointer key;
            gpointer value;

            g_hash_table_iter_init( & it , message_context.query );

            while ( g_hash_table_iter_next( & it , & key , & value ) )
            {
                result.push_back( ( const char * ) key );
            }
        }
		return result;
	}


	String get_parameter( const String & name ) const
	{
	    String result;

		if ( message_context.query )
		{
		    if ( gpointer value = g_hash_table_lookup( message_context.query, name.c_str() ) )
		    {
		        result = ( const char * ) value;
		    }
		}

		return result;
	}

	String get_content_type( ) const
	{
		return soup_message_headers_get_content_type( message_context.message->request_headers , 0 );
	}

	goffset get_content_length( ) const
	{
		return soup_message_headers_get_content_length( message_context.message->request_headers );
	}

    const HttpServer::Body & get_body() const
    {
        return body;
    }

};

//=============================================================================

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

	virtual void set_response( const String & content_type , const char * data , gsize size )
	{
	    if ( 0 == data || 0 == size )
	    {
	        set_content_type( content_type );
	    }
	    else
	    {
	        soup_message_set_response( message_context.message, content_type.c_str(), SOUP_MEMORY_COPY, data, size );
	    }
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

    void set_content_type( const String & content_type )
    {
        soup_message_headers_set_content_type( message_context.message->response_headers , content_type.c_str() , 0 );
    }

};

//=============================================================================

void HttpServer::soup_server_callback(
        SoupServer *server,
        SoupMessage *msg,
        const char * path,
        GHashTable *query,
        SoupClientContext *client,
        gpointer user_data
        )
{
    soup_message_set_status( msg , SOUP_STATUS_NOT_FOUND );

    HandlerUserData * ud = ( HandlerUserData * ) user_data;

    HttpMessageContext message_context( server , msg , path , query , client );

    HttpRequest request( message_context );
    HttpResponse response( message_context );

    if ( msg->method == SOUP_METHOD_GET )
    {
        ud->handler->handle_http_get( request , response );
    }
    else if ( msg->method == SOUP_METHOD_POST )
    {
        ud->handler->handle_http_post( request , response );
    }
    else if ( msg->method == SOUP_METHOD_PUT )
    {
        ud->handler->handle_http_put( request , response );
    }
    else if ( msg->method ==  SOUP_METHOD_HEAD )
    {
        ud->handler->handle_http_head( request , response );
    }
    else if ( msg->method ==  SOUP_METHOD_DELETE )
    {
        ud->handler->handle_http_delete( request , response );
    }
}
