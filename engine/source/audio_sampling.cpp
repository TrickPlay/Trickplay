
#include <cstdio>
#include "gmodule.h"
#include "sndfile.h"

#include "trickplay/plugins/audio-detection.h"

#include "audio_sampling.h"
#include "context.h"
#include "util.h"
#include "network.h"

//.............................................................................
static Debug_ON log( "AUDIO-SAMPLING" );
//.............................................................................

struct TPAudioSampler
{
    //==========================================================================

    class Thread
    {
    public:

        Thread( TPContext * _context );

        ~Thread();

        void submit_buffer( TPAudioBuffer * buffer );

        void source_changed();

        void pause();

        void resume();

    private:

        struct Event
        {
        public:

            typedef enum
            {
                SUBMIT_BUFFER,
                SOURCE_CHANGED,
                PAUSE,
                RESUME,
                QUIT,
                URL_RESPONSE
            }
            Type;

            static Event * make( Type type );

            static Event * make( TPAudioBuffer * buffer );

            static Event * make( TPAudioDetectionResult * result , GByteArray * response );

            static void destroy( Event * event );

            Type                        type;
            TPAudioBuffer *             buffer;
            TPAudioDetectionResult *    result;
            GByteArray *                response;

        private:

            Event()
            {}

            ~Event()
            {}
        };

        //.....................................................................

        bool scan_for_plugins( TPContext * context );

        //.....................................................................
        // Frees a buffer and its associated samples

        static void destroy_buffer( TPAudioBuffer * buffer );

        //.....................................................................
        // Frees a detection result

        static void destroy_result( TPAudioDetectionResult * result );

        //.........................................................................
        // When we copy a buffer's samples, we use this as the new free_samples
        // function.

        static void free_samples( gpointer samples , gpointer );

        //.....................................................................
        // Static process calls member process

        static gpointer process( gpointer me )
        {
            ( ( Thread * ) me )->process();
            return 0;
        }

        //.....................................................................
        // Push an event

        void push_event( Event * event );

        //.....................................................................
        // List of buffers

        typedef std::list< TPAudioBuffer * > BufferList;

        //.....................................................................
        // List of plugins

        struct Plugin
        {
            static Plugin * make( const gchar * file_name );

            ~Plugin();

            TPAudioDetectionPluginInfo      info;
            TPAudioDetectionProcessSamples  process_samples;
            TPAudioDetectionReset           reset;

        private:

            Plugin( GModule * _module ,
                    TPAudioDetectionInitialize initialize,
                    TPAudioDetectionProcessSamples _process_samples,
                    TPAudioDetectionReset _reset,
                    TPAudioDetectionShutdown _shutdown );

            static gpointer get_symbol( GModule * module , const gchar * name );

            GModule *                       module;
            TPAudioDetectionShutdown        shutdown;
        };

        typedef std::list< Plugin * > PluginList;

        //.....................................................................

        void invoke_plugins( SF_INFO * info , const float * samples );

        void invoke_plugins_reset( );

        void got_a_match( const char * json );

        //.....................................................................
        // Process samples

        void process();

        //.....................................................................

        TPContext *     context;
        GAsyncQueue *   queue;
        GThread *       thread;
        PluginList      plugins;

        //.....................................................................
        // Network stuff

        struct RequestClosure
        {
            RequestClosure( GAsyncQueue * _queue , TPAudioDetectionResult * _result )
            :
                queue( g_async_queue_ref( _queue ) ),
                result( _result )
            {
                g_assert( queue );
                g_assert( result );
            }

            ~RequestClosure()
            {
                if ( result )
                {
                    destroy_result( result );
                }

                g_async_queue_unref( queue );
            }

            static void destroy( RequestClosure * me )
            {
                delete me;
            }

            GAsyncQueue *               queue;
            TPAudioDetectionResult *    result;
        };

        static void response_callback( const Network::Response & response , gpointer closure );

        EventGroup *            event_group;
        Network *               network;
    };

    //==========================================================================


    TPAudioSampler( TPContext * context )
    :
        thread( context )
    {
    }

    //.............................................................................

