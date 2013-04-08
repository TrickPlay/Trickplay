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


//=============================================================================

#define TP_LOG_DOMAIN   "HTTP-SERVER"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//=============================================================================

HttpServer::RequestHandler::RequestHandler()
    :
    server( 0 )
{
}

//-----------------------------------------------------------------------------

HttpServer::RequestHandler::RequestHandler( HttpServer* _server , const String& _path )
    :
    server( _server ),
    path( _path )
{
    g_assert( server );
    g_assert( ! path.empty() );

    server->register_handler( path , this );
}

//-----------------------------------------------------------------------------

HttpServer::RequestHandler::~RequestHandler()
{
    if ( server )
    {
        server->unregister_handler( path );
    }
}

//=============================================================================

HttpServer::HttpServer( guint16 port , GMainContext* context )
    :
    server( NULL )
{
    if ( context )
    {
        server = soup_server_new( SOUP_SERVER_PORT, port , SOUP_SERVER_ASYNC_CONTEXT , context , NULL );
    }
    else
    {
        server = soup_server_new( SOUP_SERVER_PORT, port , NULL );
    }

    if ( ! server )
    {
        tpwarn( "FAILED TO START" );
    }
    else
    {
        if ( ! context )
        {
            tplog( "READY ON PORT %u" , soup_server_get_port( server ) );

            soup_server_run_async( server );
        }
    }
}

//-----------------------------------------------------------------------------

HttpServer::~HttpServer()
{
    if ( server )
    {
        soup_server_quit( server );

        g_object_unref( server );

        tplog2( "SHUTDOWN" );
    }
}

//-----------------------------------------------------------------------------

guint16 HttpServer::get_port( ) const
{
    return server ? soup_server_get_port( server ) : 0;
}

//-----------------------------------------------------------------------------

void HttpServer::register_handler( const String& path , RequestHandler* handler )
{
    if ( ! server )
    {
        return;
    }

    g_assert( handler );

    soup_server_add_handler(
            server,
            path.c_str(),
            soup_server_callback,
            new HandlerUserData( this , handler ),
            ( GDestroyNotify ) HandlerUserData::destroy );

    tplog2( "ADDED HANDLER FOR %s" , path.c_str() );
}

//-----------------------------------------------------------------------------

void HttpServer::unregister_handler( const String& path )
{
    if ( ! server )
    {
        return;
    }

    soup_server_remove_handler( server , path.c_str() );

    tplog2( "REMOVED HANDLER FOR %s" , path.c_str() );
}

//-----------------------------------------------------------------------------

void HttpServer::run()
{
    if ( server )
    {
        soup_server_run( server );
    }
}

//-----------------------------------------------------------------------------

void HttpServer::quit()
{
    if ( server )
    {
        soup_server_quit( server );
    }
}

//=============================================================================

class HttpMessageContext : public RefCounted
{

public:

    SoupServer* server;
    SoupMessage* message;
    String path;
    GHashTable* query;
    SoupClientContext* client;

    HttpMessageContext( SoupServer* s, SoupMessage* msg, const char* p, GHashTable* q, SoupClientContext* c )
        :
        server( s ),
        message( msg ),
        path( p ),
        query( q ),
        client( c )
    {
        g_object_ref( server );
        g_object_ref( message );

        if ( query )
        {
            g_hash_table_ref( query );
        }

        tplog2( "CREATED HTTP MESSAGE CONTEXT %p" , this );
    }

protected:

    virtual ~HttpMessageContext()
    {
        g_object_unref( message );

        if ( query )
        {
            g_hash_table_unref( query );
        }

        g_object_unref( server );

        tplog2( "DESTROYED HTTP MESSAGE CONTEXT %p" , this );
    }
};

//=============================================================================

class SoupBufferBody : public HttpServer::Request::Body
{
public:

    SoupBufferBody( SoupMessageBody* body )
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

    const char* get_data() const
    {
        return buffer ? buffer->data : 0;
    }

    gsize get_length() const
    {
        return buffer ? buffer->length : 0;
    }

private:

    SoupBuffer* buffer;
};

//=============================================================================

class HttpRequest : public HttpServer::Request
{
private:

    HttpMessageContext* message_context;
    SoupBufferBody       body;

public:

    HttpRequest( HttpMessageContext* ctx )
        :
        message_context( ctx ),
        body( ctx->message->request_body )
    {
        message_context->ref();

        tplog2( "CREATED HTTP REQUEST %p" , this );
    }

