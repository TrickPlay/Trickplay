#ifndef _TRICKPLAY_HTTP_SERVER_H_
#define _TRICKPLAY_HTTP_SERVER_H_

#include "common.h"
#include "util.h"
#include "libsoup/soup.h"

class HttpServer
{
public:

    enum ServerStatus
    {
        HTTP_STATUS_CONTINUE                        = SOUP_STATUS_CONTINUE,
        HTTP_STATUS_SWITCHING_PROTOCOLS             = SOUP_STATUS_SWITCHING_PROTOCOLS,
        HTTP_STATUS_PROCESSING                      = SOUP_STATUS_PROCESSING,

        HTTP_STATUS_OK                              = SOUP_STATUS_OK,
        HTTP_STATUS_CREATED                         = SOUP_STATUS_CREATED,
        HTTP_STATUS_ACCEPTED                        = SOUP_STATUS_ACCEPTED,
        HTTP_STATUS_NON_AUTHORITATIVE               = SOUP_STATUS_NON_AUTHORITATIVE,
        HTTP_STATUS_NO_CONTENT                      = SOUP_STATUS_NO_CONTENT,
        HTTP_STATUS_RESET_CONTENT                   = SOUP_STATUS_RESET_CONTENT,
        HTTP_STATUS_PARTIAL_CONTENT                 = SOUP_STATUS_PARTIAL_CONTENT,
        HTTP_STATUS_MULTI_STATUS                    = SOUP_STATUS_MULTI_STATUS,

        HTTP_STATUS_MULTIPLE_CHOICES                = SOUP_STATUS_MULTIPLE_CHOICES,
        HTTP_STATUS_MOVED_PERMANENTLY               = SOUP_STATUS_MOVED_PERMANENTLY,
        HTTP_STATUS_FOUND                           = SOUP_STATUS_FOUND,
        HTTP_STATUS_MOVED_TEMPORARILY               = SOUP_STATUS_MOVED_TEMPORARILY,
        HTTP_STATUS_SEE_OTHER                       = SOUP_STATUS_SEE_OTHER,
        HTTP_STATUS_NOT_MODIFIED                    = SOUP_STATUS_NOT_MODIFIED,
        HTTP_STATUS_USE_PROXY                       = SOUP_STATUS_USE_PROXY,
        HTTP_STATUS_NOT_APPEARING_IN_THIS_PROTOCOL  = SOUP_STATUS_NOT_APPEARING_IN_THIS_PROTOCOL,
        HTTP_STATUS_TEMPORARY_REDIRECT              = SOUP_STATUS_TEMPORARY_REDIRECT,

        HTTP_STATUS_BAD_REQUEST                     = SOUP_STATUS_BAD_REQUEST,
        HTTP_STATUS_UNAUTHORIZED                    = SOUP_STATUS_UNAUTHORIZED,
        HTTP_STATUS_PAYMENT_REQUIRED                = SOUP_STATUS_PAYMENT_REQUIRED,
        HTTP_STATUS_FORBIDDEN                       = SOUP_STATUS_FORBIDDEN,
        HTTP_STATUS_NOT_FOUND                       = SOUP_STATUS_NOT_FOUND,
        HTTP_STATUS_METHOD_NOT_ALLOWED              = SOUP_STATUS_METHOD_NOT_ALLOWED,
        HTTP_STATUS_NOT_ACCEPTABLE                  = SOUP_STATUS_NOT_ACCEPTABLE,
        HTTP_STATUS_PROXY_AUTHENTICATION_REQUIRED   = SOUP_STATUS_PROXY_AUTHENTICATION_REQUIRED,
        HTTP_STATUS_PROXY_UNAUTHORIZED              = SOUP_STATUS_PROXY_UNAUTHORIZED,
        HTTP_STATUS_REQUEST_TIMEOUT                 = SOUP_STATUS_REQUEST_TIMEOUT,
        HTTP_STATUS_CONFLICT                        = SOUP_STATUS_CONFLICT,
        HTTP_STATUS_GONE                            = SOUP_STATUS_GONE,
        HTTP_STATUS_LENGTH_REQUIRED                 = SOUP_STATUS_LENGTH_REQUIRED,
        HTTP_STATUS_PRECONDITION_FAILED             = SOUP_STATUS_PRECONDITION_FAILED,
        HTTP_STATUS_REQUEST_ENTITY_TOO_LARGE        = SOUP_STATUS_REQUEST_ENTITY_TOO_LARGE,
        HTTP_STATUS_REQUEST_URI_TOO_LONG            = SOUP_STATUS_REQUEST_URI_TOO_LONG,
        HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE          = SOUP_STATUS_UNSUPPORTED_MEDIA_TYPE,
        HTTP_STATUS_REQUESTED_RANGE_NOT_SATISFIABLE = SOUP_STATUS_REQUESTED_RANGE_NOT_SATISFIABLE,
        HTTP_STATUS_INVALID_RANGE                   = SOUP_STATUS_INVALID_RANGE,
        HTTP_STATUS_EXPECTATION_FAILED              = SOUP_STATUS_EXPECTATION_FAILED,
        HTTP_STATUS_UNPROCESSABLE_ENTITY            = SOUP_STATUS_UNPROCESSABLE_ENTITY,
        HTTP_STATUS_LOCKED                          = SOUP_STATUS_LOCKED,
        HTTP_STATUS_FAILED_DEPENDENCY               = SOUP_STATUS_FAILED_DEPENDENCY,

