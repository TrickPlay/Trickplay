
#include "glib-object.h"

#include "mediaplayers.h"
#include "util.h"

//=============================================================================

MediaPlayer::Event * MediaPlayer::Event::make(Type type,int code,const gchar * message,const gchar * value)
{
    Event * result=(Event*)g_malloc(sizeof(Event));
    result->type=type;
    result->code=code;
    result->message=message?g_strdup(message):NULL;
    result->value=value?g_strdup(value):NULL;
    return result;
}

void MediaPlayer::Event::destroy(Event * event)
{
    g_assert(event);
    g_free(event->message);
    g_free(event->value);
    g_free(event);
}

//=============================================================================

#define MPLOCK Util::GSRMutexLock lock(&mutex)

//-----------------------------------------------------------------------------
// Allocates a new wrapper and invokes the outside world's media player
// constructor function to initialize the media player. If that fails,
// return NULL. Sets up the wrapper and returns a new MediaPlayer instance.


MediaPlayer * MediaPlayer::make(TPMediaPlayerConstructor constructor)
{
    if (!constructor)
        return NULL;
    
    Wrapper * wrapper=(Wrapper*)g_malloc0(sizeof(Wrapper));
    
    TPMediaPlayer * mp=&wrapper->mp;
    
    wrapper->marker=mp;
    
    g_debug("MP[%p] <- constructor",mp);
    
    if (int result=constructor(mp))
    {
        // Construction failed
        
        g_warning("MP[%p]    FAILED %d",mp,result);
        
        g_free(wrapper);
        return NULL;
    }

    return new MediaPlayer(wrapper);
}

//-----------------------------------------------------------------------------

MediaPlayer::MediaPlayer(Wrapper * w)
:
    wrapper(w),
    state(TP_MEDIAPLAYER_IDLE),
    queue(g_async_queue_new_full((GDestroyNotify)Event::destroy)),
    delegate(NULL)
{
    g_assert(wrapper);
    wrapper->player=this;
    
    g_static_rec_mutex_init(&mutex);
}

//-----------------------------------------------------------------------------

MediaPlayer::~MediaPlayer()
{
    {
        MPLOCK;
        
        check(TP_MEDIAPLAYER_ANY_STATE);
    
        // Reset to return state to IDLE
        
        reset();
        
        if (wrapper->mp.destroy)
        {
            g_debug("MP[%p] <- destroy",get_mp());
            wrapper->mp.destroy(get_mp());        
        }
        
        wrapper->marker=NULL;
        wrapper->player=NULL;
    
        g_free(wrapper);
    
        wrapper=NULL;
        
        clear_events();
    
        g_async_queue_unref(queue);
    }
    
    g_static_rec_mutex_free(&mutex);
}

//-----------------------------------------------------------------------------
// Given a TPMediaPlayer pointer, this casts it to a Wrapper pointer and
// ensures that everything is in order. This relies on the TPMediaPlayer pointer
// having the same address as its wrapper.
//
// Very pedantic, but better safe than sorry when these come from the outside
// world.

MediaPlayer * MediaPlayer::get(TPMediaPlayer * mp)
{
    g_assert(mp);
    Wrapper * wrapper=(Wrapper*)mp;
    g_assert(&wrapper->mp==mp);
    g_assert(wrapper->marker==mp);
    g_assert(wrapper->player);
    g_assert(wrapper->player->wrapper==wrapper);
    
    return wrapper->player;
}

//-----------------------------------------------------------------------------

TPMediaPlayer * MediaPlayer::get_mp()
{
    return &wrapper->mp;
}

//-----------------------------------------------------------------------------

