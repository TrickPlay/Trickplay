/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file mf_openapi_ex.h
 *
 *  mediaframework open api
 *
 *  @author   	dhjung(donghwan.jung@lge.com)
 *  @version   1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _MF_EX_OPENAPI_H_
#define _MF_EX_OPENAPI_H_

#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_DOWNLOAD_ID_NUM 5

typedef  enum
{
	MF_DOWNLOAD_NONE	= 0x00,
	MF_DOWNLOAD_EOS	= 0x01,
	MF_DOWNLOAD_ERROR	= 0x02,
} MF_DOWNLOAD_STATE_T;

typedef void (*pfnGetBusMessageAsync)(int download_id, MF_DOWNLOAD_STATE_T dwState);


//#define MF_DEBUG_ERROR(fmt, args...)	AF_DEBUG_ERRTR(fmt, ##args)
//#define MF_EX_OPAPI_ENTER_FUNC()				MF_OPAPI_PRINT("[ENTER] %s\n", __FUNCTION__)
//#define MF_EX_OPAPI_LEAVE_FUNC()				MF_OPAPI_PRINT("[LEAVE] %s\n", __FUNCTION__)

// local //
HOA_STATUS_T MEDIA_EX_GetSourceInfoForNewURI(MEDIA_CHANNEL_T ch, char *pPath, char *pUri, char *pFileName, MEDIA_SOURCE_INFO_T *pSourceInfo, unsigned char tag_get, unsigned char album_get);
int MEDIA_EX_DownloadFile (char *pPath, char *pUrl, const char *pFilename);
//HOA_STATUS_T MEDIA_DownloadFileCancel(int download_id_num);

int MEDIA_EX_DownloadFileAsync (char *pPath, char *pUrl, const char *pFilename, pfnGetBusMessageAsync msgCallback);
HOA_STATUS_T MEDIA_EX_DownloadFileAsyncCancel(int download_id_num);

// export //
HOA_STATUS_T HOA_MEDIA_EX_GetFileInfoForNewURI(MEDIA_CHANNEL_T ch, char *pPath, char *pUri, char *pFileName, MEDIA_SOURCE_INFO_T *pSourceInfo, unsigned char tag_get, unsigned char album_get);
HOA_STATUS_T HOA_MEDIA_EX_GetSourceInfoForNewURI(MEDIA_CHANNEL_T ch, char *pUri, MEDIA_SOURCE_INFO_T *pSourceInfo);
HOA_STATUS_T HOA_MEDIA_EX_DownloadFile (MEDIA_CHANNEL_T ch, char *pPath, char *pUrl, const char *pFilename, MEDIA_TRANSPORT_T mediaTransportType, MEDIA_FORMAT_T mediaFormatType);
// for image download // will be removed// 2
int HOA_MEDIA_EX_DownloadImageStart (char *pPath, char *pUrl, const char *pFilename);
HOA_STATUS_T HOA_MEDIA_EX_DownloadImageCancel (int download_id);

int HOA_MEDIA_EX_DownloadImageAsyncStart(char *pPath, char *pUrl, const char *pFilename, pfnGetBusMessageAsync msgCallback);
HOA_STATUS_T HOA_MEDIA_EX_DownloadImageAsyncCancel (int download_id);

// end export //

#ifdef __cplusplus
}
#endif
#endif
