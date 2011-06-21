#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include <addon_types.h>
#include <addon_hoa.h>

#include <trickplay/mediaplayer.h>

#include "tp_common.h"
#include "tp_playclip.h"
#include "tp_playstream.h"
#include "tp_mediaplayer.h"


static TPMediaPlayer* _gpMP_MainCh;

static void _MediaPlayer_PlayCallback(MEDIA_CHANNEL_T ch, MEDIA_CB_MSG_T msg)
{
	switch (msg)
	{
		case MEDIA_CB_MSG_PLAYEND:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_PLAYEND");

			if ((ch == MEDIA_CH_A) && (_gpMP_MainCh != NULL))
				tp_media_player_end_of_stream(_gpMP_MainCh);
			break;

		case MEDIA_CB_MSG_PLAYSTART:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_PLAYSTART");
			break;

		case MEDIA_CB_MSG_ERR_PLAYING:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_ERR_PLAYING");
			break;

		case MEDIA_CB_MSG_ERR_BUFFERFULL:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_ERR_BUFFERFULL");
			break;

		case MEDIA_CB_MSG_ERR_NOT_FOUND:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_ERR_NOT_FOUND");
			break;

		case MEDIA_CB_MSG_ERR_NET_DISCONNECTED:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_ERR_NET_DISCONNECTED");
			break;

		case MEDIA_CB_MSG_ERR_NET_BUSY:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_ERR_NET_BUSY");
			break;

		case MEDIA_CB_MSG_ERR_NET_CANNOT_PROCESS:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_ERR_NET_CANNOT_PROCESS");
			break;

		default:
			DBG_PRINT_TP("play msg: Invalid!");
			break;
	}
}

static void _MediaPlayer_Destroy(TPMediaPlayer* pMP)
{
	DBG_PRINT_TP(NULL);

	if (pMP == NULL)
		return;

	if (pMP->user_data != NULL)
	{
		free(pMP->user_data);
		pMP->user_data = NULL;
	}
}

static int _MediaPlayer_Load(TPMediaPlayer* pMP, const char* szURI, const char* pExtra)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	TP_MEDIA_INFO_T* pMediaInfo = NULL;
	int code;

	assert(pMP != NULL);

	if (szURI == NULL)
	{
		code = TP_MEDIAPLAYER_ERROR_BAD_PARAMETER;
		tp_media_player_error(pMP, code, "Bad Parameter.");
		return code;
	}

	if (pMP->user_data == NULL)
		return -1;

	pMediaInfo = (TP_MEDIA_INFO_T*)pMP->user_data;

	pMediaInfo->szURI		= strdup(szURI);
	pMediaInfo->transType	= TP_MediaPlayer_GetTransportType(szURI);
	pMediaInfo->formatType	= TP_MediaPlayer_GetFormatType(szURI);
	pMediaInfo->codecType	= TP_MediaPlayer_GetCodecType(szURI);

	DBG_PRINT_TP("URI: %s", szURI);
	DBG_PRINT_TP("trans type=%d, format=%d, codec=%d",
			pMediaInfo->transType, pMediaInfo->formatType, pMediaInfo->codecType);

	if (pMediaInfo->transType == MEDIA_TRANS_FILE)
	{
		pMP->play	= TP_PlayClip_Play;
		pMP->seek	= TP_PlayClip_Seek;
		pMP->pause	= TP_PlayClip_Pause;
	}
	else if (pMediaInfo->transType == MEDIA_TRANS_BUFFERSTREAM)
	{
		pMP->play	= TP_PlayStream_Play;
		pMP->seek	= TP_PlayStream_Seek;
		pMP->pause	= TP_PlayStream_Pause;
	}
	else
	{
		code = TP_MEDIAPLAYER_ERROR_INVALID_URI;
		tp_media_player_error(pMP, code, "Invalid URI.");
		return code;
	}

	res = HOA_MEDIA_StartChannel(MEDIA_CH_A, pMediaInfo->transType, pMediaInfo->formatType, pMediaInfo->codecType);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_StartChannel() failed. (%d)", res);
		return res;
	}

	//
	_gpMP_MainCh = pMP;
	tp_media_player_loaded(pMP);

	return 0;
}

