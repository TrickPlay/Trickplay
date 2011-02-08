#ifndef _TRICKPLAY_AUDIO_SAMPLER_H
#define _TRICKPLAY_AUDIO_SAMPLER_H

#include "trickplay/trickplay.h"

#ifdef __cplusplus
extern "C" {
#endif

/*-----------------------------------------------------------------------------*/
/*
    File: Audio Sampling

    TrickPlay's audio sampling API lets you feed audio buffers to TrickPlay,
    which will attempt to detect what the source of the audio is. Using various
    methodologies, TrickPlay may be able to provide apps information about what the
    user is watching.

    To use this API, you start by getting a TPAudioSampler from your TrickPlay context
    by calling <tp_context_get_audio_sampler>. This lets TrickPlay know that you intend
    to use the audio sampling API and starts the internal machinery required for it.

    Then, you simply populate a <TPAudioBuffer> structure and pass it
    to <tp_audio_sampler_submit_buffer>. When the audio source changes, if the
    user changes channels or inputs; you call <tp_audio_sampler_source_changed>.
*/
/*-----------------------------------------------------------------------------*/
/*
    Constants: Audio Formats

    These constanst are the same as <libsndfile at http://www.mega-nerd.com/libsndfile/api.html>.

    TP_AUDIO_FORMAT_PCM_S8       - Signed 8 bit data
    TP_AUDIO_FORMAT_PCM_16       - Signed 16 bit data
    TP_AUDIO_FORMAT_PCM_24       - Signed 24 bit data
    TP_AUDIO_FORMAT_PCM_32       - Signed 32 bit data
    TP_AUDIO_FORMAT_PCM_U8       - Unsigned 8 bit data
    TP_AUDIO_FORMAT_FLOAT        - 32 bit float data
    TP_AUDIO_FORMAT_DOUBLE       - 64 bit float data
    TP_AUDIO_FORMAT_ULAW         - U-Law encoded.
    TP_AUDIO_FORMAT_ALAW         - A-Law encoded.
    TP_AUDIO_FORMAT_IMA_ADPCM    - IMA ADPCM.
    TP_AUDIO_FORMAT_MS_ADPCM     - Microsoft ADPCM.
    TP_AUDIO_FORMAT_GSM610       - GSM 6.10 encoding.
    TP_AUDIO_FORMAT_VOX_ADPCM    - Oki Dialogic ADPCM encoding.
    TP_AUDIO_FORMAT_G721_32      - 32kbs G721 ADPCM encoding.
    TP_AUDIO_FORMAT_G723_24      - 24kbs G723 ADPCM encoding.
    TP_AUDIO_FORMAT_G723_40      - 40kbs G723 ADPCM encoding.
    TP_AUDIO_FORMAT_DWVW_12      - 12 bit Delta Width Variable Word encoding.
    TP_AUDIO_FORMAT_DWVW_16      - 16 bit Delta Width Variable Word encoding.
    TP_AUDIO_FORMAT_DWVW_24      - 24 bit Delta Width Variable Word encoding.
    TP_AUDIO_FORMAT_DWVW_N       - N bit Delta Width Variable Word encoding.
    TP_AUDIO_FORMAT_DPCM_8       - 8 bit differential PCM (XI only)
    TP_AUDIO_FORMAT_DPCM_16      - 16 bit differential PCM (XI only)

    Constants: Endian-ness

    These can be OR'ed with the audio format constants.

    TP_AUDIO_ENDIAN_DEFAULT      - Default file endian-ness.
    TP_AUDIO_ENDIAN_LITTLE       - Force little endian-ness.
    TP_AUDIO_ENDIAN_BIG          - Force big endian-ness.
    TP_AUDIO_ENDIAN_CPU          - Force CPU endian-ness.
*/

#define TP_AUDIO_FORMAT_PCM_S8       0x0001
#define TP_AUDIO_FORMAT_PCM_16       0x0002
#define TP_AUDIO_FORMAT_PCM_24       0x0003
#define TP_AUDIO_FORMAT_PCM_32       0x0004
#define TP_AUDIO_FORMAT_PCM_U8       0x0005
#define TP_AUDIO_FORMAT_FLOAT        0x0006
#define TP_AUDIO_FORMAT_DOUBLE       0x0007
#define TP_AUDIO_FORMAT_ULAW         0x0010
#define TP_AUDIO_FORMAT_ALAW         0x0011
#define TP_AUDIO_FORMAT_IMA_ADPCM    0x0012
#define TP_AUDIO_FORMAT_MS_ADPCM     0x0013
#define TP_AUDIO_FORMAT_GSM610       0x0020
#define TP_AUDIO_FORMAT_VOX_ADPCM    0x0021
#define TP_AUDIO_FORMAT_G721_32      0x0030
#define TP_AUDIO_FORMAT_G723_24      0x0031
#define TP_AUDIO_FORMAT_G723_40      0x0032
#define TP_AUDIO_FORMAT_DWVW_12      0x0040
#define TP_AUDIO_FORMAT_DWVW_16      0x0041
#define TP_AUDIO_FORMAT_DWVW_24      0x0042
#define TP_AUDIO_FORMAT_DWVW_N       0x0043
#define TP_AUDIO_FORMAT_DPCM_8       0x0050
#define TP_AUDIO_FORMAT_DPCM_16      0x0051

#define TP_AUDIO_ENDIAN_DEFAULT      0x00000000
#define TP_AUDIO_ENDIAN_LITTLE       0x10000000
#define TP_AUDIO_ENDIAN_BIG          0x20000000
#define TP_AUDIO_ENDIAN_CPU          0x30000000

/*-----------------------------------------------------------------------------*/
/*
    Struct: TPAudioBuffer

    This structure contains information about an audio buffer. You can populate one
    and pass it to <tp_audio_sampler_submit_buffer>.

    TrickPlay always copies the TPAudioBuffer structure itself, so you can re-use the
    same one in future calls. If you allocate the TPAudioBuffer structure on the heap,
    you should always free it immediately after the call to <tp_audio_sampler_submit_buffer>.

    TrickPlay may or may not copy the samples themselves, unless you specifically set
    <copy_samples> to a non-zero value. If <free_samples> is set, TrickPlay will always
    call it when it is finished with the buffer.
*/

    typedef struct TPAudioBuffer TPAudioBuffer;

    struct TPAudioBuffer
    {
        /*
            Field: sample_rate

            The number of samples per second (Hz). For example, 44.1 kHz should be 44100.
        */

        unsigned int        sample_rate;

        /*
            Field: channels

            The number of channels. 1 for mono, 2 for stereo, etc.
        */

        unsigned int        channels;

        /*
            Field: format

            One of the <Audio Formats> constants defined above.
        */

        int                 format;

        /*
            Field: samples

            A pointer to the samples.
        */

        void *              samples;

        /*
            Field: size

            The size, in bytes of the buffer pointed to by samples.
        */

        unsigned long int   size;

        /*
            Field: copy_samples

            Possible Values:

            Non-zero - TrickPlay will make a copy of the samples and
            call <free_samples> (if it is set) before <tp_audio_sampler_submit_buffer>
            returns. If <free_samples> is NULL, you should free the samples after
            calling <tp_audio_sampler_submit_buffer>.

            Zero - You must populate <free_samples> and TrickPlay will
            call it when it is finished with the buffer. This approach will result
            in better performance, since it avoids the copy.
        */

        int                 copy_samples;

        /*
            Field: free_samples

            A thread-safe function TrickPlay will call when it is finished with the
            samples. If <copy_samples> is non-zero, you can set this to NULL.
        */

        void                (*free_samples)( void * samples , void * user_data );

        /*
            Field: user_data

            User data ignored by TrickPlay but passed to <free_samples>.
        */

        void *              user_data;

    };

/*-----------------------------------------------------------------------------*/
/*
    Section: Global Interface
*/
/*-----------------------------------------------------------------------------*/

    typedef struct TPAudioSampler TPAudioSampler;

/*-----------------------------------------------------------------------------*/
/*
    Function: tp_context_get_audio_sampler

    This function returns the audio sampler for the TrickPlay context. It is valid
    (and the same one) until you call tp_context_free, so you don't have to call it
    repeatedly.

    Arguments:

        context - A valid TrickPlay context.
*/

    TP_API_EXPORT
    TPAudioSampler *
    tp_context_get_audio_sampler(

        TPContext * context);

/*-----------------------------------------------------------------------------*/
/*
    Function: tp_audio_sampler_submit_buffer

    This thread-safe function is used to submit an audio buffer to TrickPlay for
    processing.

    You should try to call this function often and not accumulate samples yourself.

    Arguments:

        sampler - A TPAudioSampler obtained by calling <tp_context_get_audio_sampler>.

        buffer - A pointer to a <TPAudioBuffer> structure. TrickPlay always copies
                 the structure itself (but not necessarily the samples), so you can
                 free it or re-use the same one after this call.
*/

    TP_API_EXPORT
    void
    tp_audio_sampler_submit_buffer(

            TPAudioSampler *    sampler,
            TPAudioBuffer *     buffer);

/*-----------------------------------------------------------------------------*/
/*
    Function: tp_audio_sampler_source_changed

    This thread-safe function notifies TrickPlay that the audio source has changed.
    TrickPlay will stop processing and free any audio buffers that were submitted
    before this call.

    Although calling this function is optional, it is recommended that you do so.
    Not only will it improve the user experience, but will also improve the general
    performance of the audio sampler; because it can promtly free audio buffers that
    are no longer relevant.

    Arguments:

        sampler - A TPAudioSampler obtained by calling <tp_context_get_audio_sampler>.
*/

    TP_API_EXPORT
    void
    tp_audio_sampler_source_changed(

            TPAudioSampler *    sampler);

/*-----------------------------------------------------------------------------*/
/*
    Function: tp_audio_sampler_pause

    Instructs the audio sampler to stop processing pending audio buffers. This
    can be used to temporarily minimize the resources used by the audio sampler.

    You can still submit audio buffers while the sampler is paused; it will simply
    accumulate them and process them when you call <tp_audio_sampler_resume>.

    Arguments:

        sampler - A TPAudioSampler obtained by calling <tp_context_get_audio_sampler>.
*/

    TP_API_EXPORT
    void
    tp_audio_sampler_pause(

            TPAudioSampler *    sampler);

/*-----------------------------------------------------------------------------*/
/*
    Function: tp_audio_sampler_resume

    Instructs the audio sampler to resume processing audio buffers.

    Arguments:

        sampler - A TPAudioSampler obtained by calling <tp_context_get_audio_sampler>.
*/

    TP_API_EXPORT
    void
    tp_audio_sampler_resume(

            TPAudioSampler *    sampler);

/*-----------------------------------------------------------------------------*/

#ifdef __cplusplus
}
#endif

#endif /* _TRICKPLAY_AUDIO_SAMPLER_H */
