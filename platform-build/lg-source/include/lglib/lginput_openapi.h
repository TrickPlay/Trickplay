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
HOA_STATUS_T	HOA_LGINPUT_RegistMotionCB(LGINPUT_CB_T pfnMotionCBFuncion);
HOA_STATUS_T	HOA_LGINPUT_FinalizeMotionCB(void);
HOA_STATUS_T	HOA_LGINPUT_SetPDP3DMode(UINT32 nMode);
HOA_STATUS_T	HOA_LGINPUT_AttachManualDevice(UINT32 nRemoteType);
HOA_STATUS_T	HOA_LGINPUT_SetDragMode(HOA_DRAG_MODE_T dragType);


// Gesture Camera
HOA_STATUS_T	HOA_LGINPUT_SetGestureModeChange(HOA_GESTURE_MODE_TYPE_T modType);
HOA_STATUS_T	HOA_LGINPUT_SetDepthScreenView(HOA_GESTURE_DATA_RESOLUTION_T modType);
HOA_STATUS_T	HOA_LGINPUT_SetSilhouetteScreenView(HOA_GESTURE_DATA_RESOLUTION_T modType);
HOA_STATUS_T	HOA_LGINPUT_SetRGBScreenView(HOA_GESTURE_DATA_RESOLUTION_T modType);
HOA_STATUS_T	HOA_LGINPUT_GestureCBRegister(GESTURE_CB_T pfnGestureCB);
HOA_STATUS_T	HOA_LGINPUT_GestureCBFinalize(void);

//BSI TEST
HOA_STATUS_T	HOA_LGINPUT_SendBSICursorOnOff(UINT32 nOnOff);
HOA_STATUS_T	HOA_LGINPUT_SendBSIButtonEvent(UINT32 nButtonType, UINT32 nButtonState);
HOA_STATUS_T	HOA_LGINPUT_SendBSICursorPosition(UINT32 nPosX, UINT32 nPosY);
HOA_STATUS_T	HOA_LGINPUT_RegistBSIPosXCB(LGINPUT_BSI_CB_T pfnPosXCBFunction);
HOA_STATUS_T	HOA_LGINPUT_RegistBSIPosYCB(LGINPUT_BSI_CB_T pfnPosYCBFunction);
HOA_STATUS_T	HOA_LGINPUT_RegistBSIRFKeyCB(LGINPUT_BSI_CB_T pfnRFKeyCBFunction);
HOA_STATUS_T	HOA_LGINPUT_FinalizeBSIPosXCB(void);
HOA_STATUS_T	HOA_LGINPUT_FinalizeBSIPosYCB(void);
HOA_STATUS_T	HOA_LGINPUT_FinalizeBSIRFKeyCB(void);
//

#ifdef __cplusplus
}
#endif

#endif
