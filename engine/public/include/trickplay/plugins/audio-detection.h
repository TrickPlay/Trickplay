#ifndef _TRICKPLAY_AUDIO_DETECTION_H
#define _TRICKPLAY_AUDIO_DETECTION_H

#include "trickplay/plugins/plugins.h"

/*-----------------------------------------------------------------------------*/

    typedef struct TPAudioDetectionSamples TPAudioDetectionSamples;

    struct TPAudioDetectionSamples
    {
        unsigned int        sample_rate;
        unsigned int        channels;
        unsigned long int   frames;
        const float *       samples;
    };

    typedef struct TPAudioDetectionResult TPAudioDetectionResult;

    struct TPAudioDetectionResult
    {
        char *  url;
        char *  method;
        char *  headers;
        char *  body;

        void    (*parse_response)(

                    TPAudioDetectionResult *    result,
                    const char *                response_body,
                    unsigned long int           response_size);

        char *  json;

        void    (*free_result)( TPAudioDetectionResult * result );

        void *  user_data;
    };

    typedef
    TPAudioDetectionResult *
    (*TPAudioDetectionProcessSamples)(

            const TPAudioDetectionSamples * samples,
            void *                          user_data);

/*-----------------------------------------------------------------------------*/

    typedef
    void
    (*TPAudioDetectionReset)(

            void * user_data);

/*-----------------------------------------------------------------------------*/

#define TP_AUDIO_DETECTION_PROCESS_SAMPLES  "tp_audio_detection_process_samples"
#define TP_AUDIO_DETECTION_RESET            "tp_audio_detection_reset"

/*-----------------------------------------------------------------------------*/

#endif /* _TRICKPLAY_AUDIO_DETECTION_H */

