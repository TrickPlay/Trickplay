#include "nexus_platform.h"
#include "nexus_core_utils.h"
#include "nexus_video_decoder.h"
#include "nexus_video_decoder_trick.h"
#include "nexus_video_adj.h"
#include "nexus_stc_channel.h"
#include "nexus_display.h"
#include "nexus_display_vbi.h"
#include "nexus_video_window.h"
#include "nexus_video_input.h"
#include "nexus_audio_dac.h"
#include "nexus_audio_decoder.h"
#include "nexus_audio_decoder_trick.h"
#include "nexus_audio_output.h"
#include "nexus_audio_input.h"
#include "nexus_audio_playback.h"
#include "nexus_spdif_output.h"
#include "nexus_component_output.h"
#include "nexus_surface.h"
#if NEXUS_HAS_PLAYBACK
#include "nexus_playback.h"
#include "nexus_file.h"
#endif
#if NEXUS_DTV_PLATFORM
#include "nexus_platform_boardcfg.h"
#endif

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

#include "cmdline_args.h"

#include "trickplay/mediaplayer.h"

/*===========================================================================*/

static void start_video(const struct util_opts_t *opts, NEXUS_VideoDecoderHandle videoDecoder, const NEXUS_VideoDecoderStartSettings *videoProgram)
{
    NEXUS_Error rc;
    if (opts->videoPid) {
        rc = NEXUS_VideoDecoder_Start(videoDecoder, videoProgram);
        BDBG_ASSERT(!rc);
    }
    return;
}
static void stop_video(const struct util_opts_t *opts, NEXUS_VideoDecoderHandle videoDecoder)
{
    if (opts->videoPid) {
        NEXUS_VideoDecoder_Stop(videoDecoder);
    }
    return;
}

static void start_audio(const struct util_opts_t *opts, NEXUS_AudioDecoderHandle audioDecoder, NEXUS_AudioDecoderHandle compressedDecoder, const NEXUS_AudioDecoderStartSettings *audioProgram)
{
    NEXUS_Error rc;
    if (opts->audioPid) {
#if B_HAS_ASF
        /* if DRC for WMA pro is available apply now */
        if(audioProgram->codec == NEXUS_AudioCodec_eWmaPro && opts->dynamicRangeControlValid ){

            NEXUS_AudioDecoderCodecSettings codecSettings;

            BDBG_WRN(("wma-pro drc enabled,ref peak %d,ref target %d,ave peak %d, ave target %d",
                      opts->dynamicRangeControl.peakReference,opts->dynamicRangeControl.peakTarget,
                      opts->dynamicRangeControl.averageReference,opts->dynamicRangeControl.averageTarget));
            NEXUS_AudioDecoder_GetCodecSettings(audioDecoder, audioProgram->codec, &codecSettings);
            codecSettings.codec = audioProgram->codec;
            codecSettings.codecSettings.wmaPro.dynamicRangeControlValid = true;
            codecSettings.codecSettings.wmaPro.dynamicRangeControl.peakReference = opts->dynamicRangeControl.peakReference;
            codecSettings.codecSettings.wmaPro.dynamicRangeControl.peakTarget = opts->dynamicRangeControl.peakTarget;
            codecSettings.codecSettings.wmaPro.dynamicRangeControl.averageReference = opts->dynamicRangeControl.averageReference;
            codecSettings.codecSettings.wmaPro.dynamicRangeControl.averageTarget = opts->dynamicRangeControl.averageTarget;
            NEXUS_AudioDecoder_SetCodecSettings(audioDecoder,&codecSettings);
            }
#endif
        if(opts->decodedAudio) {
            rc = NEXUS_AudioDecoder_Start(audioDecoder, audioProgram);
            BDBG_ASSERT(!rc);
        }
        if(compressedDecoder) {
            rc = NEXUS_AudioDecoder_Start(compressedDecoder, audioProgram);
            BDBG_ASSERT(!rc);
        }
    }
    return;
}

static void stop_audio(const struct util_opts_t *opts, NEXUS_AudioDecoderHandle audioDecoder, NEXUS_AudioDecoderHandle compressedDecoder)
{
    if (opts->audioPid) {
        if(opts->decodedAudio) {
            NEXUS_AudioDecoder_Stop(audioDecoder);
        }
        if(compressedDecoder) {
            NEXUS_AudioDecoder_Stop(compressedDecoder);
        }
    }
    return;
}

