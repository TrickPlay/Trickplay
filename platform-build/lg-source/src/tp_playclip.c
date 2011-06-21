#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include <addon_types.h>
#include <addon_hoa.h>

#include <trickplay/mediaplayer.h>

#include "map.h"
#include "tp_common.h"
#include "tp_util.h"
#include "tp_mediaplayer.h"
#include "tp_playclip.h"


static HMAP _ghEffectMap = NULL;

static const HOA_RECT_T	_gVideoGeometry = { 0, 0, 1920, 1080 };
static const HOA_AUDIO_PCM_INFO_T _gPCMInfo = {
	HOA_AUDIO_16BIT,
	HOA_AUDIO_SAMPLERATE_BYPASS,
	HOA_AUDIO_PCM_STEREO
};

static void* _PlayClip_DuplicateURI(const void* ptr)
{
	return strdup((const char*)ptr);
}

static BOOLEAN _PlayClip_KeyCompareCallback(const void* pKeyA, const void* pKeyB)
{
	if ((pKeyA == NULL) || (pKeyB == NULL))
		return FALSE;

	return (strcmp((const char*)pKeyA, (const char*)pKeyB) == 0);
}

static const char* _PlayClip_RemoveFileURIPrefix(const char* szURI)
{
	static const char* szFileURIPrefix = "file://";

	if (strncmp(szURI, szFileURIPrefix, strlen(szFileURIPrefix)) == 0)
		return (szURI + strlen(szFileURIPrefix));

	return szURI;
}

static MEDIA_BUFFER_HANDLE_T* _PlayClip_BufferingMedia(const char* szURI)
{
	HOA_STATUS_T res;
	MEDIA_BUFFER_HANDLE_T* pBuffer = NULL;

	FILE*	pfURI;
	UINT32	uFileSize = 0;
	char*	pBufferContents;
	size_t	uRead;

	pfURI = fopen(_PlayClip_RemoveFileURIPrefix(szURI), "r");
	if (pfURI == NULL)
	{
		perror("fopen() failed.");
		return NULL;
	}

	uFileSize = TP_Util_GetFileSize(pfURI);

	DBG_PRINT_TP("%s (size=%u)", szURI, uFileSize);

	res = HOA_MEDIA_MakeMediaBuffer(&pBuffer, uFileSize);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_MakeMediaBuffer() failed. (%d)", res);

		fclose(pfURI);
		return NULL;
	}

	res = HOA_MEDIA_GetMediaBufferAddress(pBuffer, &pBufferContents);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_GetMediaBufferAddress() failed.");

		fclose(pfURI);
		HOA_MEDIA_DeleteMediaBuffer(pBuffer);
		return NULL;
	}

	uRead = fread(pBufferContents, 1, uFileSize, pfURI);
	fclose(pfURI);

	DBG_PRINT_TP("Buffered to Handle %p(Actual Bytes=%p)", pBuffer, pBufferContents);
	DBG_PRINT_TP("%02x%02x    %02x%02x    %02x%02x    %02x%02x",
			pBufferContents[1], pBufferContents[0], pBufferContents[3], pBufferContents[2],
			pBufferContents[5], pBufferContents[4], pBufferContents[7], pBufferContents[6]);

	if (uRead != uFileSize)
	{
		DBG_PRINT_TP("Failed to write audio data to media buffer.");

		HOA_MEDIA_DeleteMediaBuffer(pBuffer);
		return NULL;
	}

	pBuffer->nBuffSize = uRead;
	return pBuffer;
}

BOOLEAN TP_PlayClip_Initialize(TPContext* pContext)
{
	HOA_STATUS_T res;

	if (_ghEffectMap != NULL)
		return TRUE;

	_ghEffectMap = API_Map_New(_PlayClip_DuplicateURI, NULL, free, NULL, _PlayClip_KeyCompareCallback);
	if (_ghEffectMap != NULL)
		return TRUE;

	res = HOA_MEDIA_StartChannel(MEDIA_CH_B, MEDIA_TRANS_BUFFERCLIP, MEDIA_FORMAT_WAV, MEDIA_AUDIO_PCM);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_StartChannel() failed. (%d)", res);
		return -1;
	}

	return FALSE;
}

void TP_PlayClip_Finalize(TPContext* pContext)
{
	if (_ghEffectMap != NULL)
		API_Map_Destroy(_ghEffectMap);

	HOA_MEDIA_EndChannel(MEDIA_CH_B);
}

