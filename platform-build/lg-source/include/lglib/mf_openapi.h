/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file mf_openapi.h
 *
 *  mediaframework open api
 *
 *  @author   	dhjung(donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _MF_OPENAPI_H_
#define _MF_OPENAPI_H_

#include <dbus/dbus.h>
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_LANGUAGE_STR_LENGTH 24//32// --> 8*32 is over 256 size.. d-bus array size limitation.
#define MAX_LANGUAGE_LIST_NUM 8

//#define MF_DEBUG_ERROR(fmt, args...)	AF_DEBUG_ERRTR(fmt, ##args)
#define MF_OPAPI_ENTER_FUNC()				MF_OPAPI_PRINT("[ENTER] %s\n", __FUNCTION__)
#define MF_OPAPI_LEAVE_FUNC()				MF_OPAPI_PRINT("[LEAVE] %s\n", __FUNCTION__)


/* mf_openapi_send2mf.c */
// for test //
HOA_STATUS_T HOA_MEDIA_InitializeTest(BOOLEAN bBlockAudio, BOOLEAN bBlockVideo);

HOA_STATUS_T HOA_MEDIA_MakeMediaBuffer(AF_BUFFER_HNDL_T **ppHandle, UINT32 bufferSize);
HOA_STATUS_T HOA_MEDIA_GetMediaBufferAddress(AF_BUFFER_HNDL_T *pHandle, char **ppBuffer);
HOA_STATUS_T HOA_MEDIA_DeleteMediaBuffer(AF_BUFFER_HNDL_T *pHandle);
HOA_STATUS_T HOA_MEDIA_SetDebugLevel(UINT32 select, char *category, UINT32 level);
HOA_STATUS_T HOA_MEDIA_Initialize(void);
HOA_STATUS_T HOA_MEDIA_Finalize(void);
HOA_STATUS_T HOA_MEDIA_StartChannel(MEDIA_CHANNEL_T ch,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType);
HOA_STATUS_T HOA_MEDIA_EndChannel(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_PlayClipBuffer(MEDIA_CHANNEL_T ch,
											AF_BUFFER_HNDL_T *pHandle,
											UINT32 repeatNumber,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pPlayOption, UINT16 playOptionSize);
HOA_STATUS_T HOA_MEDIA_PlayClipFile(MEDIA_CHANNEL_T ch,
											char *pFileName,
											UINT32 repeatNumber,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pPlayOption, UINT16 playOptionSize
											);
HOA_STATUS_T HOA_MEDIA_PauseClip(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_ResumeClip(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_SeekClip(MEDIA_CHANNEL_T ch, UINT32 playPositionMs);
HOA_STATUS_T HOA_MEDIA_StopClip(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_OpenStream(	MEDIA_CHANNEL_T ch,
											char *pFileName,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pOpenOption, UINT16 openOptionSize);
HOA_STATUS_T HOA_MEDIA_CloseStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_PlayStream(MEDIA_CHANNEL_T ch,
											AF_BUFFER_HNDL_T *pHandle,
											MEDIA_TRANSPORT_T mediaTransportType,
											MEDIA_FORMAT_T mediaFormatType,
											MEDIA_CODEC_T mediaCodecType,
											UINT8 *pPlayOption, UINT16 playOptionSize);
HOA_STATUS_T HOA_MEDIA_SendStream(MEDIA_CHANNEL_T ch, UINT32 dataSize, UINT8 *pFeedOption, UINT16 feedOptionSize);
HOA_STATUS_T HOA_MEDIA_SendStreamRaw(MEDIA_CHANNEL_T ch, UINT32 dataSize, MEDIA_CODEC_T codecType, UINT64 pts);
HOA_STATUS_T HOA_MEDIA_PushEndOfStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_PauseStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_ResumeStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_StopStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_FlushStream(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_SetTimeToDecode(MEDIA_CHANNEL_T ch, SINT64 decodedPTS);
HOA_STATUS_T HOA_MEDIA_SetBufferLevel(MEDIA_CHANNEL_T ch, UINT32 audioMinLevel, UINT32 audioMaxLevel, UINT32 videoMinLevel, UINT32 videoMaxLevel);

HOA_STATUS_T HOA_MEDIA_GetPlayInfo(MEDIA_CHANNEL_T ch, MEDIA_PLAY_INFO_T *pPlayInfo);
HOA_STATUS_T HOA_MEDIA_RegisterPlayCallback(MEDIA_CHANNEL_T ch, MEDIA_PLAY_CB_T pfnPlayCB);
HOA_STATUS_T HOA_MEDIA_RegisterPlayCallbackEx(MEDIA_CHANNEL_T ch, MEDIA_PLAY_CB_EX_T pfnPlayCB_ex);
//#ifdef INCLUDE_ACTVILA
HOA_STATUS_T HOA_MEDIA_RegisterActvilaCallback(MEDIA_CHANNEL_T ch, MEDIA_ACTVILA_CB_T pfnActvilaCB);
//#endif
HOA_STATUS_T HOA_MEDIA_GetCapturedImage(MEDIA_CHANNEL_T ch, MEDIA_FORMAT_T format, MEDIA_CAPTURED_IMAGE_T *pCapturedImage);
HOA_STATUS_T HOA_MEDIA_FreeCapturedImage(MEDIA_CHANNEL_T ch, MEDIA_CAPTURED_IMAGE_T *pCapturedImage);
HOA_STATUS_T HOA_MEDIA_SetPlaySpeed(MEDIA_CHANNEL_T ch, BOOLEAN bForward, UINT8 speedInt, UINT8 speedFrac);
HOA_STATUS_T HOA_MEDIA_GetPlaySpeed(MEDIA_CHANNEL_T ch, BOOLEAN *bForward, UINT8 *speedInt, UINT8 *speedFrac);
HOA_STATUS_T HOA_MEDIA_GetSourceInfo(MEDIA_CHANNEL_T ch, MEDIA_SOURCE_INFO_T *pSourceInfo);
HOA_STATUS_T HOA_MEDIA_GetSourceInfoForNewUri(MEDIA_CHANNEL_T ch, char *pUri, MEDIA_SOURCE_INFO_T *pSourceInfo);
HOA_STATUS_T HOA_MEDIA_InitVideoThumbnail(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_GetVideoThumbnail(MEDIA_CHANNEL_T ch, char *pPath, char *pUrl, const char *pFilename, UINT16 width, UINT16 height);
HOA_STATUS_T HOA_MEDIA_SetHttpHeader(MEDIA_CHANNEL_T ch, UINT8* pData, UINT16 dataSize);
HOA_STATUS_T HOA_MEDIA_SetSoapHttpSrcTimeout(MEDIA_CHANNEL_T ch, UINT32 timeout_sec);
HOA_STATUS_T HOA_MEDIA_GetMediaType(MEDIA_CHANNEL_T ch, HOA_MEDIA_TYPE_T *pMediaType);
HOA_STATUS_T HOA_MEDIA_GetInternalSubtitleBlock(MEDIA_CHANNEL_T ch, UINT32 ms, SYNCBLOCK **pSbutBlock);
HOA_STATUS_T HOA_MEDIA_GetInternalBmpSubtitleBlock(MEDIA_CHANNEL_T ch, UINT32 ms, SYNCBLOCK2 **pSbutBlock);
HOA_STATUS_T HOA_MEDIA_GetSubtitleBlock(MEDIA_CHANNEL_T ch, UINT32 ms, SYNCBLOCK **pSbutBlock);
HOA_STATUS_T HOA_MEDIA_SetSubtitleProperty(MEDIA_CHANNEL_T ch,HOA_MEDIA_SUBT_PROP_TYPE_T subtitleProperty,MEDIA_SUBTITLE_INFO_T subtitleInfo);
HOA_STATUS_T HOA_MEDIA_GetWidevineDevId(MEDIA_CHANNEL_T ch, CHAR *pWVDeviceID, UINT16 *pDeviceIDSize);
HOA_STATUS_T HOA_MEDIA_SetStreamAudioLanguage(UINT8 *pAudioLang, UINT8 langIndex);
HOA_STATUS_T HOA_MEDIA_SetMedia3DType(MEDIA_CHANNEL_T ch, MEDIA_3D_TYPES_T type);

HOA_STATUS_T HOA_MEDIA_Set3DType(HOA_TV_3D_INPUTMODE_TYPE_T type, BOOLEAN bLRBalance);
HOA_STATUS_T MEDIA_Get3DType(HOA_TV_3D_INPUTMODE_TYPE_T *pType, UINT8 *pLRBalance);
HOA_STATUS_T HOA_MEDIA_GetAudioProperty(MEDIA_CHANNEL_T ch, HOA_MEDIA_AUDIO_PROP_TYPE_T audioProperty, MEDIA_AUDIO_INFO_T *pAudioInfo);
HOA_STATUS_T HOA_MEDIA_GetSubtitleProperty(MEDIA_CHANNEL_T ch, HOA_MEDIA_SUBT_PROP_TYPE_T subtitleProperty, MEDIA_SUBTITLE_INFO_T *pSubtitleInfo);
HOA_STATUS_T HOA_MEDIA_CheckChannelSubtitleIsExisted(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_GetExternalSubtitleSetting(MEDIA_CHANNEL_T ch, LMF_EXT_SUBT_SETTINGS_T settingType, UINT8 *pSettingValue);
HOA_STATUS_T HOA_MEDIA_GetInternalSubtitleSettings(MEDIA_CHANNEL_T ch, LMF_INT_SUBT_SETTINGS_T settingType, UINT8 *pSettingValue);
HOA_STATUS_T HOA_MEDIA_SetExternalSubtitleSetting(MEDIA_CHANNEL_T ch, LMF_EXT_SUBT_SETTINGS_T settingType, UINT8 settingValue);
HOA_STATUS_T HOA_MEDIA_SetInternalSubtitleSettings(MEDIA_CHANNEL_T ch, LMF_INT_SUBT_SETTINGS_T settingType, UINT8 settingValue);

HOA_STATUS_T HOA_MEDIA_GetSubtitleType(MEDIA_CHANNEL_T ch, LMF_SUBT_FILE_TYPE_T *pSubtitleType);
HOA_STATUS_T HOA_MEDIA_GetLanguageCount(MEDIA_CHANNEL_T ch, int *pNumLanguage);
HOA_STATUS_T HOA_MEDIA_GetChannelAnsiEncidingType(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_GetLanguageType(MEDIA_CHANNEL_T ch, UINT32 retvalue, char** langType);

// for audio multi track playback //
//HOA_STATUS_T HOA_MEDIA_GetLanguages(MEDIA_CHANNEL_T ch);
HOA_STATUS_T HOA_MEDIA_GetLanguages(MEDIA_CHANNEL_T ch, char **pLangs, unsigned int *pStrLength, unsigned int *pTotalLangNum);
HOA_STATUS_T HOA_MEDIA_SetLanguage(MEDIA_CHANNEL_T ch, int language);
HOA_STATUS_T HOA_MEDIA_SetAudioLanguageBeforePlayback(MEDIA_CHANNEL_T ch, unsigned char *language);
HOA_STATUS_T HOA_MEDIA_GetCurrentLanguage(MEDIA_CHANNEL_T ch, int *pCurrentLanguageNum);
// for subtitle multi track playback //
HOA_STATUS_T HOA_MEDIA_GetSubtitles(MEDIA_CHANNEL_T ch, char **pLangs, unsigned int *pStrLength, unsigned int *pTotalLangNum);
HOA_STATUS_T HOA_MEDIA_SetSubtitle(MEDIA_CHANNEL_T ch, int language);
HOA_STATUS_T HOA_MEDIA_GetCurrentSubtitleLanguage(MEDIA_CHANNEL_T ch, int *pCurrentLanguageNum);

// for thumbnail. //
HOA_STATUS_T HOA_MEDIA_DownloadFile (MEDIA_CHANNEL_T ch, char *pPath, char *pUrl, const char *pFilename, MEDIA_TRANSPORT_T mediaTransportType, MEDIA_FORMAT_T mediaFormatType);
// for thumbnail manager only //
HOA_STATUS_T HOA_MEDIA_CheckDecoderIsAvailable(MEDIA_CHANNEL_T ch, BOOLEAN *bIsAvailable);
HOA_STATUS_T HOA_MEDIA_CancelVideoThumbnail(MEDIA_CHANNEL_T ch);

// for html 5
HOA_STATUS_T HOA_MEDIA_SetBuffering (MEDIA_CHANNEL_T ch, MEDIA_FORMAT_T mediaFormatType, char *pUrl);
// for flashopenapi only
HOA_STATUS_T HOA_MEDIA_GetPlayState (MEDIA_PLAY_STATE_T *playState);
HOA_STATUS_T HOA_MEDIA_SetPlayState (MEDIA_PLAY_STATE_T playState);

//#ifdef INCLUDE_ACTVILA
HOA_STATUS_T HOA_MEDIA_InitializeRomSound(void);
HOA_STATUS_T HOA_MEDIA_FinalizeRomSound(void);
HOA_STATUS_T HOA_MEDIA_PlayRomSound(UINT32 sound_id);
//#endif

#ifdef INCLUDE_JPMARLIN
HOA_STATUS_T HOA_MEDIA_SetCPCData(char *buffer, UINT32 size);
#endif


typedef struct HOA_MEDIA_OUTPUT_SECURITY_SETTING
{
    UINT8       APS;    /* analog protection system */
    UINT8       CGMS;   /* copy management */
    BOOLEAN     bPreventUpscaling;  /* upscaling prohibited on analog outputs by CSS */
    BOOLEAN     bHDCPEncryption;        /* HDCP type encryption or no encryption */
} HOA_MEDIA_OUTPUT_SECURITY_SETTING_T;
HOA_STATUS_T HOA_MEDIA_SetOutputSecurity(HOA_MEDIA_OUTPUT_SECURITY_SETTING_T *pSettings);
HOA_STATUS_T HOA_MEDIA_GetOutputSecurity(HOA_MEDIA_OUTPUT_SECURITY_SETTING_T *pSettings);
// for DRM Common //
HOA_STATUS_T HOA_DRM_SetCpName(char *cpname);
// for Playready Only //
unsigned int HOA_DRM_PR_GetClientInfoSize(void);
HOA_STATUS_T HOA_DRM_PR_GetClientInfo(char *clientInfo, unsigned int clientInfoLen);
HOA_STATUS_T HOA_DRM_PR_PreActivate(unsigned char *license, unsigned int licenseLen);
unsigned int HOA_DRM_PR_GetActivateFailMessageSize(void);
HOA_STATUS_T HOA_DRM_PR_GetActivatingFailedMessage(char *failMsg, unsigned int failMsgLen);
BOOLEAN HOA_DRM_PR_CheckValidDrmTime(void);
// for verimatrix
HOA_STATUS_T HOA_DRM_VM_Initialize(HOA_MEDIA_SERVICE_TYPE_T client, CHAR *pCPName,CHAR *pVMConfigData);
//for widevine
HOA_STATUS_T HOA_DRM_WV_CheckDevId(void);
HOA_STATUS_T HOA_DRM_WV_GetDevId(char *widevinekey, unsigned int *keyInfoLen);
// for OIPF
HOA_STATUS_T HOA_DRM_RegisterDRMMsgResultCallback( HOA_DRM_MSG_RESULT_CB_T pfnHOADRMMsgResultCB );
HOA_STATUS_T HOA_DRM_UnRegisterDRMMsgResultCallback( void );
HOA_STATUS_T HOA_DRM_SendDRMMessage( char* pszMsgType, char* pszMsg, char* pszDRMSystemID, char** ppszMsgID );
HOA_STATUS_T HOA_DRM_RegisterDRMRightsErrCallback( HOA_DRM_RIGHTS_ERR_CB_T pfnHOADRMRightsErrCB );
HOA_STATUS_T HOA_DRM_UnRegisterDRMRightsErrCallback( void) ;

//////////////////*  from addon hoa disc.h   *//////////////////////////



//HOA_STATUS_T DOWNLOAD_SendNoti(UINT8 downloadID, DOWNLOAD_CB_MSG_T msg);
//HOA_STATUS_T DOWNLOAD_RegisterCallbackAddon(HOA_APP_TYPE_T appType, UINT16 appPID,
//												DOWNLOAD_CB_T pfnDownloadCB);
//HOA_STATUS_T DOWNLOAD_DiscSendNoti(DISC_CB_MSG_T msg);
//HOA_STATUS_T DOWNLOAD_RegisterDiscCallbackAddon(HOA_APP_TYPE_T appType, UINT16 appPID,
//											DISC_CB_T pfnDiscCB);
HOA_STATUS_T HOA_DOWNLOAD_GetDiscInfo(HOA_DISC_INFO_T *pDiscInfo, UINT8 discId);
HOA_STATUS_T HOA_DOWNLOAD_StartFormat(UINT8 discId);
HOA_STATUS_T HOA_DOWNLOAD_GetDownloadInfo(HOA_DOWNLOAD_INFO_T *pDownloadInfo, UINT8 id);
HOA_STATUS_T HOA_DOWNLOAD_CheckDownloadIsPossible(HOA_DISC_DOWNLOAD_POSSIBLE_STATE_T *pChcekDownload, UINT64 downloadSize);
HOA_STATUS_T HOA_DOWNLOAD_Download(HOA_CONTENT_ENTRY_T *pContentEntry, UINT8 *pDownloadId);
HOA_STATUS_T HOA_DOWNLOAD_GetDownloadId(UINT8 *nTotalDown, UINT8 **downloadIDs);
HOA_STATUS_T HOA_DOWNLOAD_PauseDownload(UINT8 downloadID);
HOA_STATUS_T HOA_DOWNLOAD_ResumeDownload(UINT8 downloadID);
HOA_STATUS_T HOA_DOWNLOAD_RemoveDownload(UINT8 downloadID);
HOA_STATUS_T HOA_DOWNLOAD_RemoveOnlyMedia(UINT8 downloadID);
HOA_STATUS_T HOA_DOWNLOAD_RegisterDownloadCallback(DOWNLOAD_CB_T pfnDLCB);
HOA_STATUS_T HOA_DOWNLOAD_RegisterDiscCallback(DISC_CB_T pfnDiscCB);
HOA_STATUS_T HOA_DOWNLOAD_GetSecurityVersion(UINT8 **pSecurityVersion);
HOA_STATUS_T HOA_DOWNLOAD_GetDrmInfo(UINT8 downloadID, BOOLEAN *pbIsDrmProtected, BOOLEAN *pbHasValidLicense,HOA_DOWNLOAD_STATUSCONTENTLICENSE_T *pLicenseStatus) ;
HOA_STATUS_T HOA_DOWNLOAD_GetDownloadPath(UINT8 **pDownloadPath, UINT8 downloadID);
HOA_STATUS_T HOA_DOWNLOAD_CheckWmdrmProtected(BOOLEAN *pbDrmProtected, UINT8 downloadID);
HOA_STATUS_T HOA_DOWNLOAD_CheckWmdrmHasValidContentLicense(BOOLEAN *pbHasLicense, UINT8 downloadID);

#ifdef __cplusplus
}
#endif
#endif
