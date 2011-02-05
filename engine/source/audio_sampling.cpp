
#include "audio_sampling.h"
#include "context.h"
#include "util.h"

//.............................................................................
static Debug_ON log( "AUDIO-SAMPLING" );
//.............................................................................

// We use the addresses of these as user_data in custom audio buffers.

static char AS_SOURCE_CHANGED = 0;
static char AS_QUIT = 0;

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

        // If there is no thread, it means that no buffers have been submitted,
        // so we don't care about the source change. We bail.

        if ( ! thread )
        {
            return;
        }

        // To signal a source change, we push a signal buffer

        push_signal( & AS_SOURCE_CHANGED );
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
            push_signal( & AS_QUIT );

            log( "WAITING FOR PROCESSING THREAD..." );

            g_thread_join( thread );
        }

        g_async_queue_unref( queue );
    }

    //.........................................................................
    // Pushes a buffer that has samples == 0 and a special address in
    // user_data that we use as a signal.

    void push_signal( gpointer signal )
    {
        TPAudioBuffer * buffer = g_slice_new0( TPAudioBuffer );

        buffer->user_data = signal;

        g_async_queue_push( queue , buffer );
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
    // The thread that pulls samples from the queue and does the heavy
    // lifting.

    static gpointer process_samples( gpointer q )
    {
        log( "STARTED PROCESSING THREAD %p" , g_thread_self() );

        GAsyncQueue * queue = ( GAsyncQueue * ) q;

        g_async_queue_ref( queue );

        bool done = false;

        GTimeVal t;

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
                // If it is a quit signal, we will quit

                if ( buffer->user_data == & AS_QUIT )
                {
                    done = true;
                }
                else if ( buffer->user_data == & AS_SOURCE_CHANGED )
                {
                    // TODO: What do we do now?
                }

                destroy_buffer( buffer );
            }
            else
            {
                // TODO: We've got some audio samples, what now?

                destroy_buffer( buffer );
            }
        }

        g_async_queue_unref( queue );

        log( "EXITING PROCESSING THREAD %p" , g_thread_self() );

        return 0;
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