    ~HttpRequest()
    {
        message_context->unref();

        tplog2( "DESTROYED HTTP REQUEST %p" , this );
    }

    Method get_method( ) const
    {
        const char* m( message_context->message->method );

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
        return soup_server_get_port( message_context->server );
    }

    String get_path( ) const
    {
        return message_context->path;
    }

    String get_request_uri( ) const
    {
        return soup_message_get_uri( message_context->message )->path;
    }

    HttpServer::URI get_uri() const
    {
        HttpServer::URI result;

        SoupURI* u = soup_message_get_uri( message_context->message );

        result.scheme = u->scheme ? u->scheme : "";
        result.user = u->user ? u->user : "";
        result.password = u->password ? u->password : "";
        result.host = u->host ? u->host : "";
        result.port = u->port;
        result.path = u->path ? u->path : "";
        result.query = u->query ? u->query : "";
        result.fragment = u->fragment ? u->fragment : "";

        return result;
    }

    String get_header( const String& name ) const
    {
        String result;

        if ( const char* h = soup_message_headers_get_one( message_context->message->request_headers, name.c_str() ) )
        {
            result = h;
        }

        return result;
    }

    StringMultiMap get_headers( ) const
    {
        StringMultiMap header_map;
        SoupMessageHeadersIter iter;
        soup_message_headers_iter_init( & iter , message_context->message->request_headers );
        const char* name;
        const char* val;

        while ( soup_message_headers_iter_next( & iter , & name , & val ) )
        {
            header_map.insert( StringPair( name , val ) );
        }

        return header_map;
    }

    StringList get_header_names( ) const
    {
        StringList header_names;
        SoupMessageHeadersIter iter;
        soup_message_headers_iter_init( & iter , message_context->message->request_headers );
        const char* name;
        const char* val;

        while ( soup_message_headers_iter_next( & iter , & name , & val ) )
        {
            header_names.push_back( name );
        }

        return header_names;
    }


    StringMap get_parameters( ) const
    {
        StringMap result;

        if ( message_context->query )
        {
            GHashTableIter it;

            gpointer key;
            gpointer value;

            g_hash_table_iter_init( & it , message_context->query );

            while ( g_hash_table_iter_next( & it , & key , & value ) )
            {
                const char* k = key ? ( const char* ) key : "";
                const char* v = value ? ( const char* ) value : "";

                result[ k ] = v;
            }
        }

        return result;
    }


    StringList get_parameter_names( ) const
    {
        StringList result;

        if ( message_context->query )
        {
            GHashTableIter it;

            gpointer key;
            gpointer value;

            g_hash_table_iter_init( & it , message_context->query );

            while ( g_hash_table_iter_next( & it , & key , & value ) )
            {
                if ( key )
                {
                    result.push_back( ( const char* ) key );
                }
            }
        }

        return result;
    }


    String get_parameter( const String& name ) const
    {
        String result;

        if ( message_context->query )
        {
            if ( gpointer value = g_hash_table_lookup( message_context->query, name.c_str() ) )
            {
                result = ( const char* ) value;
            }
        }

        return result;
    }

    String get_content_type( ) const
    {
        String result;

        if ( const char* value = soup_message_headers_get_content_type( message_context->message->request_headers , 0 ) )
        {
            result = value;
        }

        return result;
    }

    goffset get_content_length( ) const
    {
        return soup_message_headers_get_content_length( message_context->message->request_headers );
    }

    const HttpServer::Request::Body& get_body() const
    {
        return body;
    }

    void print_headers() const
    {
        StringMultiMap header_map = get_headers();

        for ( StringMultiMap::iterator it = header_map.begin(); it != header_map.end(); it++ )
        {
            g_debug( "%s" , ( it->first + ": " + it->second ).c_str( ) );
        }
    }

    void print_parameters() const
    {
        StringMap parameter_map = get_parameters( );

        for ( StringMap::iterator it = parameter_map.begin(); it != parameter_map.end(); it++ )
        {
            g_debug( "%s" , ( it->first + "=" + it->second ).c_str( ) );
        }
    }
};

//=============================================================================

class StreamBody : public HttpServer::Response::StreamBody
{
public:

