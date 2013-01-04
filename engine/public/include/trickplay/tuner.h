#ifndef _TRICKPLAY_TUNER_H
#define _TRICKPLAY_TUNER_H

#include "trickplay/trickplay.h"

#ifdef __cplusplus
extern "C" {
#endif

/*-----------------------------------------------------------------------------*/
/*
    File: Tuner

    A device might have one or more tuners, which can be controlled to change
    channels on that device.  This API provides a mechanism for controlling
    those tuners.

    This API allows a very high-level control of the tuner functionality.  The
    tuner itself will need to know a lot of details of its own implementation that
    the TrickPlay engine will not care about.  The TrickPlay engine will allow
    tuning to a URI-based channel.  The tuner will need to map this to underlying
    radio frequencies, etc according to its own prefered mapping, by interpreting
    the tuning URI in its own way.

    For example, an app that knows it's running on a QAM tuner might use a URI

    (code)
    tp-tuner:qam-e64/700/4000/0x200/0x28a
    (/code)

    This could be interpreted by the tuner itself to mean QAM mode e64, 700MHz, 4000kHz symbolrate,
                                                            video_pid = 0x200, audio_pid = 0x28a

    But the contents of that tuner URI are basically left entirely to the platform.

    A wiser platform might even just have:

    (code)
    tp-tuner:123
    (/code)

    which would mean 'tune to logical channel 123', and the tuner will then figure out what to do.
*/
/*-----------------------------------------------------------------------------*/

typedef struct TPTuner TPTuner;


/*-----------------------------------------------------------------------------*/
/*
    Section: Tuner Commands

*/

/*
    Callback: change_channel_callback

    The TrickPlay engine will use this function to call your tuner and ask it to change the channel.

    Arguments:

        tuner   -   The tuner that should change its channel, as returned by <tp_context_add_tuner>.

        new_channel_uri     -       The channel to tune to.  The tuner is free to interpret this
                                    URI in any way that it wants to.  If the tuner wants to retain
                                    this string after the call to <change_channel_callback> returns,
                                    it should take a copy.

        data                -       User data that was passed to <tp_context_add_tuner>

    Returns:

        resultcode          -       0 if channel tune was successful, non-zero if failed.
*/

    typedef int
    (*TPChannelChangeCallback)(

        TPTuner * tuner,
        const char *new_channel_uri,
        void * data);

/*-----------------------------------------------------------------------------*/
/*
    Section: Tuner Events

    When a tuner generates an event, it should pass it to TrickPlay using
    one or more of the functions described below. All of these functions are
    thread safe.
*/

/*
    Callback: tp_tuner_channel_changed

    Report that the channel was changed externally.  TrickPlay will take a copy of the new_channel
    if necessary.

    Arguments:

        tuner   -    The tuner returned by <tp_context_add_tuner>.

        new_channel -      A URI describing the new channel.

*/

    TP_API_EXPORT
    void
    tp_tuner_channel_changed(

        TPTuner * tuner,
        const char * new_channel);


/*
    Function: tp_context_add_tuner

    Let TrickPlay know that a new tuner has been connected. This function
    can be called before or after <tp_context_run> is called and is thread safe.

    TrickPlay will make a copy of the name.

    (code)

    TPTuner * tuner=tp_context_add_tuner(context, "QAM tuner #1", my_tuner_struct);

    (end)

    Arguments:

        context -   A pointer to the associated TrickPlay context.

        name -      A NULL terminated name for the controller. This should be
                    short and user friendly, such as "QAM tuner #1" or
                    "Sattelite Tuner #3".

        data -      User data opaque to TrickPlay. This is passed back to you
                    in calls to tp_tuner_tune. It can be NULL.

    Returns:

        tuner - A pointer to a TPTuner structure. This structure is
                    opaque to you and does not need to be freed. You use this
                    pointer to associate events with the tuner when calling
                    one of the <Tuner Events> functions.
*/

    TP_API_EXPORT
    TPTuner *
    tp_context_add_tuner(

        TPContext * context,
        const char * name,
        TPChannelChangeCallback tune_channel,
        void * data);


/*-----------------------------------------------------------------------------*/

#ifdef __cplusplus
}
#endif

/*-----------------------------------------------------------------------------*/

#endif /* _TRICKPLAY_CONTROLLER_H */
