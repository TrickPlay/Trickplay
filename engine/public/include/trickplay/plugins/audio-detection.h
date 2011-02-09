#ifndef _TRICKPLAY_AUDIO_DETECTION_H
#define _TRICKPLAY_AUDIO_DETECTION_H

/*-----------------------------------------------------------------------------*/

    typedef struct TPAudioDetectionResult TPAudioDetectionResult;

    struct TPAudioDetectionResult
    {
        char *    url;
        char *    method;
        char *    headers;
        char *    body;

        void      (*parse_response)(

                    TPAudioDetectionResult *    result,
                    const char *                response_body,
                    unsigned long int           response_size);

        char *    json;

        void      (*free_result)( TPAudioDetectionResult * result );
    };

    typedef
    TPAudioDetectionResult *
    (*TPAudioDetectionProcessSamples)(

            unsigned int        sample_rate,
            unsigned int        channels,
            unsigned long int   frames,
            const float *       samples );


#define TP_AUDIO_DETECTION_PROCESS_SAMPLES "tp_audio_detection_process_samples"

/*-----------------------------------------------------------------------------*/

#endif /* _TRICKPLAY_AUDIO_DETECTION_H */

