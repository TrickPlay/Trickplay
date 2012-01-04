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
HOA_STATUS_T	HOA_MRCU_StartMrcuPairing(void);
HOA_STATUS_T	HOA_MRCU_StopMrcuPairing(void);
HOA_STATUS_T	HOA_MRCU_StartMrcuPairingLine(void);
HOA_STATUS_T	HOA_MRCU_StopMrcuPairingLine(void);
HOA_STATUS_T	HOA_MRCU_SetMrcuCursorPosition(UINT32 nPosX, UINT32 nPosY);
HOA_STATUS_T	HOA_MRCU_SetMrcuAutoCursorAlignment(BOOLEAN bOnOff);
HOA_STATUS_T	HOA_MRCU_SetMrcuCursorSensitivity(UINT32 nSensitivity);
HOA_STATUS_T	HOA_MRCU_EnablePatternGesture(UINT32 nStartType, BOOLEAN bEnableMode); //nStartType : 0 - idle, 1 - web
HOA_STATUS_T	HOA_MRCU_StopGesturePatternRecognition(void);
HOA_STATUS_T	HOA_MRCU_GetFirmwareVersion(char** pcVersion);
HOA_STATUS_T	HOA_MRCU_GetBDInfo(int devType, UINT8** pnBdAddr, UINT8** pnFwVer);
HOA_STATUS_T	HOA_MRCU_GetGameData(UINT32 bMode);
HOA_STATUS_T	HOA_MRCU_RegisterMotionCallback(LGINPUT_CB_T pfnMotionCBFuncion);
HOA_STATUS_T	HOA_MRCU_UnregisterMotionCallback(void);
HOA_STATUS_T	HOA_MRCU_SetPdp3DMode(UINT32 nMode);
HOA_STATUS_T	HOA_MRCU_AttachManualDev(UINT32 nRemoteType);
HOA_STATUS_T	HOA_MRCU_SetDragMode(HOA_DRAG_MODE_T dragType);
HOA_STATUS_T	HOA_MRCU_UpdateFirmware(UINT32 *pnSuccess);
HOA_STATUS_T    HOA_MRCU_GetMRCURecieverEnable(int *pnOnOff);


// Gesture Camera
HOA_STATUS_T	HOA_GESTURE_SetGestureModeChange(HOA_GESTURE_MODE_TYPE_T modType);
HOA_STATUS_T	HOA_GESTURE_SetDepthScreenView(HOA_GESTURE_DATA_RESOLUTION_T modType);
HOA_STATUS_T	HOA_GESTURE_SetSilhouetteScreenView(HOA_GESTURE_DATA_RESOLUTION_T modType);
HOA_STATUS_T	HOA_GESTURE_SetRgbScreenView(HOA_GESTURE_DATA_RESOLUTION_T modType);
HOA_STATUS_T	HOA_GESTURE_RegisterGestureCallback(GESTURE_CB_T pfnGestureCB);
HOA_STATUS_T	HOA_GESTURE_UnregisterGestureCallback(void);

//BSI TEST
HOA_STATUS_T	HOA_MRCU_SendBsiCursorOnOff(UINT32 nOnOff);
HOA_STATUS_T	HOA_MRCU_SendBsiButtonEvent(UINT32 nButtonType, UINT32 nButtonState);
HOA_STATUS_T	HOA_MRCU_SendBsiCursorPosition(UINT32 nPosX, UINT32 nPosY);
HOA_STATUS_T	HOA_MRCU_RegisterBsiPositionXCallback(LGINPUT_BSI_CB_T pfnPosXCBFunction);
HOA_STATUS_T	HOA_MRCU_RegisterBsiPositionYCallback(LGINPUT_BSI_CB_T pfnPosYCBFunction);
HOA_STATUS_T	HOA_MRCU_RegisterBsiRFKeyCallback(LGINPUT_BSI_CB_T pfnRFKeyCBFunction);
HOA_STATUS_T	HOA_MRCU_UnregisterBsiPositionXCallback(void);
HOA_STATUS_T	HOA_MRCU_UnregisterBsiPositionYCallback(void);
HOA_STATUS_T	HOA_MRCU_UnregisterBsiRFKeyCallback(void);

//SG 3D Pairing
HOA_STATUS_T	HOA_SG3D_RegisterPairingCallback(LGINPUT_PDP3D_CB_T pfnPDP3DPairingCBFunction);

HOA_STATUS_T	HOA_GESTURE_SetGestureCursorAlignment(BOOLEAN bOnOff);
HOA_STATUS_T	HOA_GESTURE_SetGestureSensitivity(UINT32 nSensitivity);
HOA_STATUS_T	HOA_GESTURE_SetIRProjector(BOOLEAN bOnOff);
HOA_STATUS_T	HOA_GESTURE_GestureCreateTask(void);
HOA_STATUS_T	HOA_GESTURE_GestureDestroyTask(void);
HOA_STATUS_T	HOA_GESTURE_SetMouseOnControl(int bOn);

#ifdef __cplusplus
}
#endif

#endif
