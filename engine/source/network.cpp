
#include <cstring>
#include <cstdlib>

#include "curl/curl.h"
#include "openssl/ssl.h"

#include "network.h"
#include "util.h"
#include "app.h"

//****************************************************************************
// Internal structure to hold all the things we care about while we are
// working on a request


class Network::RequestClosure
{

public:

    RequestClosure( const Settings & _settings, const Request & req, CookieJar * cj )
    :
        settings( _settings ),
        event_group( NULL ),
        request( req ),
        callback( NULL ),
        incremental_callback( NULL ),
        data( NULL ),
        notify( NULL ),
        got_body( false ),
        put_offset( 0 ),
        cookie_jar( cookie_jar_ref( cj ) )

    {
        if ( event_group )
        {
            event_group->ref();
        }
    }

    RequestClosure( const Settings & _settings, EventGroup * eg, const Request & req, CookieJar * cj, ResponseCallback cb, gpointer d, GDestroyNotify dn )
    :
        settings( _settings ),
        event_group( eg ),
        request( req ),
        callback( cb ),
        incremental_callback( NULL ),
        data( d ),
        notify( dn ),
        got_body( false ),
        put_offset( 0 ),
        cookie_jar( cookie_jar_ref( cj ) )
    {
        if ( event_group )
        {
            event_group->ref();
        }
    }

    RequestClosure( const Settings & _settings, EventGroup * eg, const Request & req, CookieJar * cj, IncrementalResponseCallback icb, gpointer d, GDestroyNotify dn )
    :
        settings( _settings ),
        event_group( eg ),
        request( req ),
        callback( NULL ),
        incremental_callback( icb ),
        data( d ),
        notify( dn ),
        got_body( false ),
        put_offset( 0 ),
        cookie_jar( cookie_jar_ref( cj ) )
    {
        if ( event_group )
        {
            event_group->ref();
        }
    }

    ~RequestClosure()
    {
        if ( notify )
        {
            notify( data );
        }

        cookie_jar_unref( cookie_jar );

        if ( event_group )
        {
            event_group->unref();
        }
    }

    Settings                    settings;
    EventGroup         *        event_group;
    Request                     request;
    ResponseCallback            callback;
    IncrementalResponseCallback incremental_callback;
    gpointer                    data;
    GDestroyNotify              notify;
    Response                    response;
    bool                        got_body;
    size_t                      put_offset;
    CookieJar         *         cookie_jar;
};


//****************************************************************************
// Events that we push into the network thread's queue

class Network::Event
{
public:

    enum Type {QUIT, REQUEST};

    static Event * quit()
    {
        return new Event( QUIT );
    }

    static Event * request( RequestClosure * rc )
    {
        return new Event( rc );
    }

    static void destroy( gpointer event )
    {
        delete ( Event * )event;
    }

    ~Event()
    {
        if ( closure )
        {
            delete closure;
        }
    }

    RequestClosure * steal_closure()
    {
        RequestClosure * result = closure;
        closure = NULL;
        return result;
    }

    const Type type;

private:

    Event( Type t )
        :
        type( t ),
        closure( NULL )
    {}

    Event( RequestClosure * rc )
        :
        type( REQUEST ),
        closure( rc )
    {}

    RequestClosure * closure;
};



//****************************************************************************
// Cookie Jar

class Network::CookieJar : public RefCounted
{
public:

    CookieJar( const char * fn )
        :
        new_session( true ),
        file_name( fn ),
        mutex( g_mutex_new() )
    {
        g_debug( "CREATED COOKIE JAR %p", this );

        if ( g_file_test( fn, G_FILE_TEST_EXISTS ) )
        {
            gchar * contents = NULL;
            GError * error = NULL;

            g_file_get_contents( fn, &contents, NULL, &error );

            if ( error )
            {
                g_warning( "FAILED TO READ COOKIE FILE '%s' : %s", fn, error->message );
                g_clear_error( &error );
            }
            else
            {
                gchar ** lines = g_strsplit( contents, "\n", 0 );
                for ( gchar ** line = lines; *line; ++line )
                {
                    cookies.push_back( String( *line ) );
                }
                g_strfreev( lines );
            }

            g_free( contents );
        }
    }

    void set_cookie( const char * set_cookie_header )
    {
        Util::GMutexLock lock( mutex );

        cookies.push_back( set_cookie_header );
    }

