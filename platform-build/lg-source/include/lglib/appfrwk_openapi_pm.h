/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/


/** @file appfrwk_openapi_pm.h
 *
 *  Process Manager openapi header
 *
 *  @author    dhjung (donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.01
 *  @note
 *  @see
 */
#ifndef _APPFRWK_OPENAPI_PM_H_
#define _APPFRWK_OPENAPI_PM_H_

#include <dbus/dbus.h>
#include "appfrwk_common.h"
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* appfrwk_openapi_send2pm.c */
HOA_STATUS_T 		HOA_PROC_RegisterToMgr(int argc, char **argv, HOA_PROC_CALLBACKS_T *pCallbacks);
HOA_STATUS_T		HOA_PROC_DeregisterFromMgr(void);
HOA_STATUS_T		HOA_PROC_TerminateProcess(SINT32 PID, BOOLEAN bRespawn);
HOA_STATUS_T		HOA_PROC_TerminateAllProcess(BOOLEAN bRespawn);
HOA_STATUS_T 		HOA_PROC_ExecuteProcess(char *pszProcPath, char *pszArgument, BOOLEAN bSingle, UINT64 AUID, SINT32 *pPID);
HOA_STATUS_T		HOA_PROC_GetRunningProcessNum(UINT16 *pProcessNum);
HOA_STATUS_T		HOA_PROC_GetExecuteArgument(SINT32 PID, char *pszArgument);
HOA_STATUS_T		HOA_PROC_GetProcessState(SINT32 PID, PM_PROC_STATE_T *pState);
HOA_STATUS_T 		HOA_PROC_GetFocusedPID(SINT32 *pPID);
HOA_STATUS_T		HOA_PROC_GetProcessBinaryPIDList(char *pszProcPath, char *pszArgument, UINT32 *pPidNum, SINT32 *pPidList);
HOA_STATUS_T 		HOA_PROC_GetProcessPID(char *pServiceName, SINT32 *pPid);
HOA_STATUS_T 		HOA_PROC_GetProcessSvcName(SINT32 pid, char *pServiceName);
HOA_STATUS_T 		HOA_PROC_BroadInitComplete(HOA_CURSOR_TYPE_T cursorType, HOA_CURSOR_SIZE_T cursorSize);
HOA_STATUS_T 		HOA_PROC_GetBgCreateStatus(char *pServiceName, PM_PROC_BG_STATUS_T *createStatus);
HOA_STATUS_T		HOA_PROC_GetStoreMasterExecuteStatus(BOOLEAN *pStoreMasterEnable);
HOA_STATUS_T		HOA_PROC_ClearBatchList(void);
HOA_STATUS_T		HOA_PROC_RunBatchList(void);
HOA_STATUS_T		HOA_PROC_SetLoading(void);
HOA_STATUS_T		HOA_PROC_SetReady(void);
HOA_STATUS_T		HOA_PROC_SetTerminate(void);
HOA_STATUS_T        HOA_PROC_GetDisplayID(SINT32 *pDisplayID);
HOA_STATUS_T        HOA_PROC_SetEnableDisplay(BOOLEAN bShow); //Browser의 hbbtv 시험 test를 위한 임시 function 으로 추후 반드시 삭제
HOA_STATUS_T 		HOA_PROC_SetCursorShow(BOOLEAN bShow); //cursor show/hide
HOA_STATUS_T		HOA_PROC_GetCursorShow(BOOLEAN *pbShow);//get show/hide
HOA_STATUS_T		HOA_PROC_SetCursorFPS(UINT8 cursorFPS);//cursor fps
HOA_STATUS_T		HOA_PROC_SetCursorSupport(BOOLEAN bSupport);
HOA_STATUS_T 		HOA_PROC_SetCursorShape(HOA_CURSOR_TYPE_T cursorType, HOA_CURSOR_SIZE_T cursorSize, HOA_CURSOR_STATE_T cursorState);
HOA_STATUS_T 		HOA_PROC_GetCursorShape(HOA_CURSOR_TYPE_T* pCursorType, HOA_CURSOR_SIZE_T* pCursorSize, HOA_CURSOR_STATE_T *pCursorState);
HOA_STATUS_T		HOA_PROC_SetMRCUStandByTimer(UINT32 msec);
HOA_STATUS_T		HOA_PROC_GetTimeMRCUStandByTimer(UINT32 *pMsec);
HOA_STATUS_T 		HOA_PROC_CancelMRCUStandByTimer(void);
HOA_STATUS_T 		HOA_PROC_GetCursorPosition(UINT16 *pX, UINT16 *pY);
HOA_STATUS_T        HOA_PROC_DeregisterFromKeyTable(UINT32 uiNumKey, ...);
HOA_STATUS_T        HOA_PROC_DeregisterFromKeyTableByArray(UINT32 *pKeyArray, UINT32 uiNumKey);
HOA_STATUS_T		HOA_PROC_GetLastInputEventInfo(struct input_event *pEvent);
HOA_STATUS_T		HOA_PROC_SetCustomCursor(HOA_CUSTOM_CURSOR_T *pCustomCursor, UINT32 nNumOfCustomCursor);
HOA_STATUS_T		HOA_PROC_ResetCustomCursor(HOA_CUSTOM_CURSOR_T *pCustomCursor, UINT32 nNumOfCustomCursor);
HOA_STATUS_T		HOA_PROC_Set3DMode(HOA_3D_MODE_T osd3dOnOff, HOA_3D_TYPE_T osd3dType);
HOA_STATUS_T 		HOA_PROC_GetInputDevNum(UINT16 *pNumOfInputDev);
HOA_STATUS_T 		HOA_PROC_GetInputDevInfoList(HOA_INPUTDEV_INFO_T *pInptDevInfo, UINT32 nNumOfInputDev);
HOA_STATUS_T        HOA_PROC_RegisterEnabledDisplayNotiCB(ENABLED_DISPLAY_CB_T pfnEnalbeDisplayCallback);
HOA_STATUS_T        HOA_PROC_UnRegisterEnabledDisplayNotiCB(void);
HOA_STATUS_T        HOA_PROC_DispalyForceEnabledNoti(SINT32 displayID);
HOA_STATUS_T 		HOA_PROC_GetServiceNameWithAUID(UINT64 AUID, char *pServiceName);
HOA_STATUS_T 		HOA_PROC_SetAppResolution(UINT16 x, UINT16 y, UINT16 width, UINT16 height, BOOLEAN bStretchToDisplay);


