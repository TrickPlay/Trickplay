/******************************************************************************
 *   DTV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2010 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file tp_mediaplayer.cpp
 *
 *  TPMediaPlayer implementations
 *  Implements Trickplay MediaPlayer callbacks using HOA_MEDIA functions
 *
 *  @author     Hong, Won-gi (wongi.hong@lge.com)
 *  @version    1.0
 *  @date       2010.08.24
 *  @note		None
 *  @see		None
 */

/******************************************************************************
	File Inclusions
 ******************************************************************************/
#include <stdlib.h>
#include <string.h>

#include <trickplay/mediaplayer.h>

#include "tp_common.h"
#include "tp_mediaplayer.h"

/******************************************************************************
	Macro Definitions
 ******************************************************************************/

/******************************************************************************
	Local Constant Definitions
 ******************************************************************************/

/******************************************************************************
	Local Type Definitions
 ******************************************************************************/
typedef enum tagMediaStatus {
	MEDIA_STOP,
	MEDIA_PLAY,
	MEDIA_PAUSE,
	MEDIA_LAST
} MEDIA_STATUS_T;

typedef struct tagMediaPlayerData {
	int	viewport_top;
	int	viewport_left;
	int	viewport_width;
	int	viewport_height;

	char				*pszUri;
	MEDIA_TRANSPORT_T	mediaTrans;
	MEDIA_FORMAT_T		mediaFormat;
} TP_MEDIAPLAYERDATA_T;

/******************************************************************************
	Extern Variables & Function Prototype Declarations
 ******************************************************************************/

/******************************************************************************
	Static Variables & Function Prototypes Declarations
 ******************************************************************************/
static MEDIA_STATUS_T	_gMediaStatus;
static TPMediaPlayer	*_gpCurrentPlaying;

/******************************************************************************
	Global Variables & Function Prototypes Declarations
 ******************************************************************************/

/******************************************************************************
	Local Variables & Function Prototypes Declarations
 ******************************************************************************/

/**
 * URI를 분석하여 media transport type을 반환한다.
 *
 * @param	pszUri [IN] URI
 * @return	MEDIA_TRANSPORT_T
 */
static MEDIA_TRANSPORT_T _TP_GetMediaTransportType(const char *pszUri)
{
	if (pszUri == NULL) {
		return (MEDIA_TRANSPORT_T)0;
	}

	if (strstr(pszUri, "://") != NULL) {
		if (strncasecmp(pszUri, "file", 4) != 0) {
			return MEDIA_TRANS_BUFFERSTREAM;
		}
	}

	return MEDIA_TRANS_FILE;
}

/**
 * URI를 분석하여 media format type을 반환하다.
 *
 * @param	pszUri [IN] URI
 * @return	MEDIA_FORMAT_T
 */
static MEDIA_FORMAT_T _TP_GetMediaFormat(const char *pszUri)
{
	if (pszUri == NULL) {
		return MEDIA_FORMAT_RAW;
	}

	char *p = strrchr(pszUri, '.');

	if (p == NULL) {
		goto error;
	}

	if (strcasecmp(p, ".wav") == 0) {
		return MEDIA_FORMAT_WAV;
	} else if (strcasecmp(p, ".mp3") == 0) {
		return MEDIA_FORMAT_MP3;
	} else if (strcasecmp(p, ".aac") == 0) {
		return MEDIA_FORMAT_AAC;
	} else if (strcasecmp(p, ".avi") == 0) {
		return MEDIA_FORMAT_AVI;
	} else if (strcasecmp(p, ".mp4") == 0) {
		return MEDIA_FORMAT_MP4;
	} else if (strcasecmp(p, ".mpg") == 0) {
		return MEDIA_FORMAT_MPEG1;
	} else if ((strcasecmp(p, ".ts") == 0) || (strcasecmp(p, ".trp") == 0)) {
		return MEDIA_FORMAT_MPEG2;
	} else if (strcasecmp(p, ".wmv") == 0) {
		return MEDIA_FORMAT_ASF;
	} else if (strcasecmp(p, ".mkv") == 0) {
		return MEDIA_FORMAT_MKV;
	}

error:
	return MEDIA_FORMAT_RAW;
}