void MediaPlayer::check(int valid_states)
{
    g_assert(wrapper);
    g_assert(wrapper->marker==&wrapper->mp);
    g_assert(wrapper->player==this);
    
    if (!(state&valid_states))
        g_error("MP[%p]   INVALID STATE %d",get_mp(),state);
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_state()
{
    MPLOCK;
    check(TP_MEDIAPLAYER_ANY_STATE);
    return state;
}

//-----------------------------------------------------------------------------

void MediaPlayer::reset()
{
    MPLOCK;
    
    if (state==TP_MEDIAPLAYER_IDLE)
        return;
    
    if (wrapper->mp.reset)
    {
        g_debug("MP[%p] <- reset",get_mp());
        
        check(TP_MEDIAPLAYER_LOADING|TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED);
        
        wrapper->mp.reset(get_mp());
    }
    
    // Flush all pending events
    
    clear_events();
        
    // Clear tags
    
    tags.clear();
    
    state=TP_MEDIAPLAYER_IDLE;
}

//-----------------------------------------------------------------------------

int MediaPlayer::load(const char * uri,const char * extra)
{
    MPLOCK;
    
    // Get us back to IDLE
    
    reset();
    
    TPMediaPlayer * mp=get_mp();
    
    if (!mp->load)
    {
        g_warning("MP[%p]    load NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- load('%s','%s')",mp,uri,extra);
    
    if (int result=mp->load(mp,uri,extra))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    state=TP_MEDIAPLAYER_LOADING;
    
    return 0;
}

//-----------------------------------------------------------------------------

int MediaPlayer::play()
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    if (!(state&(TP_MEDIAPLAYER_PAUSED)))
    {
        g_warning("MP[%p]    play CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->play)
    {
        g_warning("MP[%p]    play NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- play",mp);
    
    if (int result=mp->play(mp))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    state=TP_MEDIAPLAYER_PLAYING;
    
    return 0;
}

//-----------------------------------------------------------------------------

int MediaPlayer::seek(double seconds)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();
    
    if (!(state&(TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)))
    {
        g_warning("MP[%p]    seek CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->seek)
    {
        g_warning("MP[%p]    seek NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- seek(%f)",mp,seconds);
    
    if (int result=mp->seek(mp,seconds))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    return 0;    
}

//-----------------------------------------------------------------------------

int MediaPlayer::pause()
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    if (!(state&(TP_MEDIAPLAYER_PLAYING)))
    {
        g_warning("MP[%p]    pause CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->pause)
    {
        g_warning("MP[%p]    pause NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- pause",mp);
    
    if (int result=mp->pause(mp))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    state=TP_MEDIAPLAYER_PAUSED;
    
    return 0;
}

//-----------------------------------------------------------------------------

int MediaPlayer::set_playback_rate(int rate)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    if (rate==0)
    {
        g_warning("MP[%p]    set_playback_rate CALLED WITH INVALID RATE %d",mp,rate);
        return TP_MEDIAPLAYER_ERROR_BAD_PARAMETER;
    }
    
    if (!(state&(TP_MEDIAPLAYER_PLAYING)))
    {
        g_warning("MP[%p]    set_playback_rate CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->set_playback_rate)
    {
        g_warning("MP[%p]    set_playback_rate NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- set_playback_rate(%d)",mp,rate);
    
    if (int result=mp->set_playback_rate(mp,rate))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    return 0;
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_position(double * seconds)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(seconds);
   
    if (!(state&(TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)))
    {
        g_warning("MP[%p]    get_position CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->get_position)
    {
        g_warning("MP[%p]    get_position NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_position",mp);
    
    if (int result=mp->get_position(mp,seconds))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %f",mp,*seconds);
    
    return 0;    
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_duration(double * seconds)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(seconds);
   
    if (!(state&(TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)))
    {
        g_warning("MP[%p]    get_duration CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->get_duration)
    {
        g_warning("MP[%p]    get_duration NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_duration",mp);
    
    if (int result=mp->get_duration(mp,seconds))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %f",mp,*seconds);
    
    return 0;    
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_buffered_duration(double * start_seconds,double * end_seconds)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(start_seconds);
    g_assert(end_seconds);
   
    if (!(state&(TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)))
    {
        g_warning("MP[%p]    get_buffered_duration CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->get_buffered_duration)
    {
        g_warning("MP[%p]    get_buffered_duration NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_buffered_duration",mp);
    
    if (int result=mp->get_buffered_duration(mp,start_seconds,end_seconds))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %f,%f",mp,*start_seconds,*end_seconds);
    
    return 0;        
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_video_size(int * width,int * height)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(width);
    g_assert(height);
   
    if (!(state&(TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)))
    {
        g_warning("MP[%p]    get_video_size CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->get_video_size)
    {
        g_warning("MP[%p]    get_video_size NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_video_size",mp);
    
    if (int result=mp->get_video_size(mp,width,height))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %d,%d",mp,*width,*height);
    
    return 0;                
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_viewport_geometry(int * left,int * top,int * width,int * height)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(left);
    g_assert(top);
    g_assert(width);
    g_assert(height);
   
    if (!mp->get_viewport_geometry)
    {
        g_warning("MP[%p]    get_viewport_geometry NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_viewport_geometry",mp);
    
    if (int result=mp->get_viewport_geometry(mp,left,top,width,height))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %d,%d,%d,%d",mp,*left,*top,*width,*height);
    
    return 0;                    
}

//-----------------------------------------------------------------------------

int MediaPlayer::set_viewport_geometry(int left,int top,int width,int height)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();
    
    if (width<0)
    {
        g_warning("MP[%p]    set_viewport_geometry CALLED WITH INVALID WIDTH %d",mp,width);
        return TP_MEDIAPLAYER_ERROR_BAD_PARAMETER;        
    }
    
    if (height<0)
    {
        g_warning("MP[%p]    set_viewport_geometry CALLED WITH INVALID HEIGHT %d",mp,height);
        return TP_MEDIAPLAYER_ERROR_BAD_PARAMETER;        
    }
  
    if (!mp->set_viewport_geometry)
    {
        g_warning("MP[%p]    set_viewport_geometry NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- set_viewport_geometry(%d,%d,%d,%d)",mp,left,top,width,height);
    
    if (int result=mp->set_viewport_geometry(mp,left,top,width,height))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    return 0;                    
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_media_type(int * type)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(type);
   
    if (!(state&(TP_MEDIAPLAYER_PLAYING|TP_MEDIAPLAYER_PAUSED)))
    {
        g_warning("MP[%p]    get_media_type CALLED IN INVALID STATE",mp);
        return TP_MEDIAPLAYER_ERROR_INVALID_STATE;
    }
    
    if (!mp->get_media_type)
    {
        g_warning("MP[%p]    get_media_type NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_media_type",mp);
    
    if (int result=mp->get_media_type(mp,type))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %d",mp,*type);
    
    return 0;                
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_audio_volume(double * volume)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(volume);
   
    if (!mp->get_audio_volume)
    {
        g_warning("MP[%p]    get_audio_volume NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_audio_volume",mp);
    
    if (int result=mp->get_audio_volume(mp,volume))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %f",mp,*volume);
    
    if (*volume<0)
        *volume=0;
    else if (*volume>1)
        *volume=1;
    
    return 0;                    
}

//-----------------------------------------------------------------------------

int MediaPlayer::set_audio_volume(double volume)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    if (!mp->set_audio_volume)
    {
        g_warning("MP[%p]    set_audio_volume NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    if (volume<0)
        volume=0;
    else if (volume>1)
        volume=1;
    
    g_debug("MP[%p] <- set_audio_volume(%f)",mp,volume);
    
    if (int result=mp->set_audio_volume(mp,volume))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    return 0;                        
}

//-----------------------------------------------------------------------------

int MediaPlayer::get_audio_mute(int * mute)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    g_assert(mute);
   
    if (!mp->get_audio_mute)
    {
        g_warning("MP[%p]    get_audio_mute NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    g_debug("MP[%p] <- get_audio_mute",mp);
    
    if (int result=mp->get_audio_mute(mp,mute))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    g_debug("MP[%p]    RETURNED %d",mp,*mute);
        
    return 0;                    
}

//-----------------------------------------------------------------------------

int MediaPlayer::set_audio_mute(int mute)
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();

    if (!mp->set_audio_mute)
    {
        g_warning("MP[%p]    set_audio_mute NOT IMPLEMENTED",mp);
        return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;
    }
    
    if (mute!=0)
        mute=1;
    
    g_debug("MP[%p] <- set_audio_mute(%d)",mp,mute);
    
    if (int result=mp->set_audio_mute(mp,mute))
    {
        g_warning("MP[%p]    FAILED %d",mp,result);
        return result;
    }
    
    return 0;                        
}

//-----------------------------------------------------------------------------

void * MediaPlayer::get_viewport_texture()
{
    MPLOCK;
    
    TPMediaPlayer * mp=get_mp();
    
    if (!mp->get_viewport_texture)
        return NULL;
    
    return mp->get_viewport_texture(mp);
}


//=============================================================================
// Called by external callbacks - they all push an event into the queue

void MediaPlayer::loaded()
{
    post_event(Event::make(Event::LOADED));
}

//-----------------------------------------------------------------------------

void MediaPlayer::error(int code,const char * message)
{
    post_event(Event::make(Event::ERROR,code,message));
}

//-----------------------------------------------------------------------------

void MediaPlayer::end_of_stream()
{
    post_event(Event::make(Event::EOS));
}

//-----------------------------------------------------------------------------

void MediaPlayer::tag_found(const char * name,const char * value)
{
    post_event(Event::make(Event::TAG,0,name,value));    
}

//-----------------------------------------------------------------------------
// Puts the event in the queue and adds an idle source that will process
// events in the main thread

void MediaPlayer::post_event(Event * event)
{
    g_async_queue_push(queue,event);
    
    GSource * source = g_idle_source_new();
    g_source_set_callback(source,process_events,this,NULL);
    g_source_attach(source,g_main_context_default());
    g_source_unref(source);        
}

//-----------------------------------------------------------------------------
// Process the events

gboolean MediaPlayer::process_events(gpointer data)
{
    ((MediaPlayer*)data)->process_events();
    return FALSE;
}

//-----------------------------------------------------------------------------

void MediaPlayer::process_events()
{
    MPLOCK;
    
    while(Event * event=(Event*)g_async_queue_try_pop(queue))
    {
        switch(event->type)
        {
            case Event::LOADED:
                
                if (state==TP_MEDIAPLAYER_LOADING)
                {
                    state=TP_MEDIAPLAYER_PAUSED;

                    if (delegate)
                        delegate->loaded(this);
                }
                break;
            
            case Event::ERROR:
                
                if (state==TP_MEDIAPLAYER_LOADING)
                {
                    // Take it back to IDLE
                    reset();
                    
                    if (delegate)
                        delegate->error(this,event->code,event->message);
                }
                else if (state==TP_MEDIAPLAYER_PLAYING)
                {
                    state=TP_MEDIAPLAYER_PAUSED;
                    
                    if (delegate)
                        delegate->error(this,event->code,event->message);
                }
                break;
            
            case Event::EOS:
                
                if (state==TP_MEDIAPLAYER_PLAYING)
                {                    
                    state=TP_MEDIAPLAYER_PAUSED;
                    
                    if (delegate)
                        delegate->end_of_stream(this);
                }
                break;
            
            case Event::TAG:
                
                if (state==TP_MEDIAPLAYER_LOADING)
                {
                    tags.push_back(std::make_pair(String(event->message),String(event->value)));
                }
        }
        
        Event::destroy(event);
    }
}

//-----------------------------------------------------------------------------

void MediaPlayer::clear_events()
{
    while (Event * event=(Event*)g_async_queue_try_pop(queue))
    {
        Event::destroy(event);
    }
}

//-----------------------------------------------------------------------------

void MediaPlayer::set_delegate(Delegate * new_delegate)
{
    MPLOCK;
    delegate=new_delegate;
}

//=============================================================================
// External callbacks
//=============================================================================

int tp_media_player_get_state(TPMediaPlayer * mp)
{
    g_debug("MP[%p] -> tp_media_player_get_state",mp);
    return MediaPlayer::get(mp)->get_state();    
}

//-----------------------------------------------------------------------------

void tp_media_player_loaded(TPMediaPlayer * mp)
{
    g_debug("MP[%p] -> tp_media_player_loaded",mp);
    MediaPlayer::get(mp)->loaded();
}

//-----------------------------------------------------------------------------

void tp_media_player_error(TPMediaPlayer * mp,int code,const char * message)
{
    g_debug("MP[%p] -> tp_media_player_error:%d:%s",mp,code,message);
    MediaPlayer::get(mp)->error(code,message);
}


//-----------------------------------------------------------------------------

void tp_media_player_end_of_stream(TPMediaPlayer * mp)
{
    g_debug("MP[%p] -> tp_media_player_end_of_stream",mp);
    MediaPlayer::get(mp)->end_of_stream();
}

//-----------------------------------------------------------------------------

void tp_media_player_tag_found(TPMediaPlayer * mp,const char * name,const char * value)
{
    g_debug("MP[%p] -> tp_media_player_tag_found:'%s':'%s'",mp,name,value);
    if (name&&value)
        MediaPlayer::get(mp)->tag_found(name,value);
}

