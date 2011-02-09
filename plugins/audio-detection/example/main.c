
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "trickplay/plugins/audio-detection.h"

/*
 * Frees our result.
 */

static void free_result( TPAudioDetectionResult * result )
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

/*
 * Parses the response from the URL to JSON.
 */

static void parse_response( TPAudioDetectionResult * result , const char * response_body , unsigned long int response_size )
{
    if ( result->json )
    {
        free( result->json );

        result->json = 0;
    }

    result->json = strdup( "[1,2,3]" );
}

/*
 * Analyzes the samples and sends Trickplay the result.
 */

TPAudioDetectionResult * tp_audio_detection_process_samples(

    unsigned int        sample_rate,
    unsigned int        channels,
    unsigned long int   frames,
    const float *       samples )
{
#if 0
    printf( "-example plugin : sample_rate=%u : channels=%u : frames=%lu\n" , sample_rate , channels , frames );
#endif

    /*
     * Allocate a new result and clear it.
    */

    TPAudioDetectionResult * result = ( TPAudioDetectionResult * ) malloc( sizeof( TPAudioDetectionResult ) );

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