    void submit_buffer( TPAudioBuffer * buffer )
    {
        thread.submit_buffer( buffer );
    }

    //.............................................................................

    void source_changed( )
    {
        thread.source_changed();
    }

    //.............................................................................

    void pause()
    {
        thread.pause();
    }

    //.............................................................................

    void resume()
    {
        thread.resume();
    }

    //.............................................................................

    static void destroy( TPAudioSampler * me )
    {
        delete me;
    }

private:

    Thread thread;
};

//=============================================================================
// This is the virtual I/O structure we use for sndfile, so it can read
// from one of our audio buffers.

struct VirtualIO
{
    VirtualIO( TPAudioBuffer * _buffer )
    :
        buffer( _buffer ),
        position( 0 )
    {
        g_assert( buffer );
        g_assert( buffer->samples );

        memset( & virtual_io , 0 , sizeof( virtual_io ) );

        virtual_io.get_filelen = get_filelen;
        virtual_io.seek = seek;
        virtual_io.read = read;
        virtual_io.tell = tell;
    }

    static sf_count_t get_filelen( void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        return v->buffer->size;
    }

    static sf_count_t seek( sf_count_t offset , int whence , void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        sf_count_t new_position = -1;

        switch ( whence )
        {
            case SEEK_SET:
                new_position = offset;
                break;

            case SEEK_CUR:
                new_position = v->position + offset;
                break;

            case SEEK_END:
                new_position = v->buffer->size + offset;
                break;
        }

        if ( new_position < 0 || new_position > sf_count_t( v->buffer->size ) )
        {
            return 1;
        }

        v->position = new_position;

        return 0;
    }

    static sf_count_t read( void * ptr , sf_count_t count , void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        sf_count_t result = count;

        if ( result > sf_count_t( v->buffer->size ) - v->position )
        {
            result = v->buffer->size - v->position;
        }

        if ( result <= 0 )
        {
            return 0;
        }

        guint8 * src = ( ( guint8 * ) v->buffer->samples ) + v->position;

        memcpy( ptr , src , result );

        return result;
    }

    static sf_count_t tell( void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        return v->position;
    }

    SF_VIRTUAL_IO   virtual_io;
    TPAudioBuffer * buffer;
    sf_count_t      position;
};

//=============================================================================
// TPAudioSampler::Thread::Event

TPAudioSampler::Thread::Event * TPAudioSampler::Thread::Event::make( Type type )
{
    Event * event = g_slice_new0( Event );

    event->type = type;

    return event;
}

TPAudioSampler::Thread::Event * TPAudioSampler::Thread::Event::make( TPAudioBuffer * buffer )
{
    g_assert( buffer );

    Event * event = g_slice_new0( Event );

    event->type = SUBMIT_BUFFER;
    event->buffer = buffer;

    return event;
}

TPAudioSampler::Thread::Event * TPAudioSampler::Thread::Event::make( TPAudioDetectionResult * result , GByteArray * response )
{
    g_assert( result );
    g_assert( response );

    Event * event = g_slice_new0( Event );

    event->type = URL_RESPONSE;
    event->result = result;
    event->response = response;

    g_byte_array_ref( response );

    return event;
}

void TPAudioSampler::Thread::Event::destroy( Event * event )
{
    g_assert( event );

    if ( event->buffer )
    {
        Thread::destroy_buffer( event->buffer );
    }

    if ( event->result )
    {
        Thread::destroy_result( event->result );
    }

    if ( event->response )
    {
        g_byte_array_unref( event->response );
    }

    g_slice_free( Event , event );
}

//=============================================================================
// TPAudioSampler::Thread::Plugin