/* appfrwk_openapi_send2proc.c */
HOA_STATUS_T		HOA_PROC_SendEventToProcess(HOA_HOST_EVENT_T event, UINT32 param);
HOA_STATUS_T 		HOA_PROC_SendMsgToProcess(char *pServiceName, HOA_SUBMSG_TYPE_T usermsg, UINT8 *pUserData);

/* appfrwk_openapi_input.c */
HOA_STATUS_T		PM_INPUT_ReturnEvent(const struct input_event *pEvent , BOOLEAN bIsKeyReturnPath);
HOA_STATUS_T		HOA_PROC_CreateUinputForReturn( void );
HOA_STATUS_T		HOA_PROC_RequestInputCheck( void );
HOA_STATUS_T		HOA_PROC_RequestInputPrintList( void );
int 				HOA_PROC_GetUinputFDForReturn( void );
HOA_STATUS_T 		HOA_PROC_GetLEDInfo(BOOLEAN *pledInfo, UINT8 nNumOfLedInfo);
HOA_STATUS_T 		HOA_PROC_SendKeyEventToApp(const char *pDstServiceName, UINT16 keyCode, UINT32 keyValue);

/* appfrwk_openapi_msg_handler.c */
void 				*HOA_PROC_Task_MsgRecvHandler(void *data);

/* appfrwk_openapi_evt_handler.c */
HOA_STATUS_T 		APP_HNDL_SendEventToProcess(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_ProcStChEventToProc(DBusConnection *conn, DBusMessage *msg, void *user_data);
void 				*HOA_PROC_Task_EvtRecvHandler(void *data);

/* appfrwk_openapi_cb_handler.c */
HOA_STATUS_T		APP_HNDL_PlayNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_PlayNoti_EX(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_PmsNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_PopupNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_HbbtvNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_BillingNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_DOWNLOAD_SendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_DOWNLOAD_DiscSendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_SDPIF_SendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_LGINPUT_MotionSendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_LGINPUT_VoiceSendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_LGINPUT_BSIPosXSendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_LGINPUT_BSIPosYSendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_LGINPUT_BSIRFKeySendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);

void 				*HOA_PROC_Task_CallbackHandler(void *data);
HOA_STATUS_T 		APP_HNDL_VCS_EventNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		APP_HNDL_SmartshareMsg(DBusConnection * conn,DBusMessage * msg,void * user_data);
HOA_STATUS_T		APP_HNDL_HomeSmtsMsg(DBusConnection * conn,DBusMessage * msg,void * user_data);
HOA_STATUS_T        APP_HNDL_EnabledDisplayIDNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		APP_HNDL_FXUI_SendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);

