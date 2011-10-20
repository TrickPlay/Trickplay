/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file bc_openapi.h
 *
 *  broadcast open api
 *
 *  @author    dhjung(donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _BC_OPENAPI_H_
#define _BC_OPENAPI_H_

#include <dbus/dbus.h>
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#define BC_DEBUG_ERROR(fmt, args...)	AF_DEBUG_ERRTR(fmt, ##args)

/* bc_openapi_send2tv.c */
HOA_STATUS_T	HOA_CTRL_SetAVBlock(BOOLEAN bBlockAudio, BOOLEAN bBlockVideo);
HOA_STATUS_T 	HOA_CTRL_SetAVBlockEx(BOOLEAN bBlockAudio, BOOLEAN bBlockVideo);
HOA_STATUS_T	HOA_CTRL_ResetAVBlock(void);
HOA_STATUS_T 	HOA_CTRL_ChannelDown(BOOLEAN bShowBanner, /*out*/API_CHANNEL_NUM_T *pChannelNum);
HOA_STATUS_T 	HOA_CTRL_ChannelUp(BOOLEAN bShowBanner, /*out*/API_CHANNEL_NUM_T *pChannelNum);
HOA_STATUS_T 	HOA_CTRL_GetBlackOutType(/*out*/HOA_BLACKOUT_TYPE_T *tBlackOut,/*out*/HOA_STRING_T* sBlackOut);
HOA_STATUS_T 	HOA_CTRL_FreeBlackOutType(HOA_STRING_T* sBlackOut);
HOA_STATUS_T 	HOA_CTRL_GetCurrentAVBlock(/*out*/BOOLEAN *pbBlockAudio, /*out*/BOOLEAN *pbBlockVideo);
HOA_STATUS_T 	HOA_CTRL_IsDVB(BOOLEAN *pbDVB);
HOA_STATUS_T 	HOA_CTRL_GetCurrentChannel(/*out*/HOA_CHANNEL_INFO_T *pChannelInfo);
HOA_STATUS_T 	HOA_CTRL_SetChannel(BOOLEAN bShowBanner, API_CHANNEL_NUM_T *pChannelNum);
HOA_STATUS_T 	HOA_CTRL_SetScreensaverOff(BOOLEAN bOff);
HOA_STATUS_T	HOA_CTRL_GetCurrentTime(TIME_T	*pTime);
HOA_STATUS_T	HOA_CTRL_GetCurrentTime_Test(TIME_T	*pTime);
#if 0
HOA_STATUS_T 	HOA_CTRL_GetLanguage(UINT32 *pLanguage);
#endif

HOA_STATUS_T	HOA_CTRL_Get3DMode(HOA_TV_3D_INPUTMODE_TYPE_T *p3DType, BOOLEAN *pbLRBalance);
HOA_STATUS_T 	HOA_CTRL_Set3DMaster(BOOLEAN b3DMaster, BOOLEAN b2Dto3DMaster, BOOLEAN bEnter);

HOA_STATUS_T 	HOA_CTRL_CreateAppsInitMsgBox(void);
HOA_STATUS_T 	HOA_CTRL_SetVolume(BOOLEAN bShowVolumebar, HOA_APP_TYPE_T appType, BOOLEAN bRelative, SINT8 volumeIn, /*out*/UINT8 *pVolumeOut);
HOA_STATUS_T 	HOA_CTRL_GetCurrentVolume(HOA_APP_TYPE_T appType, /*out*/SINT8 *pVolume);
HOA_STATUS_T 	HOA_CTRL_SetMute(BOOLEAN bShowVolumebar, BOOLEAN bMute);
HOA_STATUS_T 	HOA_CTRL_GetMute(BOOLEAN *pbMute);

HOA_STATUS_T 	HOA_CTRL_SetAspectRatio(HOA_ASPECT_RATIO_T ratio);
HOA_STATUS_T 	HOA_CTRL_ResetAspectRatio(void);
HOA_STATUS_T 	HOA_CTRL_SetDefaultPQ(void);
HOA_STATUS_T 	HOA_CTRL_SetLocalDimmingOFF(void);
HOA_STATUS_T 	HOA_CTRL_GetCurrentTime(TIME_T *pTime);
HOA_STATUS_T 	HOA_CTRL_SetAudioMode(HOA_AUDIO_MODE_T audioMode);
HOA_STATUS_T 	HOA_CTRL_GetAudioMode(HOA_AUDIO_MODE_T *pAudioMode);
HOA_STATUS_T 	HOA_CTRL_GetLanguage(UINT32 *pLanguage);
HOA_STATUS_T 	HOA_CTRL_GetCountry(UINT32 *pCountry);
HOA_STATUS_T 	HOA_CTRL_GetLocaleInfo(UINT32 localeType, UINT32 *pLocaleInfo);
HOA_STATUS_T	HOA_CTRL_CheckPassword(UINT8 *pPassword, BOOLEAN *pbMatched);
HOA_STATUS_T	HOA_CTRL_GetParentalGuidanceSettings(HOA_RATING_TYPE_T ratingType, UINT8 settingsSize, /*out*/UINT8 *pSettings);
HOA_STATUS_T	HOA_CTRL_GetParentalLockOnOff(BOOLEAN *pbOn);
HOA_STATUS_T	HOA_CTRL_SwitchToOSD(HOA_CTRL_OSD_TYPE_T osdType, HOA_CTRL_OSD_UPDATE_TYPE_T updateType);
HOA_STATUS_T	HOA_CTRL_SetNSUMenu(void);
HOA_STATUS_T 	HOA_CTRL_GetDisplayMode(HOA_DISPLAYMODE_T *pDisplayMode);
HOA_STATUS_T	HOA_CTRL_GetScheduleList(HOA_SCHEDULE_INFO_LIST_T *pScheduleInfoList);
HOA_STATUS_T	HOA_CTRL_FreeScheduleList(HOA_SCHEDULE_INFO_LIST_T *pScheduleInfoList);
HOA_STATUS_T	HOA_CTRL_FreeChannelList(HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T	HOA_CTRL_FreeEventInfoList(HOA_EVENT_INFO_LIST_T *pEventInfoList);
HOA_STATUS_T	HOA_CTRL_GetChannelList(UINT32 attribute, UINT32 startNum, HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T 	HOA_CTRL_GetSecureSerialNumber(UINT8 serial[256]);
HOA_STATUS_T 	HOA_CTRL_GetCurrentAspectRatio(HOA_ASPECT_RATIO_T *pRatio);
HOA_STATUS_T 	HOA_CTRL_GetCurrentDisplayArea(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);
HOA_STATUS_T 	HOA_CTRL_SetDimmingOff(BOOLEAN bOff);
HOA_STATUS_T 	HOA_CTRL_GetCurrCountryGroupName(char** ppszGroup);
HOA_STATUS_T 	HOA_CTRL_GetSdkVer(char** ppVer);
HOA_STATUS_T 	HOA_CTRL_GetNetcastPlatformVer(char** ppVer);

HOA_STATUS_T 	HOA_CTRL_GetMediaServerCount (UINT32 *pCount);
HOA_STATUS_T 	HOA_CTRL_GetMediaServerList (MEDIA_SERVER_LIST_T *pServerList);
HOA_STATUS_T 	HOA_CTRL_DoCommand2UI(UINT32 nCmd, UINT32 *param);
HOA_STATUS_T 	HOA_CTRL_GetPictureValue(UINT32 nitemID, UINT16 *pValue);
HOA_STATUS_T 	HOA_CTRL_CreateDefaultBanner(void);

HOA_STATUS_T HOA_CTRL_SetVideoResize(HOA_RECT_T resizeRect, BOOLEAN bDirect, BOOLEAN bSetARC);
HOA_STATUS_T HOA_CTRL_SetResetVideoResize(void);

HOA_STATUS_T 	HOA_CTRL_UpdateErrLog(int module, long result, char *pErrCode);
HOA_STATUS_T 	HOA_CTRL_Is2PartChannelNation(BOOLEAN *pb2PartChannelNation);
HOA_STATUS_T	HOA_CTRL_IsAllChannelEmpty(BOOLEAN *pbAllChannelEmpty);
HOA_STATUS_T 	HOA_CTRL_GetGuideCardInfo(HOA_EVENT_INFO_LIST_T* hoaEventInfoList);
HOA_STATUS_T 	HOA_CTRL_GetCurrentInputInfo(HOA_MEDIA_PATH_INDEX_T pathIndex, HOA_TV_SOURCE_TYPE_T *sourceType);
HOA_STATUS_T 	HOA_CTRL_IsReservedEvent(API_CHANNEL_NUM_T *pChannelNum, UINT8 *startTime, UINT8 *endTime, UINT32 eventID,SCHEDULE_TYPE_T *resvType);

/* bc_openapi_send2tv_hbbtv.c */
HOA_STATUS_T 	HOA_HBBTV_Call( HBBTV_MALLOC_T funcMAlloc, UINT8 **ppRet, UINT32 *pRetSz, UINT8 *pParam, UINT32 nParamSz );

HOA_STATUS_T	HOA_CTRL_GetHbbTVStatus(BOOLEAN *pbHbbTVStatus);
HOA_STATUS_T 	HOA_CTRL_CreateSNSMenu(UINT32 *GrWindowId);
HOA_STATUS_T 	HOA_CTRL_GetAudioLanguage(UINT32 *pAudioLanguage);
HOA_STATUS_T	HOA_CTRL_GetAudioMode(HOA_AUDIO_MODE_T *pAudioMode);
HOA_STATUS_T 	HOA_CTRL_SetAudioMode(HOA_AUDIO_MODE_T audioMode);
HOA_STATUS_T    HOA_CTRL_SmartTextSupport(ADDON_HOST_USER_SMART_MSG_T showSlect, ADDON_SMART_TEXT_T smartText);
HOA_STATUS_T 	HOA_CTRL_GetLocaleInfo(UINT32 localeType, UINT32 *pLocaleInfo);
HOA_STATUS_T 	HOA_CTRL_GetLocalTimeOffset(BOOLEAN *pbPlus, UINT8 *pOffsetHour, UINT8 *pOffsetMin);
HOA_STATUS_T 	HOA_CTRL_GetNSUVersion(UINT32 *pVersion);
HOA_STATUS_T 	HOA_CTRL_EnterVirtualPath (MEDIA_TRANSPORT_T mediaTransportType,
MEDIA_FORMAT_T	combinedFormatType, MEDIA_CODEC_T combinedCodecType);
HOA_STATUS_T 	HOA_CTRL_ExitVirtualPath(void);
//HOA_STATUS_T 	HOA_CTRL_SendMessage(HOA_CTRL_MESSAGE_TYPE_T message, UINT32 param);
HOA_STATUS_T 	HOA_CTRL_SetCursorNavigationSupport(BOOLEAN bSupport);
HOA_STATUS_T 	HOA_CTRL_SetLocalDimmingOFF(void);
HOA_STATUS_T	HOA_CTRL_GetMediaLinkState(UINT32 *pMediaLinkState);
HOA_STATUS_T 	HOA_CTRL_SetMediaLinkState(UINT32 mediaLinkState);
HOA_STATUS_T 	HOA_CTRL_GetSubtitleLanguage(UINT32 *pSubtitleLanguage);
HOA_STATUS_T 	HOA_CTRL_GetSubtitleOnOff(BOOLEAN *pbSubtitleOnOff);
HOA_STATUS_T 	HOA_CTRL_CreatePopup(HOA_POPUP_OPTION_T *pPopupOption, POPUP_CB_T pfnPopupCB, UINT32 *pPopupHandle);
HOA_STATUS_T 	HOA_CTRL_CreateMuteOSD(void);
HOA_STATUS_T 	HOA_CTRL_DestroyPopup(UINT32 popupHandler);

HOA_STATUS_T 	HOA_CTRL_SetVCSCondition(BOOLEAN bVCSCondition);
HOA_STATUS_T 	HOA_CTRL_GetVCSCondition(BOOLEAN *pbVCSCondition);
HOA_STATUS_T 	HOA_CTRL_GetWebcamOnOff(BOOLEAN *pbOn);
HOA_STATUS_T 	HOA_CTRL_SetWebcamDisplaySettings(BOOLEAN bOn, HOA_RECT_T *pOutRect);
HOA_STATUS_T 	HOA_CTRL_SendVCSSetCmd( char *pszMethod, UINT32 argSize, char *pszStr );
HOA_STATUS_T 	HOA_CTRL_SendVCSGetCmd( char *pszMethod, UINT32 argSize, char *pszStr, char *pszData );
HOA_STATUS_T 	HOA_CTRL_RegisterVCSCallback(VCS_CB_T pfnVCSCB);
HOA_STATUS_T 	VCS_SEND_EventNoti(VCS_CB_MSG_T cbMsg, UINT32 eventSize, UINT8 *pEvent, UINT32 dataSize, UINT8 *pData );

HOA_STATUS_T 	HOA_CTRL_SetDisplayMode(HOA_DISPLAYMODE_T displayMode);
HOA_STATUS_T 	HOA_CTRL_SetDisplayArea(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);
HOA_STATUS_T 	HOA_CTRL_SetDisplayAreaEx(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);


HOA_STATUS_T 	HOA_CTRL_GetModelSecret(char **ppszModelSecret);
HOA_STATUS_T 	HOA_CTRL_GetSWU_OTAID(char **ppszOtaid);
HOA_STATUS_T 	HOA_CTRL_GetHardwareVersion(UINT8 *pHardwareVersion);
HOA_STATUS_T 	HOA_CTRL_IsSdpProductionMode (BOOLEAN *pbSdpProductionMode);
HOA_STATUS_T	HOA_CTRL_GetModelName(char **ppModelName);
HOA_STATUS_T 	HOA_CTRL_IsSupportWiFi(BOOLEAN *pbSupportWifi);
HOA_STATUS_T 	HOA_CTRL_IsSupportWiFiBuiltin(BOOLEAN *pbSupportWifiBuiltin);
HOA_STATUS_T 	HOA_CTRL_GetSWVersion(char **ppSWVersion);
HOA_STATUS_T 	HOA_CTRL_IsSupportSkype(BOOLEAN *pbSupportSkype);
HOA_STATUS_T 	HOA_CTRL_GetDisplayResolutionMD(UINT32 *pDispResolution);
HOA_STATUS_T 	HOA_CTRL_GetOsdResolution(UINT32 *pOSDResolution);
HOA_STATUS_T 	HOA_CTRL_Get3DSupportType(SUPPORT_3D_TYPE_T *p3DMode);
HOA_STATUS_T 	HOA_CTRL_IsSupportMotionRemocon(MOTION_REMOCON_TYPE_T	*pMCtype);
HOA_STATUS_T	HOA_CTRL_SetRecentItem( UINT32 recentType, UINT32 iconPathSz, CHAR *iconPath, UINT32 etcDataSz, CHAR *etcData);
HOA_STATUS_T 	HOA_CTRL_GetPlatformInfo(char** ppInfo);
HOA_STATUS_T 	HOA_CTRL_ConvTime2UnicodeString( TIME_T time,TIME_OPTION_T option, char *pszData );
HOA_STATUS_T 	HOA_CTRL_DTV_Action_InDetail(HOA_DTV_DETAIL_ACTION_SPEC_T detail_spec);



/* bc_openapi_send2tv_io.c */
HOA_STATUS_T 	HOA_IO_GetAvailableStorage(UINT32 *pStorage);
HOA_STATUS_T 	HOA_IO_GetMountedDevList(HOA_IO_MOUNT_DEV_LIST_T *pusbMount);
HOA_STATUS_T	HOA_IO_GetUSBDevType(UINT32 *pusbDevType);
HOA_STATUS_T 	HOA_IO_GetUSBDeviceNum(UINT32 *pusbDevNum, HOA_IO_USB_DEV_TYPE_T usbDevType);
HOA_STATUS_T 	HOA_IO_SetUSBFormat(CHAR *pDevName, HOA_IO_USB_DEV_TYPE_T deviceType);
HOA_STATUS_T 	HOA_IO_SetUSBDevFormat(UINT32 usbDevNum, HOA_IO_USB_DEV_TYPE_T deviceType);
HOA_STATUS_T 	HOA_IO_GetMaxDevNum(UINT32 *pMaxDevNum);
HOA_STATUS_T 	HOA_IO_GetUSBProductName(UINT32 usbDevNum, CHAR *pusbProductName);
HOA_STATUS_T 	HOA_IO_GetStoragePath(UINT32 usbDevNum, char *pszPath);
HOA_STATUS_T 	HOA_IO_GetDeviceInfo(UINT32 usbDevNum, HOA_IO_USB_DEV_INFO_T *pusbDevInfo);
//HOA_STATUS_T 	HOA_DOWNLOAD_StartFormat1(UINT32 discId);

HOA_STATUS_T 	HOA_IO_GetBSIOnOff(BOOLEAN *pbBSIOn);
HOA_STATUS_T 	HOA_IO_PrintBSI(const char * pcBSIMsg, ...);
HOA_STATUS_T 	HOA_IO_GetCapability(HOA_CTRL_SUPPORT_TYPE_T supportType, UINT32 *pSupport);
HOA_STATUS_T 	HOA_IO_GetDisplayPanelType(HOA_TV_PANEL_ATTRIBUTE_TYPE_T panelAttribType, UINT32 *pType);
HOA_STATUS_T 	HOA_IO_GetDisplayResolution(UINT32 *pWidth, UINT32 *pHeight);
HOA_STATUS_T 	HOA_IO_GetInstartSystemInformation(HOA_INSTART_SYSTEM_INFO_T *pInstartsysteminfo);
HOA_STATUS_T 	HOA_IO_GetSystemInfo(HOA_CTRL_INFO_T *pSystemInfo);

HOA_STATUS_T 	HOA_IO_CheckAppStoreInternal(HOA_TVAPPS_APPSTORE_CHECK_TYPE_T *pCheckAppStore);
HOA_STATUS_T 	HOA_IO_CheckCPBox(BOOLEAN *pbCPBox);
HOA_STATUS_T 	HOA_IO_CopyFile(char *pszPathSrc, char *pszPathDest);
HOA_STATUS_T 	HOA_IO_DeleteFile(char *pszPath, BOOLEAN bRecursive);
HOA_STATUS_T 	HOA_IO_MoveFile(char *pszPathSrc, char *pszPathDest);
HOA_STATUS_T 	HOA_IO_SetAppStoreInternalFormat(void);

HOA_STATUS_T  HOA_IO_GetNetworkStatus(char *pszIpAddress , HOA_NETWORK_TYPE_T *pActivatedNetwork, HOA_NETWORK_STATUS_T *pStatus);
HOA_STATUS_T  HOA_IO_GetNetworkSettings(HOA_NETWORK_TYPE_T networkType, HOA_NETCONFIG_T *pNetworkSettings);
HOA_STATUS_T  HOA_IO_SetNetworkSettings(HOA_NETWORK_TYPE_T networkType, HOA_NETCONFIG_T *pNetworkSettings);
HOA_STATUS_T  HOA_IO_GetWirelessNetworkStatus(HOA_WIRELESSNETWORK_STATUS_T *pStatus);

HOA_STATUS_T 	HOA_CRYPTO_NF_Initialize(const char *pIDFilePath);
HOA_STATUS_T 	HOA_CRYPTO_NF_Finalize(void);
HOA_STATUS_T 	HOA_CRYPTO_NF_GetESN(UINT8* pEsn);
HOA_STATUS_T 	HOA_CRYPTO_NF_GetKde(UINT8* pKde);
HOA_STATUS_T 	HOA_CRYPTO_NF_GetKdh(UINT8* pKdh);
HOA_STATUS_T 	HOA_CRYPTO_NF_Encrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_NF_Decrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_OpenKeySlot(void);
HOA_STATUS_T 	HOA_CRYPTO_CloseKeySlot(void);
HOA_STATUS_T 	HOA_CRYPTO_GetHWRandomNumber(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_Encrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_Decrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_SFU_Initialize(const char *pSeedPath);
HOA_STATUS_T 	HOA_CRYPTO_SFU_Finalize(void);
HOA_STATUS_T 	HOA_CRYPTO_SFU_GetRSAKey(UINT8 *pData);
HOA_STATUS_T 	HOA_CRYPTO_SFU_GetAESKey(UINT8 *pData);

HOA_STATUS_T 	HOA_CTRL_Request_Login(void);
HOA_STATUS_T	HOA_CTRL_Request_Signup(void);
HOA_STATUS_T 	HOA_CTRL_Request_ConfirmUser(HOA_LOGIN_CONFIRM_TYPE_T type);
HOA_STATUS_T 	HOA_CTRL_Request_Purchase(SDPIF_PURCHASE_IN_T purchaseIn);
HOA_STATUS_T 	HOA_CTRL_SetAgreedTerms(BOOLEAN popup);
HOA_STATUS_T 	HOA_CTRL_BillingCBRegister(BILLING_CB_T pfnBillingCB);
HOA_STATUS_T 	HOA_SDPIF_SetShowSelectCountry(BOOLEAN bIsShow);
HOA_STATUS_T 	HOA_SDPIF_RequestNordicCountryInformation(BOOLEAN *pNordicCountryInfo);
HOA_STATUS_T 	HOA_SDPIF_NotifyCountryAuto(BOOLEAN bAutoCountry);
HOA_STATUS_T 	HOA_SDPIF_GetShowSelectCountry (BOOLEAN *bIsShow);

// Smart Share
HOA_STATUS_T 	HOA_SMTS_GetInitScene(UINT32* pScene);
HOA_STATUS_T	HOA_SMTS_Initialize(UINT32* pResult);
HOA_STATUS_T	HOA_SMTS_Finalize(void);
HOA_STATUS_T	HOA_SMTS_InitList(HOA_SMTS_LIST_TYPE_T hoaListType, HOA_SMTS_SORT_TYPE_T hoaSortType, UINT8 *pFullPath
											, UINT32 maxPageItemNum, UINT32 *pTotalItemNum);
HOA_STATUS_T	HOA_SMTS_UpdatePage(UINT32 mode, UINT32 param, UINT32 *pTotalItemNum);
HOA_STATUS_T	HOA_SMTS_GetLastFocusMediaId(UINT32 *pTotalItemNum, UINT32 *pMediaId);
HOA_STATUS_T 	HOA_SMTS_SetCurrentListType(UINT32 listType);
HOA_STATUS_T 	HOA_SMTS_GetListItemArray(UINT32 mediaId, UINT32 count, AF_BUFFER_HNDL_T* pBuffHandler);
HOA_STATUS_T 	HOA_SMTS_ClearListItemArray(void);
HOA_STATUS_T	HOA_SMTS_GetVideoMetaByMediaId(UINT32 mediaId, HOA_SMTS_VIDEO_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_GetPhotoMetaByMediaId(UINT32 mediaId, HOA_SMTS_PHOTO_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_GetMusicMetaByMediaId(UINT32 mediaId, HOA_SMTS_MUSIC_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_GetRecTvMetaByMediaId(UINT32 mediaId, HOA_SMTS_RECTV_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_Play(UINT32 type, UINT32 mediaId);
HOA_STATUS_T	HOA_SMTS_CheckIsRecording(BOOLEAN* pisRecording);
HOA_STATUS_T 	HOA_SMTS_GetCurrentSortMode(int cType, int *pMode);
HOA_STATUS_T 	HOA_SMTS_GetTotlaLinkedDeviceNum(int *pLength);
HOA_STATUS_T 	HOA_SMTS_GetLinkedDeviceInfo(AF_BUFFER_HNDL_T* pBuffHandler);
HOA_STATUS_T	HOA_SMTS_SetExecuteDevice(UINT32 dataId,BOOLEAN bTimer);
HOA_STATUS_T 	HOA_SMTS_GetLinkedDeviceFocus(UINT32 focusType,UINT32 dataId,UINT32 *focusIndex);
HOA_STATUS_T 	HOA_SMTS_GetDeviceMenuType(int *nType);
HOA_STATUS_T 	HOA_SMTS_GetCurSpeakerFocus(int *mode);
HOA_STATUS_T 	HOA_SMTS_GetPossibleHTS(int *type);
HOA_STATUS_T	HOA_SMTS_SetSpeakerMode(UINT32 mode);
HOA_STATUS_T	HOA_SMTS_SetVideoSize(BOOLEAN bResize);
HOA_STATUS_T	HOA_SMTS_SetInputLabel(UINT32 dataId,UINT32 inputLabelIndex);
HOA_STATUS_T 	HOA_SMTS_GetConnectHeadset(BOOLEAN *bConnect);
HOA_STATUS_T 	HOA_SMTS_CBRegister(SMTS_CB_T pfnSMTSCB);
HOA_STATUS_T 	HOA_SMTS_SetInitScene(UINT32 listType);
HOA_STATUS_T 	HOA_SMTS_GetRegionInfo(int *nRegion);
HOA_STATUS_T 	HOA_SMTS_StartThumbnail(void);


// Mcast
HOA_STATUS_T HOA_MCAST_WriteMCastFile(char *pszMCastFilePath);
HOA_STATUS_T HOA_MCAST_AddScheduleList(HOA_MCAST_FLASH_SET_INFO_T stMCastList);
HOA_STATUS_T HOA_MCAST_ExecuteBasicCmd(HOA_MCAST_CMD_T eMCastCmd, HOA_MCAST_MODE_T eMCastMode, UINT8 uId, HOA_MCAST_RET_VAL_T *pMcastResult);
HOA_STATUS_T HOA_MCAST_ExecuteFileCmd(HOA_MCAST_CMD_T eMCastCmd, char *pszFileName, HOA_MCAST_RET_VAL_T *pMcastResult);
HOA_STATUS_T HOA_MCAST_ExecuteSimpleCmd(HOA_MCAST_CMD_T eMCastCmd,HOA_MCAST_RET_VAL_T *pMcastResult);
HOA_STATUS_T HOA_MCAST_SetMemoCheckedOrNot(UINT8 uId, BOOLEAN bIsChecked);
HOA_STATUS_T HOA_MCAST_SaveDumpImgToJpeg(HOA_RECT_T dumpRect);
HOA_STATUS_T HOA_MCAST_ResizeVideoForPR(UINT8 uPRSize, UINT8 uPRPos);
HOA_STATUS_T HOA_MCAST_ResetResizeVideoForPR(UINT8 uPRSize);

// Photo (temp)
HOA_STATUS_T HOA_PHOTO_PlayImageFile(UINT32 deviceType, char *pszFilePath, BOOLEAN bDisplayImageDirectly, UINT32 timeStamp);

#ifdef __cplusplus
}
#endif
#endif

