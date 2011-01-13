#ifndef __TP_SYSTEM_H__
#define __TP_SYSTEM_H__

#include <sys/stat.h>

#include <addon_types.h>
#include <addon_hoa.h>

#include <goa_api.h>


BOOLEAN				TP_System_Initialize(void);
void				TP_System_Finalize(void);

EGLNativeWindowType	TP_System_GetEGLNativeWindow(void);
void				TP_System_EnableFullDisplay(void);
void				TP_System_DisableFullDisplay(void);

HOA_STATUS_T TP_MsgHandler(HOA_MSG_TYPE_T msg, UINT32 submsg, UINT8 *pData, UINT16 dataSize);

#endif
