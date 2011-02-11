
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "trickplay/plugins/audio-detection.h"

/******************************************************************************
 * The three 'exported' functions.
 */

void
tp_audio_detection_initialize( TPAudioDetectionPluginInfo * info , const char * config );

TPAudioDetectionResult *
tp_audio_detection_process_samples( const TPAudioDetectionSamples * samples , void * user_data );

void
tp_audio_detection_shutdown( void * user_data );

/******************************************************************************
 * Our internal functions
 */

static void
free_result( TPAudioDetectionResult * result );

static void
parse_response( TPAudioDetectionResult * result , const char * response_body , unsigned long int response_size );

/******************************************************************************
 * Initialize
 */

void
tp_audio_detection_initialize( TPAudioDetectionPluginInfo * info , const char * config )
{
    strncpy( info->name , "Trickplay example" , sizeof( info->name ) - 1 );
    strncpy( info->version , "1.0" , sizeof( info->version ) - 1 );
}

/******************************************************************************
 * Process samples
 */

TPAudioDetectionResult *
tp_audio_detection_process_samples( const TPAudioDetectionSamples * samples , void * user_data )
{
#if 0
    printf( "-example plugin : sample_rate=%u : channels=%u : frames=%lu\n" , samples->sample_rate , samples->channels , samples->frames );
#endif

    /*
     * Allocate a new result and clear it.
    */

    TPAudioDetectionResult * result;

    result = ( TPAudioDetectionResult * ) malloc( sizeof( TPAudioDetectionResult ) );

    memset( result , 0 , sizeof( TPAudioDetectionResult ) );

    /*
     * The result tells Trickplay to send a request to the url.
     * When the response is received, parse_response will be called. It will
     * convert the response body to a JSON string.
    */

    result->url = "http://trickplay.com/";
    result->parse_response = parse_response;
    result->free_result = free_result;

    return result;
}

/******************************************************************************
 * Shutdown
 */

void
tp_audio_detection_shutdown( void * user_data )
{
    // Nothing to do - but we could free resources associated with user data.
}

/******************************************************************************
 * Frees our result.
 */

static void
free_result( TPAudioDetectionResult * result )
{
    if ( result )
    {
        if ( result->json )
        {
            free( result->json );
        }

        free( result );
    }
}

/******************************************************************************
 * Parses the response from the URL to JSON.
 */

static void
parse_response( TPAudioDetectionResult * result , const char * response_body , unsigned long int response_size )
{
    if ( result->json )
    {
        free( result->json );

        result->json = 0;
    }

    result->json = strdup( "[1,2,3]" );
}

/*****************************************************************************/