    StreamBody( HttpMessageContext* _ctx , HttpServer::Response::StreamWriter* _stream_writer )
        :
        ctx( _ctx ),
        stream_writer( _stream_writer )
    {
        g_assert( ctx->message );
        g_assert( stream_writer );

        ctx->ref();

        soup_message_body_set_accumulate( ctx->message->response_body , FALSE );

        wrote_headers_handler = g_signal_connect( ctx->message , "wrote_headers", G_CALLBACK( message_wrote_chunk ) , this );
        wrote_chunk_handler = g_signal_connect( ctx->message , "wrote_chunk", G_CALLBACK( message_wrote_chunk ) , this );
        finished_handler = g_signal_connect( ctx->message , "finished", G_CALLBACK( message_finished ) , this );

        tplog2( "CREATED RESPONSE BODY %p" , this );
    }

    virtual ~StreamBody()
    {
        if ( wrote_headers_handler )
        {
            g_signal_handler_disconnect( ctx->message , wrote_headers_handler );
        }

        if ( wrote_chunk_handler )
        {
            g_signal_handler_disconnect( ctx->message , wrote_chunk_handler );
        }

        g_signal_handler_disconnect( ctx->message , finished_handler );

        ctx->unref();

        delete stream_writer;

        tplog2( "DESTROYED RESPONSE BODY %p" , this );
    }

    void append( const char* data , gsize size )
    {
        g_assert( data );
        g_assert( size );

        tplog2( "RESPONSE BODY %p APPEND %" G_GSIZE_FORMAT " b" , this , size );

        soup_message_body_append( ctx->message->response_body , SOUP_MEMORY_COPY , data , size );
    }

    void complete()
    {
        tplog2( "RESPONSE BODY %p COMPLETE" , this );

        soup_message_body_complete( ctx->message->response_body );

        g_signal_handler_disconnect( ctx->message , wrote_headers_handler );
        g_signal_handler_disconnect( ctx->message , wrote_chunk_handler );

        wrote_headers_handler = 0;
        wrote_chunk_handler = 0;
    }

    void cancel()
    {
        tplog2( "RESPONSE BODY %p CANCEL" , this );

        soup_socket_disconnect( soup_client_context_get_socket( ctx->client ) );
    }


private:

    static void message_wrote_chunk( SoupMessage* msg , StreamBody* self )
    {
        tplog2( "RESPONSE BODY %p WROTE CHUNK" , self );

        self->stream_writer->write( * self );
    }
    static void message_finished( SoupMessage* msg , StreamBody* self )
    {
        tplog2( "RESPONSE BODY %p FINISHED" , self );

        delete self;
    }

    HttpMessageContext*                     ctx;
    HttpServer::Response::StreamWriter*     stream_writer;

    gulong                                  wrote_headers_handler;
    gulong                                  wrote_chunk_handler;
    gulong                                  finished_handler;
};

//=============================================================================

class FileStreamWriter : public HttpServer::Response::StreamWriter
{
public:

    FileStreamWriter( GFile* _file )
        :
        file( _file ),
        input_stream( 0 )
    {
        g_assert( file );

        g_object_ref( file );

        input_stream = g_file_read( file , 0 , 0 );
    }

    ~FileStreamWriter()
    {
        if ( input_stream )
        {
            g_object_unref( input_stream );
        }

        g_object_unref( file );
    }

    void write( HttpServer::Response::StreamBody& body )
    {
        gssize bytes_read = input_stream ? g_input_stream_read( G_INPUT_STREAM( input_stream ) , buffer , sizeof( buffer ) , 0 , 0 ) : -1;

        if ( bytes_read < 0 )
        {
            body.cancel();
        }
        else if ( bytes_read == 0 )
        {
            body.complete();
        }
        else
        {
            body.append( buffer , bytes_read );
        }
    }

private:

    GFile*              file;
    GFileInputStream*   input_stream;
    char                buffer[512];
};

//=============================================================================

class HttpResponse : public HttpServer::Response
{
private:

    HttpMessageContext*     message_context;
    bool                    paused;

public:

    HttpResponse( HttpMessageContext* ctx )
        :
        message_context( ctx ),
        paused( false )
    {
        message_context->ref();

        tplog2( "CREATED HTTP RESPONSE %p" , this );
    }

    void set_header( const String& name, const String& value )
    {
        soup_message_headers_replace( message_context->message->response_headers, name.c_str(), value.c_str() );
    }

