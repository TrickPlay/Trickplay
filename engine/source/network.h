#ifndef _TRICKPLAY_NETWORK_H
#define _TRICKPLAY_NETWORK_H
//.............................................................................
#include "common.h"
//.............................................................................
// Forward declarations

class EventGroup;
//.............................................................................

class Network
{
public:

    //.........................................................................

    class CookieJar;

    //.........................................................................

    class Request
    {
    public:

        Request();

        Request( const String& user_agent, const String& url = String() );

        String      url;
        String      method;
        StringMap   headers;
        double      timeout_s;
        String      client_certificate_pem;
        String      client_private_key_pem;
        String      body;
        bool        redirect;
        String      user_agent;

        void set_headers( const gchar* _headers );

    private:

        void set_default_user_agent();

    };

    //.........................................................................

    class Response
    {
    public:

        Response();
        ~Response();
        Response( const Response& other );
        const Response& operator =( const Response& other );

        const char* get_header( const String& name ) const;

        void replace_body( gpointer data , gsize size );

        int             code;
        StringMultiMap  headers;
        String          status;
        GByteArray*     body;
        bool            failed;
    };


    //.........................................................................

    struct Settings
    {
        Settings( TPContext* context );

        Settings( bool _debug = false, bool _ssl_verify_peer = true, const String& _ssl_cert_bundle = String() )
            :
            debug( _debug ),
            ssl_verify_peer( _ssl_verify_peer ),
            ssl_cert_bundle( _ssl_cert_bundle )
        {}

        bool    debug;
        bool    ssl_verify_peer;
        String  ssl_cert_bundle;
    };

    //.........................................................................

    Network();

    Network( const Settings& settings, EventGroup* event_group );

    ~Network();

    //.........................................................................
    // Format a user agent

    static String format_user_agent( const char* language,
            const char* country,
            const char* app_id,
            int app_release,
            const char* system_name,
            const char* system_version );

    //.........................................................................
    // Cookie jar functions

    static CookieJar* cookie_jar_new( const char* file_name );

    static CookieJar* cookie_jar_ref( CookieJar* cookie_jar );

    // This one always returns NULL

    static CookieJar* cookie_jar_unref( CookieJar* cookie_jar );

    //.........................................................................
    // This performs the request asynchronously and invokes the callback exactly
    // once in the main thread when the request is finished.

    typedef void ( *ResponseCallback )( const Response& response, gpointer user );

    guint perform_request_async( const Request& request, CookieJar* cookie_jar, ResponseCallback callback, gpointer user, GDestroyNotify notify );

    //.........................................................................
    // This performs the request asynchronously but invokes the callback every
    // time data is received and in the network thread. The data is not appended
    // to the response body, but passed directly to the callback. When the
    // request is finished, the callback is invoked one last time and in the MAIN
    // thread with finished set to true.
    //
    // If the callback returns false, the request is aborted early - but the
    // callback will still get called one last time with finished set to true.

    typedef bool ( *IncrementalResponseCallback )( const Response& response, gpointer body, guint len, bool finished, gpointer user );

    guint perform_request_async_incremental( const Request& request, CookieJar* cookie_jar, IncrementalResponseCallback callback, gpointer user, GDestroyNotify notify , bool synchronized = false );

    //.........................................................................

    void cancel_async_request( guint id );

    //.........................................................................
    // Performs the request in the calling thread and returns the complete
    // response

    Response perform_request( const Request& request, CookieJar* cookie_jar );

private:

    class RequestClosure;
    class IncrementalResponseClosure;
    class Event;
    class Thread;

    //.........................................................................
    // Starts the thread if it is not running

    void start();

    Settings        settings;
    EventGroup*     event_group;
    GAsyncQueue*    queue;
    Thread*         thread;
};

#endif // _TRICKPLAY_NETWORK_H