static void _TP_MediaPlayer_PlayCallback(MEDIA_CHANNEL_T ch, MEDIA_CB_MSG_T msg)
{
	switch (msg) {
		case MEDIA_CB_MSG_PLAYEND:
			DBG_PRINT_TP("play msg: MEDIA_CB_MSG_PLAYEND");

			if (ch == MEDIA_CH_A) {
				_gMediaStatus = MEDIA_STOP;

				if (_gpCurrentPlaying != NULL) {
					tp_media_player_end_of_stream(_gpCurrentPlaying);
					_gpCurrentPlaying = NULL;
				}
			} else {
				HOA_MEDIA_EndChannel(MEDIA_CH_B);
			}
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

/**
 * TPMediaPlayer.destroy callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @return	void
 */
static void _TP_MediaPlayer_Destroy(TPMediaPlayer *pMp)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return;
	}

	HOA_MEDIA_Finalize();

	if (pMp->user_data != NULL) {
		free(pMp->user_data);
		pMp->user_data = NULL;
	}
}

/**
 * TPMediaPlayer.load callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pszUri [IN] the URI to load
 * @param	pExtra [IN] not used
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_Load(TPMediaPlayer *pMp, const char *pszUri, const char *pExtra)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pszUri == NULL)) {
		tp_media_player_error(pMp, TP_MEDIAPLAYER_ERROR_BAD_PARAMETER, "Bad Parameter.");
		return -1;
	}

	MEDIA_TRANSPORT_T	mediaTrans	= _TP_GetMediaTransportType(pszUri);
	MEDIA_FORMAT_T		mediaFormat	= _TP_GetMediaFormat(pszUri);

	DBG_PRINT_TP("URI: %s", pszUri);
	DBG_PRINT_TP("transport type=%d, format=%d", mediaTrans, mediaFormat);

	HOA_STATUS_T res = HOA_MEDIA_StartChannel(MEDIA_CH_A,
											  mediaTrans,
											  mediaFormat,
											  0);

	if (res != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_StartChannel() failed. (%d)", res);
		tp_media_player_error(pMp, res, "HOA_MEDIA_StartChannel() failed.");
		return -1;
	}

	tp_media_player_loaded(pMp);

	TP_MEDIAPLAYERDATA_T *pMpData = (TP_MEDIAPLAYERDATA_T *)pMp->user_data;

	const char *localPathPrefix = "file://";

	// fopen() cannot recognize 'file://...' URI path.
	if (strncmp(pszUri, localPathPrefix, strlen(localPathPrefix)) == 0) {
		pszUri += strlen(localPathPrefix);
	}

	pMpData->pszUri		 = strdup(pszUri);
	pMpData->mediaTrans	 = mediaTrans;
	pMpData->mediaFormat = mediaFormat;

	return 0;
}

/**
 * TPMediaPlayer.reset callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @return	void
 */
static void _TP_MediaPlayer_Reset(TPMediaPlayer *pMp)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return;
	}

	if (_gMediaStatus != MEDIA_STOP) {
		if (HOA_MEDIA_StopClip(MEDIA_CH_A) == HOA_OK) {
			_gMediaStatus = MEDIA_STOP;
		}
	}

	HOA_MEDIA_EndChannel(MEDIA_CH_A);
}

