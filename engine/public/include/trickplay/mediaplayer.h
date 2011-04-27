#ifndef _TRICKPLAY_MEDIAPLAYER_H
#define _TRICKPLAY_MEDIAPLAYER_H

#include "trickplay/trickplay.h"

#ifdef __cplusplus
extern "C" {
#endif 

/*
    File: Media Player

    Section: State Transitions
    
    Topic: All states
    
    Calls that can be made in any state and never change state.

        TrickPlay can always call:
        
            - <TPMediaPlayer.get_viewport_geometry>
            - <TPMediaPlayer.set_viewport_geometry>
            - <TPMediaPlayer.get_audio_volume>
            - <TPMediaPlayer.set_audio_volume>
            - <TPMediaPlayer.get_audio_mute>
            - <TPMediaPlayer.set_audio_mute>
            
        Media player can always call:
        
            - <tp_media_player_get_state>:
    
    
    Topic: IDLE state
    
    The initial state of all media players. In this state, the media player
    should hold minimal resources.
    
        TrickPlay can call:
        
            - <TPMediaPlayer.load>:            
                Returns zero, goes to <LOADING state>.
                Returns non-zero, stays in <IDLE state>.                                
            - <TPMediaPlayer.destroy>:
                Does not change state.
                            
        Media player can call:
        
            - Nothing.
            
    Topic: LOADING state
    
    The media player is attempting to load a resource.
    
        TrickPlay can call:
        
            - <TPMediaPlayer.reset>:
                Goes to <IDLE state> and drops all knowledge of the resource.
            
        Media player can call:
        
            - <tp_media_player_error>:
                Goes to <IDLE state>.
                
            - <tp_media_player_loaded>:
                Goes to <PAUSED state>.
                
            - <tp_media_player_tag_found>:
                Does not change state.

    Topic: PAUSED state
    
    The media player is paused and ready to play.
    
        TrickPlay can call:
        
            - <TPMediaPlayer.play>:
                Returns zero, goes to <PLAYING state>.
                Returns non-zero, stays in <PAUSED state>.
                    
            - <TPMediaPlayer.reset>:
                Goes to <IDLE state> and drops all knowledge of the resource.
    
            *The following calls do not change state*

            - <TPMediaPlayer.seek>            
            - <TPMediaPlayer.get_position>
            - <TPMediaPlayer.get_media_type>
            - <TPMediaPlayer.get_duration>
            - <TPMediaPlayer.get_buffered_duration>
            - <TPMediaPlayer.get_video_size>
                
        Media player can call:
        
            - Nothing.

    Topic: PLAYING state
    
    The media player is playing.
    
        TrickPlay can call:
        
            - <TPMediaPlayer.pause>:
                Returns zero, goes to <PAUSED state>.                    
                Returns non-zero, stays in <PLAYING state>. 
                    
            - <TPMediaPlayer.reset>:
                Goes to <IDLE state> and drops all knowledge of the resource.

            *The following calls do not change state*

            - <TPMediaPlayer.set_playback_rate>
            - <TPMediaPlayer.seek>
            - <TPMediaPlayer.get_position>
            - <TPMediaPlayer.get_media_type>
            - <TPMediaPlayer.get_duration>
            - <TPMediaPlayer.get_buffered_duration>
            - <TPMediaPlayer.get_video_size>
            
        Media player can call:
        
            - <tp_media_player_end_of_stream>:
                Goes to <PAUSED state>.
                Position is reset to 0, rate is reset to 1.
                
            - <tp_media_player_error>:
                Goes to <PAUSED state>.
                Position and rate do not change.

*/
/*
    Section: Global Interface    
*/
/*-----------------------------------------------------------------------------*/
/*
    Constants: Media Player States
    
    TP_MEDIAPLAYER_IDLE     - <IDLE state>.     
    TP_MEDIAPLAYER_LOADING  - <LOADING state>.
    TP_MEDIAPLAYER_PAUSED   - <PAUSED state>.
    TP_MEDIAPLAYER_PLAYING  - <PLAYING state>.
*/

#define TP_MEDIAPLAYER_IDLE         0x01
#define TP_MEDIAPLAYER_LOADING      0x02
#define TP_MEDIAPLAYER_PAUSED       0x04
#define TP_MEDIAPLAYER_PLAYING      0x08

#define TP_MEDIAPLAYER_ANY_STATE    (TP_MEDIAPLAYER_IDLE|TP_MEDIAPLAYER_LOADING|TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)

/*-----------------------------------------------------------------------------*/
/*
    Constants: Media Types
    
    TP_MEDIA_TYPE_AUDIO         - The media resource has audio.
    TP_MEDIA_TYPE_VIDEO         - The media resource has video.
    TP_MEDIA_TYPE_AUDIO_VIDEO   - The media resource has both audio and video.
*/

#define TP_MEDIA_TYPE_AUDIO         0x01
#define TP_MEDIA_TYPE_VIDEO         0x02
#define TP_MEDIA_TYPE_AUDIO_VIDEO   (TP_MEDIA_TYPE_AUDIO|TP_MEDIA_TYPE_VIDEO)

/*-----------------------------------------------------------------------------*/
/*
    Constants: Basic Errors
    
    These are some pre-defined basic errors. Most of the functions in this API
    return an integer, where zero indicates success. If appropriate, you can
    return these errors. For custom error codes, it is suggested that you use
    positive integers.

    TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED    - The function is not implemented    
    TP_MEDIAPLAYER_ERROR_INVALID_STATE      - The current state is invalid for this call
    TP_MEDIAPLAYER_ERROR_BAD_PARAMETER      - A parameter is invalid
    TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER     - Reserved    
    TP_MEDIAPLAYER_ERROR_INVALID_URI        - Bad URI
    TP_MEDIAPLAYER_ERROR_NA                 - Not applicable, like video size for an audio stream
*/

#define TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED    -1    
#define TP_MEDIAPLAYER_ERROR_INVALID_STATE      -2
#define TP_MEDIAPLAYER_ERROR_BAD_PARAMETER      -3
#define TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER     -4
#define TP_MEDIAPLAYER_ERROR_INVALID_URI        -5
#define TP_MEDIAPLAYER_ERROR_NA                 -6

/*-----------------------------------------------------------------------------
   Forward declarations
*/

typedef struct TPMediaPlayer    TPMediaPlayer;

/*-----------------------------------------------------------------------------*/

/*
    Function: TPMediaPlayerConstructor
    
    This is the prototype for a function that initializes a new media player. You
    should populate all of its functions.
    
    Arguments:
    
        mp -    A pointer to an uninitialized TPMediaPlayer structure.
    
    Returns:
    
        0 -     If the media player was initialized.

        other - The media player cannot be initialized.
*/

    typedef
    int (*TPMediaPlayerConstructor)(

        TPMediaPlayer * mp);

/*
    Function: tp_context_set_media_player_constructor
    
    Sets a function that TrickPlay will use to create new media players. This
    should only be called once; after a context is created and before it runs.

    Arguments:
    
        context -       A pointer to the relevant TPContext structure.
        constructor -   The function to call to initialize new media players.
*/

    TP_API_EXPORT
    void
    tp_context_set_media_player_constructor(

        TPContext * context,
        TPMediaPlayerConstructor constructor);

/*
    Function: tp_media_player_get_state
    
    Returns the current state of the media player. The state is managed by
    TrickPlay based on callbacks invoked.

    Arguments:
    
        mp -        The TPMediaPlayer.
    
    Returns:
    
        The current state.

*/

    TP_API_EXPORT
    int
    tp_media_player_get_state(

        TPMediaPlayer * mp);

/*
    Callback: tp_media_player_loaded
    
    Invoked when the media player is ready to play and has valid information
    about the resource.
    
    Arguments:
    
        mp -        The TPMediaPlayer.

    Valid States:
    - LOADING
*/

    TP_API_EXPORT
    void
    tp_media_player_loaded(

        TPMediaPlayer * mp);

/*
    Callback: tp_media_player_error
    
    Invoked when there is an error while loading or playing back.
    
    Arguments:
    
        mp -        The TPMediaPlayer.

    Valid States:
    - LOADING
    - PLAYING
*/

    TP_API_EXPORT
    void
    tp_media_player_error(

        TPMediaPlayer * mp,
        int code,
        const char * message);

/*
    Callback: tp_media_player_end_of_stream
    
    Invoked when the end of a resource is reached.
    
    Arguments:
    
        mp -        The TPMediaPlayer.
        code -      An integer error code.
        message -   A string describing the error. TrickPlay will make a copy.
    
    Valid States:
    - PLAYING
*/

    TP_API_EXPORT
    void
    tp_media_player_end_of_stream(

        TPMediaPlayer * mp);

/*
    Callback: tp_media_player_tag_found
    
    Invoked when a metadata tag is found in the stream.
    
    Arguments:
    
        mp -        The TPMediaPlayer.
        name -      The name of the tag. TrickPlay will make a copy.
        value -     The value of the tag as a string. TrickPlay will make a copy.
    
    Valid States:
    - LOADING
*/

    TP_API_EXPORT
    void
    tp_media_player_tag_found(

        TPMediaPlayer * mp,
        const char * name,
        const char * value);

/*-----------------------------------------------------------------------------*/
/*
    Struct: TPMediaPlayer
*/    

struct TPMediaPlayer
{
/*
    Field: user_data
    
    A pointer to user data, which is opaque to TrickPlay. If you use this member,
    you should dispose of it and any resources it holds in <destroy>. 
*/

    void * user_data;
    
/*
    Function: destroy
    
    Should release all resources associated with this media player. It should not
    free the TPMediaPlayer structure, as it belongs to TrickPlay. If the media
    player is in any state other than IDLE, TrickPlay will call <reset> before it
    calls <destroy>.
    
    Arguments:
    
        mp -    The TPMediaPlayer instance to destroy.
    
    Valid States:
    
    - IDLE
*/

    void
    (*destroy)(

        TPMediaPlayer * mp);

/*
    Function: load
    
    Should validate the URI and attempt to begin loading it asynchronously. It should
    return as quickly as possible.
   
    Arguments:
    
        mp -    The TPMediaPlayer instance.

        uri -   The URI to load. It should be validated by the media player and
                should be copied if it is to be used beyond this call.

        extra - Additional parameters specified by the application. This is
                opaque to TrickPlay and should be copied if it is to be used
                beyond this call.

    Returns:
    
        0 -     The media player has started loading the URI and will invoke
                either <tp_media_player_loaded> when it is successful
                or <tp_media_player_error> if there is a problem. The state will
                switch to LOADING.
                It can begin buffering but should not start playback or otherwise
                show anything on the video plane.

        other - An error was detected immediately (such as a bad URI) and the
                the media player will not be able to continue. It should not invoke
                any callbacks. The state will remain IDLE.
                
    Valid States:
    
    - IDLE
*/
    
    int
    (*load)(

        TPMediaPlayer * mp,
        const char * uri,
        const char * extra);
    
/*
    Function: reset
    
    Must unconditionally stop playback and free all resources associated with the
    current URI. It should retain viewport geometry and volume/mute information.
    It should not free the media player itself; that is a job for <destroy>.
    
    Arguments:
    
        mp -    The TPMediaPlayer instance.
    
    Valid States:
    
    - LOADING
    - PLAYING
    - PAUSED
*/

    void
    (*reset)(

        TPMediaPlayer * mp);
    
/*
    Function: play
    
    Should attempt to start playing the resource from the current position. If the
    current position is at the end of the stream, this call should succeed and
    <tp_media_player_end_of_stream> should be called.
    
    Arguments:

        mp -    The TPMediaPlayer instance.
    
    Returns:
    
        0 -     Playback has started without problems. The media player will switch to
                PLAYING state and can call <tp_media_player_error> or
                <tp_media_player_end_of_stream>.

        other - Playback failed to start. The state will remain PAUSED and
                no callbacks can be invoked.

    Valid States:
    
    - PAUSED
*/
    
    int
    (*play)(

        TPMediaPlayer * mp);
    
/*
    Function: seek
    
    Should attempt to seek to the given position (in seconds) within the stream.
    If the media player is in the PAUSED state, the new position
    should be noted by the media player - and clamped if out of range - but the
    media player should do nothing else until <play> is called. Even if the new
    position is at the end of the stream, the media player should not invoke
    <tp_media_player_end_of_stream> within this call; it should only do so as
    a result of playing the stream.
    
    In all cases, the state will remain as it was.
    
    Arguments:
    
        mp -        The TPMediaPlayer instance.

        seconds -   A position, in seconds, within the stream. This parameters will
                    always be greater than or equal to zero. If it is greater than
                    the duration of the stream, it should be clamped.
                
    Returns:
    
        0 -     The seek operation has started successfully.

        other - For whatever reason, the media player cannot seek.

    Valid States:
    
    - PLAYING
    - PAUSED
*/
    
    int
    (*seek)(

        TPMediaPlayer * mp,
        double seconds);
    
/*
    Function: pause
    
    Should attempt to pause the stream. If the playback rate is anything other than
    one, it should be reset to 1.
    
    Arguments:

        mp -    The TPMediaPlayer instance.
    
    Returns:
    
        0 -     The stream was paused and the state will switch to PAUSED.

        other - There was a problem pausing the stream and the state will remain PLAYING.

    Valid States:
    
    - PLAYING
*/

    int
    (*pause)(

        TPMediaPlayer * mp);
    
/*
    Function: set_playback_rate
    
    Should attempt to change the playback rate. Playback rates are integers denoting
    a speed multiplier. Negative playback rates should play backward. Zero is not
    a valid playback rate.
    
    Arguments:

        mp -    The TPMediaPlayer instance.

        rate -  An integer multiplier, which will never be zero. 1 is normal speed,
                -1 is normal speed backwards, 2 is twice the normal speed forward, etc...

    Returns:
    
        0 -     The playback rate was set successfully.

        other - The playback rate cannot be changed to the given value, it remains
                unchanged.

    Valid States:
    
    - PLAYING    
*/

    int
    (*set_playback_rate)(

        TPMediaPlayer * mp,
        int rate);
    
/*
    Function: get_position
    
    Should return the current playback position, in seconds, within the stream.
    
    Arguments:

        mp -        The TPMediaPlayer instance.
    
        seconds -   A pointer to hold the playback position.

    Returns:

        0 -     The position is known and was returned.

        other - The position is not known.
    
    Valid States:
    
    - PLAYING
    - PAUSED
*/

    int
    (*get_position)(

        TPMediaPlayer * mp,
        double * seconds);
    
/*
    Function: get_duration
    
    Should return the duration of the stream, in seconds. 

    Arguments:

        mp -        The TPMediaPlayer instance.
    
        seconds -   A pointer to hold the stream duration.

    Returns:
    
        0 -     The duration is known and was returned.
    
        other - The duration is not known.

    Valid States:
    
    - PLAYING
    - PAUSED
*/

    int
    (*get_duration)(

        TPMediaPlayer * mp,
        double * seconds);
    
/*
    Function: get_buffered_duration
    
    Returns two markers that denote the portion of the stream that is currently
    buffered, in seconds. 
    
    Arguments:
    
        mp -            The TPMediaPlayer instance.

        start_seconds - A pointer to hold the starting point of the buffer, in seconds,
                        relative to the beginning of the stream (0).

        end_seconds -   A pointer to hold the ending point of the buffer, in seconds,
                        relative to the beginning of the stream (0).

    Returns:
    
        0 -     The buffered duration is known and both start_seconds and end_seconds
                where set.

        other - The buffered duration is not known.

    Valid States:
    
    - PLAYING
    - PAUSED
*/

    int
    (*get_buffered_duration)(

        TPMediaPlayer * mp,
        double * start_seconds,
        double * end_seconds);

/*
    Function: get_video_size
    
    Returns the size of the video stream, if any. This is not the size of the view
    port used to display the video, but the actual resolution of the video itself.
        
    Arguments:
    
        mp -        The TPMediaPlayer instance.

        width -     A pointer to hold the width of the video.

        height -    A pointer to hold the height of the video.
                    
    Returns:
    
        0 -     The video size is known and both width and height were set.

        other - The video size is not known or the stream contains no video.

    Valid States:
    
    - PLAYING
    - PAUSED
*/

    int
    (*get_video_size)(

        TPMediaPlayer * mp,
        int * width,
        int * height);
    
/*
    Function: get_viewport_geometry
    
    Returns the position and size, in pixels, of the viewport used to play video.
    
    Arguments:
    
        mp -        The TPMediaPlayer instance.

        left -      A pointer to hold the left (x) coordinate of the viewport.

        top -       A pointer to hold the top (y) coordinate of the viewport.
    
        width -     A pointer to hold the width of the viewport.
    
        height -    A pointer to hold the height of the viewport.

    Returns:
    
        0 -     The viewport size is known and left, top, width and height were set.

        other - The viewport size is not known.

    Valid States:
    
    - IDLE
    - LOADING
    - PLAYING
    - PAUSED    
*/

    int
    (*get_viewport_geometry)(

        TPMediaPlayer * mp,
        int * left,
        int * top,
        int * width,
        int * height);
    
/*
    Function: set_viewport_geometry
    
    Sets the position and size of the viewport.
    
    Arguments:
    
        mp -        The TPMediaPlayer instance.

        left -      The desired left (x) coordinate of the viewport.

        top -       The desired top (y) coordinate of the viewport.
    
        width -     The desired width of the viewport.
    
        height -    The desired height of the viewport.

    Returns:
    
        0 -     The viewport geometry was changed successfully.

        other - The viewport geometry cannot be changed.

    Valid States:
    
    - IDLE
    - LOADING
    - PLAYING
    - PAUSED    
*/

    int
    (*set_viewport_geometry)(

        TPMediaPlayer * mp,
        int left,
        int top,
        int width,
        int height);
    
/*
    Function: get_media_type
    
    Returns the type of media; whether it has audio, video or both.
    
    Arguments:
    
        mp  -       The TPMediaPlayer instance.

        type -      A pointer to hold the type.

    Returns:
    
        0 -         The media type is known and type was set.

        other -     The media type is not known.

    Valid States:
    
    - PLAYING
    - PAUSED
*/

    int
    (*get_media_type)(

        TPMediaPlayer * mp,
        int * type);

/*
    Function: get_audio_volume
    
    Returns the current audio volume as a floating point number between 0 and
    1, where 0 is the lowest volume.
    
    Arguments:
    
        mp  -       The TPMediaPlayer instance.

        volume -    A pointer to hold the volume.

    Returns:
    
        0 -         The volume is known and was set.

        other -     The volume is not known.

    Valid States:
    
    - IDLE
    - LOADING
    - PLAYING
    - PAUSED
*/

    int
    (*get_audio_volume)(

        TPMediaPlayer * mp,
        double * volume);

/*
    Function: set_audio_volume
    
    Sets the audio volume as a floating point number between 0 and
    1, where 0 is the lowest volume.
    
    Arguments:
    
        mp  -       The TPMediaPlayer instance.

        volume -    The new volume, between 0 and 1 inclusive.

    Returns:
    
        0 -         The volume was set.

        other -     There was a problem setting the volume.

    Valid States:
    
    - IDLE
    - LOADING
    - PLAYING
    - PAUSED
*/

    int
    (*set_audio_volume)(

        TPMediaPlayer * mp,
        double volume);


/*
    Function: get_audio_mute
    
    Returns a value indicating whether audio is muted.
    
    Arguments:
    
        mp  -       The TPMediaPlayer instance.

        mute -      Whether audio is muted. A value of zero, means audio is NOT muted;
                    anything else means it is MUTED.

    Returns:
    
        0 -         Mute was set successfully.

        other -     There was a problem getting the mute value.

    Valid States:
    
    - IDLE
    - LOADING
    - PLAYING
    - PAUSED
*/

    int
    (*get_audio_mute)(

        TPMediaPlayer * mp,
        int * mute);


/*
    Function: set_audio_mute
    
    Mutes audio.
    
    Arguments:
    
        mp  -       The TPMediaPlayer instance.

        mute -      Whether audio should be muted. A value of zero, means audio should
                    NOT be muted; anything else means it should be MUTED.

    Returns:
    
        0 -         Mute was set successfully.

        other -     There was a problem setting the mute value.

    Valid States:
    
    - IDLE
    - LOADING
    - PLAYING
    - PAUSED
*/

    int
    (*set_audio_mute)(

        TPMediaPlayer * mp,
        int mute);

/*
    Function: play_sound

    Plays a sound file. The sound should be played asynchronously and should
    not affect anything else the media player is doing.

    Arguments:

        mp -    The TPMediaPlayer instance.

        uri -   The URI of the sound to play. It should be validated by the media
                player and should be copied if it is to be used beyond this call.

    Returns:

        0 -     The media player has started playing the sound.

        other - An error was detected immediately (such as a bad URI) and the
                the media player will not be able to play the sound.

    Valid States:

    - any

*/

    int
    (*play_sound)(

        TPMediaPlayer * mp,
        const char * uri);
    
/*
    Function: get_viewport_texture
    
    Should return NULL.
*/

    void *
    (*get_viewport_texture)(

        TPMediaPlayer * mp);
    
};


#ifdef __cplusplus
}
#endif 

#endif  /* _TRICKPLAY_MEDIAPLAYER_H */
