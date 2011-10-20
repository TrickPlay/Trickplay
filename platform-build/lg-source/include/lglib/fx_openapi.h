/******************************************************************************
 *   LCD TV LABORATORY, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/

/** @file fx_openapi.h
 *
 *  fxui open api
 *
 *  @author     dhjung(donghwan.jung@lge.com)
 *  @version    1.0
 *  @date       2011.06.20
 *  @note
 *  @see
 */

#ifndef _FX_OPENAPI_H_
#define _FX_OPENAPI_H_

#include <dbus/dbus.h>
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#if 0
/* bc_openapi_send2tv.c */
HOA_STATUS_T	HOA_TV_SetAVBlock(BOOLEAN bBlockAudio, BOOLEAN bBlockVideo);
HOA_STATUS_T	HOA_TV_ResetAVBlock(void);
HOA_STATUS_T	HOA_TV_GetCurrentTime(TIME_T	*pTime);
#if 0
HOA_STATUS_T 	HOA_TV_GetLanguage(UINT32 *pLanguage);
#endif
HOA_STATUS_T 	HOA_TV_CreateAppsInitMsgBox(void);
HOA_STATUS_T 	HOA_TV_SetVolume(BOOLEAN bShowVolumebar, HOA_APP_TYPE_T appType, BOOLEAN bRelative, SINT8 volumeIn, UINT8 *pVolumeOut);
HOA_STATUS_T 	HOA_TV_GetCurrentVolume(HOA_APP_TYPE_T appType, SINT8 *pVolume);
HOA_STATUS_T 	HOA_TV_SetMute(BOOLEAN bShowVolumebar, BOOLEAN bMute);
HOA_STATUS_T 	HOA_TV_GetMute(BOOLEAN *pbMute);

HOA_STATUS_T 	HOA_TV_SetAVBlock(BOOLEAN bBlockAudio, BOOLEAN bBlockVideo);
HOA_STATUS_T	 HOA_TV_ResetAVBlock(void);

HOA_STATUS_T 	HOA_TV_SetAspectRatio(HOA_ASPECT_RATIO_T ratio);
HOA_STATUS_T 	HOA_TV_ResetAspectRatio(void);
HOA_STATUS_T 	HOA_TV_SetDefaultPQ(void);
HOA_STATUS_T 	HOA_TV_SetLocalDimmingOFF(void);
HOA_STATUS_T 	HOA_TV_GetDisplayResolution(UINT32 *pWidth, UINT32 *pHeight);
HOA_STATUS_T 	HOA_TV_GetCurrentTime(TIME_T *pTime);
#endif

#ifdef __cplusplus
}
#endif
#endif