TPAudioSampler::Thread::Plugin * TPAudioSampler::Thread::Plugin::make( const gchar * file_name )
{
    g_assert( file_name );

    log( "FOUND PLUGIN %s" , file_name );

    GModule * module = g_module_open( file_name , G_MODULE_BIND_LOCAL );

    if ( ! module )
    {
        log( "  FAILED TO OPEN : %s" , g_module_error() );
        return 0;
    }

    TPAudioDetectionInitialize initialize = ( TPAudioDetectionInitialize ) get_symbol( module , TP_AUDIO_DETECTION_INITIALIZE );
    TPAudioDetectionProcessSamples process_samples = ( TPAudioDetectionProcessSamples ) get_symbol( module , TP_AUDIO_DETECTION_PROCESS_SAMPLES );
    TPAudioDetectionReset reset = ( TPAudioDetectionReset ) get_symbol( module , TP_AUDIO_DETECTION_RESET );
    TPAudioDetectionShutdown shutdown = ( TPAudioDetectionShutdown ) get_symbol( module , TP_AUDIO_DETECTION_SHUTDOWN );

    if ( ! initialize || ! process_samples || ! shutdown || ! reset )
    {
        g_module_close( module );
        return 0;
    }

    return new Plugin( module , initialize , process_samples , reset , shutdown );
}

TPAudioSampler::Thread::Plugin::Plugin( GModule * _module ,
        TPAudioDetectionInitialize initialize,
        TPAudioDetectionProcessSamples _process_samples,
        TPAudioDetectionReset _reset,
        TPAudioDetectionShutdown _shutdown )
:
    process_samples( _process_samples ),
    reset( _reset ),
    module( _module ),
    shutdown( _shutdown )
{
    g_assert( module );
    g_assert( initialize );
    g_assert( process_samples );
    g_assert( shutdown );

    gchar * config = 0;

    // We look for a file that has the same name as the plugin but with
    // the .config extension. If it is there, we load its contents and
    // pass them to 'initialize'.

    String file_name( g_module_name( module ) );

    size_t dot = file_name.find_last_of( '.' );

    if ( dot != String::npos )
    {
        file_name = file_name.substr( 0 , dot ) + ".config";

        if ( g_file_get_contents( file_name.c_str() , & config , 0 , 0 ) )
        {
            log( "CONFIG LOADED" );
        }
    }

    // Clear the plugin info structure and invoke the plugin's initialize
    // function - passing the config.

    memset( & info , 0 , sizeof( info ) );

    initialize( & info , config );

    g_free( config );

    // Make sure we NULL-terminate these two.

    info.name[ sizeof( info.name ) - 1 ] = 0;
    info.version[ sizeof( info.version ) - 1 ] = 0;

    log( "  NAME        : %s" , info.name );
    log( "  VERSION     : %s" , info.version );
    log( "  RESIDENT    : %s" , info.resident ? "YES" : "NO" );
    log( "  MIN SECONDS : %u" , info.min_buffer_seconds );
    log( "  USER DATA   : %p" , info.user_data );

    if ( info.resident )
    {
        g_module_make_resident( module );
    }
}

TPAudioSampler::Thread::Plugin::~Plugin()
{
    shutdown( info.user_data );

    g_module_close( module );
}

gpointer TPAudioSampler::Thread::Plugin::get_symbol( GModule * module , const gchar * name )
{
    g_assert( module );
    g_assert( name );

    gpointer result = 0;

    if ( ! g_module_symbol( module , name , & result ) )
    {
        log( "  MISSING SYMBOL '%s'" , name );
        return 0;
    }

    if ( ! result )
    {
        log( "  SYMBOL '%s' IS NULL" , name );
        return 0;
    }

    return result;
}

//=============================================================================
// TPAudioSampler::Thread

TPAudioSampler::Thread::Thread( TPContext * _context )
:
    context( _context ),
    queue( g_async_queue_new_full( ( GDestroyNotify ) Event::destroy ) ),
    thread( 0 ),
    event_group( 0 ),
    network( 0 )

{
    if ( ! context->get_bool( TP_AUDIO_SAMPLER_ENABLED , true ) )
    {
        g_warning( "AUDIO SAMPLER IS DISABLED" );
    }
    else
    {
        if ( scan_for_plugins( context ) )
        {
            // Create the thread that will process the audio samples

            GError * error = 0;

            thread = g_thread_create( process , this , TRUE , & error );

            if ( ! thread )
            {
                g_warning( "FAILED TO CREATE AUDIO SAMPLER PROCESSING THREAD : %s" , error->message );

                g_clear_error( & error );

            }

            if ( thread )
            {
                event_group = new EventGroup();

                network = new Network( Network::Settings( context ) , event_group );
            }
        }
    }
}

