/*
 * http_server.h
 *
 *  Created on: Apr 1, 2011
 */

#ifndef HTTP_SERVER_H_
#define HTTP_SERVER_H_
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
		virtual StringMap get_headers( ) const = 0;
		virtual StringList get_header_names( ) const = 0;
		virtual StringMap get_parameters( ) const = 0;
		virtual StringList get_parameter_names( ) const = 0;
		virtual String get_parameter( const String& name ) const = 0;
		virtual int get_body_size( ) const = 0;
		virtual const char * get_body_data( ) const = 0;
		virtual String get_content_type( ) const = 0;
		virtual unsigned int get_content_length( ) const = 0;

	};

	class Response
	{
	public:
		virtual void set_header( const String& name, const String& value ) = 0;
	    virtual void set_response( const String& mime_type, const char * data, unsigned int size ) = 0;
	    virtual void setStatus( int sc ) = 0;
	    virtual void sendError( int sc ) = 0;
	    virtual void sendError( int sc, const String& msg ) = 0;
	};

	class RequestHandler
    {
    public:
        virtual void do_get( const Request& request, Response& response ) {}
        virtual void do_post(  const Request& request, Response& response ) {}
        virtual void do_put(  const Request& request, Response& response ) {}
        virtual void do_delete(  const Request& request, Response& response ) {}
        virtual void do_head(  const Request& request, Response& response ) {}
    };

    HttpServer( guint16 port = 0 );

    ~HttpServer();

    void register_handler( const String& path, RequestHandler& handler );

    void unregister_handler( const String& path );

    guint16 get_port() const;

private:
    void service_request( SoupMessage *msg, const char* registered_path, const char * requested_path, GHashTable *query, SoupClientContext *client );
    Request* make_request( SoupMessage *msg, const char * path, GHashTable *query, SoupClientContext *client );
    Response* make_response( SoupMessage *msg, const char * path, GHashTable *query, SoupClientContext *client );

    static void soup_server_callback(
    		SoupServer *server,
            SoupMessage *msg,
            const char *path,
            GHashTable *query,
            SoupClientContext *client,
            gpointer user_data
            );

    std::auto_ptr<SoupServer> server;

    typedef std::map<String, RequestHandler*> RequestHandlerMap;
    RequestHandlerMap handler_map;
};



#endif /* HTTP_SERVER_H_ */
