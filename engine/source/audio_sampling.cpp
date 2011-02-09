
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

        //.....................................................................

        bool scan_for_plugins( TPContext * context );

        //.....................................................................
        // Frees a buffer and its associated samples

        static void destroy_buffer( TPAudioBuffer * buffer );

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
        // Signals that we can push

        typedef enum { SOURCE_CHANGED , QUIT , PAUSE , RESUME } Signal;

        void push_signal( Signal signal );

        //.....................................................................
        // List of buffers

        typedef std::list< TPAudioBuffer * > BufferList;

        //.....................................................................
        // List of plugins

        typedef std::pair< GModule * , TPAudioDetectionProcessSamples > PluginPair;

        typedef std::list< PluginPair > PluginList;

        //.....................................................................

        void invoke_plugins( SF_INFO * info , const float * samples );

        void got_a_match( const char * json );

        //.....................................................................
        // Process samples

        void process();

        //.....................................................................

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
                g_assert( result->free_result );
            }

            ~RequestClosure()
            {
                result->free_result( result );

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
        std::auto_ptr<Network>  network;
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
// TPAudioSampler::Thread

TPAudioSampler::Thread::Thread( TPContext * context )
:
    queue( g_async_queue_new_full( ( GDestroyNotify ) destroy_buffer ) ),
    thread( 0 ),
    event_group( 0 )
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

            network.reset( new Network( Network::Settings( context ) , event_group ) );
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

    if ( thread )
    {
        push_signal( QUIT );

        log( "WAITING FOR PROCESSING THREAD..." );

        g_thread_join( thread );
    }

    g_async_queue_unref( queue );

    if ( ! plugins.empty() )
    {
        log( "CLOSING PLUGINS..." );

        for ( PluginList::iterator it = plugins.begin(); it != plugins.end(); ++ it )
        {
            g_module_close( it->first );
        }
    }

    log( "FINISHED" );
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
            gchar * sub = g_build_filename( plugins_path , name , NULL );

            log( "FOUND PLUGIN %s" , sub );

            // TODO: We may need to play with these flags

            GModule * module = g_module_open( sub , G_MODULE_BIND_LOCAL );

            if ( ! module )
            {
                log( "  FAILED TO OPEN" );
            }
            else
            {
                gpointer ad_process_samples = 0;

                if ( ! g_module_symbol( module , TP_AUDIO_DETECTION_PROCESS_SAMPLES , & ad_process_samples ) )
                {
                    log( "  MISSING ENTRY POINT '%s'" , TP_AUDIO_DETECTION_PROCESS_SAMPLES );

                    g_module_close( module );
                }
                else if ( ! ad_process_samples )
                {
                    log( "  ENTRY POINT '%s' IS NULL" , TP_AUDIO_DETECTION_PROCESS_SAMPLES );

                    g_module_close( module );
                }
                else
                {
                    log( "  ADDED" );

                    // This module is ready to go, add it to the list.

                    plugins.push_back( PluginPair( module , ( TPAudioDetectionProcessSamples) ad_process_samples ) );
                }
            }

            g_free( sub );
        }
    }

    g_dir_close( dir );

    return true;
}

//.........................................................................

void TPAudioSampler::Thread::destroy_buffer( TPAudioBuffer * buffer )
{
    if ( buffer->samples && buffer->free_samples )
    {
        buffer->free_samples( buffer->samples , buffer->user_data );
    }

    g_slice_free( TPAudioBuffer , buffer );
}

//.........................................................................

void TPAudioSampler::Thread::free_samples( gpointer samples , gpointer )
{
    g_free( samples );
}

//.........................................................................

void TPAudioSampler::Thread::submit_buffer( TPAudioBuffer * _buffer )
{
    if ( ! thread )
    {
        return;
    }

    g_assert( _buffer );

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

    g_async_queue_push( queue , buffer );
}

//.........................................................................

void TPAudioSampler::Thread::source_changed()
{
    log( "SOURCE CHANGED" );

    push_signal( SOURCE_CHANGED );
}

//.........................................................................

void TPAudioSampler::Thread::pause()
{
    log( "PAUSE" );

    push_signal( PAUSE );
}