static void _MediaPlayer_Reset(TPMediaPlayer* pMP)
{
	DBG_PRINT_TP(NULL);

	TP_MEDIA_INFO_T* pMediaInfo = NULL;

	assert(pMP != NULL);

	if (pMP->user_data == NULL)
		return;

	pMediaInfo = (TP_MEDIA_INFO_T*)pMP->user_data;

	if (pMediaInfo->transType == MEDIA_TRANS_FILE)
		HOA_MEDIA_StopClip(MEDIA_CH_A);
	else if (pMediaInfo->transType == MEDIA_TRANS_BUFFERSTREAM)
		HOA_MEDIA_StopStream(MEDIA_CH_A);

	HOA_MEDIA_EndChannel(MEDIA_CH_A);

	//
	_gpMP_MainCh = NULL;
}


static int _MediaPlayer_SetPlaybackRate(TPMediaPlayer* pMP, int rate)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;

	assert(pMP != NULL);

	res = HOA_MEDIA_SetPlaySpeed(MEDIA_CH_A, (rate > 0), abs(rate), 0);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_SetPlaySpeed() failed. (%d)", res);
		return -1;
	}

	return 0;
}

static int _MediaPlayer_GetPosition(TPMediaPlayer* pMP, double* pSeconds)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	MEDIA_PLAY_INFO_T playInfo;

	assert(pMP != NULL);

	if (pSeconds == NULL)
	{
		tp_media_player_error(pMP, TP_MEDIAPLAYER_ERROR_BAD_PARAMETER, "Bad Parameter.");
		return -1;
	}

	res = HOA_MEDIA_GetPlayInfo(MEDIA_CH_A, &playInfo);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed. (%d)", res);
		return -1;
	}

	*pSeconds = (double)playInfo.elapsedMS / 100;
	return 0;
}

static int _MediaPlayer_GetDuration(TPMediaPlayer* pMP, double* pSeconds)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	MEDIA_PLAY_INFO_T playInfo;

	assert(pMP != NULL);

	if (pSeconds == NULL)
	{
		tp_media_player_error(pMP, TP_MEDIAPLAYER_ERROR_BAD_PARAMETER, "Bad Parameter.");
		return -1;
	}

	res = HOA_MEDIA_GetPlayInfo(MEDIA_CH_A, &playInfo);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed. (%d)", res);
		return -1;
	}

	*pSeconds = (double)playInfo.durationMS / 100;
	return 0;
}

static int _MediaPlayer_GetBufferedDuration(TPMediaPlayer* pMP,
		double* pStartSeconds, double* pEndSeconds)
{
	DBG_PRINT_TP(NULL);

	assert(pMP != NULL);

	if ((pStartSeconds == NULL) || (pEndSeconds == NULL))
	{
		tp_media_player_error(pMP, TP_MEDIAPLAYER_ERROR_BAD_PARAMETER, "Bad Parameter.");
		return -1;
	}

	*pStartSeconds	= 0;
	*pEndSeconds	= 0;

	return 0;
}

static int _MediaPlayer_GetVideoSize(TPMediaPlayer* pMP, int* pWidth, int* pHeight)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	MEDIA_SOURCE_INFO_T sourceInfo;

	assert(pMP != NULL);

	if ((pWidth == NULL) || (pHeight == NULL))
	{
		tp_media_player_error(pMP, TP_MEDIAPLAYER_ERROR_BAD_PARAMETER, "Bad Parameter.");
		return -1;
	}

	res = HOA_MEDIA_GetSourceInfo(MEDIA_CH_A, &sourceInfo);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_GetSourceInfo() failed. (%d)", res);
		return -1;
	}

	*pWidth		= sourceInfo.width;
	*pHeight	= sourceInfo.height;

	return 0;
}

static int _MediaPlayer_GetViewportGeometry(TPMediaPlayer* pMP,
		int* pLeft, int* pTop, int* pWidth, int* pHeight)
{
	DBG_PRINT_TP(NULL);

	TP_MEDIA_INFO_T* pMPData;

	assert(pMP != NULL);

	pMPData = (TP_MEDIA_INFO_T*)pMP->user_data;

	if (pLeft)		*pLeft		= pMPData->viewport.x;
	if (pTop)		*pTop		= pMPData->viewport.y;
	if (pWidth)		*pWidth		= pMPData->viewport.width;
	if (pHeight)	*pHeight	= pMPData->viewport.height;

	return 0;
}