    void add_cookies_to_handle( CURL * handle, bool clear_session = false )
    {
        Util::GMutexLock lock( mutex );

        for ( StringList::const_iterator it = cookies.begin(); it != cookies.end(); ++it )
        {
            curl_easy_setopt( handle, CURLOPT_COOKIELIST, it->c_str() );
        }

        if ( new_session || clear_session )
        {
            // This is to get around a bug in curl I reported. If you
            // call "SESS" when the cookie system has not been initialized
            // you will get a crash. Passing an empty string does nothing
            // aside from initializing curl's cookie system for the handle.
            // The bug is in cookie.c, Curl_cookie_clearsess

            if ( cookies.empty() )
            {
                curl_easy_setopt( handle, CURLOPT_COOKIELIST, "" );
            }

            curl_easy_setopt( handle, CURLOPT_COOKIELIST, "SESS" );
            new_session = false;
        }
    }

private:

    ~CookieJar()
    {
        g_debug( "DESTROYING COOKIE JAR %p", this );

        save();
        g_mutex_free( mutex );
    }

    void save()
    {
        CURL * eh = curl_easy_init();
        add_cookies_to_handle( eh, true );
        curl_easy_setopt( eh, CURLOPT_COOKIEJAR, file_name.c_str() );
        // This causes curl to save all the cookies back to the file
        // name we gave it above.
        curl_easy_cleanup( eh );
    }

    bool        new_session;
    String      file_name;
    StringList  cookies;
    GMutex   *  mutex;
};




//*****************************************************************************
// Request

Network::Request::Request( const String & _user_agent, const String & _url )
    :
    url( _url ),
    method( "GET" ),
    timeout_s( 30 ),
    redirect( true ),
    user_agent( _user_agent )
{
}

//*****************************************************************************
// Response

Network::Response::Response()
    :
    code( 0 ),
    body( g_byte_array_new() ),
    failed( false )
{
}

Network::Response::~Response()
{
    g_byte_array_unref( body );
}

Network::Response::Response( const Response & other )
    :
    code( other.code ),
    headers( other.headers ),
    status( other.status ),
    body( other.body ),
    failed( other.failed )
{
    g_byte_array_ref( body );
}

const Network::Response & Network::Response::operator =( const Network::Response & other )
{
    code = other.code;
    headers = other.headers;
    status = other.status;
    body = other.body;
    failed = other.failed;

    g_byte_array_ref( body );

    return * this;
}

const char * Network::Response::get_header( const String & name )
{
    StringMultiMap::const_iterator it = headers.find( name );

    return it == headers.end() ? NULL : it->second.c_str();
}


//*****************************************************************************

class Network::Thread
{
public:

    Thread( GAsyncQueue * q )
        :
        queue( q ),
        thread( g_thread_create( process, q, TRUE, NULL ) )
    {
        g_assert( queue );
        g_async_queue_ref( queue );
    }

    ~Thread()
    {
        g_async_queue_push( queue, Event::quit() );
        g_thread_join( thread );
        thread = NULL;
        g_async_queue_unref( queue );
    }

    //.........................................................................
    // This one calls the response callback from an idle source when a request
    // is done

    static gboolean response_callback( gpointer rc )
    {
        RequestClosure * closure = ( RequestClosure * )rc;

        if ( closure->incremental_callback )
        {
            closure->incremental_callback( closure->response, NULL, 0, true, closure->data );
        }
        else
        {
            closure->callback( closure->response, closure->data );
        }

        return FALSE;
    }

    //.........................................................................
    // This one deletes a request closure after the response callback is done

    static void request_closure_destroy( gpointer rc )
    {
        delete ( RequestClosure * )rc;
    }
    //.........................................................................
    // A request is finished, we set an idle source to run the response callback.

    static void request_finished( RequestClosure * closure )
    {
        g_assert( closure->event_group );
        closure->event_group->add_idle( G_PRIORITY_DEFAULT_IDLE, response_callback, closure, request_closure_destroy );
    }

    //.........................................................................
    // A request failed, this just sets the right fields in the closure

    static void request_failed( RequestClosure * closure, CURLcode c )
    {
        closure->response.failed = true;
        closure->response.code = c;
        closure->response.status = curl_easy_strerror( c );

        g_warning( "URL REQUEST FAILED '%s' : %d : %s", closure->request.url.c_str(), c, closure->response.status.c_str() );
    }