int TP_PlayClip_Play(TPMediaPlayer* pMP)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	TP_MEDIA_INFO_T* pMPData;

	MEDIA_PLAY_INFO_T playInfo;
	UINT8*	pPlayOption		= NULL;
	UINT16	playOptionSize	= 0;

	assert(pMP != NULL);

	res = HOA_MEDIA_GetPlayInfo(MEDIA_CH_A, &playInfo);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed. (%d)", res);
		return -1;
	}

	if (playInfo.playState == MEDIA_STATE_PLAY)
	{
		DBG_PRINT_TP("Already playing...");
		return 0;
	}
	if (playInfo.playState == MEDIA_STATE_PAUSE)
	{
		DBG_PRINT_TP("Resume clip...");

		res = HOA_MEDIA_ResumeClip(MEDIA_CH_A);
		if (res != HOA_OK)
		{
			DBG_PRINT_TP("HOA_MEDIA_ResumeClip() failed. (%d)", res);
			tp_media_player_error(pMP, res, "HOA_MEDIA_ResumeClip() failed.");
			return -1;
		}

		return 0;
	}

	pMPData = (TP_MEDIA_INFO_T*)pMP->user_data;

	if (pMPData->codecType == MEDIA_AUDIO_PCM)
	{
		pPlayOption		= (UINT8*)&_gPCMInfo;
		playOptionSize	= sizeof(_gPCMInfo);
	}
	else if ((pMPData->formatType & MEDIA_FORMAT_VIDEO_MASK) == MEDIA_FORMAT_VIDEO_MASK)
	{
		pPlayOption		= (UINT8*)&_gVideoGeometry;
		playOptionSize	= sizeof(_gVideoGeometry);
	}

	res = HOA_MEDIA_PlayClipFile(MEDIA_CH_A,
			(char*)_PlayClip_RemoveFileURIPrefix(pMPData->szURI), 1,
			pMPData->transType, pMPData->formatType, pMPData->codecType,
			pPlayOption, playOptionSize);

	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_PlayClipFile() failed. (%d)", res);
		tp_media_player_error(pMP, res, "HOA_MEDIA_PlayClipFile() failed.");
		return -1;
	}

	return 0;
}

int TP_PlayClip_Seek(TPMediaPlayer* pMP, double seconds)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	MEDIA_PLAY_INFO_T playInfo;
	UINT32 newPos;

	assert(pMP != NULL);

	res = HOA_MEDIA_GetPlayInfo(MEDIA_CH_A, &playInfo);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_GetPlayInfo() failed. (%d)", res);
		return -1;
	}

	newPos = playInfo.elapsedMS + ((UINT32)seconds * 100);

	res = HOA_MEDIA_SeekClip(MEDIA_CH_A, newPos);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_SeekClip() failed. (%d)", res);
		return -1;
	}

	return 0;
}

int TP_PlayClip_Pause(TPMediaPlayer* pMP)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;

	assert(pMP != NULL);

	res = HOA_MEDIA_PauseClip(MEDIA_CH_A);
	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_PauseClip() failed. (%d)", res);
		return -1;
	}

	return 0;
}

int TP_PlayClip_PlaySound(TPMediaPlayer* pMP, const char* szURI)
{
	DBG_PRINT_TP(NULL);

	HOA_STATUS_T res;
	MEDIA_BUFFER_HANDLE_T* pBufHandle;
	MEDIA_CHANNEL_T	ch;

	assert(pMP != NULL);

	if (szURI == NULL)
	{
		tp_media_player_error(pMP, TP_MEDIAPLAYER_ERROR_BAD_PARAMETER, "Bad Parameter.");
		return -1;
	}

	if (TP_MediaPlayer_GetCodecType(szURI) != MEDIA_AUDIO_PCM)
	{
		DBG_PRINT_TP("Only PCM format is supported for play_sound().");
		return -1;
	}

	if (_ghEffectMap == NULL)
	{
		DBG_PRINT_TP("Internal Error. - Couldn't get the map of effect sound buffer.");
		return -1;
	}

	pBufHandle = (MEDIA_BUFFER_HANDLE_T*)API_Map_Find(_ghEffectMap, szURI);

	if (pBufHandle == NULL)
	{
		pBufHandle = _PlayClip_BufferingMedia(szURI);
		if (pBufHandle == NULL)
		{
			DBG_PRINT_TP("Buffering failed.");
			return -1;
		}

		API_Map_Insert(_ghEffectMap, (char*)szURI, pBufHandle);
	}

	// When the main channel is available, we must use main channel or it should fail to play.
	ch = TP_MediaPlayer_IsMainChAvailable() ? MEDIA_CH_A : MEDIA_CH_B;

	HOA_MEDIA_StopClip(ch);

	if (ch == MEDIA_CH_A)
	{
		res = HOA_MEDIA_StartChannel(ch, MEDIA_TRANS_BUFFERCLIP, MEDIA_FORMAT_WAV, MEDIA_AUDIO_PCM);

		if (res != HOA_OK)
		{
			DBG_PRINT_TP("HOA_MEDIA_StartChannel() failed. (%d)", res);
			return -1;
		}
	}

	res = HOA_MEDIA_PlayClipBuffer(ch, pBufHandle, 1,
			MEDIA_TRANS_BUFFERCLIP, MEDIA_FORMAT_WAV, MEDIA_AUDIO_PCM,
			(UINT8*)&_gPCMInfo, sizeof(_gPCMInfo));

	if (ch == MEDIA_CH_A)
		HOA_MEDIA_EndChannel(ch);

	if (res != HOA_OK)
	{
		DBG_PRINT_TP("HOA_MEDIA_PlayClipBuffer() failed. (%d)", res);
		return -1;
	}

	return 0;
}

