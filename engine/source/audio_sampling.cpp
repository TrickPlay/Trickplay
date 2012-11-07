
#include <cstdio>
#include "gmodule.h"
#include "sndfile.h"

#include "trickplay/plugins/audio-detection.h"

#include "audio_sampling.h"
#include "context.h"
#include "util.h"
#include "network.h"
#include "plugin.h"

//.............................................................................

#define TP_LOG_DOMAIN   "AUDIO-SAMPLING"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"

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
        // List of buffers

        typedef std::pair< TPAudioBuffer * , SF_INFO > BufferPair;

        typedef std::list< BufferPair > BufferList;

        //.....................................................................
        // List of plugins

        class ADPlugin
        {
        public:

        	ADPlugin( TrickPlay::Plugin * _plugin )
        	:
        		plugin( _plugin ),
        		next_request( 0 ),
        		last_response( 0 )
        	{
        		g_assert( plugin );

        		process_samples = ( TPAudioDetectionProcessSamples ) plugin->get_symbol( TP_AUDIO_DETECTION_PROCESS_SAMPLES );
        		reset = ( TPAudioDetectionReset ) plugin->get_symbol( TP_AUDIO_DETECTION_RESET );

        		g_assert( process_samples );
        		g_assert( reset );
        	}

            ~ADPlugin()
            {
            	delete plugin;
            }

            TrickPlay::Plugin *				plugin;
            TPAudioDetectionProcessSamples  process_samples;
            TPAudioDetectionReset           reset;
            guint32                         next_request;
            guint32                         last_response;

        private:

        };

        typedef std::list< ADPlugin * > ADPluginList;

        //.....................................................................

        void invoke_plugins( SF_INFO * info , const float * samples );

        void invoke_plugins_reset( );

        void got_a_match( const char * json );

        //.....................................................................

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

            static Event * make( TPAudioDetectionResult * result ,
                    GByteArray * response ,
                    ADPlugin * plugin,
                    guint32 request);

            static void destroy( Event * event );

            Type                        type;
            TPAudioBuffer *             buffer;
            TPAudioDetectionResult *    result;
            GByteArray *                response;
            ADPlugin *                  plugin;
            guint32                     request;

        private:

            Event()
            {}

            ~Event()
            {}
        };

        //.....................................................................
        // Push an event

        void push_event( Event * event );

        //.....................................................................
        // Process samples

        void process();

        //.....................................................................

        TPContext *     context;
        GMutex *        mutex;
        GAsyncQueue *   queue;
        GThread *       thread;
        ADPluginList    plugins;
        guint32         max_buffer_kb;
        guint           max_interval;

        //.....................................................................
        // Network stuff

        struct RequestClosure
        {
            RequestClosure( GAsyncQueue * _queue , TPAudioDetectionResult * _result , ADPlugin * _plugin )
            :
                queue( g_async_queue_ref( _queue ) ),
                result( _result ),
                plugin( _plugin ),
                request( ++( plugin->next_request ) )
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
            ADPlugin *                  plugin;
            guint32                     request;
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

TPAudioSampler::Thread::Event * TPAudioSampler::Thread::Event::make( TPAudioDetectionResult * result , GByteArray * response , ADPlugin * plugin , guint32 request )
{
    g_assert( result );
    g_assert( response );
    g_assert( plugin );

    Event * event = g_slice_new0( Event );

    event->type = URL_RESPONSE;
    event->result = result;
    event->response = response;
    event->plugin = plugin;
    event->request = request;

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
// TPAudioSampler::Thread

TPAudioSampler::Thread::Thread( TPContext * _context )
:
    context( _context ),
#ifndef GLIB_VERSION_2_32
    mutex( g_mutex_new() ),
#else
    mutex( new GMutex ),
#endif
    queue( g_async_queue_new_full( ( GDestroyNotify ) Event::destroy ) ),
    thread( 0 ),
    max_buffer_kb( 0 ),
    max_interval( 0 ),
    event_group( 0 ),
    network( 0 )
{
#ifdef GLIB_VERSION_2_32
    g_mutex_init(mutex);
#endif
    if ( ! context->get_bool( TP_AUDIO_SAMPLER_ENABLED , true ) )
    {
        tpwarn( "AUDIO SAMPLER IS DISABLED" );
    }
    else
    {
        max_buffer_kb = context->get_int( TP_AUDIO_SAMPLER_MAX_BUFFER_KB , 5000 );

        if ( max_buffer_kb == 0 )
        {
            max_buffer_kb = 5000;
        }

        max_interval = context->get_int( TP_AUDIO_SAMPLER_MAX_INTERVAL , 10 );

        if ( max_interval == 0 )
        {
            max_interval = 1;
        }

        if ( scan_for_plugins( context ) )
        {
            // Lock this mutex so the thread won't start until we are done

            g_mutex_lock( mutex );

            // Create the thread that will process the audio samples

            GError * error = 0;

            thread = g_thread_create( process , this , TRUE , & error );

            if ( ! thread )
            {
                tpwarn( "FAILED TO CREATE AUDIO SAMPLER PROCESSING THREAD : %s" , error->message );

                g_clear_error( & error );

            }

            if ( thread )
            {
                g_thread_set_priority( thread , G_THREAD_PRIORITY_LOW );

                event_group = new EventGroup();

                network = new Network( Network::Settings( context ) , event_group );
            }

            g_mutex_unlock( mutex );
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

        tplog( "WAITING FOR PROCESSING THREAD..." );

        g_thread_join( thread );
    }

    g_async_queue_unref( queue );

#ifndef GLIB_VERSION_2_32
    g_mutex_free( mutex );
#else
    g_mutex_clear( mutex );
    free( mutex );
#endif

    if ( ! plugins.empty() )
    {
        tplog( "CLOSING PLUGINS..." );

        for ( ADPluginList::iterator it = plugins.begin(); it != plugins.end(); ++ it )
        {
            delete * it;
        }
    }
}

//.........................................................................

bool TPAudioSampler::Thread::scan_for_plugins( TPContext * context )
{
	StringList symbols;
	symbols.push_back( TP_AUDIO_DETECTION_PROCESS_SAMPLES );
	symbols.push_back( TP_AUDIO_DETECTION_RESET );

	TrickPlay::Plugin::List list = TrickPlay::Plugin::scan( context , "tp_audio_detection-" , symbols );

	for ( TrickPlay::Plugin::List::iterator it = list.begin(); it != list.end(); ++it )
	{
		plugins.push_back( new ADPlugin( * it ) );
	}

    return ! plugins.empty();
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

    tplog2( "BUFFER : sample_rate=%u : channels=%u : format=0x%x : samples=%p : size=%lu : copy_samples=%d : free_samples=%p",
            _buffer->sample_rate , _buffer->channels , _buffer->format , _buffer->samples , _buffer->size , _buffer->copy_samples , _buffer->free_samples );

    // First pass validation

    if ( _buffer->sample_rate == 0 )
    {
        tpwarn( "INVALID AUDIO BUFFER : sample_rate == 0" );
        return;
    }

    if ( _buffer->channels == 0 )
    {
        tpwarn( "INVALID AUDIO BUFFER : channels == 0" );
        return;
    }

    if ( _buffer->samples == 0 )
    {
        tpwarn( "INVALID AUDIO BUFFER : samples == 0" );
        return;
    }

    if ( _buffer->size == 0  )
    {
        tpwarn( "INVALID AUDIO BUFFER : size == 0" );
        return;
    }

    if ( _buffer->copy_samples == 0 && _buffer->free_samples == 0 )
    {
        tpwarn( "INVALID AUDIO BUFFER : copy_samples == 0 && free_samples == 0" );
        return;
    }

    // Make a copy of the buffer struct itself

    TPAudioBuffer * buffer = g_slice_dup( TPAudioBuffer , _buffer );

    if ( ! buffer )
    {
        tpwarn( "FAILED TO ALLOCATE MEMORY FOR AUDIO BUFFER" );

        return;
    }

    // See if we need to copy the samples

    if ( buffer->copy_samples != 0 )
    {
        // Copy them

        gpointer samples = g_memdup( _buffer->samples , _buffer->size );

        if ( ! samples )
        {
            tpwarn( "FAILED TO COPY AUDIO BUFFER SAMPLES : size = %lu" , _buffer->size );

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
        tplog( "SOURCE CHANGED" );

        push_event( Event::make( Event::SOURCE_CHANGED ) );
    }
}

//.........................................................................

void TPAudioSampler::Thread::pause()
{
    if ( thread )
    {
        tplog( "PAUSE" );

        push_event( Event::make( Event::PAUSE ) );
    }
}

//.........................................................................

void TPAudioSampler::Thread::resume()
{
    if ( thread )
    {
        tplog( "RESUME" );

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
    // Wait until this mutex is available to continue

    g_mutex_lock( mutex );
    g_mutex_unlock( mutex );

    tplog( "STARTED PROCESSING THREAD" );

    g_async_queue_ref( queue );

    bool done = false;

    BufferList buffers;

    gdouble buffered_seconds = 0;

    gdouble buffered_kb = 0;

    int paused = 0;

    while( ! done )
    {
        // Pop an event from the queue, waiting if necessary up to 10 seconds

        Event * event = ( Event * ) Util::g_async_queue_timeout_pop( queue , 10 * G_USEC_PER_SEC );

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
                    destroy_buffer( it->first );
                }

                buffers.clear();

                buffered_seconds = 0;

                buffered_kb = 0;

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
                {
                    // We are going to try to 'open' this buffer with sndfile to make
                    // sure that we can deal with it - and also get its duration in
                    // seconds. If we can't deal with it, we dump it. Otherwise
                    // we add it to the buffer list.

                    // Create the virtual IO structure for this buffer

                    VirtualIO vio( event->buffer );

                    // The sndfile info

                    SF_INFO info;

                    memset( & info , 0 , sizeof( info ) );

                    info.channels = event->buffer->channels;
                    info.format = SF_FORMAT_RAW | ( event->buffer->format & SF_FORMAT_ENDMASK ) | ( event->buffer->format & SF_FORMAT_SUBMASK );
                    info.samplerate = event->buffer->sample_rate;

                    // Now try to open it

                    SNDFILE * sf = sf_open_virtual( & vio.virtual_io , SFM_READ , & info , & vio );

                    if ( ! sf )
                    {
                        tplog( "FAILED TO OPEN AUDIO BUFFER" );
                    }
                    else
                    {
                        sf_close( sf );

                        buffered_seconds += gdouble( info.frames ) / gdouble( info.samplerate );

                        buffered_kb += event->buffer->size / 1024.0;

                        // We put the buffer in our list and steal it
                        // from the event - so that it won't free it.

                        buffers.push_back( BufferPair( event->buffer , info ) );

                        event->buffer = 0;
                    }
                }
                break;

            case Event::URL_RESPONSE:

                // We received the results of a URL request that
                // a plugin wanted.

                if ( event->request < event->plugin->last_response )
                {
                    // This one is out of order, we ignore it

                    tplog( "REQ %u : NEXT REQ %u : LAST RESP %u" , event->request , event->plugin->next_request , event->plugin->last_response );

                    tplog( "RESPONSE IS OUT OF ORDER, WILL BE IGNORED." );
                }
                else
                {
                    event->plugin->last_response = event->request;

                    // If the plugin does not have a parse_response function,
                    // it means that the body of the response is the JSON we
                    // want.

                    if ( ! event->result->parse_response )
                    {
                        tplog( "GOT URL RESPONSE WITH JSON" );

                        // We use strndup to make sure it is NULL terminated

                        gchar * json = g_strndup( ( gchar * ) event->response->data , event->response->len );

                        got_a_match( json );

                        g_free( json );
                    }
                    else
                    {
                        // The plugin does have a parse response function, we call it now

                        tplog( "GOT URL RESPONSE TO PARSE. INVOKING PARSE_RESPONSE" );

                        event->result->parse_response( event->result , ( const char * ) event->response->data , event->response->len );

                        // The plugin should have stored the parsed response in 'json'.

                        if ( ! event->result->json )
                        {
                            tplog( "PLUGIN FAILED TO PARSE RESPONSE" );
                        }
                        else
                        {
                            tplog( "RESPONSE PARSED" );

                            got_a_match( event->result->json );
                        }
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
        // No buffers, so carry on waiting.

        if ( buffers.empty() )
        {
            continue;
        }

        //.................................................................
        // See if our buffer list is getting too big

        bool overflow = max_buffer_kb == 0 ? false : buffered_kb >= max_buffer_kb;

        //.................................................................
        // If we are paused, and there is an overflow, we need to dump
        // some buffers.

        if ( paused )
        {
            // TODO: If max_buffer_kb is 0, this will not get rid of anything.

            if ( overflow )
            {
                tplog( "BUFFER TOO BIG : HAVE %1.0f KB , %1.1f s , %u BUFFERS : MAX IS %" G_GUINT32_FORMAT " KB" , buffered_kb , buffered_seconds , buffers.size() , max_buffer_kb );

                gdouble target = max_buffer_kb / 2;

                while ( buffered_kb > target && ! buffers.empty() )
                {
                    BufferPair & item( buffers.front() );

                    buffered_kb -= item.first->size / 1024.0;

                    buffered_seconds -= gdouble( item.second.frames ) / gdouble( item.second.samplerate );

                    destroy_buffer( item.first );

                    buffers.pop_front();
                }
            }

            continue;
        }

        //.................................................................
        // If we have not reached our max buffer size and we have less
        // than interval seconds, we keep accumulating.

        if ( ! overflow && buffered_seconds < max_interval )
        {
            continue;
        }

        // Otherwise, we pass all of the current buffers to the plugins.

        tplog2( "PROCESSING %1.0f KB , %1.1f s , %u BUFFERS : %s" , buffered_kb , buffered_seconds , buffers.size() , overflow ? "MAX BUFFER REACHED" : "INTERVAL REACHED" );

        // Iterate over all the buffers in the list

        for ( BufferList::iterator it = buffers.begin(); it != buffers.end(); ++it )
        {
            TPAudioBuffer * buffer = it->first;

            tplog2( "PROCESSING BUFFER" );

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
                tpwarn( "FAILED TO OPEN SOURCE BUFFER FOR READ" );
            }
            else
            {
                tplog2( "  sample rate=%d : channels=%d : frames=%" G_GOFFSET_FORMAT , info.samplerate , info.channels , info.frames );

                // Now, we read from the audio buffer a new buffer that uses float samples

                gfloat * float_samples = g_new( float , info.frames * info.channels );

                if ( ! float_samples )
                {
                    tpwarn( "FAILED TO ALLOCATE MEMORY FOR FLOAT SAMPLES : NEED %" G_GOFFSET_FORMAT " BYTES" , goffset( info.frames * info.channels ) );
                }
                else
                {
                    sf_count_t read = sf_readf_float( sf , float_samples , info.frames );

                    if ( read != info.frames )
                    {
                        tpwarn( "FAILED TO READ FLOAT SAMPLES" );
                    }
                    else
                    {
                        // OK, now we have floating point samples that we can hand off to
                        // a library for processing.

                        tplog2( "  READY TO PROCESS SAMPLES" );

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

        buffered_seconds = 0;

        buffered_kb = 0;
    }

    // The thread is exiting...

    // Get rid of any buffers we still have

    for ( BufferList::iterator it = buffers.begin(); it != buffers.end(); ++it )
    {
        destroy_buffer( it->first );
    }

    g_async_queue_unref( queue );

    tplog( "EXITING PROCESSING THREAD" );
}

//.........................................................................

void TPAudioSampler::Thread::invoke_plugins( SF_INFO * info , const float * samples )
{
    TPAudioDetectionSamples s;

    s.sample_rate = info->samplerate;
    s.channels = info->channels;
    s.frames = info->frames;
    s.samples = samples;

    for( ADPluginList::const_iterator it = plugins.begin(); it != plugins.end(); ++it )
    {
        ADPlugin * plugin = * it;

        g_assert( plugin );

        tplog2( "  CALLING %s" , plugin->info.name );

        TPAudioDetectionResult * result = plugin->process_samples( & s , plugin->plugin->user_data() );

        // The plugin returned NULL, we carry on

        if ( ! result )
        {
            tplog2( "    RETURNED NULL" );
            continue;
        }

        // The free function cannot be NULL - or we'd have a leak

        g_assert( result->free_result );

        bool free_it = true;

        // The plugin returned straight JSON, we have our result

        if ( result->json )
        {
            tplog( "    RETURNED JSON '%s'" , result->json );

            got_a_match( result->json );

            plugin->last_response = ++plugin->next_request;
        }
        else
        {
            if ( ! result->url )
            {
                tplog( "    DID NOT RETURN JSON OR A URL" );
            }
            else
            {
                tplog( "    RETURNED URL '%s'" , result->url );

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
                        new RequestClosure( queue , result , plugin ) ,
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
    for( ADPluginList::const_iterator it = plugins.begin(); it != plugins.end(); ++it )
    {
        ADPlugin * plugin = * it;

        plugin->reset( plugin->plugin->user_data() );

        // To ignore any requests that are processing now and may
        // callback after this happens.

        plugin->last_response = ++plugin->next_request;
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
        tplog( "REQUEST FROM PLUGIN FAILED FOR '%s' : %s" , rc->result->url , response.status.c_str() );

        return;
    }

    if ( response.body->len == 0 )
    {
        tplog( "REQUEST FROM PLUGIN CAME BACK WITH AN EMPTY BODY" );

        return;
    }

    tplog( "GOT URL RESPONSE" );

    // Now, we ship the response to the processing thread. We create
    // an event and steal the result from the request closure.
    // The event will ref the response body.

    g_async_queue_push( rc->queue , Event::make( rc->result , response.body , rc->plugin , rc->request ) );

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