//.........................................................................

TPAudioSampler::Thread::~Thread()
{
    if ( event_group )
    {
        event_group->cancel_all();

        event_group->unref();
    }

    if ( network )
    {
        delete network;
    }

    if ( thread )
    {
        push_event( Event::make( Event::QUIT ) );

        log( "WAITING FOR PROCESSING THREAD..." );

        g_thread_join( thread );
    }

    g_async_queue_unref( queue );

    if ( ! plugins.empty() )
    {
        log( "CLOSING PLUGINS..." );

        for ( PluginList::iterator it = plugins.begin(); it != plugins.end(); ++ it )
        {
            delete * it;
        }
    }
}

//.........................................................................

bool TPAudioSampler::Thread::scan_for_plugins( TPContext * context )
{
    if ( ! g_module_supported() )
    {
        g_warning( "PLUGINS ARE NOT SUPPORTED ON THIS PLATFORM" );

        return false;
    }

    const gchar * plugins_path = context->get( TP_PLUGINS_PATH );

    if ( ! plugins_path )
    {
        g_warning( "PLUGINS PATH IS NOT SET" );

        return false;
    }

    GError * error = 0;

    GDir * dir = g_dir_open( plugins_path , 0 , & error );

    if ( ! dir )
    {
        g_warning( "FAILED TO OPEN PLUGINS PATH '%s' : %s" , plugins_path , error->message );

        g_clear_error( & error );

        return false;
    }

    for ( const gchar * name = g_dir_read_name( dir ); name ; name = g_dir_read_name( dir ) )
    {
        if ( g_str_has_prefix( name , "tp_audio_detection-" ) )
        {
            if ( ! g_str_has_suffix( name , ".config" ) )
            {
                gchar * sub = g_build_filename( plugins_path , name , NULL );

                if ( Plugin * plugin = Plugin::make( sub ) )
                {
                    plugins.push_back( plugin );
                }

                g_free( sub );
            }
        }
    }

    g_dir_close( dir );

    return true;
}

//.........................................................................

void TPAudioSampler::Thread::destroy_buffer( TPAudioBuffer * buffer )
{
    g_assert( buffer );

    if ( buffer->samples && buffer->free_samples )
    {
        buffer->free_samples( buffer->samples , buffer->user_data );
    }

    g_slice_free( TPAudioBuffer , buffer );
}

//.........................................................................

void TPAudioSampler::Thread::destroy_result( TPAudioDetectionResult * result )
{
    g_assert( result );

    if ( result->free_result )
    {
        result->free_result( result );
    }
}

//.........................................................................

void TPAudioSampler::Thread::free_samples( gpointer samples , gpointer )
{
    g_free( samples );
}

//.........................................................................

void TPAudioSampler::Thread::submit_buffer( TPAudioBuffer * _buffer )
{
    g_assert( _buffer );

    if ( ! thread )
    {
        if ( _buffer->samples && _buffer->free_samples )
        {
            _buffer->free_samples( _buffer->samples , _buffer->user_data );
        }

        return;
    }

    log( "BUFFER : sample_rate=%u : channels=%u : format=0x%x : samples=%p : size=%lu : copy_samples=%d : free_samples=%p",
            _buffer->sample_rate , _buffer->channels , _buffer->format , _buffer->samples , _buffer->size , _buffer->copy_samples , _buffer->free_samples );

    // First pass validation

    if ( _buffer->sample_rate == 0 )
    {
        g_warning( "INVALID AUDIO BUFFER : sample_rate == 0" );
        return;
    }

    if ( _buffer->channels == 0 )
    {
        g_warning( "INVALID AUDIO BUFFER : channels == 0" );
        return;
    }

    if ( _buffer->samples == 0 )
    {
        g_warning( "INVALID AUDIO BUFFER : samples == 0" );
        return;
    }

    if ( _buffer->size == 0  )
    {
        g_warning( "INVALID AUDIO BUFFER : size == 0" );
        return;
    }

    if ( _buffer->copy_samples == 0 && _buffer->free_samples == 0 )
    {
        g_warning( "INVALID AUDIO BUFFER : copy_samples == 0 && free_samples == 0" );
        return;
    }

    // Make a copy of the buffer struct itself

    TPAudioBuffer * buffer = g_slice_dup( TPAudioBuffer , _buffer );

    if ( ! buffer )
    {
        g_warning( "FAILED TO ALLOCATE MEMORY FOR AUDIO BUFFER" );

        return;
    }

    // See if we need to copy the samples

    if ( buffer->copy_samples != 0 )
    {
        // Copy them

        gpointer samples = g_memdup( _buffer->samples , _buffer->size );

        if ( ! samples )
        {
            g_warning( "FAILED TO COPY AUDIO BUFFER SAMPLES : size = %lu" , _buffer->size );

            destroy_buffer( buffer );

            return;
        }

        // If there was an original free function, we call it now

        if ( _buffer->free_samples )
        {
            _buffer->free_samples( _buffer->samples , _buffer->user_data );
        }

        // Set our own free function and user_data

        buffer->samples = samples;

        buffer->free_samples = free_samples;
        buffer->user_data = 0;
    }

    // Now stick it in the queue

    push_event( Event::make( buffer ) );
}

