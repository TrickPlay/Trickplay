#ifndef __TP_SYSTEM_H__
#define __TP_SYSTEM_H__

#include <sys/stat.h>

//#include <addon_types.h>
//#include <addon_hoa.h>
#include <appfrwk_openapi_types.h>
#include <appfrwk_openapi.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum TP_DISPLAY_MODE {
	TP_DISP_NONE = 0,  // OSD: Off, TV Audio & Video -> Off
	TP_DISP_FULL,      // OSD: On, TV Audio & Video -> Off
	TP_DISP_WIDGET,    // OSD: On, TV Audio & Video -> On

	TP_DISP_NUM        // number of display mode
} TP_DISPLAY_MODE_T;

BOOLEAN				TP_System_Initialize(int argc, char **argv);
void				TP_System_Finalize(void);

void				TP_System_EnableFullDisplay(void);
void				TP_System_DisableFullDisplay(void);

TP_DISPLAY_MODE_T	TP_System_GetDisplayMode(void);
void				TP_System_SetDisplayMode(TP_DISPLAY_MODE_T mode);

HOA_STATUS_T		TP_System_MsgHandler(HOA_MSG_TYPE_T msg, UINT32 submsg,
										 UINT8* pData, UINT16 dataSize);

#ifdef __cplusplus
}
#endif

#endif /* __TP_SYSTEM_H__ */