HOA_STATUS_T 		APP_HNDL_LGINPUT_GestureEventNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);

/* appfrwk_openapi_pm_msg_handler.c */
HOA_STATUS_T		PM_HNDL_TerminateNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		PM_HNDL_ProcEndNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		PM_HNDL_SetFocusNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		PM_HNDL_SetExecuteNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		PM_HNDL_SetProcStatusChangedNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		PM_HNDL_SetDebugNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		PM_HNDL_SetPriorityNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		PM_HNDL_ProcExitCodeNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T		PM_HNDL_StopProcLoadingNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);

/* appfrwk_openapi_proc_msg_handler.c */
HOA_STATUS_T 		APP_HNDL_SendMsgToProcess(DBusConnection *conn, DBusMessage *msg, void *user_data);

/* appfrwk_openapi_input_handler.c */
DBusHandlerResult 	PM_HNDL_InputEventProcess(DBusConnection *conn, DBusMessage *msg, void *user_data);
void 				*HOA_PROC_Task_InputHandler(void *data);

/* appfrwk_openapi_util.c */
HOA_HNDL_CONF_T 	*HOA_UTIL_FindHandler(AF_MSG_TYPE_T msgType, DBusMessage *msg);
HOA_STATUS_T 		HOA_UTIL_AddHandleConf(AF_MSG_TYPE_T msgType, HOA_HNDL_CONF_T *hndlconf);
HOA_STATUS_T 		HOA_UTIL_AddMatchRule(DBusConnection *conn);

/* appfrwk_openapi_cb_func.c */
HOA_STATUS_T		CB_MEDIA_CheckCbInit(MEDIA_CHANNEL_T ch);
HOA_STATUS_T		CB_MEDIA_SetCallback(MEDIA_CHANNEL_T ch, MEDIA_PLAY_CB_T pfnPlayCB);
HOA_STATUS_T		CB_MEDIA_ClearCallback(MEDIA_CHANNEL_T ch);
HOA_STATUS_T		CB_MEDIA_SendPlayNoti(MEDIA_CHANNEL_T ch, MEDIA_CB_MSG_T msg);
HOA_STATUS_T		CB_MEDIA_EX_CheckCbInit(MEDIA_CHANNEL_T ch);
HOA_STATUS_T		CB_MEDIA_EX_SetCallback(MEDIA_CHANNEL_T ch, MEDIA_PLAY_CB_EX_T pfnPlayCB_ex);
HOA_STATUS_T		CB_MEDIA_EX_ClearCallback(MEDIA_CHANNEL_T ch);
HOA_STATUS_T		CB_MEDIA_EX_SendPlayNoti(MEDIA_CHANNEL_T ch, MEDIA_CB_EX_MSG_T msg, UINT32 cb_param[4]);
HOA_STATUS_T		CB_MEDIA_SendPmsNoti(MEDIA_CHANNEL_T ch, MEDIA_CB_MSG_T msg);;
HOA_STATUS_T		CB_BROAD_SendPopupNoti(UINT32 handle, UINT8 btnIdx);
HOA_STATUS_T 		CB_SDPIF_SendBillingNoti(BILLING_CB_MSG_T msg, UINT16 datasize, UINT8 *pdata);
HOA_STATUS_T 		CB_SDPIF_SendBillingRegister(BILLING_CB_T pfnBillingCB);
HOA_STATUS_T 		CB_SDPIF_SendBillingUnRegister(void);
HOA_STATUS_T 		CB_HBBTV_SendNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		CB_HBBTV_Init(HBBTV_CB_T pCallHandler);
HOA_STATUS_T 		CB_HBBTV_Final(void);
HOA_STATUS_T 		CB_DOWNLOAD_CheckCbInit(void);
HOA_STATUS_T 		CB_DOWNLOAD_SetCallback(DOWNLOAD_CB_T pfnDLCB);
HOA_STATUS_T 		CB_DOWNLOAD_ClearCallback(void);
HOA_STATUS_T 		CB_DOWNLOAD_SendNoti(UINT8 downloadID, DOWNLOAD_CB_MSG_T msg);
HOA_STATUS_T 		CB_DOWNLOAD_DiscSendNoti(DISC_CB_MSG_T msg);
HOA_STATUS_T 		CB_DOWNLOAD_DiscCheckCbInit(void);
HOA_STATUS_T 		CB_DOWNLOAD_DiscSetCallback(DISC_CB_T pfnDiscCB);
HOA_STATUS_T 		CB_DOWNLOAD_DiscClearCallback(void);
HOA_STATUS_T 		CB_SDPIF_Register(SDPIF_CB_TYPE_T type, SDPIF_CB_T callbackFn);
HOA_STATUS_T 		CB_SDPIF_SendNoti(SDPIF_CB_TYPE_T type, SDPIF_CB_MSG_T msg, UINT16 dataSize, UINT8 *pData);
HOA_STATUS_T		CB_LGINPUT_VoiceSendNoti(UINT32 dataSize, UINT8 *pData, LGINPUT_VOICE_CB_T pfnCallBack);
HOA_STATUS_T 		CB_LGINPUT_VoiceSendNotiMulti(UINT32 dataSize, UINT8 **pData, LGINPUT_VOICE_UI_CB_T pfnCallBack);
HOA_STATUS_T		CB_LGINPUT_MotionSendNoti(UINT32 pktCount, UINT32 per, UINT32 rssiTv, UINT32 rssiDv, LGINPUT_CB_T pfnCallBack);
HOA_STATUS_T		CB_LGINPUT_BSIPosXSendNoti(UINT32 posX, LGINPUT_BSI_CB_T pfnCallBack);
HOA_STATUS_T		CB_LGINPUT_BSIPosYSendNoti(UINT32 posY, LGINPUT_BSI_CB_T pfnCallBack);
HOA_STATUS_T		CB_LGINPUT_BSIRFKeySendNoti(UINT32 RFKey, LGINPUT_BSI_CB_T pfnCallBack);


