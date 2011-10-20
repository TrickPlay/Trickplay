/******************************************************************************
 *   Software Center, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 1999 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file appfrwk_openapi_uc.h
 *
 *  Update Controller openapi header
 *
 *  @author     Meekyung Lim(mimir@lge.com)
 *  @version    1.0
 *  @date       2011.06.10
 *  @note
 *  @see
 */

#ifndef _APPFRWK_OPENAPI_UC_H_
#define _APPFRWK_OPENAPI_UC_H_

#include <dbus/dbus.h>
#include "appfrwk_common.h"
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

HOA_STATUS_T		HOA_UC_InstallApp(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_UC_InstallAppInLocal(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType );
HOA_STATUS_T		HOA_UC_GetStorageSize(char *pAbsPath, UINT64 *pAvailableSize, UINT64 *pTotalSize);
HOA_STATUS_T		HOA_UC_SetInstalledAppsSync(HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_UC_CancelInstallApp(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_UC_UninstallApp(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_UC_UpdateApp(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_UC_CheckAppUpdate(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T 		HOA_UC_GetAuthenticationInfo(/*out*/char** ppAuthenticaionInfo);

HOA_STATUS_T		HOA_UC_ServerUrlNoti(void);
HOA_STATUS_T 		HOA_UC_NetcastCountryCodeNoti(void);

HOA_STATUS_T		HOA_UC_GetTotalNumInstalledApps(/*out*/UINT16 *pInstalledAppItemNum);

HOA_STATUS_T		HOA_UC_GetAdultAuth(/*out*/BOOLEAN *bAudltAuth);
HOA_STATUS_T		HOA_UC_SetAdultAuth(BOOLEAN bAdultAuth);

HOA_STATUS_T		HOA_UC_GetCEK(const char* pszFilename, /*out*/UINT8* bszCEK, /*in/out*/ UINT32* pnBufferSize);



/* appfrwk_openapi_uc_msg_handler.c */
HOA_STATUS_T 		UC_HNDL_AppManage(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		UC_HNDL_SendMsgToProcess(DBusConnection *conn, DBusMessage *msg, void *user_data);
HOA_STATUS_T 		UC_HNDL_SendEventToProc(DBusConnection *conn, DBusMessage *msg, void *user_data);



#ifdef __cplusplus
}
#endif
#endif