        HTTP_STATUS_INTERNAL_SERVER_ERROR           = SOUP_STATUS_INTERNAL_SERVER_ERROR,
        HTTP_STATUS_NOT_IMPLEMENTED                 = SOUP_STATUS_NOT_IMPLEMENTED,
        HTTP_STATUS_BAD_GATEWAY                     = SOUP_STATUS_BAD_GATEWAY,
        HTTP_STATUS_SERVICE_UNAVAILABLE             = SOUP_STATUS_SERVICE_UNAVAILABLE,
        HTTP_STATUS_GATEWAY_TIMEOUT                 = SOUP_STATUS_GATEWAY_TIMEOUT,
        HTTP_STATUS_HTTP_VERSION_NOT_SUPPORTED      = SOUP_STATUS_HTTP_VERSION_NOT_SUPPORTED,
        HTTP_STATUS_INSUFFICIENT_STORAGE            = SOUP_STATUS_INSUFFICIENT_STORAGE,
        HTTP_STATUS_NOT_EXTENDED                    = SOUP_STATUS_NOT_EXTENDED
    };

    //.........................................................................

    struct URI
    {
        String  scheme;
        String  user;
        String  password;
        String  host;
        guint   port;
        String  path;
        String  query;
        String  fragment;
    };

    //.........................................................................

    class Request
    {
    public:

        class Body
        {
        public:

            virtual ~Body() {}
            virtual const char* get_data() const = 0;
            virtual gsize get_length() const = 0;

        protected:
            Body() {}
        private:
            Body( const Body& ) {}
        };

        enum Method { HTTP_GET , HTTP_POST , HTTP_PUT , HTTP_DELETE , HTTP_HEAD , OTHER };

        virtual ~Request() {}

        virtual Method get_method() const = 0;
        virtual guint16 get_server_port( ) const = 0;
        virtual String get_path( ) const = 0;
        virtual URI get_uri() const = 0;
        virtual String get_request_uri( ) const = 0;
        virtual String get_header( const String& name ) const = 0;
        virtual StringMultiMap get_headers( ) const = 0;
        virtual StringList get_header_names( ) const = 0;
        virtual StringMap get_parameters( ) const = 0;
        virtual StringList get_parameter_names( ) const = 0;
        virtual String get_parameter( const String& name ) const = 0;
        virtual String get_content_type( ) const = 0;
        virtual goffset get_content_length( ) const = 0;
        virtual const Body& get_body() const = 0;

        virtual void print_headers() const = 0;
        virtual void print_parameters() const = 0;

    protected:
        Request() {}
    private:
        Request( const Request& ) {}
    };

    //.........................................................................

    class Response : public RefCounted
    {
    public:

        class StreamBody
        {
        public:
            virtual void append( const char* data , gsize size ) = 0;
            virtual void complete() = 0;
            virtual void cancel() = 0;
        protected:
            StreamBody() {}
            virtual ~StreamBody() {}
        private:
            StreamBody( const StreamBody& ) {}
        };

        class StreamWriter
        {
        public:
            virtual ~StreamWriter() {}
            virtual void write( StreamBody& body ) = 0;
        };

        virtual void set_header( const String& name , const String& value ) = 0;
        virtual void set_response( const String& content_type , const char* data , gsize size ) = 0;
        virtual void set_response( const String& content_type , const String& content ) = 0;
        virtual void set_status( ServerStatus status , const String& msg = String() ) = 0;
        virtual void set_content_type( const String& content_type ) = 0;
        virtual void set_content_length( goffset content_length ) = 0;
        virtual String get_content_type( ) const = 0;
        virtual void set_stream_writer( StreamWriter* stream_writer ) = 0;
        virtual bool respond_with_file_contents( const String& file_name_or_uri , const String& content_type = String() ) = 0;

        // pause increases the ref count on this response and returns a pointer to it.
        // This is so that you can defer processing of the response beyond the
        // handler callback.

        virtual Response* pause() = 0;

        virtual bool is_paused() const = 0;

        // Resume decreases the ref count and tells the server the response
        // is ready to be sent.

        virtual void resume() = 0;

    protected:

        Response() {};

        virtual ~Response() {}

    private:

        Response( const Response& ) {};
    };

    //.........................................................................

    class RequestHandler
    {
    public:

        RequestHandler();
        RequestHandler( HttpServer* server , const String& path );

        virtual ~RequestHandler();

        virtual void handle_http_request( const Request& request , Response& response ) {}

        virtual void handle_http_get( const Request& request , Response& response ) { handle_http_request( request , response ); }
        virtual void handle_http_post( const Request& request , Response& response ) { handle_http_request( request , response ); }
        virtual void handle_http_put( const Request& request , Response& response ) { handle_http_request( request , response ); }
        virtual void handle_http_delete( const Request& request , Response& response ) { handle_http_request( request , response ); }
        virtual void handle_http_head( const Request& request , Response& response ) { handle_http_request( request , response ); }

    protected:

        HttpServer*     server;
        String          path;
    };

    //.........................................................................

    HttpServer( guint16 port = 0 , GMainContext* context = 0 );

    ~HttpServer();

    void register_handler( const String& path , RequestHandler* handler );

    void unregister_handler( const String& path );

    guint16 get_port() const;

    // Only for servers that were created with their own GMainContext

    void run();

    void quit();

private:

    struct HandlerUserData
    {
        HandlerUserData( HttpServer* _server , RequestHandler* _handler )
            :
            server( _server ),
            handler( _handler )
        {
            g_assert( server );
            g_assert( handler );
        }

        HttpServer*         server;
        RequestHandler*     handler;

        static void destroy( HandlerUserData* me )
        {
            delete me;
        }
    };

    static void soup_server_callback(
            SoupServer* server,
            SoupMessage* msg,
            const char* path,
            GHashTable* query,
            SoupClientContext* client,
            gpointer user_data
    );

    SoupServer* server;
};



#endif /* _TRICKPLAY_HTTP_SERVER_H_ */
