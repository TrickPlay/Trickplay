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

HOA_STATUS_T		HOA_APP_InstallApp(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_APP_InstallAppInLocal(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType );
HOA_STATUS_T		HOA_APP_GetStorageSize(char *pAbsPath, UINT64 *pAvailableSize, UINT64 *pTotalSize);
HOA_STATUS_T		HOA_APP_CancelAppInstallation(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_APP_RequestToUninstallApp(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_APP_RequestToUpdateApp(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);
HOA_STATUS_T		HOA_APP_CheckAppIsUptodate(UINT32 appID, HOA_TVAPPS_STORAGE_TYPE_T  storageType);

HOA_STATUS_T		HOA_APP_CheckAdultAuth(/*out*/BOOLEAN *bAudltAuth);
HOA_STATUS_T		HOA_APP_SetAdultAuth(BOOLEAN bAdultAuth);

HOA_STATUS_T		HOA_APP_GetContentEncryptedKey(const char* pszFilename, /*out*/UINT8* bszCEK, /*in/out*/ UINT32* pnBufferSize);

/* Storage */ 
HOA_STATUS_T		HOA_APP_RequestToMountAppStoreStorage(void);
HOA_STATUS_T		HOA_APP_CheckAppStoreStorageIsMounted(BOOLEAN *pMountStatus);
HOA_STATUS_T		HOA_APP_InitializeAppStoreStorage(void);
HOA_STATUS_T		HOA_APP_InitializeAppStoreUsbStorage(UINT32 usbDevNum);


/* appfrwk_openapi_uc_msg_handler.c */
HOA_STATUS_T 		UC_HNDL_SendEventToProc(DBusConnection *conn, DBusMessage *msg, void *user_data);



#ifdef __cplusplus
}
#endif
#endif