static int _MediaPlayer_SetViewportGeometry(TPMediaPlayer* pMP,
		int left, int top, int width, int height)
{
	DBG_PRINT_TP(NULL);

	TP_MEDIA_INFO_T* pMPData;

	assert(pMP != NULL);

	pMPData = (TP_MEDIA_INFO_T*)pMP->user_data;

	pMPData->viewport.x			= left;
	pMPData->viewport.y			= top;
	pMPData->viewport.width		= width;
	pMPData->viewport.height	= height;

	return 0;
}

static int _MediaPlayer_GetMediaType(TPMediaPlayer* pMP, int* pType)
{
	DBG_PRINT_TP(NULL);

	TP_MEDIA_INFO_T* pMediaInfo = NULL;

	assert(pMP != NULL);

	if (pType == NULL)
	{
		tp_media_player_error(pMP, TP_MEDIAPLAYER_ERROR_BAD_PARAMETER, "Bad Parameter.");
		return -1;
	}

	pMediaInfo = (TP_MEDIA_INFO_T*)pMP->user_data;

	if ((pMediaInfo->formatType & MEDIA_FORMAT_VIDEO_MASK) != 0)
		*pType = TP_MEDIA_TYPE_AUDIO_VIDEO;
	else if ((pMediaInfo->formatType & MEDIA_FORMAT_AUDIO_MASK) != 0)
		*pType = TP_MEDIA_TYPE_AUDIO;
	else
		return -1;

	return 0;
}

static int _MediaPlayer_GetAudioVolume(TPMediaPlayer* pMP, double* pVolume)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	SINT8 volume = 0;

	assert(pMP != NULL);

	if (pVolume == NULL)
		return -1;

	res = HOA_TV_GetCurrentVolume(HOA_APP_HOST, &volume);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_TV_GetCurrentVolume() failed. (%d)", res);
		return -1;
	}

	*pVolume = volume;
	return 0;
}

static int _MediaPlayer_SetAudioVolume(TPMediaPlayer* pMP, double volume)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;

	assert(pMP != NULL);

	res = HOA_TV_SetVolume(FALSE, HOA_APP_HOST, FALSE, (SINT8)volume, NULL);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_TV_SetVolume() failed. (%d)", res);
		return -1;
	}

	return 0;
}

static int _MediaPlayer_GetAudioMute(TPMediaPlayer* pMP, int* pMute)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	BOOLEAN bMute;

	assert(pMP != NULL);

	if (pMute == NULL)
		return -1;

	res = HOA_TV_GetMute(&bMute);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_TV_GetMute() failed. (%d)", res);
		return -1;
	}

	*pMute = bMute;
	return 0;
}

static int _MediaPlayer_SetAudioMute(TPMediaPlayer* pMP, int mute)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;

	assert(pMP != NULL);

	res = HOA_TV_SetMute(FALSE, mute);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_TV_SetMute() failed. (%d)", res);
		return -1;
	}

	return 0;
}

static void* _MediaPlayer_GetViewportTexture(TPMediaPlayer* pMP)
{
	DBG_PRINT_TP(NULL);

	return NULL;
}

static int _MediaPlayer_Constructor(TPMediaPlayer* pMP)
{
	DBG_PRINT_TP(NULL);

	assert(pMP != NULL);

	TP_MEDIA_INFO_T* pMediaInfo = (TP_MEDIA_INFO_T*)malloc(sizeof(TP_MEDIA_INFO_T));

	if (pMediaInfo == NULL)
	{
		DBG_PRINT_TP("malloc() failed.");
		return -1;
	}

	memset(pMediaInfo, 0, sizeof(*pMediaInfo));

	pMP->user_data				= pMediaInfo;
	pMP->destroy				= _MediaPlayer_Destroy;
	pMP->load					= _MediaPlayer_Load;
	pMP->reset					= _MediaPlayer_Reset;
	pMP->play					= NULL;
	pMP->seek					= NULL;
	pMP->pause					= NULL;
	pMP->set_playback_rate		= _MediaPlayer_SetPlaybackRate;
	pMP->get_position			= _MediaPlayer_GetPosition;
	pMP->get_duration			= _MediaPlayer_GetDuration;
	pMP->get_buffered_duration	= _MediaPlayer_GetBufferedDuration;
	pMP->get_video_size			= _MediaPlayer_GetVideoSize;
	pMP->get_viewport_geometry	= _MediaPlayer_GetViewportGeometry;
	pMP->set_viewport_geometry	= _MediaPlayer_SetViewportGeometry;
	pMP->get_media_type			= _MediaPlayer_GetMediaType;
	pMP->get_audio_volume		= _MediaPlayer_GetAudioVolume;
	pMP->set_audio_volume		= _MediaPlayer_SetAudioVolume;
	pMP->get_audio_mute			= _MediaPlayer_GetAudioMute;
	pMP->set_audio_mute			= _MediaPlayer_SetAudioMute;
	pMP->play_sound				= TP_PlayClip_PlaySound;
	pMP->get_viewport_texture	= _MediaPlayer_GetViewportTexture;

	return 0;
}