/*===========================================================================*/


extern NEXUS_DisplayHandle           nexus_display;
extern NEXUS_PlatformConfiguration   platform_config;

struct nmp_t
{
    TPMediaPlayer *                     mp;
    
    struct util_opts_t                  opts;
    
    NEXUS_Rect                          viewport;
    
    NEXUS_PidChannelHandle              videoPidChannel;
    NEXUS_PidChannelHandle              audioPidChannel;
    NEXUS_PidChannelHandle              pcrPidChannel;
    NEXUS_StcChannelHandle              stcChannel;
    NEXUS_StcChannelSettings            stcSettings;
    NEXUS_VideoWindowHandle             window;
    NEXUS_VideoWindowSettings           windowSettings;
    NEXUS_VideoDecoderHandle            videoDecoder;
    NEXUS_VideoDecoderStartSettings     videoProgram;
    NEXUS_AudioDecoderHandle            audioDecoder;
    NEXUS_AudioDecoderStartSettings     audioProgram;
    NEXUS_FilePlayHandle                file;
    NEXUS_PlaypumpHandle                playpump;
    NEXUS_PlaybackHandle                playback;
    NEXUS_PlaybackSettings              playbackSettings;
    NEXUS_PlaybackPidChannelSettings    playbackPidSettings;
    NEXUS_PlaybackStartSettings         playbackStartSettings;
    NEXUS_VideoDecoderOpenSettings      openSettings;
    NEXUS_AudioDecoderOpenSettings      audioDecoderOpenSettings;    
};

typedef struct nmp_t NMP;

static NMP * get_nmp( TPMediaPlayer * mp )
{
    BDBG_ASSERT( mp );
    BDBG_ASSERT( mp->user_data );
    
    return ( NMP * ) mp->user_data;    
}

/*---------------------------------------------------------------------------*/

static void nmp_end_of_stream_callback( void * context , int param )
{
    BSTD_UNUSED(param);
    
    NMP * nmp = ( NMP * ) context;
    
    tp_media_player_end_of_stream( nmp->mp );    
}

static void nmp_error_callback( void * context , int param )
{
    BSTD_UNUSED(param);
    
    NMP * nmp = ( NMP * ) context;
    
    tp_media_player_error( nmp->mp , 1000 , "" );        
}

/*---------------------------------------------------------------------------*/

static void nmp_destroy( TPMediaPlayer * mp )
{
    free( get_nmp( mp ) );
}

/*---------------------------------------------------------------------------*/

