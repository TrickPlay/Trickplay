#ifndef __UTIL_API_H__
#define __UTIL_API_H__

#include "common.h"

#define MAX_UIMSG_PARAM		4

typedef void (*pfnSendMessageToUI)(UINT32 msg, UINT32 param[MAX_UIMSG_PARAM]);
typedef void (*pfnSendKeyToUI)(UINT32 key, UINT32 keyType);
typedef void (*pfnSendMouseToUI)(SINT32 dx, SINT32 dy, UINT32 button_val, UINT32 gesture_ptr);
typedef void (*pfnGetMouseParam)(char req_type, UINT32 *nParam1, UINT32 *nParam2, UINT32 *nParam3, UINT32 *nParam4);

#ifndef INCLUDE_MOUSE
extern API_STATE_T API_UTIL_InitUIMessagingSystem(pfnSendMouseToUI pfnMsgCbFn, pfnSendMouseToUI pfnUrgentMsgCbFn, pfnSendKeyToUI pfnKeyCbFn);
#else
extern API_STATE_T API_UTIL_InitUIMessagingSystem(pfnSendMouseToUI pfnMsgCbFn, pfnSendMouseToUI pfnUrgentMsgCbFn, pfnSendKeyToUI pfnKeyCbFn, pfnSendMouseToUI pfnMouseCbFn, pfnGetMouseParam pfnMouseParamCbFn);
#endif

#endif

