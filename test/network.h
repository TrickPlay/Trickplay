#ifndef NETWORK_H
#define NETWORK_H

#include "glib.h"
#include <string>
#include <map>

namespace Network
{   
    typedef std::string String;
    typedef std::map<std::string,std::string> StringMap;
    typedef std::multimap<std::string,std::string> StringMultiMap;
    
    class Request
    {
    public:
        
        Request();
            
        String      url;
        String      method;
        StringMap   headers;
        double      timeout_s;
        String      client_certificate_pem;
        String      client_private_key_pem;
        String      body;
        bool        redirect;
        String      user_agent;
    };
    
    class Response
    {
    public:
        
        Response();
        ~Response();
        Response(const Response & other);
        
        int             code;
        StringMultiMap  headers;
        String          status;
        GByteArray *    body;
        bool            failed;
    };
    
    void shutdown();
    
    //.........................................................................
    // This performs the request asynchronously and invokes the callback exactly
    // once in the main thread when the request is finished.
    
    typedef void (*ResponseCallback)(const Response & response,gpointer user);
    
    void perform_request_async(const Request & request,ResponseCallback callback,gpointer user);
    
    //.........................................................................
    // This performs the request asynchronously but invokes the callback every
    // time data is received and in the network thread. The data is not appended
    // to the response body, but passed directly to the callback. When the
    // request is finished, the callback is invoked with finished set to true.
    // If the callback returns false, the request is aborted early - but the
    // callback will still get called one last time with finished set to true.
    
    typedef bool (*IncrementalResponseCallback)(const Response & response,gpointer body,guint len,bool finished,gpointer user);

    void perform_request_async_incremental(const Request & request,IncrementalResponseCallback callback,gpointer user);
    
    //.........................................................................
    // Performs the request in the calling thread and returns the complete
    // response
    
    Response perform_request(const Request & request);
};

#endif