static int nmp_load( TPMediaPlayer * mp , const char * uri , const char * extra )
{
    NMP * nmp = get_nmp( mp );

    int result = 0;
    
    /* Only support file URIs so far */
    
    if ( strncmp( uri , "file://" , 7 ) )
    {
        return TP_MEDIAPLAYER_ERROR_NA;
    }
    
    const char * fake_argv[] = { "" , uri + 7 };
    
    if ( cmdline_parse( 2 , fake_argv , & nmp->opts ) )
    {
        return 1;
    }
    
    if ( cmdline_probe( & nmp->opts ) )
    {
        return 2;
    }
    
    if ((nmp->opts.indexname && !strcmp(nmp->opts.indexname, "same")) ||
        nmp->opts.transportType == NEXUS_TransportType_eMkv ||
        nmp->opts.transportType == NEXUS_TransportType_eMp4
        )
    {
        nmp->opts.indexname = nmp->opts.filename;
    }
    
    
    nmp->file = NEXUS_FilePlay_OpenPosix( nmp->opts.filename , nmp->opts.indexname );
    
    if ( ! nmp->file )
    {
        return 3;    
    }
    
    nmp->playpump = NEXUS_Playpump_Open( 0 , NULL );
    nmp->playback = NEXUS_Playback_Create();
    
    BDBG_ASSERT( nmp->playpump );
    BDBG_ASSERT( nmp->playback );
    
    NEXUS_StcChannel_GetDefaultSettings(0, &nmp->stcSettings);
    nmp->stcSettings.timebase = NEXUS_Timebase_e0;
    nmp->stcSettings.mode = NEXUS_StcChannelMode_eAuto;
    nmp->stcSettings.modeSettings.Auto.behavior = nmp->opts.stcChannelMaster;
    nmp->stcChannel = NEXUS_StcChannel_Open(0, &nmp->stcSettings);
    
    NEXUS_Error rc;
    
    NEXUS_Playback_GetSettings(nmp->playback, &nmp->playbackSettings);
    nmp->playbackSettings.playpump = nmp->playpump;
    nmp->playbackSettings.playpumpSettings.transportType = nmp->opts.transportType;
    nmp->playbackSettings.playpumpSettings.timestamp.pacing = false;
    nmp->playbackSettings.playpumpSettings.timestamp.type = nmp->opts.tsTimestampType;
    nmp->playbackSettings.startPaused = true;
    nmp->playbackSettings.stcChannel = nmp->stcChannel;
    nmp->playbackSettings.stcTrick = nmp->opts.stcTrick;
    nmp->playbackSettings.beginningOfStreamAction = NEXUS_PlaybackLoopMode_ePause;
    nmp->playbackSettings.endOfStreamAction = NEXUS_PlaybackLoopMode_ePause;
    nmp->playbackSettings.endOfStreamCallback.callback = nmp_end_of_stream_callback;
    nmp->playbackSettings.endOfStreamCallback.context = nmp;
    nmp->playbackSettings.errorCallback.callback = nmp_error_callback;
    nmp->playbackSettings.errorCallback.context = nmp;
    nmp->playbackSettings.parsingErrorCallback.callback = nmp_error_callback;
    nmp->playbackSettings.parsingErrorCallback.context = nmp;
    
    nmp->playbackSettings.enableStreamProcessing = nmp->opts.streamProcessing;
    rc = NEXUS_Playback_SetSettings(nmp->playback, &nmp->playbackSettings);
    BDBG_ASSERT(!rc);
    
    NEXUS_AudioDecoder_GetDefaultOpenSettings(&nmp->audioDecoderOpenSettings);
    if(nmp->opts.audioCdb)
    {
        nmp->audioDecoderOpenSettings.fifoSize = nmp->opts.audioCdb*1024;
    }
    nmp->audioDecoder = NEXUS_AudioDecoder_Open(0, &nmp->audioDecoderOpenSettings);
    BDBG_ASSERT(nmp->audioDecoder);
    
    if (nmp->opts.audioPid)
    {
        rc = NEXUS_AudioOutput_AddInput(
            NEXUS_AudioDac_GetConnector(platform_config.outputs.audioDacs[0]),
            NEXUS_AudioDecoder_GetConnector(nmp->audioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));
        BDBG_ASSERT(!rc);
    }
    
    rc = NEXUS_AudioOutput_AddInput(
        NEXUS_SpdifOutput_GetConnector(platform_config.outputs.spdif[0]),
        NEXUS_AudioDecoder_GetConnector(nmp->audioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));
    BDBG_ASSERT(!rc);

    nmp->window = NEXUS_VideoWindow_Open(nexus_display, 0);

    NEXUS_VideoWindow_GetSettings(nmp->window, &nmp->windowSettings);
    nmp->windowSettings.contentMode = nmp->opts.contentMode;
    /*
    printf( "%d - %d - %d - %d\n" , nmp->windowSettings.position.x, nmp->windowSettings.position.y,nmp->windowSettings.position.width,nmp->windowSettings.position.height);
    */
    nmp->windowSettings.position = nmp->viewport;
    rc = NEXUS_VideoWindow_SetSettings(nmp->window, &nmp->windowSettings);
    BDBG_ASSERT(!rc);
    
    NEXUS_VideoDecoder_GetDefaultOpenSettings(&nmp->openSettings);
    if(nmp->opts.videoCdb)
    {
        nmp->openSettings.fifoSize = nmp->opts.videoCdb*1024;
    }
    
    if(nmp->opts.avc51)
    {
        nmp->openSettings.avc51Enabled = nmp->opts.avc51;
    }
    
    nmp->videoDecoder = NEXUS_VideoDecoder_Open(nmp->opts.videoDecoder, &nmp->openSettings);
    rc = NEXUS_VideoWindow_AddInput(nmp->window, NEXUS_VideoDecoder_GetConnector(nmp->videoDecoder));
    BDBG_ASSERT(!rc);
    
    
    if (nmp->opts.videoCodec != NEXUS_VideoCodec_eNone && nmp->opts.videoPid!=0)
    {
        NEXUS_Playback_GetDefaultPidChannelSettings(&nmp->playbackPidSettings);
        nmp->playbackPidSettings.pidSettings.pidType = NEXUS_PidType_eVideo;
        nmp->playbackPidSettings.pidSettings.allowTimestampReordering = nmp->opts.playpumpTimestampReordering;
        nmp->playbackPidSettings.pidTypeSettings.video.decoder = nmp->videoDecoder;
        nmp->playbackPidSettings.pidTypeSettings.video.index = true;
        nmp->playbackPidSettings.pidTypeSettings.video.codec = nmp->opts.videoCodec;
        nmp->videoPidChannel = NEXUS_Playback_OpenPidChannel(nmp->playback, nmp->opts.videoPid, &nmp->playbackPidSettings);
    }

    if (nmp->opts.audioCodec != NEXUS_AudioCodec_eUnknown && nmp->opts.audioPid!=0)
    {
        NEXUS_Playback_GetDefaultPidChannelSettings(&nmp->playbackPidSettings);
        nmp->playbackPidSettings.pidSettings.pidType = NEXUS_PidType_eAudio;
        nmp->playbackPidSettings.pidTypeSettings.audio.primary = nmp->audioDecoder;
        nmp->playbackPidSettings.pidSettings.pidTypeSettings.audio.codec = nmp->opts.audioCodec;
        nmp->audioPidChannel = NEXUS_Playback_OpenPidChannel(nmp->playback, nmp->opts.audioPid, &nmp->playbackPidSettings);
    }

    if (nmp->opts.pcrPid && nmp->opts.pcrPid!=nmp->opts.videoPid && nmp->opts.pcrPid!=nmp->opts.audioPid)
    {
        NEXUS_Playback_GetDefaultPidChannelSettings(&nmp->playbackPidSettings);
        nmp->playbackPidSettings.pidSettings.pidType = NEXUS_PidType_eOther;
        nmp->pcrPidChannel = NEXUS_Playback_OpenPidChannel(nmp->playback, nmp->opts.pcrPid, &nmp->playbackPidSettings);
    }
    

    NEXUS_VideoDecoder_GetDefaultStartSettings(&nmp->videoProgram);
    nmp->videoProgram.codec = nmp->opts.videoCodec;
    nmp->videoProgram.pidChannel = nmp->videoPidChannel;
    nmp->videoProgram.stcChannel = nmp->stcChannel;
    nmp->videoProgram.frameRate = nmp->opts.videoFrameRate;
    nmp->videoProgram.aspectRatio = nmp->opts.aspectRatio;
    nmp->videoProgram.sampleAspectRatio.x = nmp->opts.sampleAspectRatio.x;
    nmp->videoProgram.sampleAspectRatio.y = nmp->opts.sampleAspectRatio.y;
    nmp->videoProgram.errorHandling = NEXUS_VideoDecoderErrorHandling_eNone;
    nmp->videoProgram.timestampMode = nmp->opts.decoderTimestampMode;
    
    NEXUS_AudioDecoder_GetDefaultStartSettings(&nmp->audioProgram);
    nmp->audioProgram.codec = nmp->opts.audioCodec;
    nmp->audioProgram.pidChannel = nmp->audioPidChannel;
    nmp->audioProgram.stcChannel = nmp->stcChannel;

    start_video( & nmp->opts , nmp->videoDecoder , & nmp->videoProgram );
    start_audio( & nmp->opts , nmp->audioDecoder , 0 , & nmp->audioProgram );

    NEXUS_Playback_GetDefaultStartSettings(&nmp->playbackStartSettings);
    if (nmp->opts.fixedBitrate)
    {
        nmp->playbackStartSettings.mode = NEXUS_PlaybackMode_eFixedBitrate;
        nmp->playbackStartSettings.bitrate = nmp->opts.fixedBitrate;
    }
    else if (nmp->opts.autoBitrate)
    {
        nmp->playbackStartSettings.mode = NEXUS_PlaybackMode_eAutoBitrate;
    }
    rc = NEXUS_Playback_Start(nmp->playback, nmp->file, &nmp->playbackStartSettings);
    BDBG_ASSERT(!rc);
    
    tp_media_player_loaded( mp );
    
    return result;
}

