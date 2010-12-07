#ifndef __TP_OPENAPI_H__
#define __TP_OPENAPI_H__

#include <addon_types.h>
#include <addon_hoa.h>

#include <goa_api.h>


BOOLEAN				TP_OpenAPI_Initialize(void);
void				TP_OpenAPI_Finalize(void);

EGLNativeWindowType	TP_OpenAPI_GetEGLNativeWindow(void);
void				TP_OpenAPI_EnableFullDisplay(void);
void				TP_OpenAPI_DisableFullDisplay(void);

HOA_STATUS_T TP_MsgHandler(HOA_MSG_TYPE_T msg, UINT32 submsg, UINT8 *pData, UINT16 dataSize);

#endif
