#ifndef _TRICKPLAY_AUDIO_DETECTION_H
#define _TRICKPLAY_AUDIO_DETECTION_H

/*-----------------------------------------------------------------------------*/

    typedef struct TPAudioDetectionPluginInfo TPAudioDetectionPluginInfo;

    struct TPAudioDetectionPluginInfo
    {
        char            name[32];
        unsigned int    version[3];
        int             resident;
        unsigned int    min_buffer_seconds;
        void *          user_data;
    };

    typedef
    void
    (*TPAudioDetectionInitialize)(

            TPAudioDetectionPluginInfo * info);

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
    (*TPAudioDetectionShutdown)(

            void * user_data);

/*-----------------------------------------------------------------------------*/

#define TP_AUDIO_DETECTION_INITIALIZE       "tp_audio_detection_initialize"
#define TP_AUDIO_DETECTION_PROCESS_SAMPLES  "tp_audio_detection_process_samples"
#define TP_AUDIO_DETECTION_SHUTDOWN         "tp_audio_detection_shutdown"

/*-----------------------------------------------------------------------------*/

#endif /* _TRICKPLAY_AUDIO_DETECTION_H */