/*---------------------------------------------------------------------------*/

static void nmp_reset( TPMediaPlayer * mp )
{
    NMP * nmp = get_nmp( mp );
    
    NEXUS_Playback_Stop( nmp->playback );

    stop_video(&nmp->opts, nmp->videoDecoder);
    stop_audio(&nmp->opts, nmp->audioDecoder, 0);

    
    NEXUS_Playback_CloseAllPidChannels(nmp->playback);
    NEXUS_FilePlay_Close(nmp->file);
    NEXUS_Playback_Destroy(nmp->playback);
    NEXUS_Playpump_Close(nmp->playpump);


    NEXUS_VideoWindow_RemoveInput(nmp->window, NEXUS_VideoDecoder_GetConnector(nmp->videoDecoder));
    NEXUS_VideoInput_Shutdown(NEXUS_VideoDecoder_GetConnector(nmp->videoDecoder));
    NEXUS_VideoDecoder_Close(nmp->videoDecoder);
    NEXUS_VideoWindow_Close(nmp->window);

    NEXUS_AudioOutput_RemoveInput(
        NEXUS_AudioDac_GetConnector(platform_config.outputs.audioDacs[0]),
        NEXUS_AudioDecoder_GetConnector(nmp->audioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));
    NEXUS_AudioOutput_RemoveInput(
        NEXUS_SpdifOutput_GetConnector(platform_config.outputs.spdif[0]),
        NEXUS_AudioDecoder_GetConnector(nmp->audioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));
    
    NEXUS_AudioInput_Shutdown(NEXUS_AudioDecoder_GetConnector(nmp->audioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));
    NEXUS_AudioDecoder_Close(nmp->audioDecoder);
    
    memset( & nmp->opts , 0 , sizeof( nmp->opts ) );
}