    //=========================================================================
    // CURL calllbacks
    //=========================================================================

    // The last parameter is a pointer to a RequestClosure

    static size_t curl_write_callback( void * ptr, size_t size, size_t nmemb, void * c )
    {
        g_assert( c );
        size_t result = size * nmemb;
        RequestClosure * closure = ( RequestClosure * ) c;

        closure->got_body = true;

        if ( closure->incremental_callback )
        {
            // If the callback returns false, we return 0 so that
            // curl will abort the request

            if ( !closure->incremental_callback( closure->response, ptr, result, false, closure->data ) )
            {
                result = 0;
            }
        }
        else
        {
            g_byte_array_append( closure->response.body, ( const guint8 * )ptr, result );
        }

        return result;
    }

    static size_t curl_read_callback( void * ptr, size_t size, size_t nmemb, void * c )
    {
        g_assert( c );
        size_t result = size * nmemb;
        RequestClosure * closure = ( RequestClosure * ) c;

        if ( closure->request.body.length() == 0 )
        {
            return 0;
        }

        size_t left = closure->request.body.length() - closure->put_offset;

        if ( left > result )
        {
            left = result;
        }

        if ( left )
        {
            memcpy( ptr, closure->request.body.c_str(), left );

            closure->put_offset += left;
        }

        return left;
    }

    static size_t curl_header_callback( void * ptr, size_t size, size_t nmemb, void * c )
    {
        g_assert( c );
        size_t result = size * nmemb;
        RequestClosure * closure = ( RequestClosure * ) c;

        // The last header only has two bytes

        if ( result == 2 )
        {
            // do nothing
        }
        // This is to ignore trailer headers that may come after the body

        else if ( !closure->got_body && result > 2 )
        {
            String header( ( char * )ptr, result - 2 );

            size_t sep = header.find( ':' );

            // If it doesn't have a ":", it must be the status line

            if ( sep == std::string::npos )
            {
                closure->response.headers.clear();

                gchar ** parts = g_strsplit( header.c_str(), " ", 3 );

                if ( g_strv_length( parts ) != 3 )
                {
                    g_warning( "BAD HEADER LINE '%s'", header.c_str() );
                }
                else
                {
                    closure->response.code = atoi( parts[1] );
                    closure->response.status = parts[2];
                }
                g_strfreev( parts );
            }
            else
            {
                if ( g_str_has_prefix( header.c_str(), "Set-Cookie:" ) && closure->cookie_jar )
                {
                    closure->cookie_jar->set_cookie( header.c_str() );
                }

                closure->response.headers.insert(
                    std::make_pair( header.substr( 0, sep ), header.substr( sep + 2, header.length() ) ) );
            }
        }

        return result;
    }

    // The SSL callback to set client certificates

    static int ssl_client_cert_callback( SSL * ssl, X509 ** x509, EVP_PKEY ** pkey)
    {
        SSL_CTX * ctx = SSL_get_SSL_CTX( ssl );

        if ( ! ctx )
        {
            g_warning( "FAILED TO GET SSL CONTEXT IN CLIENT CERT CALLBACK" );
            return 0;
        }

        RequestClosure * closure = ( RequestClosure * ) SSL_CTX_get_app_data( ctx );

        if ( ! closure )
        {
            g_warning( "FAILED TO GET REQUEST CLOSURE IN CLIENT CERT CALLBACK" );
            return 0;
        }

        // Read and set the client certificate

        if ( ! closure->request.client_certificate_pem.empty() )
        {
            BIO * bio = BIO_new_mem_buf( const_cast< char * >( closure->request.client_certificate_pem.c_str() ), -1 );

            X509 * cert = PEM_read_bio_X509( bio, x509, NULL, NULL );

            if ( ! cert )
            {
                g_warning( "FAILED TO READ CLIENT CERTIFICATE" );
            }
            else
            {
                g_debug( "SSL CLIENT CERTIFICATE SET" );
            }

            BIO_free( bio );
        }

        // Read and set the client private key

        if ( ! closure->request.client_private_key_pem.empty() )
        {
            BIO * bio = BIO_new_mem_buf( const_cast< char * >( closure->request.client_private_key_pem.c_str() ), -1 );

            EVP_PKEY * key = PEM_read_bio_PrivateKey( bio, pkey, NULL, NULL );

            if ( ! key )
            {
                g_warning( "FAILED TO READ CLIENT PRIVATE KEY" );
            }
            else
            {
                g_debug( "SSL CLIENT PRIVATE KEY SET" );
            }

            BIO_free( bio );
        }

        // If they are both OK, return 1

        if ( *x509 && *pkey )
        {
            return 1;
        }

        // Otherwise, clear and free the other one

        if ( *x509 )
        {
            X509_free( *x509 );
            *x509 = NULL;
        }

        if ( *pkey )
        {
            EVP_PKEY_free( *pkey );
            *pkey = NULL;
        }

        return 0;
    }

