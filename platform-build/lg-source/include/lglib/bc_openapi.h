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
HOA_STATUS_T 	HOA_CTRL_GetBlackOutType(/*out*/HOA_BLACKOUT_TYPE_T *tBlackOut,/*out*/HOA_BLACKOUT_STRING_T* sBlackOut);
HOA_STATUS_T 	HOA_CTRL_GetCurrentAvBlock(/*out*/BOOLEAN *pbBlockAudio, /*out*/BOOLEAN *pbBlockVideo);
HOA_STATUS_T 	HOA_CTRL_CheckBroadcastIsDvb(BOOLEAN *pbDVB);
/*epg recommand*/
HOA_STATUS_T 	HOA_CTRL_EventDetail4Recommand(UINT32 type, HOA_EVENT_DETAIL_T *pEventDetail);
HOA_STATUS_T 	HOA_CTRL_GetCurrentChannel(/*out*/HOA_CHANNEL_INFO_T *pChannelInfo);
HOA_STATUS_T 	HOA_CTRL_GetCurrentInputSourceString(HOA_INPUTSOURCE_STRING_T *pInputSourceStr);
HOA_STATUS_T 	HOA_CTRL_SetChannel(BOOLEAN bShowBanner, API_CHANNEL_NUM_T *pChannelNum);
HOA_STATUS_T 	HOA_CTRL_SetScreensaverOff(BOOLEAN bOff);
HOA_STATUS_T	HOA_CTRL_GetCurrentTime(TIME_T	*pTime);
HOA_STATUS_T	HOA_CTRL_GetCurrentTime_Test(TIME_T	*pTime);
#if 0
HOA_STATUS_T 	HOA_CTRL_GetLanguage(UINT32 *pLanguage);
#endif

HOA_STATUS_T	HOA_CTRL_Get3DMode(HOA_TV_3D_INPUTMODE_TYPE_T *p3DType, BOOLEAN *pbLRBalance);
HOA_STATUS_T	HOA_CTRL_GetDualPlayOnOff(BOOLEAN *onoff);
HOA_STATUS_T 	HOA_CTRL_Set3DMaster(BOOLEAN b3DMaster, BOOLEAN b2Dto3DMaster, BOOLEAN bEnter);
HOA_STATUS_T 	HOA_CTRL_Set3DKeyProperties(HOA_TV_3DKEY_PROPERTY_T e3DKeyProperty);
HOA_STATUS_T 	HOA_CTRL_Set3DGraphicPreAct(BOOLEAN bEnter);
HOA_STATUS_T 	HOA_CTRL_Set3DGraphicMaster(BOOLEAN b3DOnOff, HOA_TV_3D_INPUTMODE_TYPE_T e3DType, BOOLEAN bLRBalance);


HOA_STATUS_T 	HOA_CTRL_InitializeMessageBox(void);
HOA_STATUS_T 	HOA_CTRL_SetVolume(BOOLEAN bShowVolumebar, HOA_APP_TYPE_T appType, BOOLEAN bRelative, SINT8 volumeIn, /*out*/UINT8 *pVolumeOut);
HOA_STATUS_T 	HOA_CTRL_GetCurrentVolume(HOA_APP_TYPE_T appType, /*out*/SINT8 *pVolume);
HOA_STATUS_T 	HOA_CTRL_SetMute(BOOLEAN bShowVolumebar, BOOLEAN bMute);
HOA_STATUS_T 	HOA_CTRL_GetMute(BOOLEAN *pbMute);