/*---------------------------------------------------------------------------*/

static int nmp_play( TPMediaPlayer * mp )
{
    NMP * nmp = get_nmp( mp );
    
    NEXUS_Error rc;
    
    rc = NEXUS_Playback_Play( nmp->playback );
    
    return rc;
}

/*---------------------------------------------------------------------------*/

static int nmp_seek( TPMediaPlayer * mp , double seconds )
{
    NMP * nmp = get_nmp( mp );

    NEXUS_Error rc;
    
    rc = NEXUS_Playback_Seek( nmp->playback , seconds * 1000 );
    
    return rc;
}

/*---------------------------------------------------------------------------*/

static int nmp_pause( TPMediaPlayer * mp )
{
    NMP * nmp = get_nmp( mp );
    
    NEXUS_Error rc;
    
    rc = NEXUS_Playback_Pause( nmp->playback );
    
    return rc;
}

/*---------------------------------------------------------------------------*/

static int nmp_set_playback_rate( TPMediaPlayer * mp , int rate )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;    
}

/*---------------------------------------------------------------------------*/

static int nmp_get_position( TPMediaPlayer * mp , double * seconds )
{
    NMP * nmp = get_nmp( mp );
    
    NEXUS_PlaybackStatus status;
    
    NEXUS_Error rc;
    
    rc = NEXUS_Playback_GetStatus( nmp->playback , & status );
    
    if ( rc )
    {
        return rc;
    }
    
    * seconds = status.position / 1000.0;
    
    return 0;
}

/*---------------------------------------------------------------------------*/

static int nmp_get_duration( TPMediaPlayer * mp , double * seconds )
{
    NMP * nmp = get_nmp( mp );
    
    NEXUS_PlaybackStatus status;
    
    NEXUS_Error rc;
    
    rc = NEXUS_Playback_GetStatus( nmp->playback , & status );
    
    if ( rc )
    {
        return rc;
    }
    
    * seconds = status.last / 1000.0;
    
    return 0;
}

/*---------------------------------------------------------------------------*/

static int nmp_get_buffered_duration( TPMediaPlayer * mp , double * start_seconds , double * end_seconds )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;            
}

/*---------------------------------------------------------------------------*/

static int nmp_get_video_size( TPMediaPlayer * mp , int * width , int * height )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;                
}

/*---------------------------------------------------------------------------*/

static int nmp_get_viewport_geometry( TPMediaPlayer * mp,
        int * left,
        int * top,
        int * width,
        int * height)
{
    NMP * nmp = get_nmp( mp );
    
    * left = nmp->viewport.x;
    * top = nmp->viewport.y;
    * width = nmp->viewport.width;
    * height = nmp->viewport.height;
    
    return 0;                    
}