    // The SSL callback

    static CURLcode curl_ssl_ctx_callback( CURL * eh, void * sslctx , void * c )
    {
        SSL_CTX * ctx = ( SSL_CTX * )sslctx;

        // If the request has a client certificate and a private key, we set
        // another callback to read them.

        RequestClosure * closure = ( RequestClosure * ) c;

        if ( ! closure->request.client_certificate_pem.empty() && ! closure->request.client_private_key_pem.empty() )
        {
            SSL_CTX_set_client_cert_cb( ctx, ssl_client_cert_callback );
            SSL_CTX_set_app_data( ctx, c );
        }

#if 0
        ctx->cert_store->param->check_time = time_t( our_time / 1000 );
        ctx->cert_store->param->flags |= X509_V_FLAG_USE_CHECK_TIME;
#endif

        return CURLE_OK;
    }

    //=========================================================================
    // Set-up an easy handle
    //=========================================================================

#define cc(f) if(CURLcode c=f) throw c

    static CURL * create_easy_handle( RequestClosure * closure )
    {
        CURL * eh = curl_easy_init();
        g_assert( eh );

        try
        {
            // Limit to http and https - nothing else
            cc( curl_easy_setopt( eh, CURLOPT_PROTOCOLS, CURLPROTO_HTTP | CURLPROTO_HTTPS ) );

            cc( curl_easy_setopt( eh, CURLOPT_PRIVATE, closure ) );

            cc( curl_easy_setopt( eh, CURLOPT_NOPROGRESS, 1 ) );
            cc( curl_easy_setopt( eh, CURLOPT_NOSIGNAL, 1 ) );
            cc( curl_easy_setopt( eh, CURLOPT_WRITEFUNCTION, curl_write_callback ) );
            cc( curl_easy_setopt( eh, CURLOPT_WRITEDATA, closure ) );
            cc( curl_easy_setopt( eh, CURLOPT_READFUNCTION, curl_read_callback ) );
            cc( curl_easy_setopt( eh, CURLOPT_READDATA, closure ) );
            cc( curl_easy_setopt( eh, CURLOPT_HEADERFUNCTION, curl_header_callback ) );
            cc( curl_easy_setopt( eh, CURLOPT_HEADERDATA, closure ) );

            cc( curl_easy_setopt( eh, CURLOPT_URL, closure->request.url.c_str() ) );

            cc( curl_easy_setopt( eh, CURLOPT_SSL_CTX_FUNCTION, curl_ssl_ctx_callback ) );
            cc( curl_easy_setopt( eh, CURLOPT_SSL_CTX_DATA, closure ) );

            cc( curl_easy_setopt( eh, CURLOPT_SSL_VERIFYPEER, closure->settings.ssl_verify_peer ? 1 : 0 ) );

            if ( closure->settings.ssl_verify_peer && ! closure->settings.ssl_cert_bundle.empty() )
            {
                cc( curl_easy_setopt( eh, CURLOPT_CAINFO, closure->settings.ssl_cert_bundle.c_str() ) );
            }

            // TODO: proxy
            cc( curl_easy_setopt( eh, CURLOPT_FOLLOWLOCATION, closure->request.redirect ? 1 : 0 ) );
            cc( curl_easy_setopt( eh, CURLOPT_USERAGENT, closure->request.user_agent.c_str() ) );

            struct curl_slist * headers = NULL;
            for ( StringMap::const_iterator it = closure->request.headers.begin(); it != closure->request.headers.end(); ++it )
            {
                curl_slist_append( headers, std::string( it->first + ":" + it->second ).c_str() );
            }

            cc( curl_easy_setopt( eh, CURLOPT_HTTPHEADER, headers ) );
            // TODO: do we free the slist?

            if ( closure->request.method == "PUT" )
            {
                cc( curl_easy_setopt( eh, CURLOPT_UPLOAD, 1 ) );
                cc( curl_easy_setopt( eh, CURLOPT_INFILESIZE, closure->request.body.size() ) );
            }
            else if ( closure->request.method == "POST" )
            {
                cc( curl_easy_setopt( eh, CURLOPT_POST, 1 ) );
                cc( curl_easy_setopt( eh, CURLOPT_POSTFIELDSIZE, closure->request.body.size() ) );
            }
            else if ( closure->request.method != "GET" )
            {
                cc( curl_easy_setopt( eh, CURLOPT_CUSTOMREQUEST, closure->request.method.c_str() ) );
            }

            cc( curl_easy_setopt( eh, CURLOPT_TIMEOUT_MS, closure->request.timeout_s * 1000 ) );

            if ( closure->cookie_jar )
            {
                closure->cookie_jar->add_cookies_to_handle( eh );
            }

#ifndef TP_PRODUCTION

            cc( curl_easy_setopt( eh, CURLOPT_VERBOSE, closure->settings.debug ? 1 : 0 ) );
#endif
        }
        catch ( CURLcode c )
        {
            curl_easy_cleanup( eh );
            eh = NULL;
            request_failed( closure, c );
        }

        return eh;
    }

#undef cc