HOA_STATUS_T 	HOA_CTRL_SetAspectRatio(HOA_ASPECT_RATIO_T ratio);
HOA_STATUS_T 	HOA_CTRL_ResetAspectRatio(void);
HOA_STATUS_T 	HOA_CTRL_SetDefaultPQ(void);
HOA_STATUS_T 	HOA_CTRL_SetLocalDimmingOFF(void);
HOA_STATUS_T 	HOA_CTRL_GetCurrentTime(TIME_T *pTime);
HOA_STATUS_T 	HOA_CTRL_CreateSetupByListId(HOA_MENU_LIST_ID_T menuListID);
HOA_STATUS_T 	HOA_CTRL_SetAudioMode(HOA_AUDIO_MODE_T audioMode);
HOA_STATUS_T 	HOA_CTRL_GetAudioMode(HOA_AUDIO_MODE_T *pAudioMode);
HOA_STATUS_T 	HOA_CTRL_GetLanguage(UINT32 *pLanguage);
HOA_STATUS_T 	HOA_CTRL_GetVoiceLanguage(UINT32 *gCurrLang);
HOA_STATUS_T 	HOA_CTRL_GetCountry(UINT32 *pCountry);
HOA_STATUS_T 	HOA_CTRL_GetLocaleInfo(UINT32 localeType, UINT32 *pLocaleInfo);
HOA_STATUS_T 	HOA_CTRL_GetOldLocaleInfo(UINT32 localeType, UINT32 *pLocaleInfo);
HOA_STATUS_T 	HOA_CTRL_GetMRCUInfo(UINT32 mrcuType, UINT32 *pMrcuInfo);
HOA_STATUS_T	HOA_CTRL_CheckPassword(UINT8 *pPassword, BOOLEAN *pbMatched);
HOA_STATUS_T	HOA_CTRL_GetParentalGuidanceSetting(HOA_RATING_TYPE_T ratingType, UINT8 settingsSize, /*out*/UINT8 *pSettings);
HOA_STATUS_T	HOA_CTRL_CheckParentalIsLocked(BOOLEAN *pbOn);
HOA_STATUS_T	HOA_CTRL_SwitchToOSD(HOA_CTRL_OSD_TYPE_T osdType, HOA_CTRL_OSD_UPDATE_TYPE_T updateType);
HOA_STATUS_T	HOA_CTRL_SetNsuMenu(void);
HOA_STATUS_T 	HOA_CTRL_SetVoiceUiSection(int x, int y, int width, int height);
HOA_STATUS_T 	HOA_CTRL_RequestMessageBox(UINT32 type, UINT32 param1, UINT32 param2, UINT32 param3);
HOA_STATUS_T 	HOA_CTRL_GetDisplayMode(HOA_DISPLAYMODE_T *pDisplayMode);
HOA_STATUS_T	HOA_CTRL_GetScheduleList(HOA_SCHEDULE_INFO_LIST_T *pScheduleInfoList);
HOA_STATUS_T	HOA_CTRL_FreeScheduleList(HOA_SCHEDULE_INFO_LIST_T *pScheduleInfoList);
HOA_STATUS_T	HOA_CTRL_FreeChannelList(HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T	HOA_CTRL_FreeEventInfoList(HOA_EVENT_INFO_LIST_T *pEventInfoList);
HOA_STATUS_T	HOA_CTRL_GetChannelList(UINT32 attribute, UINT32 startNum, HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T	HOA_CTRL_CaptureScreen(const char* pszOutPath, const HOA_RECT_T* pSrcRect, UINT32 outWidth, UINT32 outHeight, HOA_CAPTURE_FORMAT_T format);
HOA_STATUS_T	HOA_CTRL_GetSeparateOsdMode(BOOLEAN* pbSepOSD);
HOA_STATUS_T	HOA_CTRL_SetSeparateOsdMode(BOOLEAN bSepOSD);


HOA_STATUS_T 	HOA_CTRL_GetTunerInputTypeCount(UINT32 type, HOA_TUNER_INPUT_TYPE_INFO_T *pTunerInfo);
HOA_STATUS_T	HOA_CTRL_FreeChannelLists(HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T	HOA_CTRL_GetChannelListByType(UINT32 attribute, UINT32 inputMask, UINT32 startNum, HOA_CHANNEL_LIST_T *pChannelList);
HOA_STATUS_T 	HOA_CTRL_GetSecureSerialNum(UINT8 serial[256]);
HOA_STATUS_T  	HOA_CTRL_GetSecureData(UINT8 *pPath, UINT8 **ppData, UINT32 *pLen);
HOA_STATUS_T 	HOA_CTRL_GetCurrentAspectRatio(HOA_ASPECT_RATIO_T *pRatio);
HOA_STATUS_T 	HOA_CTRL_GetCurrentDisplayArea(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);
HOA_STATUS_T 	HOA_CTRL_SetDimmingOff(BOOLEAN bOff);
HOA_STATUS_T 	HOA_CTRL_GetCurrCountryGroupName(char** ppszGroup);
HOA_STATUS_T 	HOA_CTRL_GetSdkVersion(char** ppVer);
HOA_STATUS_T 	HOA_CTRL_GetNetcastPlatformVersion(char** ppVer);

HOA_STATUS_T 	HOA_CTRL_GetMediaServerCount (UINT32 *pCount);
HOA_STATUS_T 	HOA_CTRL_GetMediaServerList (MEDIA_SERVER_LIST_T *pServerList);
HOA_STATUS_T 	HOA_CTRL_DoCommandToUi(UINT32 nCmd, int *param);
HOA_STATUS_T 	HOA_CTRL_GetPictureValue(UINT32 nitemID, int *pValue);
HOA_STATUS_T 	HOA_CTRL_CreateDefaultBanner(void);

HOA_STATUS_T HOA_CTRL_SetVideoResize(HOA_RECT_T resizeRect, BOOLEAN bDirect, BOOLEAN bSetARC);
HOA_STATUS_T HOA_CTRL_SetResetVideoResize(void);
HOA_STATUS_T HOA_CTRL_SetResetVideoResizeWithDelay(UINT32 delayTime);


HOA_STATUS_T 	HOA_CTRL_UpdateErrorLog(int module, long result, char *pErrCode);

HOA_STATUS_T HOA_CTRL_PopupPairingWindow (int param);

HOA_STATUS_T 	HOA_CTRL_CheckNationHas2PartChannel(BOOLEAN *pb2PartChannelNation);
HOA_STATUS_T	HOA_CTRL_CheckTunedChannelIsExisting(BOOLEAN *pbAllChannelEmpty);
HOA_STATUS_T 	HOA_CTRL_GetGuideCardInfo(HOA_EVENT_INFO_LIST_T* hoaEventInfoList);
HOA_STATUS_T 	HOA_CTRL_GetEventInfoList(API_CHANNEL_NUM_T *pChannelNum, TIME_T *pStartTime, TIME_T *pEndTime, HOA_EVENT_INFO_T **ppEventInfoList, UINT16 *pNumEvent);
HOA_STATUS_T 	HOA_CTRL_GetCurrentInputInfo(HOA_MEDIA_PATH_INDEX_T pathIndex, HOA_TV_SOURCE_TYPE_T *sourceType);
HOA_STATUS_T 	HOA_CTRL_CheckSelectedEventIsReserved(API_CHANNEL_NUM_T *pChannelNum, UINT8 *startTime, UINT8 *endTime, UINT32 eventID,SCHEDULE_TYPE_T *resvType);

/* bc_openapi_send2tv_hbbtv.c */
HOA_STATUS_T 	HOA_HBBTV_Call( HBBTV_MALLOC_T funcMAlloc, UINT8 **ppRet, UINT32 *pRetSz, UINT8 *pParam, UINT32 nParamSz );

HOA_STATUS_T	HOA_CTRL_GetHbbTVStatus(BOOLEAN *pbHbbTVStatus);
HOA_STATUS_T 	HOA_CTRL_GetAudioLanguage(UINT32 *pAudioLanguage);
HOA_STATUS_T	HOA_CTRL_GetAudioMode(HOA_AUDIO_MODE_T *pAudioMode);
HOA_STATUS_T 	HOA_CTRL_SetAudioMode(HOA_AUDIO_MODE_T audioMode);
HOA_STATUS_T    HOA_CTRL_SendSmartTextMessage(ADDON_HOST_USER_SMART_MSG_T showSlect, ADDON_SMART_TEXT_T smartText);
//HOA_STATUS_T    HOA_CTRL_SendSmartTextMessage(ADDON_HOST_USER_SMART_MSG_T showSlect, ADDON_SMART_TEXT_T* pSmartText);
HOA_STATUS_T 	HOA_CTRL_GetLocaleInfo(UINT32 localeType, UINT32 *pLocaleInfo);
HOA_STATUS_T 	HOA_CTRL_GetLocalTimeOffset(BOOLEAN *pbPlus, UINT8 *pOffsetHour, UINT8 *pOffsetMin);
HOA_STATUS_T 	HOA_CTRL_GetNSUVersion(UINT32 *pVersion);
HOA_STATUS_T 	HOA_CTRL_GetNsuStatus(HOA_NSU_STATE_T *pState);
HOA_STATUS_T 	HOA_CTRL_GetHcecStatus(BOOLEAN *pStateHCEC);
HOA_STATUS_T 	HOA_CTRL_GetMHLStatus(BOOLEAN *pStateMHL);
HOA_STATUS_T 	HOA_CTRL_GetDECStatus(BOOLEAN *pStateDEC);
HOA_STATUS_T 	HOA_CTRL_EnterVirtualPath (MEDIA_TRANSPORT_T mediaTransportType,
MEDIA_FORMAT_T	combinedFormatType, MEDIA_CODEC_T combinedCodecType);
HOA_STATUS_T 	HOA_CTRL_ExitVirtualPath(void);
//HOA_STATUS_T 	HOA_CTRL_SendMessage(HOA_CTRL_MESSAGE_TYPE_T message, UINT32 param);
HOA_STATUS_T 	HOA_CTRL_SetCursorNavigation(BOOLEAN bSupport);
HOA_STATUS_T 	HOA_CTRL_SetLocalDimmingOFF(void);
HOA_STATUS_T	HOA_CTRL_GetMediaLinkState(UINT32 *pMediaLinkState);
HOA_STATUS_T 	HOA_CTRL_SetMediaLinkState(UINT32 mediaLinkState);
HOA_STATUS_T 	HOA_CTRL_GetSubtitleLanguage(UINT32 *pSubtitleLanguage);
HOA_STATUS_T 	HOA_CTRL_CheckSubtitleIsVisible(BOOLEAN *pbSubtitleOnOff);
HOA_STATUS_T 	HOA_CTRL_CreatePopup(HOA_POPUP_OPTION_T *pPopupOption, POPUP_CB_T pfnPopupCB, UINT32 *pPopupHandle);
HOA_STATUS_T 	HOA_CTRL_CreateMuteOsd(void);
HOA_STATUS_T 	HOA_CTRL_DestroyPopup(UINT32 popupHandler);
HOA_STATUS_T 	HOA_CTRL_CreateDataonlyMSG(void);
HOA_STATUS_T 	HOA_CTRL_DestroyDataonlyMSG(void);

HOA_STATUS_T 	HOA_CTRL_SetVcsCondition(BOOLEAN bVCSCondition);
HOA_STATUS_T 	HOA_CTRL_CheckVcsIsAvailable(BOOLEAN *pbVCSCondition);
HOA_STATUS_T 	HOA_CTRL_CheckWebcamIsOn(BOOLEAN *pbOn);
HOA_STATUS_T 	HOA_CTRL_SetWebcamDisplay(BOOLEAN bOn, HOA_RECT_T *pOutRect);
HOA_STATUS_T 	HOA_CTRL_SendVcsSetCmd( char *pszMethod, UINT32 argSize, char *pszStr );
HOA_STATUS_T 	HOA_CTRL_SendVcsGetCmd( char *pszMethod, UINT32 argSize, char *pszStr, char *pszData );
HOA_STATUS_T 	HOA_CTRL_RegisterVcsCallback(VCS_CB_T pfnVCSCB);
HOA_STATUS_T 	VCS_SEND_EventNoti(VCS_CB_MSG_T cbMsg, UINT32 eventSize, UINT8 *pEvent, UINT32 dataSize, UINT8 *pData );

HOA_STATUS_T 	HOA_CTRL_SetDisplayMode(HOA_DISPLAYMODE_T displayMode);
HOA_STATUS_T	HOA_CTRL_ResetDisplayArea(void);

HOA_STATUS_T 	HOA_CTRL_SetDisplayArea(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);
HOA_STATUS_T 	HOA_CTRL_SetDisplayAreaEx(HOA_RECT_T *pInRect, HOA_RECT_T *pOutRect);


HOA_STATUS_T 	HOA_CTRL_GetModelSecret(char **ppszModelSecret);
HOA_STATUS_T 	HOA_CTRL_GetSwuOtaId(char **ppszOtaid);
HOA_STATUS_T 	HOA_CTRL_GetHardwareVersion(UINT8 *pHardwareVersion);
HOA_STATUS_T 	HOA_CTRL_CheckSdpProductionMode (BOOLEAN *pbSdpProductionMode);
HOA_STATUS_T	HOA_CTRL_GetModelName(char **ppModelName);
HOA_STATUS_T	HOA_CTRL_CheckRunningWiDi(BOOLEAN *pbRunningWiDi);
HOA_STATUS_T 	HOA_CTRL_StopWiDiSession(void);
HOA_STATUS_T 	HOA_CTRL_StopWiDiScan(void);
HOA_STATUS_T 	HOA_CTRL_CheckWiFiIsSupported(BOOLEAN *pbSupportWifi);
HOA_STATUS_T 	HOA_CTRL_CheckWiFiBuiltinIsSupported(BOOLEAN *pbSupportWifiBuiltin);
HOA_STATUS_T 	HOA_CTRL_GetSWVersion(char **ppSWVersion);
HOA_STATUS_T 	HOA_CTRL_CheckSkypeIsSupported(BOOLEAN *pbSupportSkype);
HOA_STATUS_T 	HOA_CTRL_CheckCameraIsReady(BOOLEAN *pbCameraReady);
HOA_STATUS_T 	HOA_CTRL_GetDisplayResolutionMD(UINT32 *pDispResolution);
HOA_STATUS_T 	HOA_CTRL_GetOsdResolution(UINT32 *pOSDResolution);
HOA_STATUS_T 	HOA_CTRL_Get3DSupportType(SUPPORT_3D_TYPE_T *p3DMode);
HOA_STATUS_T 	HOA_CTRL_CheckMrcuIsSupported(BOOLEAN	*pMCtype);
HOA_STATUS_T 	HOA_CTRL_CheckGestureIsSupported(BOOLEAN *pbSupportGesture);
HOA_STATUS_T 	HOA_CTRL_CheckVoiceMrcuIsSupported(BOOLEAN *pbSupportMRCU);




HOA_STATUS_T	HOA_CTRL_SetRecentItem( UINT32 recentType, UINT32 iconPathSz, CHAR *iconPath, UINT32 etcDataSz, CHAR *etcData);
HOA_STATUS_T 	HOA_CTRL_GetPlatformInfo(char** ppInfo);
HOA_STATUS_T 	HOA_CTRL_ConvertToUnicodeString( TIME_T time,TIME_OPTION_T option, char *pszData );
HOA_STATUS_T 	HOA_CTRL_SetDtvProperties(HOA_DTV_DETAIL_ACTION_SPEC_T detail_spec);
HOA_STATUS_T	HOA_CTRL_SetAdaptiveDisplay(BOOLEAN bSet);
HOA_STATUS_T 	HOA_CTRL_GetUserGuideOption(char *pszData);

HOA_STATUS_T 	HOA_CTRL_CheckNordicIsSupported (BOOLEAN *bSupportNordic);
HOA_STATUS_T 	HOA_CTRL_CheckCurrentPowerMode (BOOLEAN *bPowerOnlyMode);


/* bc_openapi_send2tv_io.c */
HOA_STATUS_T 	HOA_IO_GetMountedDevList(HOA_IO_MOUNT_DEV_LIST_T *pusbMount);
HOA_STATUS_T 	HOA_IO_GetUsbDevCount(UINT32 *pusbDevNum, HOA_IO_USB_DEV_TYPE_T usbDevType);
HOA_STATUS_T 	HOA_IO_SetUsbDevFormat(UINT32 usbDevNum, HOA_IO_USB_DEV_TYPE_T deviceType);
HOA_STATUS_T 	HOA_IO_GetMaxDevCount(UINT32 *pMaxDevNum);
HOA_STATUS_T 	HOA_IO_GetUsbProductName(UINT32 usbDevNum, CHAR *pusbProductName);
HOA_STATUS_T 	HOA_IO_GetStoragePath(UINT32 usbDevNum, char *pszPath);
HOA_STATUS_T 	HOA_IO_GetDevInfo(UINT32 usbDevNum, HOA_IO_USB_DEV_INFO_T *pusbDevInfo);
HOA_STATUS_T 	HOA_IO_GetGeneralUSBDevInfo(UINT32 usbDevNum, HOA_IO_GENUSB_DEV_INFO_T *pGenUsbDevInfo);
HOA_STATUS_T 	HOA_IO_CheckBluetoothUsbIsConnected(BOOLEAN *pbBTUSBCon);
HOA_STATUS_T 	HOA_IO_CheckHIDIsConnected(BOOLEAN *pbHIDCon);

HOA_STATUS_T 	HOA_IO_CheckBsiIsEnabled(BOOLEAN *pbBSIOn);
HOA_STATUS_T 	HOA_IO_PrintBsi(const char * pcBSIMsg, ...);
HOA_STATUS_T 	HOA_IO_GetCapability(HOA_CTRL_SUPPORT_TYPE_T supportType, UINT32 *pSupport);
HOA_STATUS_T 	HOA_IO_GetDisplayPanelType(HOA_TV_PANEL_ATTRIBUTE_TYPE_T panelAttribType, UINT32 *pType);
HOA_STATUS_T 	HOA_IO_GetDisplayResolution(UINT32 *pWidth, UINT32 *pHeight);
HOA_STATUS_T 	HOA_IO_GetInstartSystemInfo(HOA_INSTART_SYSTEM_INFO_T *pInstartsysteminfo);
HOA_STATUS_T 	HOA_IO_GetSystemInfo(HOA_CTRL_INFO_T *pSystemInfo);

HOA_STATUS_T 	HOA_IO_CheckCpBoxIsSupported(BOOLEAN *pbCPBox);
HOA_STATUS_T 	HOA_IO_CheckSampleSetIsSupported(BOOLEAN *pbSampleSet);

HOA_STATUS_T 	HOA_IO_CopyFile(char *pszPathSrc, char *pszPathDest);
HOA_STATUS_T 	HOA_IO_DeleteFile(char *pszPath, BOOLEAN bRecursive);
HOA_STATUS_T 	HOA_IO_MoveFile(char *pszPathSrc, char *pszPathDest);
HOA_STATUS_T 	HOA_IO_SetSystemReboot(void);
HOA_STATUS_T 	HOA_IO_SetAppStoreInternalFormat(void);
HOA_STATUS_T	HOA_IO_SetAppStoreInternalMount(void);

HOA_STATUS_T  HOA_IO_GetNetworkStatus(char *pszIpAddress , HOA_NETWORK_TYPE_T *pActivatedNetwork, HOA_NETWORK_STATUS_T *pStatus);
HOA_STATUS_T  HOA_IO_GetNetworkSetting(HOA_NETWORK_TYPE_T networkType, HOA_NETCONFIG_T *pNetworkSettings);
HOA_STATUS_T  HOA_IO_SetNetworkSetting(HOA_NETWORK_TYPE_T networkType, HOA_NETCONFIG_T *pNetworkSettings);
HOA_STATUS_T  HOA_IO_GetWirelessNetworkStatus(HOA_WIRELESSNETWORK_STATUS_T *pStatus);
//#ifdef INCLUDE_ACTVILA
HOA_STATUS_T  HOA_IO_GetActvilaDeviceId(char *deviceId);
//#endif



HOA_STATUS_T 	HOA_CRYPTO_NF_Initialize(const char *pIDFilePath);
HOA_STATUS_T 	HOA_CRYPTO_NF_Finalize(void);
HOA_STATUS_T 	HOA_CRYPTO_NF_GetEsn(UINT8* pEsn);
HOA_STATUS_T 	HOA_CRYPTO_NF_GetKde(UINT8* pKde);
HOA_STATUS_T 	HOA_CRYPTO_NF_GetKdh(UINT8* pKdh);
HOA_STATUS_T 	HOA_CRYPTO_NF_Encrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_NF_Decrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_OpenKeySlot(void);
HOA_STATUS_T 	HOA_CRYPTO_CloseKeySlot(void);
HOA_STATUS_T 	HOA_CRYPTO_GetHardwareRandomNumber(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_Encrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_Decrypt(UINT8 *pData, UINT32 nLength);
HOA_STATUS_T 	HOA_CRYPTO_SFU_Initialize(const char *pSeedPath);
HOA_STATUS_T 	HOA_CRYPTO_SFU_Finalize(void);
HOA_STATUS_T 	HOA_CRYPTO_SFU_GetRsaKey(UINT8 *pData);
HOA_STATUS_T 	HOA_CRYPTO_SFU_GetAesKey(UINT8 *pData);

HOA_STATUS_T 	HOA_CTRL_RequestLogin(void);
HOA_STATUS_T	HOA_CTRL_RequestSignup(void);
HOA_STATUS_T 	HOA_CTRL_RequestUserConfirmation(HOA_LOGIN_CONFIRM_TYPE_T type); /* 구매인증/성인인증/회원탈퇴 */
HOA_STATUS_T 	HOA_CTRL_RequestPurchase(SDPIF_PURCHASE_IN_T purchaseIn);
HOA_STATUS_T 	HOA_CTRL_RequestPasswordChange(void);
HOA_STATUS_T	HOA_CTRL_RequestLoginWithUserId(char *pID);
HOA_STATUS_T 	HOA_CTRL_SetAgreedTerm(BOOLEAN popup);
HOA_STATUS_T 	HOA_CTRL_RegisterBillingCallback(BILLING_CB_T pfnBillingCB);
HOA_STATUS_T 	HOA_SDPIF_EnableContrySelectionPopup(BOOLEAN bIsShow);
HOA_STATUS_T 	HOA_SDPIF_CheckNordicCountryIsSet(BOOLEAN *pNordicCountryInfo);
HOA_STATUS_T 	HOA_SDPIF_CheckCountryIsAutoSet(BOOLEAN bAutoCountry);
HOA_STATUS_T 	HOA_SDPIF_CheckSelectedCountryIsVisible (BOOLEAN *bIsShow);
HOA_STATUS_T    HOA_CTRL_RequestPowerOff(void);
HOA_STATUS_T    HOA_CTRL_RequestToRebootPower(void);

HOA_STATUS_T 	HOA_CTRL_LoadUnicodeStringTable(AF_BUFFER_HNDL_T *shmBufferHandle);
HOA_STATUS_T 	HOA_CTRL_GetUnicodeString(UINT32 strId, UINT16 *ucsStr, UINT32 *outLen);
HOA_STATUS_T 	HOA_CTRL_SetDimmingControl(UINT8 nValue);
HOA_STATUS_T 	HOA_CTRL_SetAgreeLegalNotice(void);

// Smart Share
HOA_STATUS_T 	HOA_SMTS_GetInitialScene(UINT32* pScene);
HOA_STATUS_T	HOA_SMTS_Initialize(UINT32* pResult);
HOA_STATUS_T	HOA_SMTS_Finalize(void);
HOA_STATUS_T	HOA_SMTS_InitializeList(HOA_SMTS_LIST_TYPE_T hoaListType, HOA_SMTS_SORT_TYPE_T hoaSortType, UINT8 *pFullPath
											, UINT32 maxPageItemNum, UINT32 *pTotalItemNum);
HOA_STATUS_T	HOA_SMTS_UpdatePage(HOA_SMTS_LIST_TYPE_T hoaListType
												, UINT8 *pDeviceId
												, UINT32 maxPageItemNum
												, UINT32 mode
												, UINT32 param
												, UINT32 *pTotalItemNum);
HOA_STATUS_T	HOA_SMTS_GetLastFocusedMediaId(UINT32 *pTotalItemNum, UINT32 *pMediaId);
HOA_STATUS_T 	HOA_SMTS_SetCurrentListType(UINT32 listType);
HOA_STATUS_T 	HOA_SMTS_GetListItems(HOA_SMTS_LIST_TYPE_T hoaListType, UINT32 mediaId, UINT32 count, UINT32 *pRetCount, AF_BUFFER_HNDL_T* pBuffHandler);
HOA_STATUS_T 	HOA_SMTS_ClearListItems(void);
HOA_STATUS_T	HOA_SMTS_GetVideoMetadata(UINT32 mediaId, HOA_SMTS_VIDEO_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_GetPhotoMetadata(UINT32 mediaId, HOA_SMTS_PHOTO_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_GetMusicMetadata(UINT32 mediaId, HOA_SMTS_MUSIC_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_GetRecordedTVProgramMetadata(UINT32 mediaId, HOA_SMTS_RECTV_METADATA_T *pMeta);
HOA_STATUS_T	HOA_SMTS_GetPathList(AF_BUFFER_HNDL_T *pSharedMemHandle, UINT32 *pRetCount);
HOA_STATUS_T	HOA_SMTS_GetMusicState(HOA_SMTS_PLAY_STATE_T *pState);
HOA_STATUS_T	HOA_SMTS_Play(UINT32 type, UINT32 mediaId);
HOA_STATUS_T	HOA_SMTS_CheckDvrIsRecording(BOOLEAN* pisRecording);
HOA_STATUS_T 	HOA_SMTS_SetCurrentSortMode(HOA_SMTS_SORT_TYPE_T sMode);
HOA_STATUS_T 	HOA_SMTS_GetCurrentSortMode(HOA_SMTS_LIST_TYPE_T cType, HOA_SMTS_SORT_TYPE_T *pMode);
HOA_STATUS_T 	HOA_SMTS_GetLinkedDevTotalCount(int *pLength);
HOA_STATUS_T 	HOA_SMTS_GetLinkedDevInfo(AF_BUFFER_HNDL_T* pBuffHandler);
HOA_STATUS_T	HOA_SMTS_SetExecuteDev(UINT32 dataId,BOOLEAN bTimer);
HOA_STATUS_T 	HOA_SMTS_GetLinkedDevFocus(UINT32 focusType,UINT32 dataId,UINT32 *focusIndex);
HOA_STATUS_T 	HOA_SMTS_GetDevMenuType(int *nType);
HOA_STATUS_T 	HOA_SMTS_GetFocusedCurrentSpeaker(int *mode);
HOA_STATUS_T 	HOA_SMTS_GetPossibleHts(int *type);
HOA_STATUS_T	HOA_SMTS_SetSpeakerMode(UINT32 mode);
HOA_STATUS_T	HOA_SMTS_SetVideoSize(BOOLEAN bResize);
HOA_STATUS_T	HOA_SMTS_SetInputLabel(UINT32 dataId,UINT32 inputLabelIndex);
HOA_STATUS_T 	HOA_SMTS_CheckHeadsetIsConnected(BOOLEAN *bConnect);
HOA_STATUS_T 	HOA_SMTS_RegisterCallback(SMTS_CB_T pfnSMTSCB);
HOA_STATUS_T 	HOA_SMTS_RegisterHomeSmtsCallback(SMTS_CB_T pfnSMTSCB);
HOA_STATUS_T 	HOA_SMTS_SetInitialScene(UINT32 listType);
HOA_STATUS_T 	HOA_SMTS_StartThumbnail(UINT32 listType);
HOA_STATUS_T 	HOA_SMTS_CreateNativePopup(int wType, int nStartPage);
HOA_STATUS_T	HOA_SMTS_GetDvrFreeSpaceInfo(AF_BUFFER_HNDL_T* pBuffHandler);
HOA_STATUS_T 	HOA_SMTS_ShowSubtitle(MEDIA_CHANNEL_T ch);
HOA_STATUS_T 	HOA_SMTS_GetUpdateInfo(BOOLEAN* bUpdateState, AF_BUFFER_HNDL_T* pShmBuffer);
HOA_STATUS_T 	HOA_SMTS_GetText(int index, AF_BUFFER_HNDL_T* pShmBuffer);
HOA_STATUS_T	HOA_SMTS_DeleteRecordedTVProgram(UINT32 *pItemIndexArray, UINT32 nArraySize);
HOA_STATUS_T	HOA_SMTS_PlayRecordedTvProgram(UINT32 *pItemIndexArray, UINT32 nArraySize);
HOA_STATUS_T	HOA_SMTS_SetDevMenuType(UINT32 type);
HOA_STATUS_T 	HOA_SMTS_GetNumOfLinkedDevCountInHomeMenu(int *pLength);
HOA_STATUS_T 	HOA_SMTS_GetLinkedDevInfoInHomeMenu(AF_BUFFER_HNDL_T* pBuffHandler);
HOA_STATUS_T	HOA_SMTS_SetRecordedTvProgramTitle(UINT32 nMediaID, UINT32 *pNewTitleString, size_t nStringLength);
HOA_STATUS_T	HOA_SMTS_RenameRecordedTvProgram(UINT32 nMediaID);
HOA_STATUS_T	HOA_SMTS_FreeThumbnail(AF_BUFFER_HNDL_T *pSharedMemHandle);
HOA_STATUS_T	HOA_SMTS_CheckDvrIsDeleting(BOOLEAN* pIsDeleting);
HOA_STATUS_T	HOA_SMTS_SelectRecordedTVListGenre(void);
HOA_STATUS_T 	HOA_SMTS_GetEditDeviceCount(int *pLength);
HOA_STATUS_T 	HOA_SMTS_GetEditDevInfo(AF_BUFFER_HNDL_T* pBuffHandler);
HOA_STATUS_T	HOA_SMTS_SetProtectableRecordedTVProgram(int *pProtectableMediaIdArray, BOOLEAN *pProtectableMediaValueArray, UINT32 nArraySize);
HOA_STATUS_T 	HOA_SMTS_DeleteSubtitleWindow(MEDIA_CHANNEL_T ch);
HOA_STATUS_T 	HOA_SMTS_SetLinkedDeviceSceneInfo(UINT32 info);
HOA_STATUS_T 	HOA_SMTS_GetLinkedDeviceSceneInfo(UINT32 *pInfo);


// Mcast
HOA_STATUS_T HOA_MCAST_WriteMcastFile(char *pszMCastFilePath);
HOA_STATUS_T HOA_MCAST_AddScheduleList(HOA_MCAST_FLASH_SET_INFO_T stMCastList);
HOA_STATUS_T HOA_MCAST_ExecuteBasicCmd(HOA_MCAST_CMD_T eMCastCmd, HOA_MCAST_MODE_T eMCastMode, UINT8 uId, HOA_MCAST_RET_VAL_T *pMcastResult);
HOA_STATUS_T HOA_MCAST_ExecuteFileCmd(HOA_MCAST_CMD_T eMCastCmd, char *pszFileName, HOA_MCAST_RET_VAL_T *pMcastResult);
HOA_STATUS_T HOA_MCAST_ExecuteSimpleCmd(HOA_MCAST_CMD_T eMCastCmd,HOA_MCAST_RET_VAL_T *pMcastResult);
HOA_STATUS_T HOA_MCAST_SetMemoCheckedOrNot(UINT8 uId, BOOLEAN bIsChecked);
HOA_STATUS_T HOA_MCAST_SaveDumpImageToJpeg(HOA_RECT_T dumpRect);
HOA_STATUS_T HOA_MCAST_ResizeVideoForPr(UINT8 uPRSize, UINT8 uPRPos);
HOA_STATUS_T HOA_MCAST_ResetVideoResizeForPr(UINT8 uPRSize);

// Photo (temp)
HOA_STATUS_T HOA_MEDIA_PlayImageFile(UINT32 deviceType, char *pszFilePath, UINT32 imageType);
HOA_STATUS_T HOA_MEDIA_PlayImageFileWithId(UINT32 deviceType, UINT32 imageID);
HOA_STATUS_T HOA_MEDIA_StartImageCache(char *pszFilePath, UINT32 imageType, UINT32 *imageID);
HOA_STATUS_T HOA_MEDIA_CancelImageCache(UINT32 imageID);
HOA_STATUS_T HOA_MEDIA_DeleteImageCache(UINT32 imageID);
HOA_STATUS_T HOA_MEDIA_ClearImageFrame(void);
HOA_STATUS_T HOA_MEDIA_CheckImageExistsInCache(UINT32 imageID);
HOA_STATUS_T HOA_CTRL_PrintCurrentImageCacheList(void);
HOA_STATUS_T HOA_CTRL_RegisterImageCallback(MEDIA_CHANNEL_T ch, CTRL_IMAGE_CB_T pfnImageCB);
HOA_STATUS_T HOA_CTRL_StartChannel(void);
HOA_STATUS_T HOA_CTRL_EndChannel(void);

// home status(PDP only)
HOA_STATUS_T HOA_CTRL_SetHomeStatus(HOME_STATUS_T homeStatus);

// User Guide status (PDP Only)
HOA_STATUS_T HOA_CTRL_SetUserGuideStatus(GUIDE_STATUS_T guideStatus);

// KKC
HOA_STATUS_T HOA_KKC_StartController(int isPred);
HOA_STATUS_T HOA_KKC_StopController(void);
HOA_STATUS_T HOA_KKC_RequestToAddChar(char* pIpCr, char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToDelete(char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToEnshort(char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToEnlong(char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestInvaliDate(void);
HOA_STATUS_T HOA_KKC_RequestToFix(char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToCarriageReturn(char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToConvert(char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToSelect(int cand_idx, char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToPredict(int isPred, char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);
HOA_STATUS_T HOA_KKC_RequestToSpace(char* pYomi, int* pCvSz, int* pCdNm, char* pCdDt);

// CMF for social center like
#ifdef INCLUDE_CMF
HOA_STATUS_T HOA_CMF_CheckLikeByCB(HOA_CMF_COMPONENT_TYPE_T contentType, UINT8* pContentId, HOA_CMF_CHECK_LIKE_CB_T fnCallBack);
HOA_STATUS_T HOA_CMF_ContentLike(HOA_CMF_CONTENT_INFO_T *pContentInfo);
HOA_STATUS_T HOA_CMF_ExcuteContent(UINT32 cmid);
HOA_STATUS_T HOA_CMF_SetChannel(HOA_CMF_CHANNEL_INFO_T *pChInfo, UINT8 *pProgramName);
HOA_STATUS_T HOA_CMF_CheckLike(HOA_CMF_COMPONENT_TYPE_T contentType, UINT8* pContentId, BOOLEAN* pIsLiked);
#endif

#ifdef __cplusplus
}
#endif
#endif