//.........................................................................

void TPAudioSampler::Thread::source_changed()
{
    if ( thread )
    {
        log( "SOURCE CHANGED" );

        push_event( Event::make( Event::SOURCE_CHANGED ) );
    }
}

//.........................................................................

void TPAudioSampler::Thread::pause()
{
    if ( thread )
    {
        log( "PAUSE" );

        push_event( Event::make( Event::PAUSE ) );
    }
}

//.........................................................................

void TPAudioSampler::Thread::resume()
{
    if ( thread )
    {
        log( "RESUME" );

        push_event( Event::make( Event::RESUME ) );
    }
}

//.........................................................................

void TPAudioSampler::Thread::push_event( Event * event )
{
    g_assert( event );

    if ( ! thread )
    {
        Event::destroy( event );
        return;
    }

    g_async_queue_push( queue , event );
}

//.........................................................................

void TPAudioSampler::Thread::process()
{
    log( "STARTED PROCESSING THREAD" );

    g_async_queue_ref( queue );

    bool done = false;

    GTimeVal t;

    BufferList buffers;

    int paused = 0;

    while( ! done )
    {
        // Create a time val for 10 seconds from now

        g_get_current_time( & t );
        g_time_val_add( & t , 10 * G_USEC_PER_SEC );

        // Pop an event from the queue, waiting if necessary

        Event * event = ( Event * ) g_async_queue_timed_pop( queue , & t );

        // Nothing in the queue, carry on

        if ( ! event )
        {
            continue;
        }

        //.................................................................

        switch( event->type )
        {
            case Event::QUIT:

                done = true;
                break;

            case Event::SOURCE_CHANGED:

                // The source changed, we get rid of any pending
                // buffers we have

                for ( BufferList::iterator it = buffers.begin(); it != buffers.end(); ++it )
                {
                    destroy_buffer( * it );
                }

                buffers.clear();

                // We also cancel any outstanding callbacks we have from
                // network requests.

                event_group->cancel_all();

                invoke_plugins_reset();

                break;

            case Event::PAUSE:

                ++paused;
                break;

            case Event::RESUME:

                if ( paused > 0 )
                {
                    --paused;
                }
                break;

            case Event::SUBMIT_BUFFER:

                // We put the buffer in our list and steal it
                // from the event - so that it won't free it.

                buffers.push_back( event->buffer );

                event->buffer = 0;

                break;

            case Event::URL_RESPONSE:

                // We received the results of a URL request that
                // a plugin wanted.

                // If the plugin does not have a parse_response function,
                // it means that the body of the response is the JSON we
                // want.

                if ( ! event->result->parse_response )
                {
                    log ( "GOT URL RESPONSE WITH JSON" );

                    // We use strndup to make sure it is NULL terminated

                    gchar * json = g_strndup( ( gchar * ) event->response->data , event->response->len );

                    got_a_match( json );

                    g_free( json );
                }
                else
                {
                    // The plugin does have a parse response function, we call it now

                    log( "GOT URL RESPONSE TO PARSE. INVOKING PARSE_RESPONSE" );

                    event->result->parse_response( event->result , ( const char * ) event->response->data , event->response->len );

                    // The plugin should have stored the parsed response in 'json'.

                    if ( ! event->result->json )
                    {
                        log( "PLUGIN FAILED TO PARSE RESPONSE" );
                    }
                    else
                    {
                        log( "RESPONSE PARSED" );

                        got_a_match( event->result->json );
                    }
                }

                // We are done with the response body and the result,
                // destroying the event will free both of them.

                break;
        }

        //.................................................................
        // Destroy the event

        Event::destroy( event );

        //.................................................................
        // Process pending buffers

        if ( paused || buffers.empty() )
        {
            continue;
        }

        // TODO: right now, we process each buffer as soon as it comes in.
        // Instead, we should have a policy for accumulating buffers.

        // Iterate over all the buffers in the list

        for ( BufferList::iterator it = buffers.begin(); it != buffers.end(); ++it )
        {
            TPAudioBuffer * buffer = * it;

            log( "PROCESSING BUFFER" );

            // Create the virtual IO structure for this buffer

            VirtualIO vio( buffer );

            // The sndfile info

            SF_INFO info;

            memset( & info , 0 , sizeof( info ) );

            info.channels = buffer->channels;
            info.format = SF_FORMAT_RAW | ( buffer->format & SF_FORMAT_ENDMASK ) | ( buffer->format & SF_FORMAT_SUBMASK );
            info.samplerate = buffer->sample_rate;

            // Now try to open it

            SNDFILE * sf = sf_open_virtual( & vio.virtual_io , SFM_READ , & info , & vio );

            if ( ! sf )
            {
                g_warning( "FAILED TO OPEN SOURCE BUFFER FOR READ" );
            }
            else
            {
                log( "  sample rate=%d : channels=%d : frames=%" G_GOFFSET_FORMAT , info.samplerate , info.channels , info.frames );

                // Now, we read from the audio buffer a new buffer that uses float samples

                gfloat * float_samples = g_new( float , info.frames * info.channels );

                if ( ! float_samples )
                {
                    g_warning( "FAILED TO ALLOCATE MEMORY FOR FLOAT SAMPLES : NEED %" G_GOFFSET_FORMAT " BYTES" , info.frames * info.channels );
                }
                else
                {
                    sf_count_t read = sf_readf_float( sf , float_samples , info.frames );

                    if ( read != info.frames )
                    {
                        g_warning( "FAILED TO READ FLOAT SAMPLES" );
                    }
                    else
                    {
                        // OK, now we have floating point samples that we can hand off to
                        // a library for processing.

                        log( "  READY TO PROCESS SAMPLES" );

                        invoke_plugins( & info , float_samples );
                    }

                    g_free( float_samples );
                }

                sf_close( sf );
            }

            destroy_buffer( buffer );
        }

        // We have destroyed all the buffers in the list, so
        // we need to clear the list.

        buffers.clear();
    }

    // The thread is exiting...

    // Get rid of any buffers we still have

    for ( BufferList::iterator it = buffers.begin(); it != buffers.end(); ++it )
    {
        destroy_buffer( * it );
    }

    g_async_queue_unref( queue );

    log( "EXITING PROCESSING THREAD" );
}

