#ifndef TP_MEDIAPLAYER_H
#define TP_MEDIAPLAYER_H

#include "tp/tp.h"

#ifdef __cplusplus
extern "C" {
#endif 

/*
    States
    
    IDLE
    ----
    
        TrickPlay can call:
        
            load
            
                returns 0
                    -> goes to LOADING state
                    
                returns non-zero
                    -> stays in IDLE state
                    
            destroy
            
                destroys the media player
                    
            get_viewport_geometry
            set_viewport_geometry
            get_audio_volume
            set_audio_volume
            get_audio_mute
            set_audio_mute
                -> do not change state
                
        MediaPlayer can call:
        
            tp_media_player_get_state
                -> does not change state
            
            
    LOADING
    -------
    
        TrickPlay can call:
        
            reset
                -> goes to IDLE state (and drops all knowledge of the resource)
            
            get_viewport_geometry
            set_viewport_geometry
            get_audio_volume
            set_audio_volume
            get_audio_mute
            set_audio_mute
                -> do not change state

        MediaPlayer can call:
        
            tp_media_player_get_state
                -> does not change state
                
            tp_media_player_error
                -> goes to IDLE state
                
            tp_media_player_loaded
                -> goes to READY state
            
    READY
    -----
    
        TrickPlay can call:
        
            play
            
                returns 0
                    -> goes to PLAYING state
                    
                returns non-zero
                    -> stays in READY state
                
            seek
            
                returns 0
                    -> stays in READY state (at new position)
                    
                returns non-zero
                    -> stays in READY state (does not change position)
                
            reset
                -> goes to IDLE state (and drops all knowledge of the resource)
                
            get_viewport_geometry
            set_viewport_geometry
            get_position
            get_media_type
            get_duration
            get_buffered_duration
            get_video_size
            get_tags
            get_audio_volume
            set_audio_volume
            get_audio_mute
            set_audio_mute
                -> do not change state
            
        MediaPlayer can call:
        
            tp_media_player_get_state
                -> does not change state
            
    PLAYING
    -------
    
        TrickPlay can call:
        
            pause
            
                returns 0
                    -> goes to PAUSED state
                    
                returns non-zero
                    -> stays in PLAYING state (continues playing)
                    
            seek
            
                returns 0
                    -> stays in PLAYING state (plays at new position)
                    
                returns non-zero
                    -> stays in PLAYING state (does not change position)
                    
            set_playback_rate
            
                returns 0
                    -> stays in PLAYING state (playing at the new rate)
                    
                return non-zero
                    -> stays in PLAYING state (playing at the same rate)
                                        
            reset
                -> goes to IDLE state (and drops all knowledge of the resource)
                
            get_viewport_geometry
            set_viewport_geometry
            get_position
            get_media_type
            get_duration
            get_buffered_duration
            get_video_size
            get_tags
            get_audio_volume
            set_audio_volume
            get_audio_mute
            set_audio_mute
                -> do not change state
            
        MediaPlayer can call:
        
            tp_media_player_get_state
                -> does not change state

            tp_media_player_end_of_stream            
                -> goes to PAUSED state (position is reset to 0, rate is reset to 1)
                
            tp_media_player_error            
                -> goes to PAUSED state (position and rate do not change)
                
    PAUSED
    ------
    
        TrickPlay can call:
        
            play
            
                returns 0
                    -> goes to PLAYING state
                    
                returns non-zero
                    -> stays in PAUSED state
                    
            seek
            
                returns 0
                    -> stays in PAUSED state (new position is set)
                    
                returns non-zero
                    -> stays in PAUSED state (does not change position)
                                                            
            reset
                -> goes to IDLE state (and drops all knowledge of the resource)
    
            get_viewport_geometry
            set_viewport_geometry
            get_position
            get_media_type
            get_duration
            get_buffered_duration
            get_video_size
            get_tags
            get_audio_volume
            set_audio_volume
            get_audio_mute
            set_audio_mute
                -> do not change state
                
        MediaPlayer can call:
        
            tp_media_player_get_state            
                -> does not change state
                    
 
*/

//-----------------------------------------------------------------------------
/*
    File: Media Player
*/
//-----------------------------------------------------------------------------
/*
    Constants: Media Player States
    
    TP_MEDIAPLAYER_IDLE     - Idle state, when there is no resource loaded.     
    TP_MEDIAPLAYER_LOADING  - The media player is trying to load a resource.
    TP_MEDIAPLAYER_READY    - The resource is ready for playback.
    TP_MEDIAPLAYER_PLAYING  - The media player is playing the resource.
    TP_MEDIAPLAYER_PAUSED   - The media player is paused.
*/

#define TP_MEDIAPLAYER_IDLE         0x01
#define TP_MEDIAPLAYER_LOADING      0x02
#define TP_MEDIAPLAYER_READY        0x04
#define TP_MEDIAPLAYER_PLAYING      0x08
#define TP_MEDIAPLAYER_PAUSED       0x10

#define TP_MEDIAPLAYER_ANY_STATE    (TP_MEDIAPLAYER_IDLE|TP_MEDIAPLAYER_LOADING|TP_MEDIAPLAYER_READY|TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)

//-----------------------------------------------------------------------------
/*
    Constants: Media Types
    
    TP_MEDIA_TYPE_AUDIO         - The media resource has audio.
    TP_MEDIA_TYPE_VIDEO         - The media resource has video.
    TP_MEDIA_TYPE_AUDIO_VIDEO   - The media resource has both audio and video.
*/

#define TP_MEDIA_TYPE_AUDIO         0x01
#define TP_MEDIA_TYPE_VIDEO         0x02
#define TP_MEDIA_TYPE_AUDIO_VIDEO   (TP_MEDIA_TYPE_AUDIO|TP_MEDIA_TYPE_VIDEO)

//-----------------------------------------------------------------------------

#define TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED    -1    
#define TP_MEDIAPLAYER_ERROR_INVALID_STATE      -2
#define TP_MEDIAPLAYER_ERROR_BAD_PARAMETER      -3
#define TP_MEDIAPLAYER_ERROR_NO_MEDIAPLAYER     -4

//-----------------------------------------------------------------------------
// Forward declarations

typedef struct TPMediaPlayer    TPMediaPlayer;

//-----------------------------------------------------------------------------

/*
    Function: TPMediaPlayerConstructor
    This is the prototype for a function that initializes a new media player. You
    should populate all of its functions.
    
    Parameters:
    
    mp -    A pointer to an uninitialized TPMediaPlayer structure. 
    
    Returns:
    
    0 -     If the media player was initialized.
    other - The media player cannot be initialized.
*/

typedef int (*TPMediaPlayerConstructor)(TPMediaPlayer * mp);

/*
    Function: tp_context_set_media_player_constructor
    Sets a function that TrickPlay will use to create new media players. This
    should only be called once; after a context is created and before it runs.
*/

void tp_context_set_media_player_constructor(TPContext * context,TPMediaPlayerConstructor constructor);

/*
    Function: tp_media_player_get_state
    Returns the current state of the media player. The state is managed by
    TrickPlay based on callbacks invoked.
*/

int tp_media_player_get_state(TPMediaPlayer * mp);

/*
    Callback: tp_media_player_loaded
    Invoked when the media player is ready to play and has valid information
    about the resource.
    
    Valid States:
    - LOADING
*/

void tp_media_player_loaded(TPMediaPlayer * mp);

/*
    Callback: tp_media_player_error
    Invoked when there is an error while loading or playing back.
    
    Valid States:
    - LOADING
    - PLAYING
*/

void tp_media_player_error(TPMediaPlayer * mp,int code,const char * message);

/*
    Callback: tp_media_player_end_of_stream
    Invoked when the end of a resource is reached.
    
    Valid States:
    - PLAYING
*/

void tp_media_player_end_of_stream(TPMediaPlayer * mp);
    

//-----------------------------------------------------------------------------
/*
    Struct: TPMediaPlayer
*/    

struct TPMediaPlayer
{
/*
    Property: user_data
    A pointer to user data, which is opaque to TrickPlay.
*/

    void * user_data;
    
/*
    Function: destroy
    Should release all resources associated with this media player. It should not
    free the TPMediaPlayer structure, as it belongs to TrickPlay.
    
    Parameters:
    
    mp -    The TPMediaPlayer instance to destroy.
    
    Valid States:
    
    - IDLE
*/

    void (*destroy)(TPMediaPlayer * mp);

/*
    Function: load
    Should validate the uri and attempt to begin loading it asynchronously. It should
    return as quickly as possible.
   
    Parameters:
    
    mp -    The TPMediaPlayer instance.
    
    uri -   The URI to load. It should be validated by the media player and
            should be copied if it is to be used beyond this call.
                
    extra - Additional parameters specified by the application. This is
            opaque to TrickPlay and should be copied if it is to be used
            beyond this call.
   
    Returns:
    
    0 -     The media player has started loading the uri and will invoke
            either <tp_media_player_loaded> when it is successful
            or <tp_media_player_error> if there is a problem. The state will
            switch to LOADING.
            It can begin buffering but should not start playback or otherwise
            show anything on the video plane.
                
    other - An error was detected immediately (such as a bad uri) and the
            the media player will not be able to continue. It should not invoke
            any callbacks. The state will remain IDLE.
            
    Valid States:
    
    - IDLE
*/
    
    int (*load)(TPMediaPlayer * mp,const char * uri,const char * extra);
    
/*
    Function: reset
    Must unconditionally stop playback, free all resources and forget all state,
    except for the viewport geometry. It should not free the media player itself;
    that is a job for <destroy>.
    
    Parameters:
    
    mp -    The TPMediaPlayer instance.
    
    Valid States:
    
    - LOADING
    - READY
    - PLAYING
    - PAUSED
*/

    void (*reset)(TPMediaPlayer * mp);
    
/*
    Function: play
    Should attempt to start playing the resource from the current position. If the
    current position is at the end of the stream, this call should succeed and
    <tp_media_player_end_of_stream> should be called.
    
    Parameters:

    mp -    The TPMediaPlayer instance.
    
    Returns:
    
    0 -     Playback has started without problems. The media player will switch to
            PLAYING state and can call <tp_media_player_error> or
            <tp_media_player_end_of_stream>.
            
    other - Playback failed to start. The state will remain READY or PAUSED and
            no callbacks can be invoked.
    
    Valid States:
    
    - READY
    - PAUSED
*/
    
    int (*play)(TPMediaPlayer * mp);
    
/*
    Function: seek
    Should attempt to seek to the given position (in seconds) within the stream.
    If the media player is in either READY or PAUSED states, the new position
    should be noted by the media player - and clamped if out of range - but the
    media player should do nothing else until <play> is called. Even if the new
    position is at the end of the stream, the media player should not invoke
    <tp_media_player_end_of_stream> within this call; it should only do so as
    a result of playing the stream.
    
    In all cases, the state will remain as it was.
    
    Parameters:
    
    mp -        The TPMediaPlayer instance.
    
    seconds -   A position, in seconds, within the stream. This parameters will
                always be greater than or equal to zero. If it is greater than
                the duration of the stream, it should be clamped.
                
    Returns:
    
    0 -     The seek operation has started successfully.
    
    other - For whatever reason, the media player cannot seek.
    
    Valid States:
    
    - READY
    - PLAYING
    - PAUSED
*/
    
    int (*seek)(TPMediaPlayer * mp,double seconds);
    
/*
    Function: pause
    Should attempt to pause the stream. If the playback rate is anything other than
    one, it should be reset to 1.
    
    Parameters:

    mp -    The TPMediaPlayer instance.
    
    Returns:
    
    0 -     The stream was paused and the state will switch to PAUSED.
    
    other - There was a problem pausing the stream and the state will remain PLAYING.
    
    Valid States:
    
    - PLAYING
*/

    int (*pause)(TPMediaPlayer * mp);
    
/*
    Function: set_playback_rate
    Should attempt to change the playback rate. Playback rates are integers denoting
    a speed multiplier. Negative playback rates should play backward. Zero is not
    a valid playback rate.
    
    Parameters:

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

    int (*set_playback_rate)(TPMediaPlayer * mp,int rate);
    
/*
    Function: get_position
    Should return the current playback position, in seconds, within the stream.
    
    Parameters:

    mp -        The TPMediaPlayer instance.

    seconds -   A pointer to hold the playback position.
    
    Returns:

    0 -     The position is known and was returned.

    other - The position is not known.
    
    Valid States:
    
    - READY
    - PLAYING
    - PAUSED
*/

    int (*get_position)(TPMediaPlayer * mp,double * seconds);
    
/*
    Function: get_duration
    Should return the duration of the stream, in seconds. 

    Parameters:

    mp -        The TPMediaPlayer instance.

    seconds -   A pointer to hold the stream duration.
    
    Returns:
    
    0 -     The duration is known and was returned.

    other - The duration is not known.
    
    Valid States:
    
    - READY
    - PLAYING
    - PAUSED
*/

    int (*get_duration)(TPMediaPlayer * mp,double * seconds);
    
/*
    Function: get_buffered_duration
    Returns two markers that denote the portion of the stream that is currently
    buffered, in seconds. 
    
    Parameters:
    
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
    
    - READY
    - PLAYING
    - PAUSED
*/

    int (*get_buffered_duration)(TPMediaPlayer * mp,double * start_seconds,double * end_seconds);
/*
    Function: get_video_size
    Returns the size of the video stream, if any. This is not the size of the view
    port used to display the video, but the actual resolution of the video itself.
        
    Parameters:
    
    mp -        The TPMediaPlayer instance.

    width -     A pointer to hold the width of the video.

    height -    A pointer to hold the height of the video.
                    
    Returns:
    
    0 -     The video size is known and both width and height were set.
            
    other - The video size is not known or the stream contains no video.
    
    Valid States:
    
    - READY
    - PLAYING
    - PAUSED
*/

    int (*get_video_size)(TPMediaPlayer * mp,int * width,int * height);
    
/*
    Function: get_viewport_geometry
    Returns the position and size, in pixels, of the viewport used to play video.
    
    Parameters:
    
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
    - READY
    - PLAYING
    - PAUSED    
*/

    int (*get_viewport_geometry)(TPMediaPlayer * mp,int * left,int * top,int * width,int * height);
    
/*
    Function: set_viewport_geometry
    Sets the position and size of the viewport.
    
    Parameters:
    
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
    - READY
    - PLAYING
    - PAUSED    
*/

    int (*set_viewport_geometry)(TPMediaPlayer * mp,int left,int top,int width,int height);
    
/*
    Function: get_media_type
    Returns the type of media; whether it has audio, video or both.
    
    Parameters:
    
    mp  -       The TPMediaPlayer instance.
    
    type -      A pointer to hold the type.
    
    Returns:
    
    0 -         The media type is known and type was set.
    
    other -     The media type is not known.
    
    Valid States:
    
    - READY
    - PLAYING
    - PAUSED
*/

    int (*get_media_type)(TPMediaPlayer * mp,int * type);

/*
    Function: get_media_tags
    TODO
*/

/*
    Function: get_audio_volume
    Returns the current audio volume as a floating point number between 0 and
    1, where 0 is the lowest volume.
    
    Parameters:
    
    mp  -       The TPMediaPlayer instance.
    
    volume -    A pointer to hold the volume.
    
    Returns:
    
    0 -         The volume is known and was set.
    
    other -     The volume is not known.
    
    Valid States:
    
    - IDLE
    - LOADING
    - READY
    - PLAYING
    - PAUSED
*/

    int (*get_audio_volume)(TPMediaPlayer * mp,double * volume);

/*
    Function: set_audio_volume
    Sets the audio volume as a floating point number between 0 and
    1, where 0 is the lowest volume.
    
    Parameters:
    
    mp  -       The TPMediaPlayer instance.
    
    volume -    The new volume, between 0 and 1 inclusive.
    
    Returns:
    
    0 -         The volume was set.
    
    other -     There was a problem setting the volume.
    
    Valid States:
    
    - IDLE
    - LOADING
    - READY
    - PLAYING
    - PAUSED
*/

    int (*set_audio_volume)(TPMediaPlayer * mp,double volume);


/*
    Function: get_audio_mute
    Returns a value indicating whether audio is muted.
    
    Parameters:
    
    mp  -       The TPMediaPlayer instance.
    
    mute -      Whether audio is muted. A value of zero, means audio is NOT muted;
                anything else means it is MUTED.
    
    Returns:
    
    0 -         Mute was set successfully.
    
    other -     There was a problem getting the mute value.
    
    Valid States:
    
    - IDLE
    - LOADING
    - READY
    - PLAYING
    - PAUSED
*/

    int (*get_audio_mute)(TPMediaPlayer * mp,int * mute);


/*
    Function: set_audio_mute
    Mutes audio.
    
    Parameters:
    
    mp  -       The TPMediaPlayer instance.
    
    mute -      Whether audio should be muted. A value of zero, means audio should
                NOT be muted; anything else means it should be MUTED.
    
    Returns:
    
    0 -         Mute was set successfully.
    
    other -     There was a problem setting the mute value.
    
    Valid States:
    
    - IDLE
    - LOADING
    - READY
    - PLAYING
    - PAUSED
*/

    int (*set_audio_mute)(TPMediaPlayer * mp,int mute);
    
/*
    Function: get_viewport_texture
    Should return NULL.
*/

    void * (*get_viewport_texture)(TPMediaPlayer * mp);
    
};


#ifdef __cplusplus
}
#endif 

#endif  // TP_MEDIAPLAYER_H