/**
 * TPMediaPlayer.play callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_Play(TPMediaPlayer *pMp)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}

	HOA_STATUS_T res;

	if (_gMediaStatus == MEDIA_PAUSE) {
		res = HOA_MEDIA_ResumeClip(MEDIA_CH_A);

		if (res != HOA_OK) {
			DBG_PRINT_TP("HOA_MEDIA_ResumeClip() failed. (%d)", res);
			tp_media_player_error(pMp, res, "HOA_MEDIA_ResumeClip() failed.");
			return -1;
		}

		_gMediaStatus = MEDIA_PLAY;
		return 0;
	}

	// If media is not stopped, stop it at first.
	if (_gMediaStatus != MEDIA_STOP) {
		if (HOA_MEDIA_StopClip(MEDIA_CH_A) != HOA_OK) {
			DBG_PRINT_TP("HOA_MEDIA_StopClip() failed. (%d)", res);
			tp_media_player_error(pMp, res, "HOA_MEDIA_StopClip() failed.");
			return -1;
		}

		_gMediaStatus = MEDIA_STOP;
	}

	TP_MEDIAPLAYERDATA_T *pMpData = (TP_MEDIAPLAYERDATA_T *)pMp->user_data;
	MEDIA_CODEC_T codecType = 0;
	UINT16 playOptionSize = 0;
	UINT8 *pPlayOption = NULL;

	if (pMpData->mediaFormat == MEDIA_FORMAT_RAW) {
		codecType		= MEDIA_AUDIO_PCM;
		playOptionSize	= sizeof(HOA_AUDIO_PCM_INFO_T);
		pPlayOption		= (UINT8 *)malloc(playOptionSize);

		HOA_AUDIO_PCM_INFO_T *pPCMInfo = (HOA_AUDIO_PCM_INFO_T *)pPlayOption;

		pPCMInfo->bitsPerSample	= HOA_AUDIO_16BIT;
		pPCMInfo->sampleRate	= HOA_AUDIO_SAMPLERATE_48K;
		pPCMInfo->channelMode	= HOA_AUDIO_PCM_STEREO;
	} else if ((pMpData->mediaFormat & MEDIA_FORMAT_AUDIO_MASK) == 0) {
		playOptionSize	= sizeof(HOA_RECT_T);
		pPlayOption		= (UINT8 *)malloc(playOptionSize);

		HOA_RECT_T *pHOARect = (HOA_RECT_T *)pPlayOption;

		pHOARect->x	= 0;
		pHOARect->y	= 0;
		pHOARect->width  = 1920;
		pHOARect->height = 1080;
	}

	res = HOA_MEDIA_PlayClipFile(MEDIA_CH_A,
								 pMpData->pszUri,
								 1,
								 pMpData->mediaTrans,
								 pMpData->mediaFormat,
								 codecType,
								 pPlayOption,
								 playOptionSize);

	if (pPlayOption != NULL) {
		free(pPlayOption);
	}

	if (res != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_PlayClipFile() failed. (%d)", res);
		tp_media_player_error(pMp, res, "HOA_MEDIA_PlayClipFile() failed.");
		return -1;
	}

	_gMediaStatus = MEDIA_PLAY;
	_gpCurrentPlaying = pMp;

	return 0;
}

/**
 * TPMediaPlayer.seek callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	seconds [IN] position within the stream in seconds
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_Seek(TPMediaPlayer *pMp, double seconds)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}

	UINT32 posMilliSec = ((UINT32)seconds) * 1000;

	if (HOA_MEDIA_SeekClip(MEDIA_CH_A, posMilliSec) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_SeekClip() failed.");
		return -1;
	}

	return 0;
}

/**
 * TPMediaPlayer.pause callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_Pause(TPMediaPlayer *pMp)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}

	if (HOA_MEDIA_PauseClip(MEDIA_CH_A) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_PauseClip() failed.");
		return -1;
	}

	_gMediaStatus = MEDIA_PAUSE;
	return 0;
}

/**
 * TPMediaPlayer.set_playback_rate callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	rate [IN] integer multiplier, which will never be 0. 1 is normal speed.
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_SetPlaybackRate(TPMediaPlayer *pMp, int rate)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}
	if (rate == 0) {
		return -1;
	}

	if (HOA_MEDIA_SetPlaySpeed(MEDIA_CH_A, (rate > 0), abs(rate), 0) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_SetPlaySpeed() failed.");
		return -1;
	}

	return 0;
}

/**
 * TPMediaPlayer.get_position callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pSeconds [OUT] playback position
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetPosition(TPMediaPlayer *pMp, double *pSeconds)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pSeconds == NULL)) {
		return -1;
	}

	MEDIA_PLAY_INFO_T playInfo;

	if (HOA_MEDIA_GetPlayInfo(MEDIA_CH_A, &playInfo) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed.");
		return -1;
	}

	*pSeconds = (double)playInfo.elapsedMS / 1000;

	return 0;
}

/**
 * TPMediaPlayer.get_duration callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pSeconds [OUT] stream duration in seconds
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetDuration(TPMediaPlayer *pMp, double *pSeconds)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pSeconds == NULL)) {
		return -1;
	}

	MEDIA_PLAY_INFO_T playInfo;

	if (HOA_MEDIA_GetPlayInfo(MEDIA_CH_A, &playInfo) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed.");
		return -1;
	}

	*pSeconds = (double)playInfo.durationMS / 1000;

	return 0;
}

/**
 * TPMediaPlayer.load callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pStartSeconds [OUT] starting point of the buffer in seconds
 * @param	pEndSeconds [OUT] ending point of the buffer in seconds
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetBufferedDuration(TPMediaPlayer *pMp, double *pStartSeconds, double *pEndSeconds)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pStartSeconds == NULL) || (pEndSeconds == NULL)) {
		return -1;
	}

	MEDIA_PLAY_INFO_T playInfo;

	if (HOA_MEDIA_GetPlayInfo(MEDIA_CH_A, &playInfo) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed.");
		return -1;
	}

	*pStartSeconds	= playInfo.bufBeginSec;
	*pEndSeconds	= playInfo.bufEndSec;

	return 0;
}

/**
 * TPMediaPlayer.get_video_size callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pWidth [OUT] width of the video
 * @param	pHeight [OUT] height of the video
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetVideoSize(TPMediaPlayer *pMp, int *pWidth, int *pHeight)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pWidth == NULL) || (pHeight == NULL)) {
		return -1;
	}

	MEDIA_SOURCE_INFO_T srcInfo;

	if (HOA_MEDIA_GetSourceInfo(MEDIA_CH_A, &srcInfo) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed.");
		return -1;
	}

	*pWidth		= srcInfo.width;
	*pHeight	= srcInfo.height;

	return 0;
}

/**
 * TPMediaPlayer.get_viewport_geometry callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pLeft [OUT] the left (x) coordinate of the viewport
 * @param	pTop [OUT] the top (y) coordinate of the viewport
 * @param	pWidth [OUT] the width of the viewport
 * @param	pHeight [OUT] the height of the viewport
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetViewportGeometry(TPMediaPlayer *pMp, int *pLeft, int *pTop, int *pWidth, int *pHeight)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pLeft == NULL) || (pTop == NULL) || (pWidth == NULL) || (pHeight == NULL)) {
		return -1;
	}

	TP_MEDIAPLAYERDATA_T *pMpData = (TP_MEDIAPLAYERDATA_T *)pMp->user_data;

	*pLeft		= pMpData->viewport_left;
	*pTop		= pMpData->viewport_top;
	*pWidth		= pMpData->viewport_width;
	*pHeight	= pMpData->viewport_height;

	return 0;
}

/**
 * TPMediaPlayer.set_viewport_geometry callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pLeft [IN] desired left (x) coordinate of the viewport
 * @param	pTop [IN] desired top (y) coordinate of the viewport
 * @param	pWidth [IN] desired width of the viewport
 * @param	pHeight [IN] desired height of the viewport
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_SetViewportGeometry(TPMediaPlayer *pMp, int left, int top, int width, int height)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}

	TP_MEDIAPLAYERDATA_T *pMpData = (TP_MEDIAPLAYERDATA_T *)pMp->user_data;

	pMpData->viewport_left		= left;
	pMpData->viewport_top		= top;
	pMpData->viewport_width		= width;
	pMpData->viewport_height	= height;

	return 0;
}

/**
 * TPMediaPlayer.get_media_type callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pType [OUT] type
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetMediaType(TPMediaPlayer *pMp, int *pType)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pType == NULL)) {
		return -1;
	}

	MEDIA_SOURCE_INFO_T srcInfo;

	if (HOA_MEDIA_GetSourceInfo(MEDIA_CH_A, &srcInfo) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_GetSourceInfo() failed.");
		return -1;
	}

	if ((srcInfo.format & MEDIA_FORMAT_VIDEO_MASK) != 0) {
		*pType = TP_MEDIA_TYPE_AUDIO_VIDEO;
	} else if ((srcInfo.format & MEDIA_FORMAT_AUDIO_MASK) != 0) {
		*pType = TP_MEDIA_TYPE_AUDIO;
	}

	return 0;
}

/**
 * TPMediaPlayer.get_audio_volume callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pVolume [OUT] volume
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetAudioVolume(TPMediaPlayer *pMp, double *pVolume)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pVolume == NULL)) {
		return -1;
	}

	SINT8 volume = 0;

	if (HOA_TV_GetCurrentVolume(HOA_APP_ADDON, &volume) != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_GetCurrentVolume() failed.");
		return -1;
	}

	*pVolume = volume;
	return 0;
}

/**
 * TPMediaPlayer.set_audio_volume callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	volume [IN] new volume (0 ~ 1)
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_SetAudioVolume(TPMediaPlayer *pMp, double volume)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}

	if (HOA_TV_SetVolume(TRUE, HOA_APP_ADDON, FALSE, (SINT8)volume, NULL) != HOA_OK) {
		DBG_PRINT_TP("HOA_TV_SetVolume() failed.");
		return -1;
	}

	return 0;
}

/**
 * TPMediaPlayer.get_audio_mute callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pMute [OUT] whether audio is muted. (0: not muted / other: muted)
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_GetAudioMute(TPMediaPlayer *pMp, int *pMute)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pMute == NULL)) {
		return -1;
	}

	BOOLEAN bMute;

	if (HOA_TV_GetMute(&bMute) != HOA_OK) {
		DBG_PRINT_TP("HOA_TV_GetMute() failed.");
		return -1;
	}

	*pMute = bMute ? 1 : 0;
	return 0;
}

/**
 * TPMediaPlayer.set_audio_mute callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	mute [IN] whether audio should be muted. (0: not muted / other: muted)
 * @return	int 0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_SetAudioMute(TPMediaPlayer *pMp, int mute)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}

	BOOLEAN bMute = (mute != 0) ? TRUE : FALSE;

	if (HOA_TV_SetMute(TRUE, bMute) != HOA_OK) {
		DBG_PRINT_TP("HOA_TV_SetMute() failed.");
		return -1;
	}

	return 0;
}

/**
 * TPMediaPlayer.play_sound callback 구현
 * main media 플레이를 위해 사용중인 채널 A가 아닌 채널 B에서 사운드를 플레이한다.
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @param	pszUri [IN] the URI of the sound to play.
 * @return	void
 */