//.........................................................................

void TPAudioSampler::Thread::invoke_plugins( SF_INFO * info , const float * samples )
{
    TPAudioDetectionSamples s;

    s.sample_rate = info->samplerate;
    s.channels = info->channels;
    s.frames = info->frames;
    s.samples = samples;

    for( PluginList::const_iterator it = plugins.begin(); it != plugins.end(); ++it )
    {
        Plugin * plugin = * it;

        g_assert( plugin );

        log( "  CALLING %s" , plugin->info.name );

        TPAudioDetectionResult * result = plugin->process_samples( & s , plugin->info.user_data );

        // The plugin returned NULL, we carry on

        if ( ! result )
        {
            log( "    RETURNED NULL" );
            continue;
        }

        // The free function cannot be NULL - or we'd have a leak

        g_assert( result->free_result );

        bool free_it = true;

        // The plugin returned straight JSON, we have our result

        if ( result->json )
        {
            log( "    RETURNED JSON '%s'" , result->json );

            got_a_match( result->json );
        }
        else
        {
            if ( ! result->url )
            {
                log( "    DID NOT RETURN JSON OR A URL" );
            }
            else
            {
                log( "    RETURNED URL '%s'" , result->url );

                // The plugin returned a URL, which means it wants us to
                // call that URL, so we create a request for it.

                // TODO: user agent?

                String user_agent;

                Network::Request request( user_agent , result->url );

                if ( result->method )
                {
                    request.method = result->method;
                }

                if ( result->body )
                {
                    request.body = result->body;
                }

                if ( result->headers )
                {
                    request.set_headers( result->headers );
                }

                // Fire off the request

                network->perform_request_async(
                        request ,
                        0 ,
                        response_callback ,
                        new RequestClosure( queue , result ) ,
                        ( GDestroyNotify ) RequestClosure::destroy );

                // The result now belongs to the RequestClosure, so we
                // don't free it here.

                free_it = false;
            }
        }

        if ( free_it )
        {
            // Free the result, we are done with it

            destroy_result( result );
        }
    }
}