    void set_response( const String& content_type , const char* data , gsize size )
    {
        if ( 0 == data || 0 == size )
        {
            set_content_type( content_type );
        }
        else
        {
            soup_message_set_response( message_context->message, content_type.c_str(), SOUP_MEMORY_COPY, data, size );
        }
    }

    void set_response( const String& content_type , const String& content )
    {
        set_response( content_type , content.data() , content.size() );
    }


    void set_status( HttpServer::ServerStatus status , const String& msg = String() )
    {
        if ( msg.empty() )
        {
            soup_message_set_status( message_context->message, int( status ) );
        }
        else
        {
            soup_message_set_status_full( message_context->message , int( status ) , msg.c_str() );
        }
    }

    void set_content_type( const String& content_type )
    {
        soup_message_headers_set_content_type( message_context->message->response_headers , content_type.c_str() , 0 );
    }

    void set_content_length( goffset content_length )
    {
        soup_message_headers_set_content_length( message_context->message->response_headers , content_length );
    }

    String get_content_type( ) const
    {
        const char* ct = soup_message_headers_get_content_type( message_context->message->response_headers , 0 );

        if ( ct )
        {
            return String( ct );
        }

        return String();
    }

    void set_stream_writer( StreamWriter* stream_writer )
    {
        new ::StreamBody( message_context , stream_writer );
    }

    virtual bool respond_with_file_contents( const String& file_name_or_uri , const String& content_type )
    {
        GFile* file = g_file_new_for_commandline_arg( file_name_or_uri.c_str() );

        if ( ! g_file_query_exists( file , 0 ) )
        {
            g_object_unref( file );
            return false;
        }

        GFileInfo* info = g_file_query_info( file , G_FILE_ATTRIBUTE_STANDARD_SIZE , G_FILE_QUERY_INFO_NONE , 0 , 0 );

        if ( ! info )
        {
            g_object_unref( file );
            return false;
        }

        goffset size = g_file_info_get_size( info );

        g_object_unref( info );

        if ( ! size )
        {
            g_object_unref( file );
            return false;
        }

        if ( content_type.empty() )
        {
            set_content_type( "application/octet-stream" );
        }
        else
        {
            set_content_type( content_type );
        }

        set_content_length( size );

        set_status( HttpServer::HTTP_STATUS_OK );

        new ::StreamBody( message_context , new FileStreamWriter( file ) );

        g_object_unref( file );

        return true;
    }

    Response* pause()
    {
        g_assert( ! paused );

        soup_server_pause_message( message_context->server , message_context->message );

        ref();

        paused = true;

        return this;
    }

    bool is_paused() const
    {
        return paused;
    }

    void resume()
    {
        g_assert( paused );

        soup_server_unpause_message( message_context->server , message_context->message );

        paused = false;

        unref();
    }

protected:

    virtual ~HttpResponse()
    {
        message_context->unref();

        tplog2( "DESTROYED HTTP RESPONSE %p" , this );
    }

};

//=============================================================================

void HttpServer::soup_server_callback(
        SoupServer* server,
        SoupMessage* msg,
        const char* path,
        GHashTable* query,
        SoupClientContext* client,
        gpointer user_data
)
{
    tplog( "%s [%s]" , msg->method , path );

    soup_message_set_status( msg , HttpServer::HTTP_STATUS_NOT_FOUND );

    HandlerUserData* ud = ( HandlerUserData* ) user_data;

    HttpMessageContext* message_context = new HttpMessageContext( server , msg , path , query , client );

    HttpRequest request( message_context );

    HttpResponse* response = new HttpResponse( message_context );

    if ( msg->method == SOUP_METHOD_GET )
    {
        ud->handler->handle_http_get( request , * response );
    }
    else if ( msg->method == SOUP_METHOD_POST )
    {
        ud->handler->handle_http_post( request , * response );
    }
    else if ( msg->method == SOUP_METHOD_PUT )
    {
        ud->handler->handle_http_put( request , * response );
    }
    else if ( msg->method ==  SOUP_METHOD_HEAD )
    {
        ud->handler->handle_http_head( request , * response );
    }
    else if ( msg->method ==  SOUP_METHOD_DELETE )
    {
        ud->handler->handle_http_delete( request , * response );
    }

    if ( response->is_paused() )
    {
        tplog( ">> PAUSED" );
    }
    else
    {
        tplog( ">> %u %s" , msg->status_code , msg->reason_phrase );
    }

    message_context->unref();

    response->unref();
}