    //=========================================================================
    // The function that the thread runs

    static gpointer process( gpointer q )
    {
        g_debug( "STARTED NETWORK THREAD %p", g_thread_self() );

        // Get the queue

        GAsyncQueue * queue = ( GAsyncQueue * )q;

        // Initialize the multi handle

        CURLM * multi = curl_multi_init();
        g_assert( multi );

        // Variables pulled out of the loop

        GTimeVal tv;
        long timeout;
        glong pop_wait;
        int running_handles = 0;
        std::set<CURL *> handles;
        Event * event;

        while ( true )
        {
            if ( running_handles )
            {
                // If there are running requests, we won't wait for new ones
                // to arrive

                pop_wait = 0;
            }
            else
            {
                // Otherwise, we use the curl multi timeout as guidance. This
                // number is sometimes completely out of whack.

                timeout = 0;
                curl_multi_timeout( multi, &timeout );

                pop_wait = ( timeout < 0 || timeout > 1000 ) ? G_USEC_PER_SEC : timeout * 1000;
            }

            if ( pop_wait )
            {
                // Wait for a new request

                g_get_current_time( &tv );
                g_time_val_add( &tv, pop_wait );

                event = ( Event * )g_async_queue_timed_pop( queue, &tv );
            }
            else
            {
                // See if there is a new request but don't wait

                event = ( Event * )g_async_queue_try_pop( queue );
            }

            if ( event )
            {
                if ( event->type == Event::QUIT )
                {
                    // Cleanup any handles that are still running

                    for ( std::set<CURL *>::const_iterator it = handles.begin(); it != handles.end(); ++it )
                    {
                        CURL * eh = *it;

                        RequestClosure * closure = NULL;

                        curl_easy_getinfo( eh, CURLINFO_PRIVATE, &closure );
                        curl_multi_remove_handle( multi, eh );
                        curl_easy_cleanup( eh );

                        if ( closure )
                        {
                            delete closure;
                        }
                    }

                    delete event;

                    // Break out of the main thread loop, not switch

                    break;
                }
                else if ( event->type == Event::REQUEST )
                {
                    // Initialize the new request

                    RequestClosure * closure = event->steal_closure();

                    // Create the easy handle for it

                    CURL * eh = create_easy_handle( closure );

                    if ( !eh )
                    {
                        request_finished( closure );
                    }
                    else
                    {
                        curl_multi_add_handle( multi, eh );
                        handles.insert( eh );
                    }

                    delete event;
                }
                else
                {
                    delete event;
                }
            }


            // Perform all the requests

            while ( true )
            {
                CURLMcode result = curl_multi_perform( multi, &running_handles );

                if ( result != CURLM_CALL_MULTI_PERFORM )
                {
                    break;
                }

#ifndef TP_PRODUCTION

                static float slow = -1;

                if ( slow == -1 )
                {
                    if ( const char * e = g_getenv( "TP_NETWORK_DELAY" ) )
                    {
                        slow = atof( e );
                    }
                    else
                    {
                        slow = 0;
                    }
                }

                if ( slow )
                {
                    usleep( slow * G_USEC_PER_SEC );
                }
#endif

            }

            // Check for requests that are finished, whether completed or
            // failed

            int msgs_in_queue;

            while ( true )
            {
                CURLMsg * msg = curl_multi_info_read( multi, &msgs_in_queue );

                if ( !msg )
                {
                    break;
                }

                CURL * eh = msg->easy_handle;

                if ( msg->msg == CURLMSG_DONE )
                {
                    RequestClosure * closure = NULL;

                    curl_easy_getinfo( eh, CURLINFO_PRIVATE, &closure );
                    g_assert( closure );

                    if ( msg->data.result != CURLE_OK )
                    {
                        request_failed( closure, msg->data.result );
                    }

                    handles.erase( eh );

                    curl_multi_remove_handle( multi, eh );

                    curl_easy_cleanup( eh );

                    request_finished( closure );
                }
            }
        }

        curl_multi_cleanup( multi );

        g_debug( "NETWORK THREAD TERMINATING %p", g_thread_self() );

        return NULL;
    }

private:

