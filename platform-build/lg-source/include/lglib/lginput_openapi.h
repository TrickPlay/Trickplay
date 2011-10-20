/******************************************************************************
 *   Software Center, LG ELECTRONICS INC., SEOUL, KOREA
 *   Copyright(c) 2008 by LG Electronics Inc.
 *
 *   All rights reserved. No part of this work may be reproduced, stored in a
 *   retrieval system, or transmitted by any means without prior written
 *   permission of LG Electronics Inc.
 *****************************************************************************/




#ifndef _LGINPUT_OPENAPI_H_
#define _LGINPUT_OPENAPI_H_

#include <dbus/dbus.h>
#include "appfrwk_openapi_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "lginput_openapi_voice.h"

#define LI_DEBUG_ERROR(fmt, args...)	AF_DEBUG_ERRTR(fmt, ##args)


//HOA_STATUS_T	HOA_LGINPUT_SetMRCUStandBy(void);
HOA_STATUS_T	HOA_LGINPUT_StartMRCUPairing(void);
HOA_STATUS_T	HOA_LGINPUT_StopMRCUPairing(void);
HOA_STATUS_T	HOA_LGINPUT_SetMRCUCursorPosition(UINT32 nPosX, UINT32 nPosY);
HOA_STATUS_T	HOA_LGINPUT_SetMRCUAutoCursorAlignment(BOOLEAN bOnOff);
HOA_STATUS_T	HOA_LGINPUT_SetMRCUCursorSensitivity(UINT32 nSensitivity);


HOA_STATUS_T	HOA_LGINPUT_EnablePatternGesture(UINT32 nStartType, BOOLEAN bEnableMode); //nStartType : 0 - idle, 1 - web
HOA_STATUS_T	HOA_LGINPUT_StopPatternGesture(void);
HOA_STATUS_T	HOA_LGINPUT_GetFWVersion(char** pcVersion);
HOA_STATUS_T	HOA_LGINPUT_EnableGetSensorData(BOOLEAN bOnOff);
HOA_STATUS_T	HOA_LGINPUT_EnableGetPacketCount(BOOLEAN bOnOff);

HOA_STATUS_T	HOA_LGINPUT_SetPDP3DMode(UINT32 nMode);

HOA_STATUS_T	HOA_LGINPUT_AttachManualDevice(UINT32 nRemoteType);

#ifdef __cplusplus
}
#endif

#endif