//.........................................................................
// When the source changes, we call the plugin reset function

void TPAudioSampler::Thread::invoke_plugins_reset( )
{
    for( PluginList::const_iterator it = plugins.begin(); it != plugins.end(); ++it )
    {
        Plugin * plugin = * it;

        plugin->reset( plugin->info.user_data );
    }
}

//.........................................................................
// A plugin asked us to call a URL, and we did so. Here is the response
// from that URL. Note that the TPAudioDetectionResult will be destroyed
// after this callback by RequestClosure::destroy.
//
// This callback happens in the main thread.

void TPAudioSampler::Thread::response_callback( const Network::Response & response , gpointer closure )
{
    RequestClosure * rc = ( RequestClosure * ) closure;

    if ( response.failed )
    {
        log( "REQUEST FROM PLUGIN FAILED FOR '%s' : %s" , rc->result->url , response.status.c_str() );

        return;
    }

    if ( response.body->len == 0 )
    {
        log( "REQUEST FROM PLUGIN CAME BACK WITH AN EMPTY BODY" );

        return;
    }

    log( "GOT URL RESPONSE" );

    // Now, we ship the response to the processing thread. We create
    // an event and steal the result from the request closure.
    // The event will ref the response body.

    g_async_queue_push( rc->queue , Event::make( rc->result , response.body ) );

    rc->result = 0;
}

//.........................................................................
// This is what we have been after this whole time.
// We need to bubble up this JSON result to the engine and
// give it a chance to act on it.

void TPAudioSampler::Thread::got_a_match( const char * json )
{
    g_assert( json );

    context->audio_detection_match( json );
}

//=============================================================================
// External functions

TPAudioSampler * tp_context_get_audio_sampler( TPContext * context )
{
    g_assert( context );

    static char key = 0;

    TPAudioSampler * sampler = ( TPAudioSampler * ) context->get_internal( & key );

    if ( ! sampler )
    {
        sampler = new TPAudioSampler( context );

        context->add_internal( & key , sampler , ( GDestroyNotify ) TPAudioSampler::destroy );
    }

    return sampler;
}

//.............................................................................

void tp_audio_sampler_submit_buffer( TPAudioSampler * sampler , TPAudioBuffer * buffer )
{
    g_assert( sampler );

    sampler->submit_buffer( buffer );
}

//.............................................................................

void tp_audio_sampler_source_changed( TPAudioSampler * sampler )
{
    g_assert( sampler );

    sampler->source_changed();
}

//.............................................................................

void tp_audio_sampler_pause( TPAudioSampler * sampler )
{
    g_assert( sampler );

    sampler->pause();
}

//.............................................................................

void tp_audio_sampler_resume( TPAudioSampler * sampler )
{
    g_assert( sampler );

    sampler->resume();
}