    GAsyncQueue  *  queue;
    GThread    *    thread;
};

//*****************************************************************************

Network::Network( const Settings & _settings, EventGroup * _event_group )
:
    settings( _settings ),
    event_group( _event_group ),
    queue( g_async_queue_new_full( Event::destroy ) ),
    thread( NULL )
{
    g_assert( event_group );
    g_assert( queue );

    event_group->ref();
}

//.............................................................................

Network::~Network()
{
    if ( thread )
    {
        delete thread;
    }

    g_async_queue_unref( queue );

    event_group->unref();
}

//.............................................................................

void Network::start()
{
    if ( !thread )
    {
        thread = new Thread( queue );
        g_assert( thread );
    }
}

//.............................................................................

String Network::format_user_agent( const char * language,
                                   const char * country,
                                   const char * app_id,
                                   int app_release,
                                   const char * system_name,
                                   const char * system_version )
{
    static const char * user_agent_template = "Mozilla/5.0 (compatible; %s-%s) TrickPlay/%d.%d.%d (%s/%d; %s/%s)";

    gchar * ua = g_strdup_printf( user_agent_template,
                                  language, country,
                                  TP_MAJOR_VERSION, TP_MINOR_VERSION, TP_PATCH_VERSION,
                                  app_id, app_release,
                                  system_name, system_version );

    String result( ua );

    g_free( ua );

    return result;
}

//.............................................................................

Network::CookieJar * Network::cookie_jar_new( const char * file_name )
{
    return new CookieJar( file_name );
}

//.............................................................................

Network::CookieJar * Network::cookie_jar_ref( CookieJar * cookie_jar )
{
    CookieJar::ref( cookie_jar );
    return cookie_jar;
}

//.............................................................................

Network::CookieJar * Network::cookie_jar_unref( CookieJar * cookie_jar )
{
    CookieJar::unref( cookie_jar );
    return NULL;
}

//.............................................................................

Network::Response Network::perform_request( const Request & request, CookieJar * cookie_jar )
{
    RequestClosure closure( settings, request, cookie_jar );

    CURL * eh = Thread::create_easy_handle( &closure );

    if ( eh )
    {
        CURLcode c = curl_easy_perform( eh );

        if ( c != CURLE_OK )
        {
            Thread::request_failed( &closure, c );
        }

        curl_easy_cleanup( eh );
    }

    return closure.response;
}

//.............................................................................

void Network::perform_request_async( const Network::Request & request, Network::CookieJar * cookie_jar, Network::ResponseCallback callback, gpointer user, GDestroyNotify notify )
{
    start();

    g_async_queue_push( queue, Event::request( new RequestClosure( settings, event_group, request, cookie_jar, callback, user, notify ) ) );
}

//.............................................................................

void Network::perform_request_async_incremental( const Network::Request & request, Network::CookieJar * cookie_jar, Network::IncrementalResponseCallback callback, gpointer user, GDestroyNotify notify )
{
    start();

    g_async_queue_push( queue, Event::request( new RequestClosure( settings, event_group, request, cookie_jar, callback, user, notify ) ) );
}

//.............................................................................