BOOLEAN TP_MediaPlayer_Initialize(TPContext* pContext)
{
	DBG_PRINT_TP(NULL);

#ifndef MEDIA_PLAYER_SUPPORTED
	return FALSE;
#endif

	if (pContext == NULL)
		return FALSE;

	if (HOA_MEDIA_Initialize() != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_Initialize() failed.");
		return -1;
	}

	if (HOA_MEDIA_RegisterPlayCallback(MEDIA_CH_A, _MediaPlayer_PlayCallback) != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_RegisterPlayCallback() failed.");
		return -1;
	}

	TP_PlayClip_Initialize(pContext);
	TP_PlayStream_Initialize(pContext);

	tp_context_set_media_player_constructor(pContext, _MediaPlayer_Constructor);
	return TRUE;
}

void TP_MediaPlayer_Finalize(TPContext* pContext)
{
	TP_PlayClip_Finalize(pContext);
	TP_PlayStream_Finalize(pContext);

	HOA_MEDIA_Finalize();
}

MEDIA_TRANSPORT_T TP_MediaPlayer_GetTransportType(const char* szURI)
{
	if (szURI == NULL)
		return (MEDIA_TRANSPORT_T)0;

	if (strstr(szURI, "://") != NULL)
	{
		if (strncasecmp(szURI, "file", strlen("file")) != 0)
			return MEDIA_TRANS_BUFFERSTREAM;
	}

	return MEDIA_TRANS_FILE;
}

MEDIA_FORMAT_T TP_MediaPlayer_GetFormatType(const char* szURI)
{
	if (szURI == NULL)
		return MEDIA_FORMAT_RAW;

	char* p = strrchr(szURI, '.');

	if (p == NULL)
		return MEDIA_FORMAT_RAW;

	if (strcasecmp(p, ".wav") == 0)
		return MEDIA_FORMAT_WAV;
	else if (strcasecmp(p, ".mp3") == 0)
		return MEDIA_FORMAT_MP3;
	else if (strcasecmp(p, ".aac") == 0)
		return MEDIA_FORMAT_AAC;
	else if (strcasecmp(p, ".avi") == 0)
		return MEDIA_FORMAT_AVI;
	else if (strcasecmp(p, ".mp4") == 0)
		return MEDIA_FORMAT_MP4;
	else if (strcasecmp(p, ".mpg") == 0)
		return MEDIA_FORMAT_MPEG1;
	else if ((strcasecmp(p, ".ts") == 0) || (strcasecmp(p, ".trp") == 0))
		return MEDIA_FORMAT_MPEG2;
	else if (strcasecmp(p, ".wmv") == 0)
		return MEDIA_FORMAT_ASF;
	else if (strcasecmp(p, ".mkv") == 0)
		return MEDIA_FORMAT_MKV;

	return MEDIA_FORMAT_RAW;
}

MEDIA_CODEC_T TP_MediaPlayer_GetCodecType(const char* szURI)
{
	if (TP_MediaPlayer_GetFormatType(szURI) == MEDIA_FORMAT_WAV)
		return MEDIA_AUDIO_PCM;

	return 0;
}

BOOLEAN TP_MediaPlayer_IsMainChAvailable(void)
{
	return (_gpMP_MainCh == NULL);
}