static int _TP_MediaPlayer_PlaySound(TPMediaPlayer *pMp, const char *pszUri)
{
	DBG_PRINT_TP();

	if ((pMp == NULL) || (pszUri == NULL)) {
		return -1;
	}

	MEDIA_PLAY_INFO_T playInfo;
	if ((HOA_MEDIA_GetPlayInfo(MEDIA_CH_B, &playInfo) == HOA_OK) &&
		(playInfo.playState == MEDIA_STATE_PLAY)) {
		HOA_MEDIA_StopClip(MEDIA_CH_B);
		HOA_MEDIA_EndChannel(MEDIA_CH_B);
	}

	HOA_STATUS_T res;
	MEDIA_TRANSPORT_T	mediaTrans	= _TP_GetMediaTransportType(pszUri);
	MEDIA_FORMAT_T		mediaFormat	= _TP_GetMediaFormat(pszUri);

	if ((mediaFormat & MEDIA_FORMAT_AUDIO_MASK) == 0) {
		DBG_PRINT_TP("%s is not an audio file.", pszUri);
		return -1;
	}

	res = HOA_MEDIA_StartChannel(MEDIA_CH_B, mediaTrans, mediaFormat, 0);
	if (res != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_StartChannel() failed. (%d)", res);
		return -1;
	}

	// 'file://' URL prefix must be removed because fopen() cannot recognize it.
	const char *localPathPrefix = "file://";

	if (strncmp(pszUri, localPathPrefix, strlen(localPathPrefix)) == 0) {
		pszUri += strlen(localPathPrefix);
	}

	if (mediaFormat == MEDIA_FORMAT_RAW) {
		HOA_AUDIO_PCM_INFO_T PCMInfo = { HOA_AUDIO_16BIT, HOA_AUDIO_SAMPLERATE_48K, HOA_AUDIO_PCM_STEREO };

		res = HOA_MEDIA_PlayClipFile(MEDIA_CH_B,
									 (char *)pszUri,
									 1,
									 mediaTrans,
									 mediaFormat,
									 MEDIA_AUDIO_PCM,
									 (UINT8 *)&PCMInfo,
									 sizeof(PCMInfo));
	} else {
		res = HOA_MEDIA_PlayClipFile(MEDIA_CH_B, (char *)pszUri, 1, mediaTrans, mediaFormat, MEDIA_VIDEO_NONE, NULL, 0);
	}

	if (res != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_PlayClipFile() failed. (%d)", res);
		HOA_MEDIA_EndChannel(MEDIA_CH_B);
		return -1;
	}

	return 0;
}

