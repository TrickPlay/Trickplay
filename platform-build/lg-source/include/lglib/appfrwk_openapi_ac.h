/******************************************************************************
 *   SOFTWARE PLATFORM LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2011 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/


/** @file appfrwk_openapi_ac.h
 *
 *  Application Controller Open API header
 *
 *  @author    hyejeong lee (hyejeong.lee@lge.com)
 *  @version   1.0
 *  @date      2011.05.24
 *  @note
 *  @see
 */


#ifndef _APPFRWK_OPENAPI_AC_H_
#define _APPFRWK_OPENAPI_AC_H_

#include <dbus/dbus.h>
#include "appfrwk_common.h"
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

HOA_STATUS_T		HOA_APP_ExecuteApp (UINT64 AUID);
HOA_STATUS_T		HOA_APP_ExecuteAppEx (UINT64 AUID, char *pszParam);
HOA_STATUS_T		HOA_APP_RequestFocus (UINT64 AUID);
HOA_STATUS_T		HOA_APP_ExitApp (UINT64 AUID, AM_EXITCODE_T exitCode);
HOA_STATUS_T		HOA_APP_ExitAllApp (void);
HOA_STATUS_T		HOA_APP_SwitchService (UINT64 AUID, SINT32 oldPID, SINT32 newPID);
HOA_STATUS_T		HOA_APP_GetAppState (UINT64 AUID, /*out*/AM_APP_STATE_T *pState);

HOA_STATUS_T		HOA_APP_GetRunningAppNum (/*out*/UINT32 *pRunningAppNum);
HOA_STATUS_T		HOA_APP_GetFocusedAUID(UINT64 *pAUID);
HOA_STATUS_T		HOA_APP_GetFocusedIDByStr(AM_APP_PROVIDER_T *pAppProvider, char **pszID);
HOA_STATUS_T		HOA_APP_IsAppLoading (/*out*/BOOLEAN *pbAppLoading);
HOA_STATUS_T		HOA_APP_GetBackVideoType(AM_EXITCODE_T exitCode, AM_VIDEO_TYPE_T *pVideoType);

#if 1
/**
* Do Not Use this function!!
* This function will be deleted!!
*/
HOA_STATUS_T		HOA_APP_IsAppExist (AM_APP_PROVIDER_T appProvider, /*out*/BOOLEAN *pAppExist);
/**
* Do Not Use this function!!
* This function will be deleted!!
*/
HOA_STATUS_T		HOA_APP_IsFocusedAppExist (/*out*/BOOLEAN *pbAppExist);
#endif

//App List
HOA_STATUS_T		HOA_APP_GetAppNum (/*out*/UINT32 *pNumApps, AM_APPLIST_TYPE_T appListType, AM_CTXT_TYPE_T ctxtType);
HOA_STATUS_T		HOA_APP_GetAppList (/*out*/AM_APP_INFO_T *appInfoArr, AM_APPLIST_TYPE_T appListType, AM_CTXT_TYPE_T ctxtType);
HOA_STATUS_T		HOA_APP_GetAppInfo (UINT64 AUID, /*out*/AM_APP_INFO_T *appInfo);
HOA_STATUS_T		HOA_APP_GetAppDeactivationInfo (UINT64 AUID, /*out*/AM_DEACTIVATION_INFO_T *deactiveInfo);
HOA_STATUS_T		HOA_APP_GetAppStoreStorageState (HOA_TVAPPS_STORAGE_TYPE_T storageType, AM_STORAGE_STATE_T *pState);

HOA_STATUS_T		HOA_APP_GetAppListByIndex (/*out*/AM_APP_INFO_T *appInfoArr, UINT32 startAppIndex, UINT32 numApps, AM_APPLIST_TYPE_T appListType, AM_CTXT_TYPE_T ctxtType);
HOA_STATUS_T		HOA_APP_ChangeAppOrder (UINT64 AUID, UINT16 absOrderIndex, AM_APPLIST_TYPE_T appListTypeFrom, AM_APPLIST_TYPE_T appListTypeTo, AM_CTXT_TYPE_T ctxtType);

//systemapp - 삭제/이동 불가 - ERROR 리턴
//premiumapp - 삭제/이동 가능 - list에서만 삭제 - HOA_APP_DeleteApp(AUID, AM_APPLIST_MYAPPS) 호출할 것
//downloadedapp - 삭제/이동 가능 - HOA_UC_UninstallApp을 호출할 것 (TBD)
HOA_STATUS_T		HOA_APP_DeleteApp (UINT64 AUID, AM_APPLIST_TYPE_T appListTypeFrom);
HOA_STATUS_T		HOA_APP_AddApp (UINT64 AUID, AM_APPLIST_TYPE_T appListTypeTo);

HOA_STATUS_T		HOA_APP_GetAUID (/*out*/UINT64 *AUID, AM_APP_PROVIDER_T appProvider, UINT32 uint32ID, char *strID);
HOA_STATUS_T		HOA_APP_GetDownloadedID(/*out*/UINT32 *pDownloadedID, UINT64 AUID);
HOA_STATUS_T		HOA_APP_GetPremiumID(/*out*/char **pszPremiumID, UINT64 AUID);

/* Card */
HOA_STATUS_T		HOA_APP_CreateCard(const char* szName, UINT64* pAUIDArr, UINT32 nAUIDArrSize, /*out*/UINT32* pnCardID);
HOA_STATUS_T		HOA_APP_DestroyCard(UINT32 nCardID);
HOA_STATUS_T		HOA_APP_UpdateCard(UINT32 nCardID, UINT64* pAUIDArr, UINT32 nAUIDArrSize);
HOA_STATUS_T		HOA_APP_GetCardItemList(UINT32 nCardID, /*out*/AM_APP_INFO_T** ppAppInfoArr, /*out*/UINT32* pnNumItems);
HOA_STATUS_T		HOA_APP_GetCardName(UINT32 nCardID, /*out*/char** pszCardName);
HOA_STATUS_T		HOA_APP_SetCardName(UINT32 nCardID, const char* szCardName);
HOA_STATUS_T		HOA_APP_GetCardList(/*out*/UINT32** ppnCardIdArr, /*out*/UINT32* pnCardNum);


/* appfrwk_openapi_ac_msg_handler.c */
HOA_STATUS_T        AC_HNDL_AppListChangeNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T        AC_HNDL_AppListAddNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T        AC_HNDL_AppListDeleteNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		AC_HNDL_AppLoadingNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		AC_HNDL_RunningAppExistNoti(DBusConnection *conn, DBusMessage *msg, void *user_data);

#ifdef __cplusplus
}
#endif
#endif
