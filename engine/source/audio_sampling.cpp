
#include "audio_sampling.h"
#include "context.h"

//.............................................................................

struct TPAudioSampler
{
    TPAudioSampler( TPContext * _context )
    :
        context( _context ),
        queue( g_async_queue_new_full( destroy_item ) )
    {

    }

    //.............................................................................
    // Called by the outside world, needs to be thread-safe.

    void submit_buffer( TPAudioBuffer * buffer )
    {

    }

    //.............................................................................
    // Called by the outside world, needs to be thread-safe.

    void source_changed( )
    {

    }

    //.............................................................................

    static void destroy( gpointer me )
    {
        delete ( TPAudioSampler * ) me;
    }

private:

    ~TPAudioSampler( )
    {
        g_async_queue_unref( queue );
    }

    static void destroy_item( gpointer item )
    {

    }

    TPContext *     context;
    GAsyncQueue *   queue;
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