/**
 * TPMediaPlayer.get_viewport_texture callback 구현
 *
 * @param	pMp [IN] TPMediaPlayer interface
 * @return	void* should return NULL.
 */
static void *_TP_MediaPlayer_GetViewportTexture(TPMediaPlayer *pMp)
{
	DBG_PRINT_TP();

	return NULL;
}

/**
 * initializes a new media player.
 * typedef int (*TPMediaPlayerContructor)(TPMediaPlayer *mp);
 *
 * @param	pMp [IN] a pointer to an uninitialized TPMediaPlayer structure
 * @return	int	0 : 성공 / other : 실패
 */
static int _TP_MediaPlayer_Constructor(TPMediaPlayer *pMp)
{
	DBG_PRINT_TP();

	if (pMp == NULL) {
		return -1;
	}

	if (HOA_MEDIA_Initialize() != HOA_OK) {
		DBG_PRINT_TP("HOA_MEDIA_Initialize() failed.");
		return -1;
	}

	if ((HOA_MEDIA_RegisterPlayCallback(MEDIA_CH_A, _TP_MediaPlayer_PlayCallback) != HOA_OK) ||
		(HOA_MEDIA_RegisterPlayCallback(MEDIA_CH_B, _TP_MediaPlayer_PlayCallback) != HOA_OK)) {
		DBG_PRINT_TP("HOA_MEDIA_RegisterPlayCallback() failed.");
		return -1;
	}

	_gMediaStatus = MEDIA_STOP;

	TP_MEDIAPLAYERDATA_T *pMpData = (TP_MEDIAPLAYERDATA_T*)malloc(sizeof(TP_MEDIAPLAYERDATA_T));
	if (pMpData == NULL) {
		return -1;
	}

	memset(pMpData, 0, sizeof(*pMpData));

	pMp->user_data				= pMpData;
	pMp->destroy				= _TP_MediaPlayer_Destroy;
	pMp->load					= _TP_MediaPlayer_Load;
	pMp->reset					= _TP_MediaPlayer_Reset;
	pMp->play					= _TP_MediaPlayer_Play;
	pMp->seek					= _TP_MediaPlayer_Seek;
	pMp->pause					= _TP_MediaPlayer_Pause;
	pMp->set_playback_rate		= _TP_MediaPlayer_SetPlaybackRate;
	pMp->get_position			= _TP_MediaPlayer_GetPosition;
	pMp->get_duration			= _TP_MediaPlayer_GetDuration;
	pMp->get_buffered_duration	= _TP_MediaPlayer_GetBufferedDuration;
	pMp->get_video_size			= _TP_MediaPlayer_GetVideoSize;
	pMp->get_viewport_geometry	= _TP_MediaPlayer_GetViewportGeometry;
	pMp->set_viewport_geometry	= _TP_MediaPlayer_SetViewportGeometry;
	pMp->get_media_type			= _TP_MediaPlayer_GetMediaType;
	pMp->get_audio_volume		= _TP_MediaPlayer_GetAudioVolume;
	pMp->set_audio_volume		= _TP_MediaPlayer_SetAudioVolume;
	pMp->get_audio_mute			= _TP_MediaPlayer_GetAudioMute;
	pMp->set_audio_mute			= _TP_MediaPlayer_SetAudioMute;
	pMp->play_sound				= _TP_MediaPlayer_PlaySound;
	pMp->get_viewport_texture	= _TP_MediaPlayer_GetViewportTexture;

	return 0;
}

/**
 * initializes Media Player features of TPContext
 * registers TPMediaPlayerConstructor callback
 *
 * @param	pContext [IN] a pointer to the relevant TPContext structure
 * @return	BOOLEAN 성공 여부
 */
BOOLEAN TP_MediaPlayer_Initialize(TPContext *pContext)
{
	DBG_PRINT_TP();

	if (pContext == NULL) {
		return FALSE;
	}

	tp_context_set_media_player_constructor(pContext, _TP_MediaPlayer_Constructor);
	return TRUE;
}

