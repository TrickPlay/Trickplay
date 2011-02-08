
#include "audio_sampling.h"
#include "context.h"
#include "util.h"

//.............................................................................
static Debug_ON log( "AUDIO-SAMPLING" );
//.............................................................................

#define AS_SOURCE_CHANGED   1
#define AS_QUIT             2
#define AS_PAUSE            3
#define AS_RESUME           4

//.............................................................................

struct TPAudioSampler
{
    TPAudioSampler( TPContext * _context )
    :
        context( _context ),
        queue( g_async_queue_new_full( destroy_buffer ) ),
        thread( 0 )
    {
    }

    //.............................................................................
    // Called by the outside world, needs to be thread-safe.

    void submit_buffer( TPAudioBuffer * _buffer )
    {
        g_assert( _buffer );

        log( "BUFFER : sample_rate=%u : channels=%u : format=%x : samples=%p : size=%ul : copy_samples=%d : free_samples=%p",
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

        // Start the thread if necessary. If we can't, there is no sense
        // in doing the rest of the work.

        if ( ! thread )
        {
            GError * error = 0;

            thread = g_thread_create( process_samples , queue , TRUE , & error );

            if ( ! thread )
            {
                g_warning( "FAILED TO CREATE AUDIO SAMPLER PROCESSING THREAD : %s" , error->message );

                g_clear_error( & error );

                return;
            }
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

    //.............................................................................
    // Called by the outside world, needs to be thread-safe.

    void source_changed( )
    {
        log( "SOURCE CHANGED" );

        // To signal a source change, we push a signal buffer

        push_signal( AS_SOURCE_CHANGED );
    }

    //.............................................................................

    void pause()
    {
        log( "PAUSED" );

        push_signal( AS_PAUSE );
    }

    //.............................................................................

    void resume()
    {
        log( "RESUME" );

        push_signal( AS_RESUME );
    }

    //.............................................................................

    static void destroy( gpointer me )
    {
        delete ( TPAudioSampler * ) me;
    }

private:

    ~TPAudioSampler( )
    {
        if ( thread )
        {
            push_signal( AS_QUIT );

            log( "WAITING FOR PROCESSING THREAD..." );

            g_thread_join( thread );
        }

        g_async_queue_unref( queue );
    }

    //.........................................................................
    // Pushes a buffer that has samples == 0 and a special address in
    // user_data that we use as a signal.

    void push_signal( int signal )
    {
        // Signals are meaningless unless the thread is already running

        if ( thread )
        {
            TPAudioBuffer * buffer = g_slice_new0( TPAudioBuffer );

            buffer->user_data = GINT_TO_POINTER( signal );

            g_async_queue_push( queue , buffer );
        }
    }

    //.........................................................................
    // This destroys a buffer - either after we are done with it,
    // or when it is still sitting in the queue and the queue
    // goes away.

    static void destroy_buffer( gpointer item )
    {
        TPAudioBuffer * buffer = ( TPAudioBuffer * ) item;

        if ( buffer->samples && buffer->free_samples )
        {
            buffer->free_samples( buffer->samples , buffer->user_data );
        }

        g_slice_free( TPAudioBuffer , buffer );
    }

    //.........................................................................
    // When we copy a buffer's samples, we use this as the new free_samples
    // function.

    static void free_samples( gpointer samples , gpointer )
    {
        g_free( samples );
    }

    //.........................................................................

    typedef std::list< TPAudioBuffer * >    BufferList;

    //.........................................................................
    // The thread that pulls samples from the queue and does the heavy
    // lifting.

    static gpointer process_samples( gpointer q )
    {
        log( "STARTED PROCESSING THREAD" );

        GAsyncQueue * queue = ( GAsyncQueue * ) q;

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

            TPAudioBuffer * buffer = ( TPAudioBuffer * ) g_async_queue_timed_pop( queue , & t );

            if ( ! buffer )
            {
                continue;
            }

            // If the buffer does not have any samples, it is a signal - it wants
            // us to do something

            if ( ! buffer->samples )
            {
                switch( GPOINTER_TO_INT( buffer->user_data ) )
                {
                    case AS_QUIT:

                        done = true;
                        break;

                    case AS_SOURCE_CHANGED:

                        // The source changed, we get rid of any pending
                        // buffers we have

                        for ( BufferList::iterator it = buffers.begin(); it != buffers.end(); ++it )
                        {
                            destroy_buffer( * it );
                        }

                        buffers.clear();
                        break;

                    case AS_PAUSE:

                        ++paused;
                        break;

                    case AS_RESUME:

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

            // TODO: right now, we process each buffer as soon as it comes in.
            // Instead, we should have a policy for accumulating buffers.

            if ( ! paused && ! buffers.empty() )
            {
                process_buffers( buffers );
            }
        }

        // The thread is exiting...

        // Get rid of any buffers we still have

        for ( BufferList::iterator it = buffers.begin(); it != buffers.end(); ++it )
        {
            destroy_buffer( * it );
        }

        g_async_queue_unref( queue );

        log( "EXITING PROCESSING THREAD" );

        return 0;
    }

    //.........................................................................
    // What do we do with the buffers?

    static void process_buffers( BufferList & buffers )
    {

    }

    TPContext *     context;
    GAsyncQueue *   queue;
    GThread *       thread;
};

//=============================================================================
// External functions

TPAudioSampler * tp_context_get_audio_sampler( TPContext * context )
{
    static char key = 0;

    TPAudioSampler * sampler = ( TPAudioSampler * ) context->get_internal( & key );

    if ( ! sampler )
    {
        sampler = new TPAudioSampler( context );

        context->add_internal( & key , sampler , TPAudioSampler::destroy );
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