HOA_STATUS_T 		CB_VCS_RegisterCallback(VCS_CB_T pfnVCSCB);
HOA_STATUS_T 		CB_VCS_UnRegisterCallback( void );
HOA_STATUS_T 		CB_VCS_SendEventNoti( VCS_CB_MSG_T cbMsg, UINT32 eventSize, char *pEvent, UINT32 dataSize, char *pData );
HOA_STATUS_T 		CB_LGINPUT_GestureSendNoti(int gesture_type, int gesture_time, int key_value, int shmid, int buffer_size, GESTURE_CB_T pfnCallBack);


HOA_STATUS_T 		CB_SMTS_SendSmartshareMsg(UINT32 operation, UINT32 mode[4], int ip,char *pParam);
HOA_STATUS_T 		CB_SMTS_RegisterCallback(SMTS_CB_T callbackFn);
HOA_STATUS_T 		CB_SMTS_UnRegisterCallback(void);

HOA_STATUS_T 		CB_SMTS_SendHomeSmtsMsg(UINT32 operation, UINT32 mode[4], int ip,char *pParam);
HOA_STATUS_T 		CB_SMTS_HomeSmtsRegisterCallback(SMTS_CB_T callbackFn);
HOA_STATUS_T 		CB_SMTS_HomeSmtsUnRegisterCallback(void);

HOA_STATUS_T        CB_DISPLAY_RegisterCallback(ENABLED_DISPLAY_CB_T pfnEnableDisplayCB);
HOA_STATUS_T        CB_DISPLAY_UnRegisterCallback(void);
HOA_STATUS_T        CB_DISPLAY_EnabledDisplayIDNoti(SINT32 nDisplayID);

HOA_STATUS_T 		CB_FXUI_SendAgreeTermNoti(FXUI_CB_MSG_T msg, UINT16 datasize, UINT8 *pdata);
HOA_STATUS_T 		CB_FXUI_RegisterAgreeTermCallback(FXUI_CB_T pfnFXUICB);
HOA_STATUS_T		CB_FXUI_ClearCallback(FXUI_CB_MSG_T cb_msg);

HOA_STATUS_T 		APP_HNDL_ImageNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);

HOA_STATUS_T 		CB_CTRL_SetCallback(MEDIA_CHANNEL_T ch, CTRL_IMAGE_CB_T pfnImageCB);
HOA_STATUS_T 		CB_CTRL_ClearCallback(MEDIA_CHANNEL_T ch);
HOA_STATUS_T 		CB_CTRL_SendImageNoti(MEDIA_CHANNEL_T ch, IMAGE_CB_MSG_T msg);


#ifdef __cplusplus
}
#endif
#endif