//.........................................................................

void TPAudioSampler::Thread::resume()
{
    log( "RESUME" );

    push_signal( RESUME );
}

//.........................................................................
// Pushes a buffer that has samples == 0 and a special address in
// user_data that we use as a signal.

void TPAudioSampler::Thread::push_signal( Signal signal )
{
    if ( thread )
    {
        TPAudioBuffer * buffer = g_slice_new0( TPAudioBuffer );

        buffer->user_data = GINT_TO_POINTER( signal );

        g_async_queue_push( queue , buffer );
    }
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

        // Pop a buffer from the queue, waiting if necessary

        TPAudioBuffer * buffer = ( TPAudioBuffer * ) g_async_queue_timed_pop( queue , & t );

        // Nothing in the queue, carry on

        if ( ! buffer )
        {
            continue;
        }

        //.................................................................
        // If the buffer does not have any samples, it is a signal - it wants
        // us to do something

        if ( ! buffer->samples )
        {
            switch( Signal( GPOINTER_TO_INT( buffer->user_data ) ) )
            {
                case QUIT:

                    done = true;
                    break;

                case SOURCE_CHANGED:

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

                    break;

                case PAUSE:

                    ++paused;
                    break;

                case RESUME:

                    if ( paused > 0 )
                    {
                        --paused;
                    }
                    break;
            }

            destroy_buffer( buffer );
        }
        else
        {
            // We got a new buffer, we add it to the list

            buffers.push_back( buffer );
        }

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
                log( "  sample rate=%d : channels=%d : frames=%ld" , info.samplerate , info.channels , info.frames );

                // Now, we read from the audio buffer a new buffer that uses float samples

                gfloat * float_samples = g_new( float , info.frames * info.channels );

                if ( ! float_samples )
                {
                    g_warning( "FAILED TO ALLOCATE MEMORY FOR FLOAT SAMPLES : NEED %ld BYTES" , info.frames * info.channels );
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
    for( PluginList::const_iterator it = plugins.begin(); it != plugins.end(); ++it )
    {
        log( "  CALLING %s" , g_module_name( it->first ) );

        TPAudioDetectionResult * result = it->second( info->samplerate , info->channels , info->frames , samples );

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

                // TODO: Now we should create a network request to
                // the given url. Add to it the method, headers and body,
                // if any. When the request comes back, we check to
                // see if parse_response is NULL. If it is, we assume
                // that the response body is the JSON we want. Otherwise,
                // we call parse_response and check result->json again
                // for the final JSON.

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

                // TODO: headers - we have to parse them and stick them into the
                // request's map.

                // Fire off the request

                network->perform_request_async(
                        request ,
                        0 ,
                        response_callback ,
                        new RequestClosure( queue , result ) ,
                        ( GDestroyNotify ) RequestClosure::destroy );

                free_it = false;
            }
        }

        if ( free_it )
        {
            // Free the result, we are done with it

            result->free_result( result );
        }
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

    // TODO: What we need to do here is to somehow put the response body
    // into the queue, so that our thread can deal with it.

    log( "GOT A RESPONSE! %u" , response.body->len );

    // If the result does not have a parse_response function, we
    // assume that the body of this response is the JSON we want

    if ( ! rc->result->parse_response )
    {
        // We use strndup to make sure it is NULL terminated

        gchar * json = g_strndup( ( gchar * ) response.body->data , response.body->len );

        // got_a_match( json );

        g_free( json );
    }
    else
    {
        // The result does have a parse_response method, so we pass it the response

        rc->result->parse_response( rc->result , ( const char * ) response.body->data , response.body->len );

        if ( ! rc->result->json )
        {
            log( "PLUGIN FAILED TO PARSE RESPONSE" );
        }
        else
        {
            log( "GOT JSON" );
            log( "%s" , rc->result->json );
//            got_a_match( json );
        }
    }
}

//.........................................................................
// TODO: This is what we have been after this whole time.
// We need to bubble up this JSON result to the engine and
// give it a chance to act on it.

// TODO: Make sure we copy the json

void TPAudioSampler::Thread::got_a_match( const char * json )
{

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
