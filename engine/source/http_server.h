#ifndef _TRICKPLAY_HTTP_SERVER_H_
#define _TRICKPLAY_HTTP_SERVER_H_

#include "common.h"
#include "libsoup/soup.h"

class HttpServer
{
public:

	class Request
	{
	public:
		virtual guint16 get_server_port( ) const = 0;
		virtual String get_request_uri( ) const = 0;
		virtual String get_header( const String & name ) const = 0;
		virtual StringMultiMap get_headers( ) const = 0;
		virtual StringList get_header_names( ) const = 0;
		virtual StringMap get_parameters( ) const = 0;
		virtual StringList get_parameter_names( ) const = 0;
		virtual String get_parameter( const String& name ) const = 0;
		virtual goffset get_body_size( ) const = 0;
		virtual const char * get_body_data( ) const = 0;
		virtual String get_content_type( ) const = 0;
		virtual goffset get_content_length( ) const = 0;
	protected:
		Request() {}
	private:
		Request( const Request & ) {}
	};

	class Response
	{
	public:
		virtual void set_header( const String& name, const String& value ) = 0;
	    virtual void set_response( const String& mime_type, const char * data, unsigned int size ) = 0;
	    virtual void set_status( int sc , const String & msg = String() ) = 0;
	protected:
	    Response() {}
	private:
	    Response( const Response & ) {}
	};

	class RequestHandler
    {
    public:
        virtual void do_get( const Request & request, Response & response ) {}
        virtual void do_post(  const Request & request, Response & response ) {}
        virtual void do_put(  const Request & request, Response & response ) {}
        virtual void do_delete(  const Request & request, Response & response ) {}
        virtual void do_head(  const Request & request, Response & response ) {}
    };

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
