#ifndef _TRICKPLAY_HTTP_SERVER_H_
#define _TRICKPLAY_HTTP_SERVER_H_

#include "common.h"
#include "libsoup/soup.h"

class HttpServer
{
public:

    //.........................................................................

	class Request
	{
	public:

	    class Body
	    {
	    public:

	        virtual ~Body() {}
	        virtual const char * get_data() const = 0;
	        virtual gsize get_length() const = 0;

	    protected:
	        Body() {}
	    private:
	        Body( const Body & ) {}
	    };

        enum Method { HTTP_GET , HTTP_POST , HTTP_PUT , HTTP_DELETE , HTTP_HEAD , OTHER };

        virtual Method get_method() const = 0;
		virtual guint16 get_server_port( ) const = 0;
		virtual String get_path( ) const = 0;
		virtual String get_request_uri( ) const = 0;
		virtual String get_header( const String & name ) const = 0;
		virtual StringMultiMap get_headers( ) const = 0;
		virtual StringList get_header_names( ) const = 0;
		virtual StringMap get_parameters( ) const = 0;
		virtual StringList get_parameter_names( ) const = 0;
		virtual String get_parameter( const String& name ) const = 0;
		virtual String get_content_type( ) const = 0;
		virtual goffset get_content_length( ) const = 0;
		virtual const Body & get_body() const = 0;

		virtual void print_headers() const = 0;
		virtual void print_parameters() const = 0;

	protected:
		Request() {}
	private:
		Request( const Request & ) {}
	};

    //.........................................................................

	class Response
	{
	public:

	    class StreamBody
	    {
	    public:
	        virtual void append( const char * data , gsize size ) = 0;
	        virtual void complete() = 0;
	        virtual void cancel() = 0;
	    protected:
	        StreamBody() {}
	    private:
	        StreamBody( const StreamBody & ) {}
	    };

	    class StreamWriter
	    {
	    public:
	        virtual ~StreamWriter() {}
	        virtual void write( StreamBody & body ) = 0;
	    };

		virtual void set_header( const String & name , const String & value ) = 0;
	    virtual void set_response( const String & content_type , const char * data , gsize size ) = 0;
	    virtual void set_status( int sc , const String & msg = String() ) = 0;
	    virtual void set_content_type( const String & content_type ) = 0;
	    virtual void set_content_length( goffset content_length ) = 0;
	    virtual void set_stream_writer( StreamWriter * stream_writer ) = 0;
	    virtual bool respond_with_file_contents( const String & file_name , const String & content_type = String() ) = 0;

	protected:
	    Response() {};
	private:
	    Response( const Response & ) {};
	};

    //.........................................................................

	class RequestHandler
    {
    public:
	    virtual void handle_http_request( const Request & request , Response & response ) {}

        virtual void handle_http_get    ( const Request & request , Response & response ) { handle_http_request( request , response ); }
        virtual void handle_http_post   ( const Request & request , Response & response ) { handle_http_request( request , response ); }
        virtual void handle_http_put    ( const Request & request , Response & response ) { handle_http_request( request , response ); }
        virtual void handle_http_delete ( const Request & request , Response & response ) { handle_http_request( request , response ); }
        virtual void handle_http_head   ( const Request & request , Response & response ) { handle_http_request( request , response ); }
    };

    //.........................................................................

    HttpServer( guint16 port = 0 );

    ~HttpServer();

    void register_handler( const String & path , RequestHandler * handler );

    void unregister_handler( const String & path );

    guint16 get_port() const;

private:

    struct HandlerUserData
    {
        HandlerUserData( HttpServer * _server , RequestHandler * _handler )
        :
            server( _server ),
            handler( _handler )
        {
            g_assert( server );
            g_assert( handler );
        }

        HttpServer *        server;
        RequestHandler *    handler;

        static void destroy( HandlerUserData * me )
        {
            delete me;
        }
    };

    static void soup_server_callback(
    		SoupServer *server,
            SoupMessage *msg,
            const char *path,
            GHashTable *query,
            SoupClientContext *client,
            gpointer user_data
            );

    SoupServer * server;
};



#endif /* _TRICKPLAY_HTTP_SERVER_H_ */