/*---------------------------------------------------------------------------*/

static int nmp_set_viewport_geometry( 
        TPMediaPlayer * mp,
        int left,
        int top,
        int width,
        int height)
{
    /*
    TODO: This doesn't seem to work right. The position appears to be relative
    to the bottom, left of the screen. When resized and repositioned, the
    video tends to get corrupted.
    */
    
    NMP * nmp = get_nmp( mp );
    
    NEXUS_Rect r;
    
    r.x = left;
    r.y = top;
    r.width = width;
    r.height = height;
    
    if ( nmp->window )
    {
        NEXUS_VideoWindowSettings settings;
        
        NEXUS_VideoWindow_GetSettings( nmp->window , & settings );
        settings.position = r;
        NEXUS_Error rc;
        rc = NEXUS_VideoWindow_SetSettings( nmp->window , & settings );
        if ( rc )
        {
            return rc;
        }
    }
    
    nmp->viewport = r;
    
    return 0;
}

/*---------------------------------------------------------------------------*/

static int nmp_get_media_type( TPMediaPlayer * mp , int * type )
{
    NMP * nmp = get_nmp( mp );
    
    * type = 0;
    
    if ( nmp->opts.videoCodec != NEXUS_VideoCodec_eUnknown )
    {
        * type |= TP_MEDIA_TYPE_VIDEO;
    }
    
    if ( nmp->opts.audioCodec != NEXUS_AudioCodec_eUnknown )
    {
        * type |= TP_MEDIA_TYPE_AUDIO;
    }
    
    return 0;
}

/*---------------------------------------------------------------------------*/

static int nmp_get_audio_volume( TPMediaPlayer * mp , double * volume )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;                            
}

/*---------------------------------------------------------------------------*/

static int nmp_set_audio_volume( TPMediaPlayer * mp , double volume )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;                                
}

/*---------------------------------------------------------------------------*/

static int nmp_get_audio_mute( TPMediaPlayer * mp , int * mute )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;                                    
}

/*---------------------------------------------------------------------------*/

static int nmp_set_audio_mute( TPMediaPlayer * mp , int mute )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;                                    
}

/*---------------------------------------------------------------------------*/

static int nmp_play_sound( TPMediaPlayer * mp , const char * uri )
{
    return TP_MEDIAPLAYER_ERROR_NOT_IMPLEMENTED;                                        
}

/*---------------------------------------------------------------------------*/

static void * nmp_get_viewport_texture( TPMediaPlayer * mp )
{
    return 0;
}

/*---------------------------------------------------------------------------*/

int nmp_constructor( TPMediaPlayer * mp )
{
    NMP * nmp = ( NMP * ) malloc( sizeof( NMP ) );
    
    memset( nmp , 0 , sizeof( NMP ) );
    
    nmp->mp = mp;
    
    nmp->viewport.x = 0;
    nmp->viewport.y = 0;
    nmp->viewport.width = 1920;
    nmp->viewport.height = 1080;
    
    mp->user_data = nmp;
    
    mp->destroy = nmp_destroy;
    mp->load = nmp_load;
    mp->reset = nmp_reset;
    mp->play = nmp_play;
    mp->seek = nmp_seek;
    mp->pause = nmp_pause;
    mp->set_playback_rate = nmp_set_playback_rate;
    mp->get_position = nmp_get_position;
    mp->get_duration = nmp_get_duration;
    mp->get_buffered_duration = nmp_get_buffered_duration;
    mp->get_video_size = nmp_get_video_size;
    mp->get_viewport_geometry = nmp_get_viewport_geometry;
    mp->set_viewport_geometry = nmp_set_viewport_geometry;
    mp->get_media_type = nmp_get_media_type;
    mp->get_audio_volume = nmp_get_audio_volume;
    mp->set_audio_volume = nmp_set_audio_volume;
    mp->get_audio_mute = nmp_get_audio_mute;
    mp->set_audio_mute = nmp_set_audio_mute;
    mp->play_sound = nmp_play_sound;
    mp->get_viewport_texture = nmp_get_viewport_texture;
        
    return 0;
}

/*---------------------------------------------------------------------------*/

